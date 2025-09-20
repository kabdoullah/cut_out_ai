import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/config/app_config.dart';
import '../../../core/services/permission_service.dart';

class PermissionDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback onGranted;

  const PermissionDialog({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.onGranted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            icon,
            color: colorScheme.primary,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Text(title),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: colorScheme.primary,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Ces permissions sont nécessaires pour le bon fonctionnement de l\'app.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Plus tard'),
        ),
        FilledButton(
          onPressed: () async {
            final navigator = Navigator.of(context); // ✅ Capturer avant l'async
            final messenger = ScaffoldMessenger.of(context); // ✅ Capturer avant l'async

            navigator.pop(); // Fermer le dialog d'abord

            final granted = await _requestPermission();
            if (granted) {
              onGranted();
            } else {
              // Utiliser les références capturées
              _showSettingsDialog(context, navigator, messenger);
            }
          },
          child: const Text('Autoriser'),
        ),
      ],
    );
  }

  Future<bool> _requestPermission() async {
    if (icon == Icons.camera_alt) {
      return await PermissionService.requestCameraPermission();
    } else {
      return await PermissionService.requestGalleryPermission();
    }
  }

  void _showSettingsDialog(BuildContext context, NavigatorState navigator, ScaffoldMessengerState messenger) {
    // Vérifier si le widget est encore monté
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission refusée'),
        content: const Text(
          'Pour utiliser cette fonctionnalité, veuillez autoriser l\'accès dans les paramètres de votre appareil.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              final dialogNavigator = Navigator.of(context); // Capturer avant async

              dialogNavigator.pop(); // Fermer le dialog

              try {
                final opened = await PermissionService.openDeviceSettings();
                
                if (opened) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Paramètres ouverts. Revenez dans l\'app après avoir activé les permissions.'),
                      duration: Duration(seconds: 4),
                      backgroundColor: Colors.blue,
                    ),
                  );
                } else {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Impossible d\'ouvrir les paramètres automatiquement. Allez manuellement dans Paramètres > Applications > CutOut AI > Autorisations.'),
                      duration: Duration(seconds: 6),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Erreur: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Text('Paramètres'),
          ),
        ],
      ),
    );
  }

  // Factory methods pour simplifier l'usage
  static void showCameraPermissionDialog(
      BuildContext context,
      VoidCallback onGranted,
      ) {
    showDialog(
      context: context,
      builder: (context) => PermissionDialog(
        title: 'Accès à la caméra',
        message: '${AppConfig.appName} a besoin d\'accéder à votre appareil photo pour prendre des photos à traiter avec l\'IA.',
        icon: Icons.camera_alt,
        onGranted: onGranted,
      ),
    );
  }

  static void showGalleryPermissionDialog(
      BuildContext context,
      VoidCallback onGranted,
      ) {
    showDialog(
      context: context,
      builder: (context) => PermissionDialog(
        title: 'Accès à la galerie',
        message: '${AppConfig.appName} a besoin d\'accéder à votre galerie pour sélectionner des photos à traiter avec l\'IA.',
        icon: Icons.photo_library,
        onGranted: onGranted,
      ),
    );
  }
}