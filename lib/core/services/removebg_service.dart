import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class RemoveBgService {
  final Dio _dio;

  RemoveBgService({required Dio dio}) : _dio = dio;

  Future<Uint8List> removeBackground(String imagePath) async {
    try {
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();

      // Vérifier la taille de l'image
      final imageSizeMB = imageBytes.length / (1024 * 1024);
      if (imageSizeMB > AppConfig.maxImageSizeMB) {
        throw RemoveBgException(
          'Image trop volumineuse (${imageSizeMB.toStringAsFixed(1)}MB). Maximum autorisé: ${AppConfig.maxImageSizeMB}MB',
        );
      }

      debugPrint('🖼️ Traitement image: ${imageSizeMB.toStringAsFixed(2)}MB');
      debugPrint('📡 URL: ${_dio.options.baseUrl}${AppConfig.removeBgEndpoint}');

      // Créer FormData pour l'upload
      final formData = FormData.fromMap({
        'image_file': MultipartFile.fromBytes(
          imageBytes,
          filename: 'image.${_getFileExtension(imagePath)}',
        ),
        'size': 'auto', // Options: auto, preview, full
        'format': 'png', // Format de sortie
      });

      final response = await _dio.post(
        AppConfig.removeBgEndpoint,
        data: formData,
        options: Options(
          headers: {'X-Api-Key': AppConfig.removeBgApiKey},
          responseType: ResponseType.bytes,
        ),
      );

      debugPrint('✅ Remove.bg Response: ${response.statusCode}');

      // Vérifier les headers pour les infos de l'API
      final remainingCredits = response.headers.value('x-foreground-count');
      final totalCredits = response.headers.value('x-credits-total');

      if (remainingCredits != null && totalCredits != null) {
        debugPrint('💰 Crédits restants: $remainingCredits/$totalCredits');
      }

      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data);
      } else {
        throw RemoveBgException(
          'Remove.bg API returned ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ Remove.bg DioException: ${e.message}');
      debugPrint('❌ Status: ${e.response?.statusCode}');
      debugPrint('❌ Data: ${e.response?.data}');

      throw RemoveBgException(_handleRemoveBgError(e));
    } catch (e) {
      debugPrint('❌ Remove.bg General error: $e');
      throw RemoveBgException('Erreur inattendue: $e');
    }
  }

  String _getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }

  /// Décode les bytes de réponse d'erreur et extrait le premier message d'erreur.
  String? _extractApiMessage(dynamic data) {
    try {
      final bytes = data as List<int>;
      final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      final errors = json['errors'] as List<dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        return (errors.first as Map<String, dynamic>)['title'] as String?;
      }
    } catch (_) {}
    return null;
  }

  String _handleRemoveBgError(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        return _extractApiMessage(e.response?.data) ??
            'Aucun sujet détecté — essayez une image avec un sujet bien défini';
      case 402:
        return 'Crédits API épuisés - Consultez votre compte Remove.bg';
      case 403:
        return 'API Key invalide ou accès refusé';
      case 429:
        return 'Trop de requêtes - Ralentissez le rythme';
      case 500:
        return 'Erreur serveur Remove.bg - Réessayez plus tard';
      default:
        return 'Erreur Remove.bg (${e.response?.statusCode}): ${e.message}';
    }
  }
}

// Exception personnalisée pour Remove.bg
class RemoveBgException implements Exception {
  final String message;
  const RemoveBgException(this.message);

  @override
  String toString() => message;
}
