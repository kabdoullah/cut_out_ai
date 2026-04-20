import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Vérifier et demander les permissions caméra
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Vérifier et demander les permissions galerie
  static Future<bool> requestGalleryPermission() async {
    try {
      // Pour Android 13+ (API 33+)
      if (await _isAndroid13OrHigher()) {
        final status = await Permission.photos.status;

        if (status.isGranted) {
          return true;
        } else if (status.isDenied) {
          final newStatus = await Permission.photos.request();
          return newStatus.isGranted;
        } else if (status.isPermanentlyDenied) {
          debugPrint('❌ Permission photos refusée définitivement');
          return false;
        }
      } else {
        // Pour les versions antérieures
        final status = await Permission.storage.status;

        if (status.isGranted) {
          return true;
        } else if (status.isDenied) {
          final newStatus = await Permission.storage.request();
          return newStatus.isGranted;
        } else if (status.isPermanentlyDenied) {
          debugPrint('❌ Permission storage refusée définitivement');
          return false;
        }
      }

      return false;
    } catch (e) {
      debugPrint('❌ Erreur lors de la demande de permission galerie: $e');
      return false;
    }
  }

  // Ouvrir les paramètres si permission refusée définitivement
  static Future<bool> openDeviceSettings() async {
    try {
      debugPrint('📱 Ouverture des paramètres de l\'application...');
      return await openAppSettings(); // Fonction globale du package
    } catch (e) {
      debugPrint('❌ Erreur ouverture paramètres: $e');
      return false;
    }
  }

  // Vérifier la version Android
  static Future<bool> _isAndroid13OrHigher() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.version.sdkInt >= 33;
      }
      return false;
    } catch (e) {
      return false; // Fallback sécurisé
    }
  }
}
