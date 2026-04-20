import 'dart:io';
import 'dart:isolate';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_background_remover/image_background_remover.dart';

import '../config/app_config.dart';
import 'background_removal_service.dart';

// Top-level — required by Isolate.run
Uint8List _encodeRawRgbaToPng(_RawImageData data) {
  final image = img.Image.fromBytes(
    width: data.width,
    height: data.height,
    bytes: data.pixels.buffer,
    order: img.ChannelOrder.rgba,
  );
  return Uint8List.fromList(img.encodePng(image));
}

class _RawImageData {
  final Uint8List pixels;
  final int width;
  final int height;
  const _RawImageData(this.pixels, this.width, this.height);
}

class LocalMlBackgroundRemovalService implements BackgroundRemovalService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    await BackgroundRemover.instance.initializeOrt();
    _initialized = true;
  }

  @override
  Future<Uint8List> removeBackground(String imagePath) async {
    try {
      await initialize();

      final imageFile = File(imagePath);
      final stat = await imageFile.stat();
      final sizeMB = stat.size / (1024 * 1024);
      if (sizeMB > AppConfig.maxImageSizeMB) {
        throw BackgroundRemovalException(
          'Image trop volumineuse (${sizeMB.toStringAsFixed(1)}MB). Maximum: ${AppConfig.maxImageSizeMB}MB',
        );
      }

      final imageBytes = await imageFile.readAsBytes();
      debugPrint('🖼️ ML traitement: ${sizeMB.toStringAsFixed(2)}MB');

      // ONNX inference — must stay on main isolate (returns ui.Image)
      final uiImage = await BackgroundRemover.instance.removeBg(imageBytes);

      // Raw RGBA export: fast memory copy, no compression
      final byteData =
          await uiImage.toByteData(format: ui.ImageByteFormat.rawRgba);
      final width = uiImage.width;
      final height = uiImage.height;
      uiImage.dispose();

      if (byteData == null) {
        throw const BackgroundRemovalException('Export RGBA échoué');
      }

      // PNG compression (DEFLATE) in background isolate — frees main thread
      return Isolate.run(
        () => _encodeRawRgbaToPng(
          _RawImageData(byteData.buffer.asUint8List(), width, height),
        ),
      );
    } on BackgroundRemovalException {
      rethrow;
    } catch (e) {
      debugPrint('❌ ML background removal error: $e');
      throw BackgroundRemovalException('Erreur de traitement: $e');
    }
  }
}
