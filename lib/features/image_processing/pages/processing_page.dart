import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/models/app_state.dart';
import '../../../core/router/app_router.dart';
import '../../../core/models/app_image.dart';
import '../providers/image_view_model.dart';
import '../widgets/image_status_widget.dart';

class ProcessingPage extends ConsumerStatefulWidget {
  final String imagePath;

  const ProcessingPage({super.key, required this.imagePath});

  @override
  ConsumerState<ProcessingPage> createState() => _ProcessingPageMVVMState();
}

class _ProcessingPageMVVMState extends ConsumerState<ProcessingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Écouter l'état pour détecter la fin du traitement
    ref.listen<AppState>(imageViewModelProvider, (previous, next) {
      final currentImage = next.currentImage;

      if (currentImage != null) {
        if (currentImage.status.isCompleted &&
            currentImage.processedPath != null) {
          // Navigation vers les résultats
          context.replaceWithResult(
            originalPath: currentImage.originalPath,
            processedPath: currentImage.processedPath!,
          );
        } else if (currentImage.status.isFailed) {
          // Afficher dialog d'erreur
          _showErrorDialog(context, next.error ?? 'Erreur inconnue');
        }
      }
    });

    final state = ref.watch(imageViewModelProvider);
    final currentImage = state.currentImage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Traitement IA'),
        automaticallyImplyLeading: false,
        actions: [
          // Bouton annuler seulement si en cours
          if (currentImage?.status.isProcessing == true)
            TextButton(
              onPressed: () => context.popOrGoHome(),
              child: const Text('Annuler'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 
                      MediaQuery.of(context).padding.top - 
                      kToolbarHeight,
          ),
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              // Animation de traitement IA
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationAnimation.value * 2 * 3.14159,
                      child: Container(
                        width: 140.w,
                        height: 140.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.secondary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.auto_fix_high,
                          size: 60.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 40.h),

              // Status widget
              if (currentImage != null) ...[
                ImageStatusWidget(
                  status: currentImage.status,
                  onRetry: currentImage.status.isFailed
                      ? () => ref.read(imageViewModelProvider.notifier).retryProcessing(currentImage.id)
                      : null,
                ),
                SizedBox(height: 24.h),
              ],

              // Texte principal
              Text(
                _getStatusText(currentImage?.status ?? AppImageStatus.processing),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),

              // Sous-texte
              Text(
                _getSubText(currentImage?.status ?? AppImageStatus.processing),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),

              // Barre de progression avec étapes
              if (state.isLoading) ...[
                _buildProgressSteps(context, currentImage),
                SizedBox(height: 32.h),
              ],

              // Informations sur l'image
              if (currentImage != null)
                _buildImageInfo(context, currentImage),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSteps(BuildContext context, AppImage? currentImage) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        LinearProgressIndicator(
          backgroundColor: colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStep(context, Icons.upload, 'Envoi', true),
            _buildStep(context, Icons.psychology, 'IA', currentImage?.status.isProcessing == true),
            _buildStep(context, Icons.download, 'Réception', false),
          ],
        ),
      ],
    );
  }

  Widget _buildStep(BuildContext context, IconData icon, String label, bool isActive) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: isActive
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isActive
                ? colorScheme.onPrimary
                : colorScheme.onSurface.withValues(alpha: 0.5),
            size: 20.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isActive
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.5),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildImageInfo(BuildContext context, AppImage image) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.image,
            color: colorScheme.primary,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  image.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Traitement IA en cours',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(AppImageStatus status) {
    switch (status) {
      case AppImageStatus.pending:
        return 'Préparation de l\'image...';
      case AppImageStatus.processing:
        return 'L\'IA analyse votre image...';
      case AppImageStatus.completed:
        return 'Traitement terminé !';
      case AppImageStatus.failed:
        return 'Oups, quelque chose s\'est mal passé';
    }
  }

  String _getSubText(AppImageStatus status) {
    switch (status) {
      case AppImageStatus.pending:
        return 'Préparation du traitement';
      case AppImageStatus.processing:
        return 'L\'intelligence artificielle analyse votre image et supprime l\'arrière-plan automatiquement.\nCela peut prendre quelques secondes.';
      case AppImageStatus.completed:
        return 'Ton image est prête ! L\'arrière-plan a été supprimé avec succès.';
      case AppImageStatus.failed:
        return 'Le traitement a échoué. Vérifie ta connexion internet et réessaie.';
    }
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(width: 8.w),
            const Text('Erreur de traitement'),
          ],
        ),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.popOrGoHome();
            },
            child: const Text('Retour'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(imageViewModelProvider.notifier).clearError();
              // Relancer automatiquement si possible
              final currentImage = ref.read(imageViewModelProvider).currentImage;
              if (currentImage != null) {
                ref.read(imageViewModelProvider.notifier).retryProcessing(currentImage.id);
              }
            },
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}
