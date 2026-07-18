import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/app_config.dart';

// ID de l'appareil de dev — enregistré comme "test device" pour recevoir des
// pubs test garanties pendant le développement (un compte AdMob neuf a 0 fill
// réel les premiers jours). Google logue cet ID au premier lancement.
const _devTestDeviceId = 'BEED6A06B5806B8E1EF12A4927B7E09D';

/// Gère le SDK Google Mobile Ads: init, et cycle de vie des interstitiels.
/// Les banners se créent directement via [AdService.createBannerAd] et vivent
/// dans le widget qui les affiche (elles doivent être disposées par ce widget).
class AdService {
  AdService._();

  static InterstitialAd? _interstitialAd;
  static bool _isLoadingInterstitial = false;

  static Future<void> initialize() async {
    await _requestTrackingAuthorization();
    await MobileAds.instance.initialize();

    if (kDebugMode) {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: [_devTestDeviceId]),
      );
    }
  }

  // Sur iOS 14+, le SDK Ads attend le statut ATT avant de pouvoir servir des
  // pubs personnalisées. Sans ça il retombe sur des pubs non personnalisées.
  static Future<void> _requestTrackingAuthorization() async {
    if (!Platform.isIOS) return;

    final status =
        await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }

  static BannerAd createBannerAd({required void Function() onLoaded}) {
    final banner = BannerAd(
      adUnitId: AppConfig.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded(),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    );
    banner.load();
    return banner;
  }

  /// Précharge un interstitiel pour un affichage ultérieur via [showInterstitialAd].
  static void preloadInterstitialAd() {
    if (_interstitialAd != null || _isLoadingInterstitial) return;
    _isLoadingInterstitial = true;

    InterstitialAd.load(
      adUnitId: AppConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoadingInterstitial = false;
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _isLoadingInterstitial = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  /// Affiche l'interstitiel préchargé s'il est prêt, puis en précharge un nouveau.
  static void showInterstitialAd() {
    final ad = _interstitialAd;
    if (ad == null) {
      preloadInterstitialAd();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        preloadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        preloadInterstitialAd();
      },
    );
    ad.show();
  }
}
