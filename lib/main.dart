import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:vidgo_ultra_pro/first_launch_screen.dart';
import 'package:vidgo_ultra_pro/home_screen.dart';
import 'package:vidgo_ultra_pro/services/storage_service.dart';
import 'package:vidgo_ultra_pro/theme_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(const VidGoApp());
}

class VidGoApp extends StatelessWidget {
  const VidGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, _) {
          return MaterialApp(
            title: 'VidGo Ultra Pro',
            debugShowCheckedModeBanner: false,
            themeMode: themeNotifier.themeMode,
            theme: ThemeData(
              colorSchemeSeed: Colors.indigo,
              brightness: Brightness.light,
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorSchemeSeed: Colors.indigo,
              brightness: Brightness.dark,
              useMaterial3: true,
            ),
            home: const LaunchRouter(),
          );
        },
      ),
    );
  }
}

class LaunchRouter extends StatefulWidget {
  const LaunchRouter({super.key});

  @override
  State<LaunchRouter> createState() => _LaunchRouterState();
}

class _LaunchRouterState extends State<LaunchRouter> {
  final StorageService _storageService = StorageService();
  bool _loading = true;
  bool _accepted = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _accepted = await _storageService.getAcceptedTerms();
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _accepted ? const HomeScreen() : const FirstLaunchScreen();
  }
}
