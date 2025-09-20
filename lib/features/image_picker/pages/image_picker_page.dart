import 'package:cutout_ai/core/models/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/app_state.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/widgets/retry_connection_dialog.dart';
import '../../image_processing/providers/image_view_model.dart';
import '../widgets/permission_dialog.dart';

class ImagePickerPage extends ConsumerStatefulWidget {
  const ImagePickerPage({super.key});

  @override
  ConsumerState<ImagePickerPage> createState() => _ImagePickerPageMVVMState();
}

class _ImagePickerPageMVVMState extends ConsumerState<ImagePickerPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isSelecting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Surveiller l'état pour détecter le début du traitement
    ref.listen<AppState>(imageViewModelProvider, (previous, next) {
      if (next.currentImage != null && next.currentImage!.status.isProcessing) {
        // Navigation automatique vers la page de traitement
        context.pushToProcessing(next.currentImage!.originalPath);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir une photo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.popOrGoHome(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            // Instructions
            Text(
              'Sélectionne la source de ton image',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'L\'intelligence artificielle va analyser ton image et supprimer automatiquement l\'arrière-plan.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 48.h),

            // Boutons de sélection
            Expanded(
              child: Column(
                children: [
                  // Bouton Caméra
                  _buildSourceButton(
                    context: context,
                    icon: Icons.camera_alt_outlined,
                    title: 'Prendre une photo',
                    subtitle: 'Utilise l\'appareil photo',
                    onTap: () => _handleCameraSelection(),
                    color: colorScheme.primary,
                    isLoading: _isSelecting,
                  ),
                  SizedBox(height: 24.h),

                  // Bouton Galerie
                  _buildSourceButton(
                    context: context,
                    icon: Icons.photo_library_outlined,
                    title: 'Choisir dans la galerie',
                    subtitle: 'Sélectionne une photo existante',
                    onTap: () => _handleGallerySelection(),
                    color: colorScheme.secondary,
                    isLoading: _isSelecting,
                  ),

                  const Spacer(),

                  // Conseils
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: colorScheme.primary,
                          size: 24.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Astuce : Les images avec des contours nets donnent de meilleurs résultats !',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    required bool isLoading,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: isLoading
                    ? SizedBox(
                  width: 32.sp,
                  height: 32.sp,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
                    : Icon(
                  icon,
                  size: 32.sp,
                  color: color,
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isLoading ? theme.colorScheme.onSurface.withValues(alpha: 0.5) : null,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLoading)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCameraSelection() async {
    // Vérifier les permissions d'abord
    final hasPermission = await PermissionService.requestCameraPermission();
    if (!hasPermission) {
      if (mounted) {
        PermissionDialog.showCameraPermissionDialog(
          context,
              () => _selectImage(ImageSource.camera),
        );
      }
      return;
    }

    await _selectImage(ImageSource.camera);
  }

  Future<void> _handleGallerySelection() async {
    // Prévenir les appels multiples
    if (_isSelecting) return;

    // Vérifier les permissions d'abord
    final hasPermission = await PermissionService.requestGalleryPermission();
    if (!hasPermission) {
      if (mounted) {
        PermissionDialog.showGalleryPermissionDialog(
          context,
              () => _selectImage(ImageSource.gallery),
        );
      }
      return;
    }

    await _selectImage(ImageSource.gallery);
  }

  Future<void> _selectImage(ImageSource source) async {
    if (_isSelecting) return;

    setState(() {
      _isSelecting = true;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );

      if (image != null) {
        final imageName = 'CutOut_${DateTime.now().millisecondsSinceEpoch}';

        // Démarrer le traitement via le ViewModel
        await ref.read(imageViewModelProvider.notifier).processImage(
          image.path,
          imageName,
        );
      }
    } catch (e) {
      // Afficher l'erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSelecting = false;
        });
      }
    }
  }

  void _showConnectionDialog() {
    showDialog(
      context: context,
      builder: (context) => const RetryConnectionDialog(),
    );
  }
}

