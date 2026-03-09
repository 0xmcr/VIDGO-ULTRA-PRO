import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'services/browser_detection_service.dart';
import 'services/downloader_service.dart';

class BrowserScreen extends StatefulWidget {
  final String? initialUrl;
  const BrowserScreen({super.key, this.initialUrl});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  final _urlController = TextEditingController(text: 'https://www.google.com');
  final _detect = BrowserDetectionService();
  final _downloader = DownloaderService.instance;
  late final WebViewController _controller;
  String? _detectedUrl;

  @override
  void initState() {
    super.initState();
    if (widget.initialUrl != null) _urlController.text = widget.initialUrl!;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => _inspectUrl(url),
          onNavigationRequest: (request) {
            _inspectUrl(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_urlController.text));
  }

  void _inspectUrl(String url) {
    if (_detect.looksLikeVideoUrl(url)) {
      setState(() => _detectedUrl = url);
    }
  }

  Future<void> _startDownload() async {
    final url = _detectedUrl;
    if (url == null) return;
    if (url.contains('drm') || url.contains('private')) {
      _showError('Protected/DRM video cannot be downloaded.');
      return;
    }
    await _downloader.queueDownload(
      url: url,
      fileName: 'video_${DateTime.now().millisecondsSinceEpoch}.mp4',
      platform: _detect.platformOf(url),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Download started')));
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cannot download video'),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _urlController,
          decoration: const InputDecoration(border: InputBorder.none, hintText: 'Enter URL'),
          onSubmitted: (value) => _controller.loadRequest(Uri.parse(value)),
        ),
        actions: [
          IconButton(
            onPressed: () => _controller.reload(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_detectedUrl != null)
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.extended(
                onPressed: _startDownload,
                icon: const Icon(Icons.download),
                label: const Text('Download Video'),
              ),
            ),
        ],
      ),
    );
  }
}
