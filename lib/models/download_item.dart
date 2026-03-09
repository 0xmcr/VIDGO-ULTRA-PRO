enum DownloadStatus { queued, downloading, paused, completed, failed, canceled }

class DownloadItem {
  DownloadItem({
    required this.id,
    required this.url,
    required this.fileName,
    required this.platform,
    this.progress = 0,
    this.speedMbps = 0,
    this.eta = Duration.zero,
    this.status = DownloadStatus.queued,
    this.savePath = '',
    this.error,
  });

  final String id;
  final String url;
  final String fileName;
  final String platform;
  double progress;
  double speedMbps;
  Duration eta;
  DownloadStatus status;
  String savePath;
  String? error;
}
