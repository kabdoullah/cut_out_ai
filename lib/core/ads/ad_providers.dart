import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/app_config.dart';

// ---------------------------------------------------------------------------
// Interstitial Ad
// ---------------------------------------------------------------------------

class InterstitialAdNotifier extends Notifier<InterstitialAd?> {
  DateTime? _lastShownAt;

  @override
  InterstitialAd? build() {
    _loadAd();
    return null;
  }

  String get _adUnitId => Platform.isAndroid
      ? AppConfig.interstitialAdUnitIdAndroid
      : AppConfig.interstitialAdUnitIdIos;

  void _loadAd() {
    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              state = null;
              _loadAd();
            },
            onAdFailedToShowFullScreenContent: (ad, _) {
              ad.dispose();
              state = null;
              _loadAd();
            },
          );
          state = ad;
        },
        onAdFailedToLoad: (_) {
          state = null;
          Future.delayed(const Duration(seconds: 60), _loadAd);
        },
      ),
    );
  }

  /// Affiche l'interstitiel si disponible et si le cap de fréquence est respecté.
  /// Retourne true si la pub a été affichée.
  bool tryShow() {
    final ad = state;
    if (ad == null) return false;
    final now = DateTime.now();
    if (_lastShownAt != null &&
        now.difference(_lastShownAt!) < AppConfig.interstitialFrequencyCap) {
      return false;
    }
    _lastShownAt = now;
    ad.show();
    return true;
  }
}

final interstitialAdProvider =
    NotifierProvider<InterstitialAdNotifier, InterstitialAd?>(
        InterstitialAdNotifier.new);

// ---------------------------------------------------------------------------
// Rewarded Ad
// ---------------------------------------------------------------------------

class RewardedAdNotifier extends Notifier<RewardedAd?> {
  @override
  RewardedAd? build() {
    _loadAd();
    return null;
  }

  String get _adUnitId => Platform.isAndroid
      ? AppConfig.rewardedAdUnitIdAndroid
      : AppConfig.rewardedAdUnitIdIos;

  void _loadAd() {
    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              state = null;
              _loadAd();
            },
            onAdFailedToShowFullScreenContent: (ad, _) {
              ad.dispose();
              state = null;
              _loadAd();
            },
          );
          state = ad;
        },
        onAdFailedToLoad: (_) {
          state = null;
          Future.delayed(const Duration(seconds: 60), _loadAd);
        },
      ),
    );
  }

  /// Affiche la pub récompensée. [onRewarded] est appelé si l'utilisateur gagne la récompense.
  /// Retourne false si aucune pub n'est disponible.
  bool tryShow({required VoidCallback onRewarded}) {
    final ad = state;
    if (ad == null) return false;
    ad.show(onUserEarnedReward: (_, __) => onRewarded());
    return true;
  }
}

final rewardedAdProvider =
    NotifierProvider<RewardedAdNotifier, RewardedAd?>(RewardedAdNotifier.new);
