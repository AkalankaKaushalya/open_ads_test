import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:open_ads_test/app_lifecycle_reactor.dart';
import 'app_open_ad_manager.dart'; // Import your App Open Ad Manager

Future<void> main() async {
  // Ensure Flutter binding is initialized before using any plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Google Mobile Ads
  await MobileAds.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Open Ads Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(), // Navigate to Splash Screen
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late AppOpenAdManager _appOpenAdManager;
  late AppLifecycleReactor _appLifecycleReactor;

  @override
  void initState() {
    super.initState();

    // Initialize App Open Ad Manager
    _appOpenAdManager = AppOpenAdManager()..loadAd();

    // Initialize AppLifecycleReactor
    _appLifecycleReactor = AppLifecycleReactor(
      appOpenAdManager: _appOpenAdManager,
    );
    _appLifecycleReactor
        .listenToAppStateChanges(); // Start listening for app state changes

    // Simulate a delay for the splash screen (e.g., 3 seconds)
    Future.delayed(Duration(seconds: 3), () {
      // Show App Open Ad if available
      _appOpenAdManager.showAdIfAvailable(() {
        // After ad is dismissed, navigate to Home Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyHomePage(title: 'Home Screen'),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to My App!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late AppOpenAdManager _appOpenAdManager;
  late AppLifecycleReactor _appLifecycleReactor;

  @override
  void initState() {
    super.initState();
    setState(() {
      // Initialize App Open Ad Manager
      _appOpenAdManager =
          AppOpenAdManager()
            ..loadAd()
            ..loadAd()
            ..loadBannerAd()
            ..loadInterstitialAd()
            ..loadNativeAd()
            ..loadRewardedAd();

      // Initialize AppLifecycleReactor
      _appLifecycleReactor = AppLifecycleReactor(
        appOpenAdManager: _appOpenAdManager,
      );
      _appLifecycleReactor
          .listenToAppStateChanges(); // Start listening for app state changes
    });
  }

  @override
  void dispose() {
    _appOpenAdManager.dispose();
    _appLifecycleReactor.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
              onPressed: () {
                _appOpenAdManager.showInterstitialAd();
              },
              child: Text('Show Interstitial Ad'),
            ),
            SizedBox(height: 20),
            _appOpenAdManager.showBannerAd(),
            SizedBox(height: 20),
            _appOpenAdManager.showNativeAd(), // Show Native Ad
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _appOpenAdManager.showRewardedAd();
              },
              child: Text('Show Rewarded Ad'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
