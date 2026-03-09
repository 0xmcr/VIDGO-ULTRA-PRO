import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vidgo_ultra_pro/services/storage_service.dart';
import 'package:vidgo_ultra_pro/tutorial_screen.dart';
import 'package:vidgo_ultra_pro/widgets/ios_modal.dart';
import 'package:vidgo_ultra_pro/widgets/primary_button.dart';

class FirstLaunchScreen extends StatefulWidget {
  const FirstLaunchScreen({super.key});

  @override
  State<FirstLaunchScreen> createState() => _FirstLaunchScreenState();
}

class _FirstLaunchScreenState extends State<FirstLaunchScreen> {
  final StorageService _storageService = StorageService();
  bool _loading = false;

  Future<void> _requestPermissionsAndContinue() async {
    setState(() => _loading = true);
    await [Permission.storage, Permission.videos].request();

    if (!mounted) return;
    await showIosModal(
      context: context,
      title: 'Terms & Disclaimer',
      body:
          'Only download publicly available and non-DRM content. You are responsible for respecting platform terms and copyright laws.',
      onAccept: () async {
        await _storageService.setAcceptedTerms(true);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TutorialScreen()),
        );
      },
    );

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to VidGo Ultra Pro', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text('Grant permissions to enable browser-based smart downloading and offline playback.'),
            const SizedBox(height: 32),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else
              PrimaryButton(
                label: 'Allow Permissions & Continue',
                icon: Icons.security,
                onPressed: _requestPermissionsAndContinue,
              ),
          ],
        ),
      ),
    );
  }
}
