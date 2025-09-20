import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_image.dart';

// Service pour la persistance locale
class StorageService {
  static const String _imagesKey = 'cutout_ai_images';
  static const String _settingsKey = 'cutout_ai_settings';

  // Sauvegarder les images
  Future<void> saveImages(List<AppImage> images) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = images.map((image) => image.toJson()).toList();
      final success = await prefs.setString(_imagesKey, jsonEncode(jsonList));

      if (!success) {
        throw StorageException('Impossible de sauvegarder les images');
      }
    } catch (e) {
      throw StorageException('Erreur de sauvegarde: $e');
    }
  }

  // Charger les images
  Future<List<AppImage>> loadImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_imagesKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => AppImage.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // En cas d'erreur de parsing, on retourne une liste vide
      // et on nettoie les données corrompues
      await clearImages();
      throw StorageException('Données corrompues détectées et nettoyées');
    }
  }

  // Sauvegarder une seule image (optimisation)
  Future<void> saveImage(AppImage image, List<AppImage> allImages) async {
    final updatedImages = allImages.map((img) {
      return img.id == image.id ? image : img;
    }).toList();

    // Si l'image n'existe pas, l'ajouter
    if (!updatedImages.any((img) => img.id == image.id)) {
      updatedImages.add(image);
    }

    await saveImages(updatedImages);
  }

  // Supprimer une image
  Future<void> deleteImage(String imageId, List<AppImage> allImages) async {
    final updatedImages = allImages.where((img) => img.id != imageId).toList();
    await saveImages(updatedImages);
  }

  // Supprimer toutes les images
  Future<void> clearImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_imagesKey);
    } catch (e) {
      throw StorageException('Impossible de supprimer les images: $e');
    }
  }

  // Sauvegarder les paramètres de l'app
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, jsonEncode(settings));
    } catch (e) {
      throw StorageException('Impossible de sauvegarder les paramètres: $e');
    }
  }

  // Charger les paramètres de l'app
  Future<Map<String, dynamic>> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_settingsKey);

      if (jsonString == null) {
        return {};
      }

      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return {}; // Paramètres par défaut en cas d'erreur
    }
  }

  // Statistiques de stockage
  Future<StorageStats> getStorageStats() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    int totalSize = 0;
    int imageCount = 0;

    for (final key in keys) {
      if (key.startsWith('cutout_ai_')) {
        final value = prefs.getString(key);
        if (value != null) {
          totalSize += value.length;
          if (key == _imagesKey) {
            try {
              final jsonList = jsonDecode(value) as List;
              imageCount = jsonList.length;
            } catch (e) {
              // Ignorer les erreurs de parsing pour les stats
            }
          }
        }
      }
    }

    return StorageStats(totalSizeInBytes: totalSize, imageCount: imageCount);
  }
}

// Modèle pour les statistiques de stockage
class StorageStats {
  final int totalSizeInBytes;
  final int imageCount;

  const StorageStats({
    required this.totalSizeInBytes,
    required this.imageCount,
  });

  String get formattedSize {
    if (totalSizeInBytes > 1024) {
      final kb = totalSizeInBytes / 1024;
      return '${kb.toStringAsFixed(1)} KB';
    }
    return '$totalSizeInBytes bytes';
  }
}

// Exception personnalisée pour le stockage
class StorageException implements Exception {
  final String message;

  const StorageException(this.message);

  @override
  String toString() => message;
}

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});
