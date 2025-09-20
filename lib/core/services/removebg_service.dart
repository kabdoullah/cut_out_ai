import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
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
        throw RemoveBgException('Image trop volumineuse (${imageSizeMB.toStringAsFixed(1)}MB). Maximum autorisé: ${AppConfig.maxImageSizeMB}MB');
      }

      print('🖼️ Traitement image: ${imageSizeMB.toStringAsFixed(2)}MB');
      print('📡 URL: ${_dio.options.baseUrl}${AppConfig.removeBgEndpoint}');

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
          headers: {
            'X-Api-Key': AppConfig.removeBgApiKey,
          },
          responseType: ResponseType.bytes,
        ),
      );

      print('✅ Remove.bg Response: ${response.statusCode}');

      // Vérifier les headers pour les infos de l'API
      final remainingCredits = response.headers.value('x-foreground-count');
      final totalCredits = response.headers.value('x-credits-total');

      if (remainingCredits != null && totalCredits != null) {
        print('💰 Crédits restants: $remainingCredits/$totalCredits');
      }

      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data);
      } else {
        throw RemoveBgException('Remove.bg API returned ${response.statusCode}');
      }

    } on DioException catch (e) {
      print('❌ Remove.bg DioException: ${e.message}');
      print('❌ Status: ${e.response?.statusCode}');
      print('❌ Data: ${e.response?.data}');

      throw RemoveBgException(_handleRemoveBgError(e));
    } catch (e) {
      print('❌ Remove.bg General error: $e');
      throw RemoveBgException('Erreur inattendue: $e');
    }
  }

  String _getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }

  String _handleRemoveBgError(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        return 'Image invalide ou format non supporté';
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