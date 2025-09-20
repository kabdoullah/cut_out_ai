import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/gallery/pages/gallery_page.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/image_picker/pages/image_picker_page.dart';
import '../../features/image_processing/pages/processing_page.dart';
import '../../features/result/pages/result_page.dart';


// Routes constantes pour éviter les erreurs de typo
class AppRoutes {
  static const String home = '/';
  static const String imagePicker = '/image-picker';
  static const String processing = '/processing';
  static const String result = '/result';
  static const String gallery = '/gallery';
}

// Configuration du router principal
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: true, // Pour le debug en développement

  routes: [
    // Route Home
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),

    // Route sélection d'image
    GoRoute(
      path: AppRoutes.imagePicker,
      name: 'image-picker',
      builder: (context, state) => const ImagePickerPage(),
    ),

    // Route traitement (avec paramètre image)
    GoRoute(
      path: AppRoutes.processing,
      name: 'processing',
      builder: (context, state) {
        final imagePath = state.uri.queryParameters['imagePath'] ?? '';
        return ProcessingPage(imagePath: imagePath);
      },
    ),

    // Route résultat (avec paramètres)
    GoRoute(
      path: AppRoutes.result,
      name: 'result',
      builder: (context, state) {
        final originalPath = state.uri.queryParameters['originalPath'] ?? '';
        final processedPath = state.uri.queryParameters['processedPath'] ?? '';
        return ResultPage(
          originalImagePath: originalPath,
          processedImagePath: processedPath,
        );
      },
    ),

    // Route galerie
    GoRoute(
      path: AppRoutes.gallery,
      name: 'gallery',
      builder: (context, state) => const GalleryPage(),
    ),
  ],

  // Gestion des erreurs de navigation
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(
      title: const Text('Erreur'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go(AppRoutes.home),
      ),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Page non trouvée',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'La page "${state.matchedLocation}" n\'existe pas.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('Retour à l\'accueil'),
          ),
        ],
      ),
    ),
  ),
);

// Extensions pour simplifier la navigation
extension AppRouterExtension on BuildContext {
  // Navigation vers la page d'accueil (reset de la pile)
  void goToHome() => go(AppRoutes.home);
  
  // Navigation vers les pages principales (avec pile de navigation)
  void pushToImagePicker() => push(AppRoutes.imagePicker);
  void pushToGallery() => push(AppRoutes.gallery);

  // Navigation avec paramètres (avec pile de navigation)
  void pushToProcessing(String imagePath) {
    push('${AppRoutes.processing}?imagePath=${Uri.encodeComponent(imagePath)}');
  }

  void pushToResult({
    required String originalPath,
    required String processedPath,
  }) {
    push(
      '${AppRoutes.result}?originalPath=${Uri.encodeComponent(originalPath)}&processedPath=${Uri.encodeComponent(processedPath)}',
    );
  }

  // Navigation avec remplacement (pour éviter le retour)
  void replaceWithResult({
    required String originalPath,
    required String processedPath,
  }) {
    pushReplacement(
      '${AppRoutes.result}?originalPath=${Uri.encodeComponent(originalPath)}&processedPath=${Uri.encodeComponent(processedPath)}',
    );
  }

  // Méthodes de retour
  void popOrGoHome() {
    if (canPop()) {
      pop();
    } else {
      go(AppRoutes.home);
    }
  }

  // Méthodes de compatibilité (deprecated - à remplacer progressivement)
  @deprecated
  void goToImagePicker() => pushToImagePicker();
  
  @deprecated
  void goToGallery() => pushToGallery();
  
  @deprecated
  void goToProcessing(String imagePath) => pushToProcessing(imagePath);
  
  @deprecated
  void goToResult({
    required String originalPath,
    required String processedPath,
  }) => pushToResult(originalPath: originalPath, processedPath: processedPath);
}
