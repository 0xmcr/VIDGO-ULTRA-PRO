class PlatformSnifferService {
  static const supported = {
    'instagram': ['instagram.com'],
    'tiktok': ['tiktok.com'],
    'facebook': ['facebook.com', 'fb.watch'],
    'twitter': ['twitter.com', 'x.com'],
    'whatsapp': ['whatsapp.com'],
  };

  String detectPlatform(String url) {
    final lower = url.toLowerCase();
    for (final entry in supported.entries) {
      if (entry.value.any(lower.contains)) {
        return entry.key;
      }
    }
    return 'unknown';
  }

  bool isSupported(String url) => detectPlatform(url) != 'unknown';
}
