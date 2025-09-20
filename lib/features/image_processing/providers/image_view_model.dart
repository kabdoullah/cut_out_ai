import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/app_image.dart';
import '../../../core/models/app_state.dart';
import '../../../core/providers/connectivity_provider.dart';
import '../../../core/services/image_processing_service.dart';
import '../../../core/services/removebg_service.dart';
import '../../../core/services/storage_service.dart';

// 🎯 ViewModel principal - Orchestrateur de l'application
class ImageViewModel extends Notifier<AppState> {
  late final ImageProcessingService _imageProcessingService;
  late final StorageService _storageService;

  @override
  AppState build() {
    // Injection des services via Riverpod
    _imageProcessingService = ref.watch(imageProcessingServiceProvider);
    _storageService = ref.watch(storageServiceProvider);

    // Initialiser après le premier build
    Future.microtask(() => _initializeApp());

    return AppState.empty;
  }

  // Initialisation de l'application
  Future<void> _initializeApp() async {
    // Vérifier si déjà initialisé
    if (state.isInitialized) return;

    try {
      state = state.withLoading;

      // Charger les images sauvegardées
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

  // 🤖 Traiter une nouvelle image avec Hugging Face
  Future<void> processImage(String imagePath, String imageName) async {
    try {
      // 0. Vérifier la connexion internet - AJOUTÉ ICI
      final connectivityService = ref.read(connectivityServiceProvider);
      final hasConnection = await connectivityService.checkConnection();

      if (!hasConnection) {
        throw RemoveBgException('Pas de connexion internet. Vérifiez votre WiFi ou vos données mobiles.');
      }
      // 1. Créer une nouvelle image avec statut pending
      final newImage = AppImage.create(
        originalPath: imagePath,
        name: imageName,
      );

      // 2. Ajouter à la liste et marquer comme en cours
      state = state.addImage(newImage);
      state = state.startProcessing(newImage.id);

      // 3. Traitement de l'image via Remove.bg
      final processedPath = await _imageProcessingService.removeBackground(imagePath);

      // 4. Récupérer les métadonnées (optionnel)
      final metadata = await _imageProcessingService.getImageMetadata(imagePath);

      // 5. Mettre à jour l'image avec les résultats
      state = state.completeProcessing(newImage.id, processedPath);

      // 6. Sauvegarder dans le storage local
      await _storageService.saveImages(state.images);

    } on RemoveBgException catch (e) {
      // Erreur spécifique Remove.bg
      final currentImage = state.currentImage;
      if (currentImage != null) {
        state = state.failProcessing(currentImage.id, 'Remove.bg: ${e.message}');
        await _storageService.saveImages(state.images);
      }
    } on StorageException catch (e) {
      // Erreur de sauvegarde
      final currentImage = state.currentImage;
      if (currentImage != null) {
        state = state.failProcessing(currentImage.id, 'Sauvegarde: ${e.message}');
      }
    } catch (e) {
      // Erreur générale
      final currentImage = state.currentImage;
      if (currentImage != null) {
        state = state.failProcessing(currentImage.id, 'Erreur inattendue: $e');
        await _storageService.saveImages(state.images);
      }
    }
  }

  // 🔄 Réessayer le traitement d'une image échouée
  Future<void> retryProcessing(String imageId) async {
    try {
      final image = state.images.firstWhere((img) => img.id == imageId);

      // Remettre en mode processing
      state = state.startProcessing(imageId);

      // Relancer le traitement
      await processImage(image.originalPath, image.name);

    } catch (e) {
      state = state.failProcessing(imageId, 'Échec du retry: $e');
    }
  }

  // 🗑️ Supprimer une image
  Future<void> deleteImage(String imageId) async {
    try {
      // Supprimer du storage
      await _storageService.deleteImage(imageId, state.images);

      // Mettre à jour l'état
      state = state.removeImage(imageId);

    } catch (e) {
      state = state.copyWith(error: 'Erreur lors de la suppression: $e');
    }
  }

  // 🧹 Supprimer toutes les images
  Future<void> clearAllImages() async {
    try {
      await _storageService.clearImages();
      state = state.clearAllImages();
    } catch (e) {
      state = state.copyWith(error: 'Erreur lors du nettoyage: $e');
    }
  }

  // 📊 Rafraîchir les données
  Future<void> refreshData() async {
    await _initializeApp();
  }

  // ✅ Actions simples pour l'UI
  void clearError() {
    state = state.withoutError;
  }

  void setCurrentImage(AppImage? image) {
    state = state.copyWith(currentImage: image);
  }

  void clearCurrentImage() {
    state = state.withoutCurrentImage;
  }
}

// 🎯 Provider principal du ViewModel
final imageViewModelProvider = NotifierProvider<ImageViewModel, AppState>(() {
  return ImageViewModel();
});

// 📊 Providers dérivés pour l'UI (sélecteurs)
final completedImagesProvider = Provider<List<AppImage>>((ref) {
  final state = ref.watch(imageViewModelProvider);
  return state.images.where((img) => img.status.isCompleted).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Plus récent en premier
});

final processingImagesProvider = Provider<List<AppImage>>((ref) {
  final state = ref.watch(imageViewModelProvider);
  return state.images.where((img) => img.status.isProcessing).toList();
});

final failedImagesProvider = Provider<List<AppImage>>((ref) {
  final state = ref.watch(imageViewModelProvider);
  return state.images.where((img) => img.status.isFailed).toList();
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

// Modèle pour les statistiques
class ImageStats {
  final int total;
  final int completed;
  final int processing;
  final int failed;

  const ImageStats({
    required this.total,
    required this.completed,
    required this.processing,
    required this.failed,
  });

  double get successRate => total > 0 ? (completed / total) * 100 : 0;
  bool get hasAnyImages => total > 0;
  bool get hasProcessingImages => processing > 0;
  bool get hasFailedImages => failed > 0;
}

// 🎮 Provider pour les actions async (pour éviter les conflits d'état)
final processImageProvider = FutureProvider.family<void, ProcessImageParams>((ref, params) async {
  final viewModel = ref.read(imageViewModelProvider.notifier);
  await viewModel.processImage(params.imagePath, params.imageName);
});

class ProcessImageParams {
  final String imagePath;
  final String imageName;

  const ProcessImageParams({
    required this.imagePath,
    required this.imageName,
  });
}

// 🎯 Provider pour surveiller l'état de l'app
final appInitializationProvider = Provider<bool>((ref) {
  final state = ref.watch(imageViewModelProvider);
  return state.isInitialized;
});

// Provider pour l'état de chargement global
final isLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(imageViewModelProvider);
  return state.isLoading;
});

// Provider pour les erreurs
final errorProvider = Provider<String?>((ref) {
  final state = ref.watch(imageViewModelProvider);
  return state.error;
});

// Provider pour l'image en cours de traitement
final currentImageProvider = Provider<AppImage?>((ref) {
  final state = ref.watch(imageViewModelProvider);
  return state.currentImage;
});