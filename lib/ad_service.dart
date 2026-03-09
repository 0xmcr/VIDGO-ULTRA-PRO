class AdService {
  static const bool testMode = true;

  static const String bannerAdUnitId = testMode
      ? 'ca-app-pub-3940256099942544/6300978111'
      : '';

  static const String interstitialAdUnitId = testMode
      ? 'ca-app-pub-3940256099942544/1033173712'
      : '';

  static const String rewardedAdUnitId = testMode
      ? 'ca-app-pub-3940256099942544/5224354917'
      : '';
}
