import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' show Platform;

class AppOpenAdManager {
  // App Open Ad Unit ID
  String adUnitId =
      Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/9257395921' // Test Ad Unit ID for Android
          : 'ca-app-pub-3940256099942544/5662855259'; // Test Ad Unit ID for iOS

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;

  // Banner Ad Unit ID
  String bannerAdUnitId =
      Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/9214589741' // Test Ad Unit ID for Android
          : 'ca-app-pub-3940256099942544/2934735716'; // Test Ad Unit ID for iOS

  BannerAd? _bannerAd;

  // Interstitial Ad Unit ID
  String interstitialAdUnitId =
      Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712' // Test Ad Unit ID for Android
          : 'ca-app-pub-3940256099942544/4411468910'; // Test Ad Unit ID for iOS

  InterstitialAd? _interstitialAd;

  // Native Ad Unit ID
  String nativeAdUnitId =
      Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/2247696110' // Test Ad Unit ID for Android
          : 'ca-app-pub-3940256099942544/3986624511'; // Test Ad Unit ID for iOS

  NativeAd? _nativeAd;
  bool _isNativeAdLoaded = false;

  // Reward Ad Unit ID
  String rewardAdUnitId =
      Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917' // Test Ad Unit ID for Android
          : 'ca-app-pub-3940256099942544/1712485313'; // Test Ad Unit ID for iOS
  RewardedAd? _rewardedAd;

  // Maximum duration allowed between loading and showing the ad.
  final Duration maxCacheDuration = Duration(hours: 4);

  // Keep track of load time so we don't show an expired ad.
  DateTime? _appOpenLoadTime;

  /// Load an AppOpenAd.
  void loadAd() {
    AppOpenAd.load(
      adUnitId: adUnitId,
      request: AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          print('AppOpenAd loaded.');
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('AppOpenAd failed to load: $error');
        },
      ),
    );
  }

  /// Show the ad if available.
  void showAdIfAvailable(VoidCallback onAdDismissed) {
    if (!isAdAvailable) {
      print('No ad available yet.');
      onAdDismissed(); // Directly navigate to Home Screen if no ad
      return;
    }
    if (_isShowingAd) {
      print('Already showing an ad.');
      return;
    }

    // Check if the ad has expired.
    if (_appOpenLoadTime != null &&
        DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)) {
      print('Maximum cache duration exceeded. Loading another ad.');
      _appOpenAd!.dispose();
      _appOpenAd = null;
      loadAd();
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        print('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        onAdDismissed(); // Navigate to Home Screen if ad fails
      },
      onAdDismissedFullScreenContent: (ad) {
        print('$ad onAdDismissedFullScreenContent');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        onAdDismissed(); // Navigate to Home Screen after ad is dismissed
      },
    );
    _appOpenAd!.show();
  }

  /// Check if an ad is available.
  bool get isAdAvailable {
    return _appOpenAd != null;
  }

  // Load a Banner Ad.
  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Banner Ad loaded.');
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner Ad failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  /// Show the Banner Ad.
  Widget showBannerAd() {
    return _bannerAd == null
        ? Container() // If no ad is available, return an empty container
        : Container(
          alignment: Alignment.center,
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!), // Show the ad
        );
  }

  /// Load an Interstitial Ad.
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('Interstitial Ad loaded.');
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('Interstitial Ad failed to load: $error');
        },
      ),
    );
  }

  /// Show the Interstitial Ad.
  void showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Tried to show Interstitial Ad before available.');
      loadInterstitialAd();
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _interstitialAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        print('$ad onAdDismissedFullScreenContent');
        ad.dispose();
        _interstitialAd = null;
      },
    );
    _interstitialAd!.show();
  }

  /// Load a Native Ad.
  void loadNativeAd() {
    _nativeAd = NativeAd(
      adUnitId: nativeAdUnitId,
      factoryId: 'listTile',
      request: AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          print('$NativeAd loaded.');
          _isNativeAdLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          print('$NativeAd failed to load: $error');
          ad.dispose();
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: Colors.white,
        cornerRadius: 10.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: const Color.fromARGB(255, 119, 64, 247),
          style: NativeTemplateFontStyle.monospace,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          style: NativeTemplateFontStyle.italic,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          style: NativeTemplateFontStyle.normal,
          size: 16.0,
        ),
      ),
    )..load();
  }

  /// Show the Native Ad.
  Widget showNativeAd() {
    return _isNativeAdLoaded && _nativeAd != null
        ? ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 320,
            minHeight: 320,
            maxWidth: 400,
            maxHeight: 400,
          ),
          child: AdWidget(ad: _nativeAd!),
        )
        : SizedBox(
          height: 100,
          child: Center(child: Text('No Native Ad available')),
        ); // If no ad is available, return an empty container
  }

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardAdUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          print('Rewarded Ad loaded.');
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('Rewarded Ad failed to load: $error');
        },
      ),
    );
  }

  /// Show the Rewarded Ad.
  void showRewardedAd() {
    if (_rewardedAd == null) {
      print('Tried to show Rewarded Ad before available.');
      loadRewardedAd();
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('$ad onAdShowedFullScreenContent.');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _rewardedAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        print('$ad onAdDismissedFullScreenContent');
        ad.dispose();
        _rewardedAd = null;
      },
    );
    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        print('$reward onUserEarnedReward.');
      },
    );
  }

  /// Dispose the ads when they are no longer needed.
  void dispose() {
    if (_appOpenAd != null) {
      _appOpenAd!.dispose();
    }
    if (_interstitialAd != null) {
      _interstitialAd!.dispose();
    }
    if (_bannerAd != null) {
      _bannerAd!.dispose();
    }
    if (_nativeAd != null) {
      _nativeAd!.dispose();
    }
    if (_rewardedAd != null) {
      _rewardedAd!.dispose();
    }
  }
}
