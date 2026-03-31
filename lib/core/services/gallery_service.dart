import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';

class GalleryService {
  // Sauvegarder une image dans la galerie système
  static Future<bool> saveImageToGallery(
    String imagePath, {
    String? albumName,
  }) async {
    try {
      // 1. Vérifier les permissions
      final hasPermission = await _checkStoragePermission();
      if (!hasPermission) {
        throw GalleryException('Permission de stockage refusée');
      }

      // 2. Vérifier que le fichier existe
      final file = File(imagePath);
      if (!file.existsSync()) {
        throw GalleryException('Fichier image introuvable: $imagePath');
      }

      // 3. Sauvegarder avec Gal (plus moderne et maintenu)
      await Gal.putImage(imagePath, album: albumName ?? 'CutOut AI');

      debugPrint('📸 Image sauvegardée avec succès dans la galerie');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur sauvegarde galerie: $e');
      if (e is GalleryException) {
        rethrow;
      } else {
        throw GalleryException('Erreur inattendue: $e');
      }
    }
  }

  // Sauvegarder des bytes directement
  static Future<bool> saveImageBytesToGallery(
    Uint8List imageBytes, {
    String? name,
  }) async {
    try {
      // 1. Vérifier les permissions
      final hasPermission = await _checkStoragePermission();
      if (!hasPermission) {
        throw GalleryException('Permission de stockage refusée');
      }

      // 2. Créer un fichier temporaire
      final tempFile = await _createTempFile(imageBytes, name);

      // 3. Sauvegarder avec Gal
      await Gal.putImage(tempFile.path, album: 'CutOut AI');

      // 4. Nettoyer le fichier temporaire
      await tempFile.delete();

      debugPrint('📸 Image (bytes) sauvegardée avec succès dans la galerie');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur sauvegarde galerie (bytes): $e');
      if (e is GalleryException) {
        rethrow;
      } else {
        throw GalleryException('Erreur inattendue: $e');
      }
    }
  }

  // Créer un fichier temporaire pour les bytes
  static Future<File> _createTempFile(
    Uint8List imageBytes,
    String? name,
  ) async {
    final tempDir = Directory.systemTemp;
    final fileName = name ?? _generateImageName();
    final tempFile = File('${tempDir.path}/$fileName.png');

    await tempFile.writeAsBytes(imageBytes);
    return tempFile;
  }

  // Vérifier et demander les permissions de stockage - AVEC device_info_plus et Gal
  static Future<bool> _checkStoragePermission() async {
    try {
      // 1. D'abord essayer avec Gal (méthode recommandée)
      final hasGalAccess = await Gal.hasAccess();
      if (hasGalAccess) {
        debugPrint('✅ Accès galerie déjà accordé via Gal');
        return true;
      }

      debugPrint('📱 Demande d\'accès galerie via Gal...');
      final galAccessGranted = await Gal.requestAccess();
      if (galAccessGranted) {
        debugPrint('✅ Accès galerie accordé via Gal');
        return true;
      }

      // 2. Si Gal échoue, utiliser permission_handler comme fallback
      debugPrint(
        '⚠️ Gal n\'a pas pu obtenir l\'accès, fallback vers permission_handler',
      );

      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        debugPrint('📱 Version Android détectée: API $sdkInt');

        if (sdkInt >= 33) {
          // Android 13+ (API 33+) : Permission photos
          debugPrint('📱 Android 13+ détecté - Utilisation permission photos');
          return await _requestAndroidPhotosPermission();
        } else {
          // Android < 13 : Permission storage
          debugPrint(
              '📱 Android < 13 détecté - Utilisation permission storage');
          return await _requestAndroidStoragePermission();
        }
      } else if (Platform.isIOS) {
        // iOS : Permission photos
        debugPrint('📱 iOS détecté - Utilisation permission photos');
        return await _requestIOSPhotosPermission();
      }

      return false;
    } catch (e) {
      debugPrint('❌ Erreur permissions stockage: $e');
      // Dernier fallback : essayer storage directement
      return await _requestAndroidStoragePermission();
    }
  }

  // Demander permission photos sur Android 13+
  static Future<bool> _requestAndroidPhotosPermission() async {
    final status = await Permission.photos.status;

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      final newStatus = await Permission.photos.request();
      if (newStatus.isGranted) {
        return true;
      } else if (newStatus.isPermanentlyDenied) {
        debugPrint(
          '❌ Permission photos refusée définitivement - Redirection vers paramètres',
        );
        throw GalleryException(
          'Permission refusée définitivement. Allez dans Paramètres > Applications > CutOut AI > Autorisations pour activer l\'accès aux photos.',
        );
      } else {
        debugPrint('❌ Permission photos refusée');
        throw GalleryException('Permission d\'accès aux photos refusée');
      }
    } else if (status.isPermanentlyDenied) {
      debugPrint(
        '❌ Permission photos refusée définitivement - Redirection vers paramètres',
      );
      throw GalleryException(
        'Permission refusée définitivement. Allez dans Paramètres > Applications > CutOut AI > Autorisations pour activer l\'accès aux photos.',
      );
    }

    return false;
  }

  // Demander permission storage sur Android < 13
  static Future<bool> _requestAndroidStoragePermission() async {
    final status = await Permission.storage.status;

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      final newStatus = await Permission.storage.request();
      if (newStatus.isGranted) {
        return true;
      } else if (newStatus.isPermanentlyDenied) {
        debugPrint(
          '❌ Permission storage refusée définitivement - Redirection vers paramètres',
        );
        throw GalleryException(
          'Permission refusée définitivement. Allez dans Paramètres > Applications > CutOut AI > Autorisations pour activer l\'accès au stockage.',
        );
      } else {
        debugPrint('❌ Permission storage refusée');
        throw GalleryException('Permission d\'accès au stockage refusée');
      }
    } else if (status.isPermanentlyDenied) {
      debugPrint(
        '❌ Permission storage refusée définitivement - Redirection vers paramètres',
      );
      throw GalleryException(
        'Permission refusée définitivement. Allez dans Paramètres > Applications > CutOut AI > Autorisations pour activer l\'accès au stockage.',
      );
    }

    return false;
  }

  // Demander permission photos sur iOS
  static Future<bool> _requestIOSPhotosPermission() async {
    final status = await Permission.photos.status;

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      final newStatus = await Permission.photos.request();
      if (newStatus.isGranted) {
        return true;
      } else if (newStatus.isPermanentlyDenied) {
        debugPrint(
          '❌ Permission photos iOS refusée définitivement - Redirection vers paramètres',
        );
        throw GalleryException(
          'Permission refusée définitivement. Allez dans Réglages > Confidentialité > Photos pour autoriser CutOut AI.',
        );
      } else {
        debugPrint('❌ Permission photos iOS refusée');
        throw GalleryException('Permission d\'accès aux photos refusée');
      }
    } else if (status.isPermanentlyDenied) {
      debugPrint(
        '❌ Permission photos iOS refusée définitivement - Redirection vers paramètres',
      );
      throw GalleryException(
        'Permission refusée définitivement. Allez dans Réglages > Confidentialité > Photos pour autoriser CutOut AI.',
      );
    }

    return false;
  }

  // Générer un nom unique pour l'image
  static String _generateImageName() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'CutOutAI_$timestamp';
  }

  // Obtenir le chemin de sauvegarde (pour info)
  static Future<String?> getGalleryPath() async {
    try {
      // Avec Gal, on ne peut pas obtenir le chemin exact
      // mais on peut vérifier si Gal est disponible
      final hasAccess = await Gal.hasAccess();
      return hasAccess ? 'Galerie système' : null;
    } catch (e) {
      debugPrint('❌ Impossible de vérifier l\'accès galerie: $e');
      return null;
    }
  }

  // Vérifier si l'accès à la galerie est disponible
  static Future<bool> hasGalleryAccess() async {
    try {
      return await Gal.hasAccess();
    } catch (e) {
      debugPrint('❌ Erreur vérification accès galerie: $e');
      return false;
    }
  }

  // Demander l'accès à la galerie
  static Future<bool> requestGalleryAccess() async {
    try {
      return await Gal.requestAccess();
    } catch (e) {
      debugPrint('❌ Erreur demande accès galerie: $e');
      return false;
    }
  }
}

// Exception personnalisée pour la galerie
class GalleryException implements Exception {
  final String message;
  const GalleryException(this.message);

  @override
  String toString() => message;
}
