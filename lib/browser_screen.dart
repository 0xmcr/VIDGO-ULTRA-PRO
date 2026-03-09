import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vidgo_ultra_pro/downloads_screen.dart';
import 'package:vidgo_ultra_pro/services/browser_detection_service.dart';
import 'package:vidgo_ultra_pro/widgets/browser_toolbar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key, this.initialUrl});

  final String? initialUrl;

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  late final WebViewController _webController;
  final BrowserDetectionService _detectionService = BrowserDetectionService();
  final TextEditingController _urlController = TextEditingController();
  VideoDetectionResult? _currentDetection;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialUrl ?? 'https://www.google.com';
    _urlController.text = initial;
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(onPageFinished: (url) {
        setState(() => _currentDetection = _detectionService.detectFromUrl(url));
      }))
      ..loadRequest(Uri.parse(initial));
  }

  void _goToUrl() {
    final raw = _urlController.text.trim();
    if (raw.isEmpty) return;
    final uri = Uri.tryParse(raw.startsWith('http') ? raw : 'https://$raw');
    if (uri != null) {
      _webController.loadRequest(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Browser')),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: WebViewWidget(controller: _webController)),
              BrowserToolbar(
                controller: _urlController,
                onGo: _goToUrl,
                onBack: () => _webController.goBack(),
                onForward: () => _webController.goForward(),
                onRefresh: () => _webController.reload(),
              ),
            ],
          ),
          if (_currentDetection?.detected == true)
            Positioned(
              right: 16,
              bottom: 90,
              child: FloatingActionButton.extended(
                onPressed: () {
                  final url = _currentDetection!.url;
                  final platform = _currentDetection!.platform;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DownloadsScreen(
                        queuedUrl: url,
                        queuedPlatform: platform,
                        suggestedName: 'video_${Random().nextInt(99999)}.mp4',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text('Download'),
              ),
            ),
          if (_currentDetection != null && _currentDetection?.detected == false)
            Positioned(
              left: 12,
              right: 12,
              bottom: 95,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_currentDetection?.reason ?? ''),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
