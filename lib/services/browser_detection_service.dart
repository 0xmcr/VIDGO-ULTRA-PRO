import 'platform_sniffer_service.dart';

class BrowserDetectionService {
  final PlatformSnifferService _sniffer = PlatformSnifferService();

  bool looksLikeVideoUrl(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('drm') || lower.contains('private') || lower.contains('protected')) {
      return false;
    }
    return _sniffer.isSupported(url) ||
        lower.endsWith('.mp4') ||
        lower.contains('video') ||
        lower.contains('reel') ||
        lower.contains('status');
  }

  String platformOf(String url) => _sniffer.detectPlatform(url);
}
