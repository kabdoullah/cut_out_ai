import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class DeviceService {

  // Ouvrir la galerie photos système
  static Future<bool> openGallery() async {
    try {
      if (Platform.isAndroid) {
        // Android : Ouvrir l'app Galerie/Photos
        const androidGalleryUrl = 'content://media/external/images/media';
        final Uri uri = Uri.parse(androidGalleryUrl);

        // Essayer d'ouvrir la galerie
        if (await canLaunchUrl(uri)) {
          return await launchUrl(uri);
        } else {
          // Fallback : ouvrir l'app Galerie via intent
          return await _openAndroidGalleryFallback();
        }
      } else if (Platform.isIOS) {
        // iOS : Ouvrir l'app Photos
        const iosPhotosUrl = 'photos-redirect://';
        final Uri uri = Uri.parse(iosPhotosUrl);

        if (await canLaunchUrl(uri)) {
          return await launchUrl(uri);
        } else {
          // Fallback iOS
          return await _openIOSPhotosFallback();
        }
      }

      return false;
    } catch (e) {
      print('❌ Erreur ouverture galerie: $e');
      return false;
    }
  }

  // Fallback Android : Essayer différents intents
  static Future<bool> _openAndroidGalleryFallback() async {
    try {
      // Intent pour ouvrir la galerie
      final List<String> galleryIntents = [
        'content://media/external/images/media',
        'com.google.android.apps.photos',
        'com.android.gallery3d',
        'com.miui.gallery', // MIUI
        'com.samsung.android.gallery3d', // Samsung
      ];

      for (String intentUrl in galleryIntents) {
        try {
          final Uri uri = Uri.parse(intentUrl);
          if (await canLaunchUrl(uri)) {
            final result = await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
            if (result) return true;
          }
        } catch (e) {
          continue; // Essayer le suivant
        }
      }

      return false;
    } catch (e) {
      print('❌ Erreur fallback Android: $e');
      return false;
    }
  }

  // Fallback iOS : URL scheme Photos
  static Future<bool> _openIOSPhotosFallback() async {
    try {
      const iosUrl = 'photos://';
      final Uri uri = Uri.parse(iosUrl);

      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }

      return false;
    } catch (e) {
      print('❌ Erreur fallback iOS: $e');
      return false;
    }
  }

  // Ouvrir les paramètres système
  static Future<bool> openSettings() async {
    try {
      if (Platform.isAndroid) {
        const androidSettingsUrl = 'package:com.abdoulaye.cutout_ai';
        final Uri uri = Uri.parse(androidSettingsUrl);

        if (await canLaunchUrl(uri)) {
          return await launchUrl(uri);
        }
      } else if (Platform.isIOS) {
        const iosSettingsUrl = 'app-settings:';
        final Uri uri = Uri.parse(iosSettingsUrl);

        if (await canLaunchUrl(uri)) {
          return await launchUrl(uri);
        }
      }

      return false;
    } catch (e) {
      print('❌ Erreur ouverture paramètres: $e');
      return false;
    }
  }

  // Ouvrir le gestionnaire de fichiers
  static Future<bool> openFileManager() async {
    try {
      if (Platform.isAndroid) {
        const androidFilesUrl = 'content://com.android.externalstorage.documents/';
        final Uri uri = Uri.parse(androidFilesUrl);

        if (await canLaunchUrl(uri)) {
          return await launchUrl(uri);
        }
      }

      return false;
    } catch (e) {
      print('❌ Erreur ouverture gestionnaire fichiers: $e');
      return false;
    }
  }

  // Ouvrir une URL web
  static Future<bool> openUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }

      return false;
    } catch (e) {
      print('❌ Erreur ouverture URL: $e');
      return false;
    }
  }

  // Partager du texte
  static Future<bool> shareText(String text, {String? subject}) async {
    try {
      final String shareUrl = 'mailto:?subject=${Uri.encodeComponent(subject ?? 'CutOut AI')}&body=${Uri.encodeComponent(text)}';
      final Uri uri = Uri.parse(shareUrl);

      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }

      return false;
    } catch (e) {
      print('❌ Erreur partage texte: $e');
      return false;
    }
  }
}