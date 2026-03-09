import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ad_service.dart';
import 'first_launch_screen.dart';
import 'home_screen.dart';
import 'theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdService.init();
  final themeNotifier = ThemeNotifier();
  await themeNotifier.init();
  runApp(VidGoApp(themeNotifier: themeNotifier));
}

class VidGoApp extends StatelessWidget {
  final ThemeNotifier themeNotifier;
  const VidGoApp({super.key, required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: themeNotifier,
      child: Consumer<ThemeNotifier>(
        builder: (context, notifier, _) {
          return MaterialApp(
            title: 'VidGo Ultra Pro',
            debugShowCheckedModeBanner: false,
            themeMode: notifier.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: const Color(0xFF0A84FF),
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: const Color(0xFF0A84FF),
              brightness: Brightness.dark,
            ),
            home: const FirstLaunchScreen(nextScreen: HomeScreen()),
          );
        },
      ),
    );
  }
}
