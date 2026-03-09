class PlatformSnifferService {
  static const _platformPatterns = {
    'Instagram': r'(instagram\\.com|instagr\\.am)',
    'TikTok': r'tiktok\\.com',
    'Facebook': r'(facebook\\.com|fb\\.watch)',
    'Twitter': r'(twitter\\.com|x\\.com)',
    'WhatsApp': r'whatsapp\\.com',
  };

  String detectPlatform(String url) {
    final lower = url.toLowerCase();
    for (final entry in _platformPatterns.entries) {
      if (RegExp(entry.value).hasMatch(lower)) {
        return entry.key;
      }
    }
    return 'Other';
  }
}
