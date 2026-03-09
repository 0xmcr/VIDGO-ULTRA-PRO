import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tutorial_screen.dart';
import 'widgets/premium_card.dart';
import 'widgets/primary_button.dart';

class FirstLaunchScreen extends StatefulWidget {
  final Widget nextScreen;
  const FirstLaunchScreen({super.key, required this.nextScreen});

  @override
  State<FirstLaunchScreen> createState() => _FirstLaunchScreenState();
}

class _FirstLaunchScreenState extends State<FirstLaunchScreen> {
  static const _firstLaunchKey = 'first_launch_completed';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_firstLaunchKey) ?? false;
    if (completed && mounted) {
      _goNext();
      return;
    }
    await _requestPermissions();
    if (!mounted) return;
    await _showDisclaimer();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TutorialScreen()),
    );
    await prefs.setBool(_firstLaunchKey, true);
    if (!mounted) return;
    _goNext();
  }

  Future<void> _requestPermissions() async {
    await [Permission.storage, Permission.videos].request();
  }

  Future<void> _showDisclaimer() {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Disclaimer',
      pageBuilder: (_, __, ___) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: PremiumCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Terms & Disclaimer', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                const Text('Use this app only for publicly available content and where you hold rights to download. DRM/private content is blocked.'),
                const SizedBox(height: 20),
                PrimaryButton(label: 'Accept & Continue', onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
        ),
      ),
      transitionDuration: const Duration(milliseconds: 280),
      transitionBuilder: (_, anim, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: ScaleTransition(scale: Tween(begin: .96, end: 1.0).animate(anim), child: child),
      ),
    );
  }

  void _goNext() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => widget.nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator()));
}
