import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:vidgo_ultra_pro/models/download_item.dart';

class DownloaderService {
  final Dio _dio = Dio();
  final Map<String, CancelToken> _tokens = {};

  Future<String> _outputPath(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory(p.join(dir.path, 'downloads'));
    if (!downloadDir.existsSync()) {
      downloadDir.createSync(recursive: true);
    }
    return p.join(downloadDir.path, fileName);
  }

  Future<void> startDownload(
    DownloadItem item,
    void Function(DownloadItem) onUpdate,
  ) async {
    final savePath = await _outputPath(item.fileName);
    final token = CancelToken();
    _tokens[item.id] = token;

    item.status = DownloadStatus.downloading;
    item.savePath = savePath;
    onUpdate(item);

    final stopwatch = Stopwatch()..start();
    int lastBytes = 0;

    try {
      await _dio.download(
        item.url,
        savePath,
        cancelToken: token,
        onReceiveProgress: (received, total) {
          if (total <= 0) return;
          item.progress = received / total;
          final elapsed = stopwatch.elapsedMilliseconds / 1000;
          if (elapsed > 0) {
            final delta = received - lastBytes;
            item.speedMbps = (delta * 8 / 1000000) / elapsed;
            final remainingBytes = total - received;
            final secondsLeft =
                item.speedMbps == 0 ? 0 : (remainingBytes * 8 / 1000000) / item.speedMbps;
            item.eta = Duration(seconds: secondsLeft.round());
          }
          lastBytes = received;
          stopwatch
            ..reset()
            ..start();
          onUpdate(item);
        },
      );
      item.status = DownloadStatus.completed;
      item.progress = 1;
      onUpdate(item);
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        final reason = e.error?.toString() ?? '';
        item.status = reason.contains('paused') ? DownloadStatus.paused : DownloadStatus.canceled;
      } else {
        item.status = DownloadStatus.failed;
        item.error = e.message;
      }
      onUpdate(item);
    }
  }

  void pause(String id) {
    _tokens[id]?.cancel('User paused');
  }

  void cancel(String id) {
    _tokens[id]?.cancel('User canceled');
  }
}
