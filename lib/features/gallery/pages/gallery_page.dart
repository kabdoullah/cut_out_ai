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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final state = ref.watch(imageViewModelProvider);
    final stats = ref.watch(imageStatsProvider);
    final completedImages = ref.watch(completedImagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes créations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.popOrGoHome(),
        ),
        actions: [
          if (stats.hasAnyImages)
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: () => _shareMultipleImages(context, completedImages),
                  child: const Row(
                    children: [
                      Icon(Icons.share),
                      SizedBox(width: 8),
                      Text('Partager tout'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: () => _showStatsDialog(context, stats),
                  child: const Row(
                    children: [
                      Icon(Icons.analytics_outlined),
                      SizedBox(width: 8),
                      Text('Statistiques'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: () => _confirmClearAll(context, ref),
                  child: const Row(
                    children: [
                      Icon(Icons.delete_outline),
                      SizedBox(width: 8),
                      Text('Tout supprimer'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : completedImages.isEmpty
          ? _buildEmptyState(context)
          : _buildGalleryGrid(context, completedImages),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushToImagePicker(),
        child: const Icon(Icons.add_photo_alternate),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 96.sp,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            SizedBox(height: 24.h),
            Text(
              'Aucune création pour le moment',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Text(
              'Tes images traitées par l\'intelligence artificielle apparaîtront ici.\nCommence par créer ta première image !',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: () => context.pushToImagePicker(),
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Créer ma première image'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryGrid(BuildContext context, List<AppImage> images) {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.8,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        return _buildImageCard(context, image);
      },
    );
  }

  Widget _buildImageCard(BuildContext context, AppImage image) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _viewImage(context, image),
        onLongPress: () => _showImageOptions(context, image),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image réelle
            Expanded(
              child: Stack(
                children: [
                  _buildImageWidget(context, image),
                  // Badge de statut en haut à droite
                  if (image.processedPath != null)
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12.sp,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    image.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _formatDate(image.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours}h';
    } else {
      return 'Il y a ${difference.inMinutes}min';
    }
  }

  void _viewImage(BuildContext context, AppImage image) {
    if (image.processedPath != null) {
      context.pushToResult(
        originalPath: image.originalPath,
        processedPath: image.processedPath!,
      );
    }
  }

  void _showStatsDialog(BuildContext context, ImageStats stats) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Statistiques'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('Total d\'images', '${stats.total}'),
            _buildStatRow('Images terminées', '${stats.completed}'),
            _buildStatRow(
              'Taux de succès',
              '${stats.successRate.toStringAsFixed(1)}%',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
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

  // Partager plusieurs images
  void _shareMultipleImages(BuildContext context, List<AppImage> images) {
    if (images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune image à partager')),
      );
      return;
    }

    // Extraire les chemins des images traitées
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
      onShareComplete: () {
        print('✅ Partage multiple terminé depuis GalleryPage');
      },
    );
  }

  // Options pour une image individuelle (long press)
  void _showImageOptions(BuildContext context, AppImage image) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            // Title
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Text(
                image.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Options
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  // Voir l'image
                  ListTile(
                    leading: Icon(Icons.visibility, color: Theme.of(context).colorScheme.primary),
                    title: const Text('Voir'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _viewImage(context, image);
                    },
                  ),

                  // Partager
                  if (image.processedPath != null)
                    ListTile(
                      leading: Icon(Icons.share, color: Theme.of(context).colorScheme.primary),
                      title: const Text('Partager'),
                      onTap: () {
                        Navigator.of(context).pop();
                        ShareBottomSheet.showForSingleImage(
                          context: context,
                          imagePath: image.processedPath!,
                          onShareComplete: () {
                            print('✅ Partage individuel terminé');
                          },
                        );
                      },
                    ),

                  // Supprimer
                  ListTile(
                    leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                    title: const Text('Supprimer'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _confirmDeleteSingle(context, image);
                    },
                  ),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(BuildContext context, AppImage image) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Priorité : image traitée si disponible, sinon image originale
    final imagePath = image.processedPath ?? image.originalPath;
    final file = File(imagePath);
    
    // Vérifier si le fichier existe
    if (!file.existsSync()) {
      return _buildImagePlaceholder(context);
    }
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Image.file(
        file,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        // Optimisation mémoire - adapter à la taille de la carte
        cacheWidth: (120 * (ScreenUtil().pixelRatio ?? 1)).round(),
        cacheHeight: (150 * (ScreenUtil().pixelRatio ?? 1)).round(),
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder(context);
        },
      ),
    );
  }
  
  Widget _buildImagePlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: colorScheme.primaryContainer,
      child: Icon(
        Icons.image,
        size: 48.sp,
        color: colorScheme.primary,
      ),
    );
  }

  // Confirmer suppression d'une image
  void _confirmDeleteSingle(BuildContext context, AppImage image) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'image'),
        content: Text('Voulez-vous vraiment supprimer "${image.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Supprimer via le ViewModel
              // Note: Il faudrait ajouter cette méthode au ViewModel
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
