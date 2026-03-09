import 'dart:async';

import 'package:flutter/services.dart';

class ClipboardService {
  Timer? _timer;
  String _lastValue = '';

  void startMonitoring(void Function(String) onVideoUrl) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) async {
      final data = await Clipboard.getData('text/plain');
      final text = data?.text?.trim() ?? '';
      if (text.isEmpty || text == _lastValue) return;
      _lastValue = text;
      final isValidUrl =
          Uri.tryParse(text)?.hasAbsolutePath == true && text.startsWith('http');
      if (isValidUrl) {
        onVideoUrl(text);
      }
    });
  }

  void dispose() {
    _timer?.cancel();
  }
}
