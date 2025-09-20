import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/device_service.dart';
import '../../../core/services/gallery_service.dart';
import '../../../core/widgets/share_bottom_sheet.dart';

class ResultPage extends ConsumerStatefulWidget {
  final String originalImagePath;
  final String processedImagePath;

  const ResultPage({
    super.key,
    required this.originalImagePath,
    required this.processedImagePath,
  });

  @override
  ConsumerState<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends ConsumerState<ResultPage> 
    with TickerProviderStateMixin {
  double _sliderValue = 0.5; // 0 = avant, 1 = après
  bool _isComparisonMode = false;
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
      CurvedAnimation(
        parent: _celebrationController,
        curve: Curves.elasticOut,
      ),
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
          icon: const Icon(Icons.close),
          onPressed: () => context.popOrGoHome(),
        ),
        actions: [
          IconButton(
            icon: Icon(_isComparisonMode ? Icons.compare : Icons.share),
            onPressed: () => _isComparisonMode 
                ? _toggleComparisonMode() 
                : _shareResult(context),
          ),
          IconButton(
            icon: Icon(_isComparisonMode ? Icons.close : Icons.compare),
            onPressed: _toggleComparisonMode,
          ),
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
                        SizedBox(height: 20.h),
                        
                        // Message de succès
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.w),
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  'Traitement terminé avec succès !',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 24.h),
                        
                        // Comparaison avant/après ou slider
                        _isComparisonMode
                            ? _buildSliderComparison(context)
                            : _buildSideBySideComparison(context),
                        
                        SizedBox(height: 24.h),

                        // Infos sur les fichiers
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
            padding: EdgeInsets.all(24.w),
            child: Column(
              children: [
                // Bouton principal : Sauvegarder
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton.icon(
                    onPressed: () => _saveResult(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    icon: const Icon(Icons.download),
                    label: const Text('Sauvegarder dans la galerie'),
                  ),
                ),
                SizedBox(height: 12.h),

                // Actions secondaires
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.pushToImagePicker(),
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Nouvelle photo'),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.pushToGallery(),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Mes créations'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      )
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

    return Column(
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 200.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: _buildImageWidget(imagePath, isProcessed),
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget(String imagePath, bool isProcessed) {
    // Vérifier si le fichier existe
    final file = File(imagePath);

    if (!file.existsSync()) {
      return _buildImagePlaceholder(isProcessed);
    }

    return Image.file(
      file,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return _buildImagePlaceholder(isProcessed);
      },
    );
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
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12.sp,
            ),
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
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations des fichiers',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          _buildFileInfoRow('Original', widget.originalImagePath),
          SizedBox(height: 8.h),
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
            child: Stack(
              children: [
                // Image de base (après)
                Positioned.fill(
                  child: _buildImageWidget(widget.processedImagePath, true),
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
                  left: _sliderValue * MediaQuery.of(context).size.width * 0.8,
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
                  left: (_sliderValue * MediaQuery.of(context).size.width * 0.8) - 15.w,
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

  void _shareResult(BuildContext context) {
    ShareBottomSheet.showForResult(
      context: context,
      originalPath: widget.originalImagePath,
      processedPath: widget.processedImagePath,
      onShareComplete: () {
        // Optionnel: actions après partage réussi
        print('✅ Partage terminé depuis ResultPage');
      },
    );
  }

  void _saveResult(BuildContext context) async {
    try {
      // Montrer un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Sauvegarder l'image traitée dans la galerie
      final success = await GalleryService.saveImageToGallery(widget.processedImagePath);

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
                onPressed: () async {
                  // ✅ Ouvrir la galerie système
                  final opened = await DeviceService.openGallery();
                  if (!opened && context.mounted) {
                    // Si échec, proposer d'ouvrir les paramètres
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Impossible d\'ouvrir la galerie automatiquement'),
                        action: SnackBarAction(
                          label: 'Paramètres',
                          onPressed: () => DeviceService.openSettings(),
                        ),
                      ),
                    );
                  }
                },
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
                  Expanded(
                    child: Text(e.message),
                  ),
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
                  Expanded(
                    child: Text(e.message),
                  ),
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
                Expanded(
                  child: Text('Erreur inattendue: $e'),
                ),
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
    return oldClipper is _SliderClipper && oldClipper.sliderValue != sliderValue;
  }
}