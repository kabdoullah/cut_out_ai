import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

// Top-level — required by Isolate.run
Uint8List _compositeAndEncodePng(_CompositeRequest request) {
  final source = img.decodeImage(request.sourceBytes);
  if (source == null) throw Exception('Impossible de décoder l\'image source');

  final rgba = source.convert(numChannels: 4);

  final background = img.Image(
    width: rgba.width,
    height: rgba.height,
    numChannels: 4,
  );
  img.fill(
    background,
    color: img.ColorRgba8(
      request.backgroundRed,
      request.backgroundGreen,
      request.backgroundBlue,
      request.backgroundAlpha,
    ),
  );

  img.compositeImage(background, rgba);
  return Uint8List.fromList(img.encodePng(background));
}

class _CompositeRequest {
  final Uint8List sourceBytes;
  final int backgroundRed;
  final int backgroundGreen;
  final int backgroundBlue;
  final int backgroundAlpha;

  const _CompositeRequest({
    required this.sourceBytes,
    required this.backgroundRed,
    required this.backgroundGreen,
    required this.backgroundBlue,
    required this.backgroundAlpha,
  });
}

// Top-level — required by Isolate.run
Uint8List _compositeWithImageBackground(_CompositeImageRequest request) {
  final source = img.decodeImage(request.sourceBytes);
  if (source == null) throw Exception('Impossible de décoder l\'image source');

  final bgRaw = img.decodeImage(request.backgroundBytes);
  if (bgRaw == null) throw Exception('Impossible de décoder l\'image de fond');

  final rgba = source.convert(numChannels: 4);

  // Scale background to cover target dimensions, preserving aspect ratio
  final scaleX = rgba.width / bgRaw.width;
  final scaleY = rgba.height / bgRaw.height;
  final scale = scaleX > scaleY ? scaleX : scaleY;

  final scaledWidth = (bgRaw.width * scale).round();
  final scaledHeight = (bgRaw.height * scale).round();

  final scaled = img.copyResize(
    bgRaw,
    width: scaledWidth,
    height: scaledHeight,
    interpolation: img.Interpolation.linear,
  );

  // Center-crop to exact target dimensions
  final offsetX = ((scaledWidth - rgba.width) / 2).round();
  final offsetY = ((scaledHeight - rgba.height) / 2).round();
  final background = img.copyCrop(
    scaled,
    x: offsetX,
    y: offsetY,
    width: rgba.width,
    height: rgba.height,
  );

  img.compositeImage(background, rgba);
  return Uint8List.fromList(img.encodePng(background));
}

class _CompositeImageRequest {
  final Uint8List sourceBytes;
  final Uint8List backgroundBytes;

  const _CompositeImageRequest({
    required this.sourceBytes,
    required this.backgroundBytes,
  });
}

class FileService {
  Future<Directory> get _appDirectory async {
    final directory = await getApplicationDocumentsDirectory();
    final appDir = Directory('${directory.path}/cutout_ai');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return appDir;
  }

  Future<String> saveProcessedImage(
    Uint8List imageData,
    String originalName,
  ) async {
    try {
      final appDir = await _appDirectory;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'processed_${timestamp}_$originalName.png';
      final filePath = '${appDir.path}/$fileName';
      await File(filePath).writeAsBytes(imageData);
      return filePath;
    } catch (e) {
      throw FileServiceException('Impossible de sauvegarder l\'image: $e');
    }
  }

  Future<void> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw FileServiceException('Impossible de supprimer le fichier: $e');
    }
  }

  Future<Uint8List> applyBackgroundImage(
    String imagePath,
    Uint8List backgroundImageBytes,
  ) async {
    try {
      final sourceBytes = await File(imagePath).readAsBytes();
      final request = _CompositeImageRequest(
        sourceBytes: sourceBytes,
        backgroundBytes: backgroundImageBytes,
      );
      return Isolate.run(() => _compositeWithImageBackground(request));
    } catch (e) {
      throw FileServiceException('Impossible d\'appliquer l\'image de fond: $e');
    }
  }

  /// Decode + composite + PNG encode in background isolate — main thread free.
  Future<Uint8List> applyBackgroundColor(
    String imagePath,
    Color backgroundColor,
  ) async {
    try {
      final sourceBytes = await File(imagePath).readAsBytes();

      final request = _CompositeRequest(
        sourceBytes: sourceBytes,
        backgroundRed: (backgroundColor.r * 255.0).round().clamp(0, 255),
        backgroundGreen: (backgroundColor.g * 255.0).round().clamp(0, 255),
        backgroundBlue: (backgroundColor.b * 255.0).round().clamp(0, 255),
        backgroundAlpha: (backgroundColor.a * 255.0).round().clamp(0, 255),
      );

      return Isolate.run(() => _compositeAndEncodePng(request));
    } catch (e) {
      throw FileServiceException('Impossible d\'appliquer la couleur de fond: $e');
    }
  }
}

class FileServiceException implements Exception {
  final String message;
  const FileServiceException(this.message);

  @override
  String toString() => message;
}
