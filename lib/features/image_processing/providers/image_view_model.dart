import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/app_image.dart';
import '../../../core/models/app_state.dart';
import '../../../core/services/background_removal_service.dart';
import '../../../core/services/image_processing_service.dart';
import '../../../core/services/storage_service.dart';

class ImageViewModel extends Notifier<AppState> {
  late final ImageProcessingService _imageProcessingService;
  late final StorageService _storageService;

  @override
  AppState build() {
    _imageProcessingService = ref.watch(imageProcessingServiceProvider);
    _storageService = ref.watch(storageServiceProvider);

    Future.microtask(() => _initializeApp());

    return AppState.empty;
  }

  Future<void> _initializeApp() async {
    if (state.isInitialized) return;

    try {
      state = state.withLoading;

      final savedImages = await _storageService.loadImages();

      state = state.copyWith(
        images: savedImages,
        isLoading: false,
        isInitialized: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors de l\'initialisation: $e',
        isInitialized: true,
      );
    }
  }

  Future<void> processImage(String imagePath, String imageName) async {
    try {
      final newImage = AppImage.create(
        originalPath: imagePath,
        name: imageName,
      );

      state = state.addImage(newImage);
      state = state.startProcessing(newImage.id);

      final processedPath =
          await _imageProcessingService.removeBackground(imagePath);

      state = state.completeProcessing(newImage.id, processedPath);

      await _storageService.saveImages(state.images);
    } on BackgroundRemovalException catch (e) {
      final currentImage = state.currentImage;
      if (currentImage != null) {
        state = state.failProcessing(currentImage.id, e.message);
        await _storageService.saveImages(state.images);
      }
    } on StorageException catch (e) {
      final currentImage = state.currentImage;
      if (currentImage != null) {
        state = state.failProcessing(currentImage.id, 'Sauvegarde: ${e.message}');
      }
    } catch (e) {
      final currentImage = state.currentImage;
      if (currentImage != null) {
        state = state.failProcessing(currentImage.id, 'Erreur inattendue: $e');
        await _storageService.saveImages(state.images);
      }
    }
  }

  Future<void> retryProcessing(String imageId) async {
    try {
      final image = state.images.firstWhere((img) => img.id == imageId);
      state = state.startProcessing(imageId);
      await processImage(image.originalPath, image.name);
    } catch (e) {
      state = state.failProcessing(imageId, 'Échec du retry: $e');
    }
  }

  Future<void> deleteImage(String imageId) async {
    try {
      await _storageService.deleteImage(imageId, state.images);
      state = state.removeImage(imageId);
    } catch (e) {
      state = state.copyWith(error: 'Erreur lors de la suppression: $e');
    }
  }

  Future<void> clearAllImages() async {
    try {
      await _storageService.clearImages();
      state = state.clearAllImages();
    } catch (e) {
      state = state.copyWith(error: 'Erreur lors du nettoyage: $e');
    }
  }

  Future<void> updateProcessedPath(String imageId, String newPath) async {
    try {
      final image = state.images.firstWhere((img) => img.id == imageId);
      final updated = image.copyWith(processedPath: newPath);
      state = state.updateImage(updated);
      await _storageService.saveImages(state.images);
    } catch (e) {
      state = state.copyWith(error: 'Erreur mise à jour chemin: $e');
    }
  }

  void clearError() {
    state = state.withoutError;
  }


}

final imageViewModelProvider = NotifierProvider<ImageViewModel, AppState>(() {
  return ImageViewModel();
});

final completedImagesProvider = Provider<List<AppImage>>((ref) {
  final state = ref.watch(imageViewModelProvider);
  return state.images.where((img) => img.status.isCompleted).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

final imageStatsProvider = Provider<ImageStats>((ref) {
  final state = ref.watch(imageViewModelProvider);

  return ImageStats(
    total: state.images.length,
    completed: state.completedImages,
    processing: state.processingImages,
    failed: state.failedImages,
  );
});

final isLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(imageViewModelProvider);
  return state.isLoading;
});

final errorProvider = Provider<String?>((ref) {
  final state = ref.watch(imageViewModelProvider);
  return state.error;
});

final currentImageProvider = Provider<AppImage?>((ref) {
  final state = ref.watch(imageViewModelProvider);
  return state.currentImage;
});
