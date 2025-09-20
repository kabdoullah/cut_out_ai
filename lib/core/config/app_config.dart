class AppConfig {
  // Configuration Remove.bg API
  static const String removeBgApiKey = String.fromEnvironment(
    'REMOVEBG_API_KEY',
    defaultValue: '', // ⚠️ Laisse vide pour forcer l'erreur si pas défini
  );

  static const String removeBgBaseUrl = 'https://api.remove.bg/v1.0';
  static const String removeBgEndpoint = '/removebg';

  // 🔍 Méthode de debug pour vérifier le token
  static void debugApiKeyInfo() {
    print('🔑 Remove.bg API Key configurée: ${removeBgApiKey.isNotEmpty ? 'OUI' : 'NON'}');
    if (removeBgApiKey.isNotEmpty) {
      print('🔑 Longueur de l\'API Key: ${removeBgApiKey.length}');
      // Afficher seulement les premiers et derniers caractères pour la sécurité
      if (removeBgApiKey.length > 10) {
        print('🔑 API Key: ${removeBgApiKey.substring(0, 4)}...${removeBgApiKey.substring(removeBgApiKey.length - 4)}');
      }
    } else {
      print('❌ ERREUR: API Key Remove.bg non configurée !');
      print('💡 Solution: flutter run --dart-define=REMOVEBG_API_KEY=ton_api_key');
    }
  }

  // Configuration app
  static const String appName = 'CutOut AI';
  static const String appVersion = '1.0.0';

// Limites Remove.bg
  static const int maxImageSizeMB = 12; // Remove.bg limite à 12MB
  static const int maxImagesStored = 100;
  static const Duration apiTimeout = Duration(seconds: 45);

  // URLs utiles
  static const String supportEmail = 'support@cutoutai.app';
  static const String privacyPolicyUrl = 'https://cutoutai.app/privacy';
  static const String termsOfServiceUrl = 'https://cutoutai.app/terms';

  // Mode debug
  static const bool isDebugMode = bool.fromEnvironment('DEBUG', defaultValue: false);
}