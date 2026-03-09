import 'dart:async';

import 'package:flutter/services.dart';

class ClipboardService {
  Timer? _timer;
  String _lastSeen = '';

  void startMonitoring(void Function(String text) onNewUrl) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) async {
      final data = await Clipboard.getData('text/plain');
      final text = data?.text?.trim() ?? '';
      if (text.isNotEmpty && text != _lastSeen && _isUrl(text)) {
        _lastSeen = text;
        onNewUrl(text);
      }
    });
  }

  bool _isUrl(String text) {
    final uri = Uri.tryParse(text);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }

  void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
  }
}
