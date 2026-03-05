import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// Service pour la gestion des fichiers locaux
class FileService {

  // Obtenir le répertoire de l'app pour sauvegarder les images traitées
  Future<Directory> get _appDirectory async {
    final directory = await getApplicationDocumentsDirectory();
    final appDir = Directory('${directory.path}/cutout_ai');

    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }

    return appDir;
  }

  // Sauvegarder une image traitée localement
  Future<String> saveProcessedImage(Uint8List imageData, String originalName) async {
    try {
      final appDir = await _appDirectory;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'processed_${timestamp}_$originalName.png';
      final filePath = '${appDir.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(imageData);

      return filePath;
    } catch (e) {
      throw FileServiceException('Impossible de sauvegarder l\'image: $e');
    }
  }

  // Vérifier si un fichier existe
  Future<bool> fileExists(String path) async {
    try {
      final file = File(path);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // Supprimer un fichier
  Future<void> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw FileServiceException('Impossible de supprimer le fichier: $e');
    }
  }

  // Nettoyer les anciens fichiers (par exemple, plus de 30 jours)
  Future<void> cleanupOldFiles({int daysToKeep = 30}) async {
    try {
      final appDir = await _appDirectory;
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

      await for (final entity in appDir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      throw FileServiceException('Erreur lors du nettoyage: $e');
    }
  }

  // Appliquer une couleur de fond sur un PNG transparent
  Future<Uint8List> applyBackgroundColor(String imagePath, Color backgroundColor) async {
    try {
      final bytes = await File(imagePath).readAsBytes();

      final completer = Completer<ui.Image>();
      ui.decodeImageFromList(bytes, completer.complete);
      final uiImage = await completer.future;

      final w = uiImage.width;
      final h = uiImage.height;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      canvas.drawRect(
        Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
        Paint()..color = backgroundColor,
      );
      canvas.drawImage(uiImage, Offset.zero, Paint());

      final composited = await recorder.endRecording().toImage(w, h);
      final byteData = await composited.toByteData(format: ui.ImageByteFormat.png);

      uiImage.dispose();
      composited.dispose();

      return byteData!.buffer.asUint8List();
    } catch (e) {
      throw FileServiceException('Impossible d\'appliquer la couleur de fond: $e');
    }
  }

  // Obtenir la taille du répertoire de l'app
  Future<int> getAppDirectorySize() async {
    try {
      final appDir = await _appDirectory;
      int totalSize = 0;

      await for (final entity in appDir.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }
}

// Exception personnalisée pour les fichiers
class FileServiceException implements Exception {
  final String message;
  const FileServiceException(this.message);

  @override
  String toString() => message;
}