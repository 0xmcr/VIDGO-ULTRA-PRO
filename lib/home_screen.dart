import 'package:flutter/material.dart';
import 'package:vidgo_ultra_pro/browser_screen.dart';
import 'package:vidgo_ultra_pro/downloads_screen.dart';
import 'package:vidgo_ultra_pro/saved_videos_screen.dart';
import 'package:vidgo_ultra_pro/services/clipboard_service.dart';
import 'package:vidgo_ultra_pro/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ClipboardService _clipboardService = ClipboardService();
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _clipboardService.startMonitoring((url) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Detected URL in clipboard: $url'),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BrowserScreen(initialUrl: url)),
            ),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _clipboardService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const BrowserScreen(),
      const DownloadsScreen(),
      const SavedVideosScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: pages[_index],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.public), label: 'Browser'),
          NavigationDestination(icon: Icon(Icons.downloading), label: 'Downloads'),
          NavigationDestination(icon: Icon(Icons.video_library), label: 'Saved'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
