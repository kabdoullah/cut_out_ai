import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'background_removal_service.dart';
import 'file_service.dart';
import 'local_ml_background_removal_service.dart';

class ImageProcessingService {
  final BackgroundRemovalService _backgroundRemovalService;
  final FileService _fileService;

  ImageProcessingService({
    required BackgroundRemovalService backgroundRemovalService,
    required FileService fileService,
  })  : _backgroundRemovalService = backgroundRemovalService,
        _fileService = fileService;

  Future<String> removeBackground(String imagePath) async {
    final processedBytes =
        await _backgroundRemovalService.removeBackground(imagePath);
    final originalFileName = imagePath.split('/').last;
    return _fileService.saveProcessedImage(processedBytes, originalFileName);
  }
}

final imageProcessingServiceProvider = Provider<ImageProcessingService>((ref) {
  final fileService = ref.watch(fileServiceProvider);
  return ImageProcessingService(
    backgroundRemovalService: LocalMlBackgroundRemovalService(),
    fileService: fileService,
  );
});

final fileServiceProvider = Provider<FileService>((ref) {
  return FileService();
});
