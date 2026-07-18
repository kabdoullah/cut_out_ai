import 'dart:io';

class AppConfig {
  static const String appName = 'CutOut AI';

  static const int maxImageSizeMB = 10;

  static const String appStoreLink =
      'https://play.google.com/store/apps/details?id=com.abdoulaye.cutoutai&pcampaignid=web_share';

  // Android: IDs AdMob réels. iOS: IDs de test Google (pas d'app iOS pour l'instant).
  static String get bannerAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-1481899209152092/9992645593'
      : 'ca-app-pub-3940256099942544/2934735716';

  static String get interstitialAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-1481899209152092/1027975049'
      : 'ca-app-pub-3940256099942544/4411468910';
}
