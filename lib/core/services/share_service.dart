import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../config/app_config.dart';

class ShareService {
  // Partager une image simple avec texte
  static Future<ShareResult> shareImage(
    String imagePath, {
    String? text,
    String? subject,
    Rect? sharePositionOrigin,
  }) async {
    try {
      // Vérifier que le fichier existe
      final file = File(imagePath);
      if (!file.existsSync()) {
        throw ShareException('Fichier image introuvable: $imagePath');
      }

      debugPrint('📤 Partage image: ${file.path}');

      // Créer XFile pour le partage
      final xFile = XFile(imagePath, name: _generateFileName(imagePath));

      // Texte par défaut si non fourni
      final shareText = text ?? _getDefaultShareText();

      // Partager
      final result = await Share.shareXFiles(
        [xFile],
        text: shareText,
        subject: subject ?? '${AppConfig.appName} - Image traitée',
        sharePositionOrigin: sharePositionOrigin,
      );

      debugPrint('✅ Partage réussi: ${result.status}');
      return result;
    } catch (e) {
      debugPrint('❌ Erreur partage image: $e');
      if (e is ShareException) {
        rethrow;
      } else {
        throw ShareException('Erreur inattendue lors du partage: $e');
      }
    }
  }

  // Partager plusieurs images
  static Future<ShareResult> shareImages(
    List<String> imagePaths, {
    String? text,
    String? subject,
    Rect? sharePositionOrigin,
  }) async {
    try {
      if (imagePaths.isEmpty) {
        throw ShareException('Aucune image à partager');
      }

      debugPrint('Partage ${imagePaths.length} images');

      // Créer XFiles pour toutes les images
      final xFiles = <XFile>[];
      for (final path in imagePaths) {
        final file = File(path);
        if (file.existsSync()) {
          xFiles.add(XFile(path, name: _generateFileName(path)));
        } else {
          debugPrint('Image ignorée (introuvable): $path');
        }
      }

      if (xFiles.isEmpty) {
        throw ShareException('Aucune image valide à partager');
      }

      // Texte adapté au nombre d'images
      final shareText = text ?? _getMultipleImagesShareText(xFiles.length);

      // Partager
      final result = await Share.shareXFiles(
        xFiles,
        text: shareText,
        subject: subject ?? '${AppConfig.appName} - Mes créations',
        sharePositionOrigin: sharePositionOrigin,
      );

      debugPrint('Partage multiple réussi: ${result.status}');
      return result;
    } catch (e) {
      debugPrint('Erreur partage multiple: $e');
      if (e is ShareException) {
        rethrow;
      } else {
        throw ShareException('Erreur inattendue lors du partage: $e');
      }
    }
  }

  // Partager seulement du texte (pour lien d'app, etc.)
  static Future<ShareResult> shareText(
    String text, {
    String? subject,
    Rect? sharePositionOrigin,
  }) async {
    try {
      debugPrint(
        '📤 Partage texte: ${text.substring(0, text.length > 50 ? 50 : text.length)}...',
      );

      final result = await Share.share(
        text,
        subject: subject,
        sharePositionOrigin: sharePositionOrigin,
      );

      debugPrint('Partage texte réussi: ${result.status}');
      return result;
    } catch (e) {
      debugPrint('Erreur partage texte: $e');
      throw ShareException('Erreur lors du partage de texte: $e');
    }
  }

  // Méthodes utilitaires privées

  static String _getDefaultShareText() {
    return 'J\'ai supprimé l\'arrière-plan de cette photo avec ${AppConfig.appName} ! ✨\n\n'
        'Une app gratuite pour traiter vos photos avec l\'IA 🚀';
  }

  static String _getMultipleImagesShareText(int count) {
    return 'Mes $count créations avec ${AppConfig.appName} ! ✨\n\n'
        'Suppression d\'arrière-plan par IA en quelques secondes 🚀';
  }

  static String _generateFileName(String originalPath) {
    final extension = originalPath.split('.').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'cutout_ai_$timestamp.$extension';
  }

  // Vérifier si le partage est disponible sur la plateforme
  static bool get isAvailable {
    return Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isMacOS ||
        Platform.isWindows;
  }

  // Obtenir des informations sur le résultat du partage
  static String getShareStatusMessage(ShareResult result) {
    switch (result.status) {
      case ShareResultStatus.success:
        return 'Partagé avec succès !';
      case ShareResultStatus.dismissed:
        return 'Partage annulé';
      case ShareResultStatus.unavailable:
        return 'Partage non disponible sur cette plateforme';
    }
  }
}

// Exception personnalisée pour le partage
class ShareException implements Exception {
  final String message;
  const ShareException(this.message);

  @override
  String toString() => message;
}

