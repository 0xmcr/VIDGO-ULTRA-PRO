import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static const bool useTestAds = true;

  static String get bannerAdUnitId => useTestAds
      ? 'ca-app-pub-3940256099942544/6300978111'
      : '';

  static String get interstitialAdUnitId => useTestAds
      ? 'ca-app-pub-3940256099942544/1033173712'
      : '';

  static String get rewardedAdUnitId => useTestAds
      ? 'ca-app-pub-3940256099942544/5224354917'
      : '';

  static Future<void> init() => MobileAds.instance.initialize();
}
