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
  }) : _backgroundRemovalService = backgroundRemovalService,
       _fileService = fileService;

  /// Copies [pickedImagePath] out of the OS-managed picker cache into
  /// permanent app storage, returning the durable path to use as an
  /// [AppImage.originalPath] from now on.
  Future<String> persistOriginalImage(
    String pickedImagePath,
    String imageName,
  ) {
    return _fileService.persistOriginalImage(pickedImagePath, imageName);
  }

  Future<String> removeBackground(String imagePath) async {
    final processedBytes = await _backgroundRemovalService.removeBackground(
      imagePath,
    );
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
