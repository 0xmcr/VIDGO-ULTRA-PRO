class VideoItem {
  final String id;
  final String url;
  final String title;
  final String platform;
  final String? thumbnailPath;
  final DateTime createdAt;
  final String localPath;

  const VideoItem({
    required this.id,
    required this.url,
    required this.title,
    required this.platform,
    required this.createdAt,
    required this.localPath,
    this.thumbnailPath,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'url': url,
        'title': title,
        'platform': platform,
        'thumbnailPath': thumbnailPath,
        'createdAt': createdAt.toIso8601String(),
        'localPath': localPath,
      };

  factory VideoItem.fromMap(Map<String, dynamic> map) => VideoItem(
        id: map['id'] as String,
        url: map['url'] as String,
        title: map['title'] as String,
        platform: map['platform'] as String,
        thumbnailPath: map['thumbnailPath'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
        localPath: map['localPath'] as String,
      );
}
