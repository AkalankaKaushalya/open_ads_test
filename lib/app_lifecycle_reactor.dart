import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app_open_ad_manager.dart';

/// Listens for app foreground events and shows app open ads.
class AppLifecycleReactor {
  final AppOpenAdManager appOpenAdManager;

  AppLifecycleReactor({required this.appOpenAdManager});

  void listenToAppStateChanges() {
    // Start listening to app state changes
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream.forEach(
      (state) => _onAppStateChanged(state),
    );
  }

  void _onAppStateChanged(AppState appState) {
    // Show an app open ad if the app is brought to the foreground
    if (appState == AppState.foreground) {
      appOpenAdManager.showAdIfAvailable(() {});
    }
  }

  void dispose() {
    // Stop listening to app state changes
    AppStateEventNotifier.stopListening();
  }
}
