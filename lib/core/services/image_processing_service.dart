import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_image.dart';
import '../network/dio_config.dart';
import 'removebg_service.dart';
import 'file_service.dart';

class ImageProcessingService {
  final RemoveBgService _removeBgService;
  final FileService _fileService;

  ImageProcessingService({
    required RemoveBgService removeBgService,
    required FileService fileService,
  }) : _removeBgService = removeBgService,
       _fileService = fileService;

  Future<String> removeBackground(String imagePath) async {
    try {
      // 1. Appel API Remove.bg
      final processedImageData = await _removeBgService.removeBackground(
        imagePath,
      );

      // 2. Sauvegarde locale du résultat
      final originalFileName = imagePath.split('/').last;
      final processedPath = await _fileService.saveProcessedImage(
        processedImageData,
        originalFileName,
      );

      return processedPath;
    } catch (e) {
      rethrow; // Laisser les exceptions remonter avec leur type
    }
  }

  Future<ImageMetadata> getImageMetadata(String imagePath) async {
    try {
      final file = File(imagePath);
      final bytes = await file.readAsBytes();

      return ImageMetadata(
        width: 1080, // TODO: Parser les vraies dimensions si besoin
        height: 1920,
        sizeInBytes: bytes.length,
        format: imagePath.endsWith('.png') ? 'PNG' : 'JPEG',
      );
    } catch (e) {
      throw ImageProcessingException('Cannot read image metadata: $e');
    }
  }
}

// Provider final avec Remove.bg
final imageProcessingServiceProvider = Provider<ImageProcessingService>((ref) {
  final removeBgService = ref.watch(removeBgServiceProvider);
  final fileService = ref.watch(fileServiceProvider);

  return ImageProcessingService(
    removeBgService: removeBgService,
    fileService: fileService,
  );
});



class ImageProcessingException implements Exception {
  final String message;

  const ImageProcessingException(this.message);

  @override
  String toString() => message;
}

// Provider pour FileService aussi
final fileServiceProvider = Provider<FileService>((ref) {
  return FileService();
});
