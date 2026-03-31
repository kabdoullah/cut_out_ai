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

  // Vérifier toutes les permissions nécessaires
  static Future<Map<String, bool>> checkAllPermissions() async {
    try {
      final cameraStatus = await Permission.camera.status;

      PermissionStatus galleryStatus;
      if (await _isAndroid13OrHigher()) {
        galleryStatus = await Permission.photos.status;
      } else {
        galleryStatus = await Permission.storage.status;
      }

      return {
        'camera': cameraStatus.isGranted,
        'gallery': galleryStatus.isGranted,
      };
    } catch (e) {
      debugPrint('❌ Erreur lors de la vérification des permissions: $e');
      return {'camera': false, 'gallery': false};
    }
  }

  // Demander toutes les permissions d'un coup
  static Future<bool> requestAllPermissions() async {
    try {
      final permissions = <Permission>[];

      // Ajouter les permissions nécessaires
      permissions.add(Permission.camera);

      if (await _isAndroid13OrHigher()) {
        permissions.add(Permission.photos);
      } else {
        permissions.add(Permission.storage);
      }

      final statuses = await permissions.request();

      // Vérifier que toutes sont accordées
      final allGranted = statuses.values.every((status) => status.isGranted);

      if (!allGranted) {
        // Log des permissions refusées pour debug
        statuses.forEach((permission, status) {
          if (!status.isGranted) {
            debugPrint('❌ Permission refusée: $permission - Status: $status');
          }
        });
      }

      return allGranted;
    } catch (e) {
      debugPrint('❌ Erreur lors de la demande des permissions: $e');
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

  // Vérifier si une permission est refusée définitivement
  static Future<bool> isPermissionPermanentlyDenied(
    Permission permission,
  ) async {
    try {
      final status = await permission.status;
      return status.isPermanentlyDenied;
    } catch (e) {
      debugPrint('❌ Erreur vérification permission refusée définitivement: $e');
      return false;
    }
  }

  // Obtenir le statut détaillé d'une permission pour debug
  static Future<String> getPermissionStatusString(Permission permission) async {
    try {
      final status = await permission.status;
      switch (status) {
        case PermissionStatus.granted:
          return 'Accordée';
        case PermissionStatus.denied:
          return 'Refusée';
        case PermissionStatus.restricted:
          return 'Restreinte';
        case PermissionStatus.limited:
          return 'Limitée';
        case PermissionStatus.permanentlyDenied:
          return 'Refusée définitivement';
        default:
          return 'Statut inconnu';
      }
    } catch (e) {
      return 'Erreur: $e';
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
