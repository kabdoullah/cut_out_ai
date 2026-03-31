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
  static const String appStoreLink = 'https://kabdoullah.github.io/cut_out_ai/';
  static const String supportEmail = 'abdoullahcoulibaly2@gmail.com';
  static const String privacyPolicyUrl =
      'https://kabdoullah.github.io/cut_out_ai/';
  static const String termsOfServiceUrl =
      'https://kabdoullah.github.io/cut_out_ai/';

  // Mode debug
  static const bool isDebugMode = bool.fromEnvironment(
    'DEBUG',
    defaultValue: false,
  );

  // --- AdMob ---
  // IDs de test Google par défaut. Passer --dart-define=USE_TEST_ADS=false en production.
  static bool get useTestAds =>
      const bool.fromEnvironment('USE_TEST_ADS', defaultValue: true);

  static String get bannerAdUnitIdAndroid => useTestAds
      ? 'ca-app-pub-3940256099942544/6300978111'
      : const String.fromEnvironment(
          'BANNER_AD_UNIT_ANDROID',
          defaultValue: '',
        );
  static String get bannerAdUnitIdIos => useTestAds
      ? 'ca-app-pub-3940256099942544/2934735716'
      : const String.fromEnvironment('BANNER_AD_UNIT_IOS', defaultValue: '');

  static String get interstitialAdUnitIdAndroid => useTestAds
      ? 'ca-app-pub-3940256099942544/1033173712'
      : const String.fromEnvironment(
          'INTERSTITIAL_AD_UNIT_ANDROID',
          defaultValue: '',
        );
  static String get interstitialAdUnitIdIos => useTestAds
      ? 'ca-app-pub-3940256099942544/4411468910'
      : const String.fromEnvironment(
          'INTERSTITIAL_AD_UNIT_IOS',
          defaultValue: '',
        );

  static String get rewardedAdUnitIdAndroid => useTestAds
      ? 'ca-app-pub-3940256099942544/5224354917'
      : const String.fromEnvironment(
          'REWARDED_AD_UNIT_ANDROID',
          defaultValue: '',
        );
  static String get rewardedAdUnitIdIos => useTestAds
      ? 'ca-app-pub-3940256099942544/1712485313'
      : const String.fromEnvironment('REWARDED_AD_UNIT_IOS', defaultValue: '');

  static const Duration interstitialFrequencyCap = Duration(minutes: 3);
}
