enum DownloadStatus { queued, downloading, paused, completed, failed, canceled }

class DownloadItem {
  final String id;
  final String url;
  final String fileName;
  final String platform;
  final DateTime createdAt;
  final double progress;
  final DownloadStatus status;
  final int downloadedBytes;
  final int totalBytes;
  final String? savePath;
  final String? error;
  final double speedBytesPerSec;

  const DownloadItem({
    required this.id,
    required this.url,
    required this.fileName,
    required this.platform,
    required this.createdAt,
    this.progress = 0,
    this.status = DownloadStatus.queued,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.savePath,
    this.error,
    this.speedBytesPerSec = 0,
  });

  DownloadItem copyWith({
    double? progress,
    DownloadStatus? status,
    int? downloadedBytes,
    int? totalBytes,
    String? savePath,
    String? error,
    double? speedBytesPerSec,
  }) {
    return DownloadItem(
      id: id,
      url: url,
      fileName: fileName,
      platform: platform,
      createdAt: createdAt,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      savePath: savePath ?? this.savePath,
      error: error,
      speedBytesPerSec: speedBytesPerSec ?? this.speedBytesPerSec,
    );
  }
}
