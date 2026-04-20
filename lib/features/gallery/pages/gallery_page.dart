import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/models/app_image.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/share_bottom_sheet.dart';
import '../../image_processing/providers/image_view_model.dart';

class GalleryPage extends ConsumerWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(imageViewModelProvider);
    final stats = ref.watch(imageStatsProvider);
    final completedImages = ref.watch(completedImagesProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Mes créations'),
            if (stats.hasAnyImages)
              Text(
                '${stats.completed} image${stats.completed > 1 ? 's' : ''}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.popOrGoHome(),
        ),
        actions: [
          if (stats.hasAnyImages)
            PopupMenuButton(
              icon: const Icon(Icons.more_vert_rounded),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: () => _shareMultipleImages(context, completedImages),
                  child: const Row(
                    children: [
                      Icon(Icons.share_rounded, size: 20),
                      SizedBox(width: 12),
                      Text('Partager tout'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: () => _confirmClearAll(context, ref),
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded,
                          size: 20, color: colorScheme.error),
                      const SizedBox(width: 12),
                      Text('Tout supprimer',
                          style: TextStyle(color: colorScheme.error)),
                    ],
                  ),
                ),
              ],
            ),
          SizedBox(width: 8.w),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : completedImages.isEmpty
              ? _buildEmptyState(context)
              : _buildGalleryGrid(context, completedImages),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushToImagePicker(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nouvelle'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96.w,
              height: 96.w,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.outline),
              ),
              child: Icon(
                Icons.photo_library_outlined,
                size: 40.sp,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Aucune création',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              'Tes images traitées apparaîtront ici.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            FilledButton.icon(
              onPressed: () => context.pushToImagePicker(),
              icon: const Icon(Icons.add_photo_alternate_rounded),
              label: const Text('Créer ma première image'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryGrid(BuildContext context, List<AppImage> images) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.82,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) => _buildImageCard(context, images[index]),
    );
  }

  Widget _buildImageCard(BuildContext context, AppImage image) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => _viewImage(context, image),
      onLongPress: () => _showImageOptions(context, image),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.4),
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImageWidget(context, image),
                    // Gradient overlay at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 40.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Status badge
                    if (image.processedPath != null)
                      Positioned(
                        top: 8.h,
                        right: 8.w,
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 10.sp,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Info
              Padding(
                padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      image.name,
                      style: theme.textTheme.labelMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _formatDate(image.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) {
      return 'Il y a ${diff.inDays}j';
    } else if (diff.inHours > 0) {
      return 'Il y a ${diff.inHours}h';
    }
    return 'Il y a ${diff.inMinutes}min';
  }

  void _viewImage(BuildContext context, AppImage image) {
    if (image.processedPath != null) {
      context.pushToResult(
        originalPath: image.originalPath,
        processedPath: image.processedPath!,
        imageId: image.id,
      );
    }
  }

  void _confirmClearAll(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer tout'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer toutes vos images ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(imageViewModelProvider.notifier).clearAllImages();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _shareMultipleImages(BuildContext context, List<AppImage> images) {
    if (images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune image à partager')),
      );
      return;
    }

    final imagePaths = images
        .where((img) => img.processedPath != null)
        .map((img) => img.processedPath!)
        .toList();

    if (imagePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune image traitée à partager')),
      );
      return;
    }

    ShareBottomSheet.showForGallery(
      context: context,
      imagePaths: imagePaths,
      onShareComplete: () {},
    );
  }

  void _showImageOptions(BuildContext context, AppImage image) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8.h),
              Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colorScheme.outline,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  image.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 8.h),
              ListTile(
                leading: Icon(Icons.visibility_rounded,
                    color: colorScheme.primary),
                title: const Text('Voir'),
                onTap: () {
                  Navigator.of(context).pop();
                  _viewImage(context, image);
                },
              ),
              if (image.processedPath != null)
                ListTile(
                  leading: Icon(Icons.share_rounded,
                      color: colorScheme.primary),
                  title: const Text('Partager'),
                  onTap: () {
                    Navigator.of(context).pop();
                    ShareBottomSheet.showForSingleImage(
                      context: context,
                      imagePath: image.processedPath!,
                      onShareComplete: () {},
                    );
                  },
                ),
              ListTile(
                leading: Icon(Icons.delete_outline_rounded,
                    color: colorScheme.error),
                title: Text('Supprimer',
                    style: TextStyle(color: colorScheme.error)),
                onTap: () {
                  Navigator.of(context).pop();
                  _confirmDeleteSingle(context, image);
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget(BuildContext context, AppImage image) {
    final imagePath = image.processedPath ?? image.originalPath;
    final file = File(imagePath);

    if (!file.existsSync()) return _buildImagePlaceholder(context);

    return Image.file(
      file,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      cacheWidth: (120 * (ScreenUtil().pixelRatio ?? 1)).round(),
      cacheHeight: (150 * (ScreenUtil().pixelRatio ?? 1)).round(),
      errorBuilder: (_, __, ___) => _buildImagePlaceholder(context),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_outlined,
        size: 40.sp,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  void _confirmDeleteSingle(BuildContext context, AppImage image) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'image'),
        content: Text('Supprimer "${image.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${image.name} supprimée'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
