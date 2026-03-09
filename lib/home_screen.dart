import 'package:flutter/material.dart';

import 'browser_screen.dart';
import 'downloads_screen.dart';
import 'saved_videos_screen.dart';
import 'services/clipboard_service.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _clipboardService = ClipboardService();
  int _currentIndex = 0;
  String? _clipboardUrl;

  @override
  void initState() {
    super.initState();
    _clipboardService.startMonitoring((url) {
      if (!mounted) return;
      setState(() => _clipboardUrl = url);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Detected link in clipboard: $url'),
          action: SnackBarAction(label: 'Open', onPressed: () => setState(() => _currentIndex = 0)),
        ),
      );
    });
  }

  @override
  void dispose() {
    _clipboardService.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      BrowserScreen(initialUrl: _clipboardUrl),
      const DownloadsScreen(),
      const SavedVideosScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (value) => setState(() => _currentIndex = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.language), label: 'Browser'),
          NavigationDestination(icon: Icon(Icons.download), label: 'Downloads'),
          NavigationDestination(icon: Icon(Icons.video_library), label: 'Saved'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
