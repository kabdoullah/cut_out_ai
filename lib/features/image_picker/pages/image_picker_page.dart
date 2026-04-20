import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/app_image.dart';
import '../../../core/models/app_state.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../image_processing/providers/image_view_model.dart';
import '../widgets/permission_dialog.dart';

class ImagePickerPage extends ConsumerStatefulWidget {
  const ImagePickerPage({super.key});

  @override
  ConsumerState<ImagePickerPage> createState() => _ImagePickerPageMVVMState();
}

class _ImagePickerPageMVVMState extends ConsumerState<ImagePickerPage>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  bool _isSelecting = false;
  late AnimationController _entryController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    _fadeIn = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ref.listen<AppState>(imageViewModelProvider, (previous, next) {
      if (next.currentImage != null && next.currentImage!.status.isProcessing) {
        context.pushToProcessing(next.currentImage!.originalPath);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir une photo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.popOrGoHome(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeIn,
        child: SlideTransition(
          position: _slideUp,
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                Text('Source de l\'image', style: theme.textTheme.headlineMedium),
                SizedBox(height: 8.h),
                Text(
                  'L\'IA va analyser et supprimer l\'arrière-plan automatiquement.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 36.h),

                _buildSourceCard(
                  context: context,
                  icon: Icons.camera_alt_rounded,
                  title: 'Appareil photo',
                  subtitle: 'Prendre une nouvelle photo',
                  onTap: _handleCameraSelection,
                  gradient: AppTheme.brandGradientSubtle,
                  isLoading: _isSelecting,
                ),
                SizedBox(height: 16.h),

                _buildSourceCard(
                  context: context,
                  icon: Icons.photo_library_rounded,
                  title: 'Galerie',
                  subtitle: 'Sélectionner une photo existante',
                  onTap: _handleGallerySelection,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD946EF), Color(0xFFEC4899)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  isLoading: _isSelecting,
                ),

                const Spacer(),

                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryViolet.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.tips_and_updates_rounded,
                          color: AppTheme.primaryViolet,
                          size: 18.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Les images avec des contours nets donnent de meilleurs résultats.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSourceCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required LinearGradient gradient,
    required bool isLoading,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedOpacity(
        opacity: isLoading ? 0.6 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 80.w,
                height: 80.w,
                margin: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(22),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Icon(icon, size: 32.sp, color: Colors.white),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14.sp,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCameraSelection() async {
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
    if (_isSelecting) return;
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
    setState(() => _isSelecting = true);

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );

      if (image != null) {
        final imageName = 'CutOut_${DateTime.now().millisecondsSinceEpoch}';
        await ref
            .read(imageViewModelProvider.notifier)
            .processImage(image.path, imageName);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSelecting = false);
    }
  }
}
