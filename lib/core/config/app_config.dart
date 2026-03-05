class AppConfig {
  // Configuration Remove.bg API
  // IMPORTANT: L'API key doit être fournie via --dart-define=REMOVEBG_API_KEY=votre_clé
  // Exemple: flutter run --dart-define=REMOVEBG_API_KEY=votre_clé_ici
  static const String removeBgApiKey = String.fromEnvironment(
    'REMOVEBG_API_KEY',
    defaultValue: '',
  );

  // Vérifier si l'API key est configurée
  static bool get isApiKeyConfigured => removeBgApiKey.isNotEmpty;

  static const String removeBgBaseUrl = 'https://api.remove.bg/v1.0';
  static const String removeBgEndpoint = '/removebg';

  // Configuration app
  static const String appName = 'CutOut AI';
  static const String appVersion = '1.0.0';

// Limites Remove.bg
  static const int maxImageSizeMB = 12; // Remove.bg limite à 12MB
  static const int maxImagesStored = 100;
  static const int dailyRequestLimit = 2;
  static const Duration apiTimeout = Duration(seconds: 45);

  // URLs utiles
  static const String supportEmail = 'abdoullahcoulibaly2@gmail.com';
  static const String privacyPolicyUrl = 'https://kabdoullah.github.io/cut_out_ai/';
  static const String termsOfServiceUrl = 'https://kabdoullah.github.io/cut_out_ai/';

  // Mode debug
  static const bool isDebugMode = bool.fromEnvironment('DEBUG', defaultValue: false);
}