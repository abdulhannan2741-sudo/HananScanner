import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Wraps Google Mobile Ads initialization and provides helpers to load
/// banner / interstitial / rewarded ads. Uses test ad unit IDs from
/// [AdConfig] — replace with real IDs before publishing.
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
  }

  /// Create a banner ad sized for the current screen.
  BannerAd createBannerAd({required void Function(Ad ad) onLoaded}) {
    return BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    );
  }

  Future<InterstitialAd?> loadInterstitial({
    required void Function(InterstitialAd ad) onLoaded,
  }) async {
    InterstitialAd? ad;
    await InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: (error) {},
      ),
    );
    return ad;
  }
}
