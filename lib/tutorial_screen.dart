import 'package:flutter/material.dart';
import 'package:vidgo_ultra_pro/home_screen.dart';
import 'package:vidgo_ultra_pro/services/storage_service.dart';
import 'package:vidgo_ultra_pro/widgets/primary_button.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _controller = PageController();
  final StorageService _storageService = StorageService();
  int _index = 0;

  final List<(IconData, String, String)> _slides = const [
    (Icons.language, 'Browse', 'Open social video links securely using the built-in browser.'),
    (Icons.radar, 'Detect', 'Smart sniffer identifies public playable streams instantly.'),
    (Icons.download_done, 'Download & Watch', 'Save videos for offline playback with progress tracking.'),
  ];

  Future<void> _finish() async {
    await _storageService.setTutorialSeen(true);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => _index = i),
              itemCount: _slides.length,
              itemBuilder: (context, i) {
                final slide = _slides[i];
                return Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(slide.$1, size: 120),
                      const SizedBox(height: 24),
                      Text(slide.$2, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 12),
                      Text(slide.$3, textAlign: TextAlign.center),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: _index == 2
                ? PrimaryButton(label: 'Start Using App', onPressed: _finish, icon: Icons.rocket_launch)
                : PrimaryButton(
                    label: 'Next',
                    icon: Icons.arrow_forward,
                    onPressed: () => _controller.nextPage(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
