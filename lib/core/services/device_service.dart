import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class DeviceService {
  // Ouvrir les paramètres système
  static Future<bool> openSettings() async {
    try {
      if (Platform.isAndroid) {
        const androidSettingsUrl = 'package:com.abdoulaye.cutoutai';
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
      debugPrint('❌ Erreur ouverture paramètres: $e');
      return false;
    }
  }
}
