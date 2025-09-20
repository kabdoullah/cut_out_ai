import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import '../config/app_config.dart';
import '../services/share_service.dart';

class ShareBottomSheet extends StatelessWidget {
  final String? originalPath;
  final String? processedPath;
  final List<String>? multiplePaths;
  final VoidCallback? onShareComplete;

  const ShareBottomSheet({
    super.key,
    this.originalPath,
    this.processedPath,
    this.multiplePaths,
    this.onShareComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
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
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Title
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Icon(
                  Icons.share,
                  color: colorScheme.primary,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Partager',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Options de partage
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                // Image traitée seule
                if (processedPath != null)
                  _buildShareOption(
                    context,
                    icon: Icons.image,
                    title: 'Image traitée',
                    subtitle: 'Partager seulement l\'image sans arrière-plan',
                    onTap: () => _shareProcessedImage(context),
                  ),

         /*       // Avant/Après
                if (originalPath != null && processedPath != null)
                  _buildShareOption(
                    context,
                    icon: Icons.compare,
                    title: 'Avant/Après',
                    subtitle: 'Partager la comparaison originale vs traitée',
                    onTap: () => _shareBeforeAfter(context),
                  ),*/

                // Images multiples
                if (multiplePaths != null && multiplePaths!.isNotEmpty)
                  _buildShareOption(
                    context,
                    icon: Icons.photo_library,
                    title: 'Mes créations (${multiplePaths!.length})',
                    subtitle: 'Partager toutes les images sélectionnées',
                    onTap: () => _shareMultipleImages(context),
                  ),

                // Partager l'app
                _buildShareOption(
                  context,
                  icon: Icons.mobile_friendly,
                  title: 'Recommander ${AppConfig.appName}',
                  subtitle: 'Partager l\'app avec vos amis',
                  onTap: () => _shareApp(context),
                ),

                SizedBox(height: 20.h),
              ],
            ),
          ),

          // Bouton fermer
          Padding(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              bottom: MediaQuery.of(context).padding.bottom + 20.h,
            ),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.onPrimaryContainer,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
              Icon(
                Icons.arrow_forward_ios,
                color: colorScheme.onSurfaceVariant,
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareProcessedImage(BuildContext context) async {
    if (processedPath == null) return;

    try {
      _showLoadingDialog(context);

      final result = await ShareService.shareImage(
        processedPath!,
        sharePositionOrigin: _getSharePosition(context),
      );

      if (context.mounted) {
        Navigator.of(context).pop(); // Fermer loading
        Navigator.of(context).pop(); // Fermer bottom sheet
        _showResultSnackBar(context, result);
        onShareComplete?.call();
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Fermer loading
        _showErrorSnackBar(context, e.toString());
      }
    }
  }

  Future<void> _shareBeforeAfter(BuildContext context) async {
    if (originalPath == null || processedPath == null) return;

    try {
      _showLoadingDialog(context);

      final result = await ShareService.shareBeforeAfter(
        originalPath: originalPath!,
        processedPath: processedPath!,
        sharePositionOrigin: _getSharePosition(context),
      );

      if (context.mounted) {
        Navigator.of(context).pop(); // Fermer loading
        Navigator.of(context).pop(); // Fermer bottom sheet
        _showResultSnackBar(context, result);
        onShareComplete?.call();
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Fermer loading
        _showErrorSnackBar(context, e.toString());
      }
    }
  }

  Future<void> _shareMultipleImages(BuildContext context) async {
    if (multiplePaths == null || multiplePaths!.isEmpty) return;

    try {
      _showLoadingDialog(context);

      final result = await ShareService.shareImages(
        multiplePaths!,
        sharePositionOrigin: _getSharePosition(context),
      );

      if (context.mounted) {
        Navigator.of(context).pop(); // Fermer loading
        Navigator.of(context).pop(); // Fermer bottom sheet
        _showResultSnackBar(context, result);
        onShareComplete?.call();
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Fermer loading
        _showErrorSnackBar(context, e.toString());
      }
    }
  }

  Future<void> _shareApp(BuildContext context) async {
    try {
      final appText = '🎨 Découvrez ${AppConfig.appName} !\n\n'
          'Supprimez l\'arrière-plan de vos photos en quelques secondes avec l\'intelligence artificielle.\n\n'
          '✨ Gratuit et facile à utiliser\n'
          '🚀 Résultats professionnels\n'
          '📱 Disponible sur mobile\n\n'
          'Téléchargez-la maintenant !';

      final result = await ShareService.shareText(
        appText,
        subject: 'Découvrez ${AppConfig.appName} !',
        sharePositionOrigin: _getSharePosition(context),
      );

      if (context.mounted) {
        Navigator.of(context).pop(); // Fermer bottom sheet
        _showResultSnackBar(context, result);
        onShareComplete?.call();
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, e.toString());
      }
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _showResultSnackBar(BuildContext context, ShareResult result) {
    final message = ShareService.getShareStatusMessage(result);
    final isSuccess = result.status == ShareResultStatus.success;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.info,
              color: Colors.white,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.blue,
        duration: Duration(seconds: isSuccess ? 2 : 3),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error,
              color: Colors.white,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Expanded(child: Text('Erreur: $error')),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  Rect? _getSharePosition(BuildContext context) {
    // Pour iPad - position du bouton de partage
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box != null) {
      final position = box.localToGlobal(Offset.zero);
      return Rect.fromLTWH(position.dx, position.dy, box.size.width, box.size.height);
    }
    return null;
  }

  // Factory constructors pour différents cas d'usage
  static void showForResult({
    required BuildContext context,
    required String originalPath,
    required String processedPath,
    VoidCallback? onShareComplete,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ShareBottomSheet(
        originalPath: originalPath,
        processedPath: processedPath,
        onShareComplete: onShareComplete,
      ),
    );
  }

  static void showForGallery({
    required BuildContext context,
    required List<String> imagePaths,
    VoidCallback? onShareComplete,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ShareBottomSheet(
        multiplePaths: imagePaths,
        onShareComplete: onShareComplete,
      ),
    );
  }

  static void showForSingleImage({
    required BuildContext context,
    required String imagePath,
    VoidCallback? onShareComplete,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ShareBottomSheet(
        processedPath: imagePath,
        onShareComplete: onShareComplete,
      ),
    );
  }
}