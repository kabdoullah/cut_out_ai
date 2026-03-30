import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
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

      print('📤 Partage image: ${file.path}');

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

      print('✅ Partage réussi: ${result.status}');
      return result;
    } catch (e) {
      print('❌ Erreur partage image: $e');
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

      print('Partage ${imagePaths.length} images');

      // Créer XFiles pour toutes les images
      final xFiles = <XFile>[];
      for (final path in imagePaths) {
        final file = File(path);
        if (file.existsSync()) {
          xFiles.add(XFile(path, name: _generateFileName(path)));
        } else {
          print('Image ignorée (introuvable): $path');
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

      print('Partage multiple réussi: ${result.status}');
      return result;
    } catch (e) {
      print('Erreur partage multiple: $e');
      if (e is ShareException) {
        rethrow;
      } else {
        throw ShareException('Erreur inattendue lors du partage: $e');
      }
    }
  }

  // Partager avant/après (image originale + traitée)
  static Future<ShareResult> shareBeforeAfter({
    required String originalPath,
    required String processedPath,
    String? customText,
    Rect? sharePositionOrigin,
  }) async {
    try {
      print('📤 Partage avant/après');

      // Vérifier les deux images
      final originalFile = File(originalPath);
      final processedFile = File(processedPath);

      if (!originalFile.existsSync()) {
        throw ShareException('Image originale introuvable');
      }
      if (!processedFile.existsSync()) {
        throw ShareException('Image traitée introuvable');
      }

      // Créer les XFiles
      final xFiles = [
        XFile(originalPath, name: 'avant_${_generateFileName(originalPath)}'),
        XFile(processedPath, name: 'apres_${_generateFileName(processedPath)}'),
      ];

      // Texte de comparaison
      final shareText = customText ?? _getBeforeAfterShareText();

      // Partager
      final result = await Share.shareXFiles(
        xFiles,
        text: shareText,
        subject: '${AppConfig.appName} - Avant/Après',
        sharePositionOrigin: sharePositionOrigin,
      );

      print('✅ Partage avant/après réussi: ${result.status}');
      return result;
    } catch (e) {
      print('❌ Erreur partage avant/après: $e');
      if (e is ShareException) {
        rethrow;
      } else {
        throw ShareException('Erreur inattendue lors du partage: $e');
      }
    }
  }

  // Partager depuis des bytes (pour images générées à la volée)
  static Future<ShareResult> shareImageBytes(
    Uint8List imageBytes, {
    required String fileName,
    String? text,
    String? subject,
    String mimeType = 'image/png',
    Rect? sharePositionOrigin,
  }) async {
    try {
      print('📤 Partage image depuis bytes: $fileName');

      // Créer un fichier temporaire
      final tempFile = await _createTempFileFromBytes(imageBytes, fileName);

      // Partager comme fichier normal
      final result = await shareImage(
        tempFile.path,
        text: text,
        subject: subject,
        sharePositionOrigin: sharePositionOrigin,
      );

      // Nettoyer le fichier temporaire (optionnel - sera nettoyé automatiquement)
      tempFile.deleteSync();

      return result;
    } catch (e) {
      print('❌ Erreur partage bytes: $e');
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
      print(
          '📤 Partage texte: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');

      final result = await Share.share(
        text,
        subject: subject,
        sharePositionOrigin: sharePositionOrigin,
      );

      print('Partage texte réussi: ${result.status}');
      return result;
    } catch (e) {
      print('Erreur partage texte: $e');
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

  static String _getBeforeAfterShareText() {
    return 'Avant/Après avec ${AppConfig.appName} ! ✨\n\n'
        'Regardez comme l\'arrière-plan a été supprimé proprement par l\'IA 🚀';
  }

  static String _generateFileName(String originalPath) {
    final extension = originalPath.split('.').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'cutout_ai_$timestamp.$extension';
  }

  static Future<File> _createTempFileFromBytes(
      Uint8List bytes, String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/$fileName');
    await tempFile.writeAsBytes(bytes);
    return tempFile;
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
      default:
        return 'Statut de partage inconnu';
    }
  }
}

// Provider pour le service de partage
final shareServiceProvider = Provider<ShareService>((ref) {
  return ShareService();
});

// Exception personnalisée pour le partage
class ShareException implements Exception {
  final String message;
  const ShareException(this.message);

  @override
  String toString() => message;
}

// Enum pour les options de partage
enum ShareOption {
  imageOnly,
  imageWithText,
  beforeAfter,
  textOnly,
  multiple,
}

// Classe pour configurer les options de partage
class ShareConfig {
  final ShareOption option;
  final String? customText;
  final String? customSubject;
  final bool includeAppBranding;

  const ShareConfig({
    required this.option,
    this.customText,
    this.customSubject,
    this.includeAppBranding = true,
  });

  factory ShareConfig.imageOnly({String? customText}) {
    return ShareConfig(
      option: ShareOption.imageOnly,
      customText: customText,
    );
  }

  factory ShareConfig.beforeAfter({String? customText}) {
    return ShareConfig(
      option: ShareOption.beforeAfter,
      customText: customText,
    );
  }

  factory ShareConfig.multiple({String? customText}) {
    return ShareConfig(
      option: ShareOption.multiple,
      customText: customText,
    );
  }
}
