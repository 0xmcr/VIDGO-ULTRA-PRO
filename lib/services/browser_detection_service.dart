import 'package:vidgo_ultra_pro/services/platform_sniffer_service.dart';

class VideoDetectionResult {
  VideoDetectionResult({
    required this.detected,
    required this.platform,
    required this.url,
    this.reason,
  });

  final bool detected;
  final String platform;
  final String url;
  final String? reason;
}

class BrowserDetectionService {
  final PlatformSnifferService _sniffer = PlatformSnifferService();

  VideoDetectionResult detectFromUrl(String url) {
    final isVideoLink =
        url.contains('/reel') ||
        url.contains('/video') ||
        url.contains('watch') ||
        url.contains('.mp4') ||
        url.contains('/status/');

    final blocked = url.contains('private') ||
        url.contains('drm') ||
        url.contains('protected');

    if (blocked) {
      return VideoDetectionResult(
        detected: false,
        platform: _sniffer.detectPlatform(url),
        url: url,
        reason: 'Protected or DRM video is not supported.',
      );
    }

    if (!isVideoLink) {
      return VideoDetectionResult(
        detected: false,
        platform: _sniffer.detectPlatform(url),
        url: url,
        reason: 'No downloadable public video detected yet.',
      );
    }

    return VideoDetectionResult(
      detected: true,
      platform: _sniffer.detectPlatform(url),
      url: url,
    );
  }
}
