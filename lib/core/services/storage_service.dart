import 'dart:convert';
import 'dart:isolate';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_image.dart';

// Top-level — required by Isolate.run
String _encodeImagesToJson(List<Map<String, dynamic>> jsonMaps) {
  return jsonEncode(jsonMaps);
}

List<Map<String, dynamic>> _decodeJsonToMaps(String jsonString) {
  return (jsonDecode(jsonString) as List).cast<Map<String, dynamic>>();
}

class StorageService {
  static const String _imagesKey = 'cutout_ai_images';

  Future<void> saveImages(List<AppImage> images) async {
    try {
      final jsonMaps = images.map((image) => image.toJson()).toList();
      final jsonString =
          await Isolate.run(() => _encodeImagesToJson(jsonMaps));
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(_imagesKey, jsonString);
      if (!success) {
        throw StorageException('Impossible de sauvegarder les images');
      }
    } on StorageException {
      rethrow;
    } catch (e) {
      throw StorageException('Erreur de sauvegarde: $e');
    }
  }

  Future<List<AppImage>> loadImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_imagesKey);
      if (jsonString == null || jsonString.isEmpty) return [];

      final jsonMaps =
          await Isolate.run(() => _decodeJsonToMaps(jsonString));
      return jsonMaps.map(AppImage.fromJson).toList();
    } catch (e) {
      await clearImages();
      throw StorageException('Données corrompues détectées et nettoyées');
    }
  }

  Future<void> saveImage(AppImage image, List<AppImage> allImages) async {
    final index = allImages.indexWhere((img) => img.id == image.id);
    final updated = index >= 0
        ? (List.of(allImages)..[index] = image)
        : [...allImages, image];
    await saveImages(updated);
  }

  Future<void> deleteImage(String imageId, List<AppImage> allImages) async {
    final updated = allImages.where((img) => img.id != imageId).toList();
    await saveImages(updated);
  }

  Future<void> clearImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_imagesKey);
    } catch (e) {
      throw StorageException('Impossible de supprimer les images: $e');
    }
  }
}

class StorageException implements Exception {
  final String message;
  const StorageException(this.message);

  @override
  String toString() => message;
}

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});
