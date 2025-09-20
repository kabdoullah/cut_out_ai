import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../services/removebg_service.dart';

// Configuration Dio avec intercepteurs
class DioConfig {
  static Dio createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConfig.removeBgBaseUrl,
      connectTimeout: AppConfig.apiTimeout,
      receiveTimeout: AppConfig.apiTimeout,
      sendTimeout: AppConfig.apiTimeout,
      headers: {
        'User-Agent': '${AppConfig.appName}/${AppConfig.appVersion}',
      },
    ));

    // Intercepteur pour les logs
    dio.interceptors.add(LogInterceptor(
      requestBody: false, // Ne pas logger les images
      responseBody: false, // Ne pas logger les images
      requestHeader: true,
      responseHeader: true,
      logPrint: (object) => print('🌐 Remove.bg: $object'),
    ));

    // Intercepteur pour retry (moins agressif que pour Hugging Face)
    dio.interceptors.add(RetryInterceptor(
      dio: dio,
      retries: 2,
      retryDelays: const [
        Duration(seconds: 2),
        Duration(seconds: 5),
      ],
    ));

    return dio;
  }
}
// Intercepteur de retry personnalisé pour Remove.bg
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int retries;
  final List<Duration> retryDelays;

  RetryInterceptor({
    required this.dio,
    required this.retries,
    required this.retryDelays,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final retryCount = extra['retryCount'] ?? 0;

    // Ne retry que pour certains codes d'erreur
    if (retryCount < retries && _shouldRetry(err)) {
      extra['retryCount'] = retryCount + 1;

      print('🔄 Retry ${retryCount + 1}/$retries pour ${err.response?.statusCode}');

      // Attendre avant de réessayer
      if (retryCount < retryDelays.length) {
        await Future.delayed(retryDelays[retryCount]);
      }

      try {
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
      } catch (e) {
        super.onError(err, handler);
      }
    } else {
      super.onError(err, handler);
    }
  }

  bool _shouldRetry(DioException err) {
    // Retry seulement pour les erreurs temporaires
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null &&
            [500, 502, 503, 504].contains(err.response!.statusCode));

    // Ne PAS retry pour 402 (pas de crédits), 403 (API key), etc.
  }
}
final dioProvider = Provider<Dio>((ref) {
  // Debug de l'API Key au démarrage
  AppConfig.debugApiKeyInfo();

  // Validation de l'API Key
  if (AppConfig.removeBgApiKey.isEmpty) {
    throw Exception('❌ API Key Remove.bg manquante ! Utilise: flutter run --dart-define=REMOVEBG_API_KEY=ton_api_key');
  }

  final dio = DioConfig.createDio();

  print('✅ Dio configuré pour Remove.bg');
  print('🌐 Base URL: ${dio.options.baseUrl}');

  return dio;
});

final removeBgServiceProvider = Provider<RemoveBgService>((ref) {
  final dio = ref.watch(dioProvider);
  return RemoveBgService(dio: dio);
});