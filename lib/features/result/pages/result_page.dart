import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/device_service.dart';
import '../../../core/services/gallery_service.dart';
import '../../../core/services/image_processing_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/share_bottom_sheet.dart';
import '../../image_processing/providers/image_view_model.dart';
import '../widgets/background_color_picker.dart';
import '../widgets/background_image_picker.dart';

class ResultPage extends ConsumerStatefulWidget {
  final String originalImagePath;
  final String processedImagePath;
  final String imageId;

  const ResultPage({
    super.key,
    required this.originalImagePath,
    required this.processedImagePath,
    required this.imageId,
  });

  @override
  ConsumerState<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends ConsumerState<ResultPage>
    with TickerProviderStateMixin {
  double _sliderValue = 0.5;
  bool _isComparisonMode = false;
  Color? _backgroundColor;
  Uint8List? _backgroundImageBytes;
  late AnimationController _celebrationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _showCelebration();
  }

  void _setupAnimations() {
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );
  }

  void _showCelebration() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      _celebrationController.forward();
    }
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.popOrGoHome(),
        ),
        actions: [
          if (!_isComparisonMode)
            IconButton(
              icon: const Icon(Icons.share_rounded),
              onPressed: () => _shareResult(context),
            ),
          IconButton(
            icon: Icon(
              _isComparisonMode ? Icons.close_rounded : Icons.compare_rounded,
            ),
            onPressed: _toggleComparisonMode,
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      children: [
                        SizedBox(height: 8.h),

                        // Comparison view
                        _isComparisonMode
                            ? _buildSliderComparison(context)
                            : _buildSideBySideComparison(context),

                        SizedBox(height: 20.h),

                        // Background selection card
                        _buildBackgroundCard(context),

                        SizedBox(height: 16.h),

                        // File info
                        _buildFileInfoCard(context),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Actions du bas
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.4),
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Save button — gradient
                GestureDetector(
                  onTap: () => _saveResult(context),
                  child: Container(
                    width: double.infinity,
                    height: 52.h,
                    decoration: BoxDecoration(
                      gradient: AppTheme.brandGradient,
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryViolet.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.download_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 8.w),
                        Text(
                          'Sauvegarder',
                          style: GoogleFonts.outfit(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10.h),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.pushToImagePicker(),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Nouvelle'),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.pushToGallery(),
                        icon: const Icon(Icons.photo_library_outlined, size: 18),
                        label: const Text('Galerie'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_outlined, size: 16.sp, color: colorScheme.primary),
              SizedBox(width: 8.w),
              Text(
                'Fond',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          BackgroundColorPicker(
            selectedColor: _backgroundColor,
            onColorSelected: (color) => setState(() {
              _backgroundColor = color;
              _backgroundImageBytes = null;
            }),
          ),
          SizedBox(height: 14.h),
          BackgroundImagePicker(
            selectedImageBytes: _backgroundImageBytes,
            onImageSelected: (bytes) => setState(() {
              _backgroundImageBytes = bytes;
              _backgroundColor = null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildImageComparison(
    BuildContext context,
    String title,
    String imagePath,
    Color color,
    bool isProcessed,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: isProcessed
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isProcessed ? colorScheme.primary : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 200.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isProcessed
                  ? colorScheme.primary.withValues(alpha: 0.3)
                  : colorScheme.outline.withValues(alpha: 0.4),
              width: isProcessed ? 1.5 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: _buildImageWidget(
              imagePath,
              isProcessed,
              bgColor: isProcessed ? _backgroundColor : null,
              bgImageBytes: isProcessed ? _backgroundImageBytes : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget(
    String imagePath,
    bool isProcessed, {
    Color? bgColor,
    Uint8List? bgImageBytes,
  }) {
    // Vérifier si le fichier existe
    final file = File(imagePath);

    if (!file.existsSync()) {
      return _buildImagePlaceholder(isProcessed);
    }

    final image = Image.file(
      file,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return _buildImagePlaceholder(isProcessed);
      },
    );

    if (bgImageBytes != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(bgImageBytes, fit: BoxFit.cover),
          image,
        ],
      );
    }
    if (bgColor != null) {
      return ColoredBox(color: bgColor, child: image);
    }
    return image;
  }

  Widget _buildImagePlaceholder(bool isProcessed) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isProcessed ? Icons.auto_fix_high : Icons.image,
            size: 48.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 8.h),
          Text(
            isProcessed ? 'Image traitée' : 'Image originale',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildFileInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16.sp, color: colorScheme.primary),
              SizedBox(width: 8.w),
              Text(
                'Fichiers',
                style: theme.textTheme.titleSmall,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildFileInfoRow('Original', widget.originalImagePath),
          SizedBox(height: 6.h),
          _buildFileInfoRow('Traité', widget.processedImagePath),
        ],
      ),
    );
  }

  Widget _buildFileInfoRow(String label, String path) {
    final file = File(path);
    final exists = file.existsSync();
    String sizeText = 'N/A';

    if (exists) {
      try {
        final sizeInBytes = file.lengthSync();
        final sizeInMB = sizeInBytes / (1024 * 1024);
        sizeText = '${sizeInMB.toStringAsFixed(1)} MB';
      } catch (e) {
        sizeText = 'Erreur';
      }
    }

    return Row(
      children: [
        Icon(
          exists ? Icons.check_circle : Icons.error,
          color: exists ? Colors.green : Colors.red,
          size: 16.sp,
        ),
        SizedBox(width: 8.w),
        Text(
          '$label: ',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12.sp),
        ),
        Expanded(
          child: Text(
            '$sizeText${exists ? '' : ' (fichier introuvable)'}',
            style: TextStyle(fontSize: 12.sp),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _toggleComparisonMode() {
    setState(() {
      _isComparisonMode = !_isComparisonMode;
    });
  }

  Widget _buildSideBySideComparison(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Image originale
        Expanded(
          child: _buildImageComparison(
            context,
            'Avant',
            widget.originalImagePath,
            colorScheme.outline,
            false,
          ),
        ),
        SizedBox(width: 16.w),

        // Image traitée
        Expanded(
          child: _buildImageComparison(
            context,
            'Après',
            widget.processedImagePath,
            colorScheme.primary,
            true,
          ),
        ),
      ],
    );
  }

  Widget _buildSliderComparison(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Instructions
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            'Glissez pour comparer avant/après',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // Container pour la comparaison avec slider
        Container(
          height: 300.h,
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final containerWidth = constraints.maxWidth;
                return Stack(
              children: [
                // Image de base (après)
                Positioned.fill(
                  child: _buildImageWidget(
                    widget.processedImagePath,
                    true,
                    bgColor: _backgroundColor,
                    bgImageBytes: _backgroundImageBytes,
                  ),
                ),

                // Image overlay (avant) avec clip
                Positioned.fill(
                  child: ClipRect(
                    clipper: _SliderClipper(_sliderValue),
                    child: _buildImageWidget(widget.originalImagePath, false),
                  ),
                ),

                // Ligne de séparation
                Positioned(
                  left: _sliderValue * containerWidth,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: Colors.white,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 8.h),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Handle du slider
                Positioned(
                  left: (_sliderValue * containerWidth) - 15.w,
                  top: (300.h / 2) - 15.h,
                  child: Container(
                    width: 30.w,
                    height: 30.h,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.compare_arrows,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                ),
              ],
                );
              },
            ),
          ),
        ),

        SizedBox(height: 16.h),

        // Slider
        Slider(
          value: _sliderValue,
          onChanged: (value) {
            setState(() {
              _sliderValue = value;
            });
          },
          activeColor: colorScheme.primary,
          inactiveColor: colorScheme.primary.withValues(alpha: 0.3),
        ),

        SizedBox(height: 8.h),

        // Labels
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Avant',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                'Après',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<Uint8List> _compositeBackground() async {
    final fileService = ref.read(fileServiceProvider);
    if (_backgroundImageBytes != null) {
      return fileService.applyBackgroundImage(
        widget.processedImagePath,
        _backgroundImageBytes!,
      );
    }
    return fileService.applyBackgroundColor(
      widget.processedImagePath,
      _backgroundColor!,
    );
  }

  void _shareResult(BuildContext context) async {
    try {
      String pathToShare = widget.processedImagePath;

      if (_backgroundImageBytes != null || _backgroundColor != null) {
        final composited = await _compositeBackground();
        final tempDir = await getTemporaryDirectory();
        final tempPath =
            '${tempDir.path}/cutout_share_${DateTime.now().millisecondsSinceEpoch}.png';
        await File(tempPath).writeAsBytes(composited);
        pathToShare = tempPath;
      }

      if (!context.mounted) return;

      ShareBottomSheet.showForResult(
        context: context,
        originalPath: widget.originalImagePath,
        processedPath: pathToShare,
        onShareComplete: () {},
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible de préparer le partage: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _saveResult(BuildContext context) async {
    try {
      // Montrer un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Sauvegarder l'image traitée dans la galerie (avec couleur de fond si sélectionnée)
      bool success;
      String savedPath = widget.processedImagePath;
      if (_backgroundImageBytes != null || _backgroundColor != null) {
        final fileService = ref.read(fileServiceProvider);
        final composited = await _compositeBackground();
        final prefix = _backgroundImageBytes != null ? 'bg_img' : 'bg';
        savedPath = await fileService.saveProcessedImage(
          composited,
          '${prefix}_${DateTime.now().millisecondsSinceEpoch}',
        );
        if (widget.imageId.isNotEmpty) {
          await ref
              .read(imageViewModelProvider.notifier)
              .updateProcessedPath(widget.imageId, savedPath);
        }
        success = await GalleryService.saveImageBytesToGallery(composited);
      } else {
        success = await GalleryService.saveImageToGallery(
          widget.processedImagePath,
        );
      }

      // Fermer le dialog de chargement
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (success) {
        // Succès
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Image sauvegardée dans votre galerie !'),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Voir',
                textColor: Colors.white,
                onPressed: () => OpenFilex.open(savedPath),
              ),
            ),
          );
        }
      } else {
        throw Exception('Échec de la sauvegarde');
      }
    } on GalleryException catch (e) {
      // Fermer le dialog de chargement si ouvert
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Gestion spécifique des erreurs de permissions
      if (context.mounted) {
        if (e.message.contains('refusée définitivement')) {
          // Permission refusée définitivement - proposer d'ouvrir les paramètres
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.settings, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(e.message)),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 6),
              action: SnackBarAction(
                label: 'Paramètres',
                textColor: Colors.white,
                onPressed: () async {
                  await DeviceService.openSettings();
                },
              ),
            ),
          );
        } else {
          // Autre erreur de permission - proposer de réessayer
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(e.message)),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Réessayer',
                textColor: Colors.white,
                onPressed: () => _saveResult(context),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Fermer le dialog de chargement si ouvert
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Erreur générale
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Erreur inattendue: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Réessayer',
              textColor: Colors.white,
              onPressed: () => _saveResult(context),
            ),
          ),
        );
      }
    }
  }
}

// Custom clipper pour le slider de comparaison
class _SliderClipper extends CustomClipper<Rect> {
  final double sliderValue;

  _SliderClipper(this.sliderValue);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * sliderValue, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return oldClipper is _SliderClipper &&
        oldClipper.sliderValue != sliderValue;
  }
}
