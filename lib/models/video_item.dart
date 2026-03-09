class VideoItem {
  VideoItem({
    required this.id,
    required this.sourceUrl,
    required this.localPath,
    required this.platform,
    required this.title,
    required this.thumbnailUrl,
    required this.createdAt,
  });

  final String id;
  final String sourceUrl;
  final String localPath;
  final String platform;
  final String title;
  final String thumbnailUrl;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceUrl': sourceUrl,
        'localPath': localPath,
        'platform': platform,
        'title': title,
        'thumbnailUrl': thumbnailUrl,
        'createdAt': createdAt.toIso8601String(),
      };

  factory VideoItem.fromJson(Map<String, dynamic> json) => VideoItem(
        id: json['id'] as String,
        sourceUrl: json['sourceUrl'] as String,
        localPath: json['localPath'] as String,
        platform: json['platform'] as String,
        title: json['title'] as String,
        thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
