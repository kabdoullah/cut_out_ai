import 'package:equatable/equatable.dart';
import 'app_image.dart';

// État global de l'application
class AppState extends Equatable {
  final List<AppImage> images; // Toutes les images de l'utilisateur
  final bool isLoading; // État de chargement global
  final String? error; // Message d'erreur actuel
  final AppImage? currentImage; // Image en cours de traitement
  final bool isInitialized; // App initialisée ?

  const AppState({
    this.images = const [],
    this.isLoading = false,
    this.error,
    this.currentImage,
    this.isInitialized = false,
  });

  // Méthode copyWith pour créer un nouvel état
  AppState copyWith({
    List<AppImage>? images,
    bool? isLoading,
    String? error,
    AppImage? currentImage,
    bool? isInitialized,
    bool clearError = false, // Pour effacer l'erreur
    bool clearCurrentImage = false, // Pour effacer l'image courante
  }) {
    return AppState(
      images: images ?? this.images,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      currentImage: clearCurrentImage
          ? null
          : (currentImage ?? this.currentImage),
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  // État initial vide
  static const empty = AppState();

  // États prédéfinis utiles
  AppState get withLoading => copyWith(isLoading: true, clearError: true);

  AppState get withoutLoading => copyWith(isLoading: false);

  AppState get withoutError => copyWith(clearError: true);

  AppState get withoutCurrentImage => copyWith(clearCurrentImage: true);

  @override
  List<Object?> get props => [
    images,
    isLoading,
    error,
    currentImage,
    isInitialized,
  ];

  // Méthodes utiles pour l'UI
  bool get hasImages => images.isNotEmpty;

  bool get hasError => error != null;

  bool get hasCurrentImage => currentImage != null;

  // Statistiques rapides
  int get totalImages => images.length;

  int get completedImages =>
      images.where((img) => img.status.isCompleted).length;

  int get processingImages =>
      images.where((img) => img.status.isProcessing).length;

  int get failedImages => images.where((img) => img.status.isFailed).length;

  // Image la plus récente
  AppImage? get lastImage => images.isNotEmpty ? images.last : null;

  // Toutes les images terminées (pour la galerie)
  List<AppImage> get successfulImages =>
      images.where((img) => img.status.isCompleted).toList();
}

// Extensions pour des opérations courantes sur AppState
extension AppStateExtensions on AppState {
  // Ajouter une nouvelle image
  AppState addImage(AppImage image) {
    return copyWith(images: [...images, image], currentImage: image);
  }

  // Mettre à jour une image existante
  AppState updateImage(AppImage updatedImage) {
    final updatedImages = images.map((img) {
      return img.id == updatedImage.id ? updatedImage : img;
    }).toList();

    return copyWith(
      images: updatedImages,
      currentImage: currentImage?.id == updatedImage.id
          ? updatedImage
          : currentImage,
    );
  }

  // Supprimer une image
  AppState removeImage(String imageId) {
    final updatedImages = images.where((img) => img.id != imageId).toList();

    return copyWith(
      images: updatedImages,
      currentImage: currentImage?.id == imageId ? null : currentImage,
      clearCurrentImage: currentImage?.id == imageId,
    );
  }

  // Marquer une image comme en cours de traitement
  AppState startProcessing(String imageId) {
    final image = images.firstWhere((img) => img.id == imageId);
    final processingImage = image.copyWith(status: AppImageStatus.processing);

    return updateImage(
      processingImage,
    ).copyWith(isLoading: true, clearError: true);
  }

  // Marquer une image comme terminée avec succès
  AppState completeProcessing(String imageId, String processedPath) {
    final image = images.firstWhere((img) => img.id == imageId);
    final completedImage = image.copyWith(
      status: AppImageStatus.completed,
      processedPath: processedPath,
    );

    return updateImage(
      completedImage,
    ).copyWith(isLoading: false, clearError: true);
  }

  // Marquer une image comme échouée
  AppState failProcessing(String imageId, String errorMessage) {
    final image = images.firstWhere((img) => img.id == imageId);
    final failedImage = image.copyWith(status: AppImageStatus.failed);

    return updateImage(
      failedImage,
    ).copyWith(isLoading: false, error: errorMessage);
  }

  // Effacer toutes les images
  AppState clearAllImages() {
    return copyWith(images: [], clearCurrentImage: true, clearError: true);
  }
}
