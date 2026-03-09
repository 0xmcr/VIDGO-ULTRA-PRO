import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../models/download_item.dart';
import '../models/video_item.dart';
import 'storage_service.dart';

class DownloaderService {
  DownloaderService._();
  static final DownloaderService instance = DownloaderService._();

  final Dio _dio = Dio();
  final StorageService _storageService = StorageService();
  final Map<String, CancelToken> _cancelTokens = {};
  final _controller = StreamController<List<DownloadItem>>.broadcast();

  List<DownloadItem> _items = [];
  List<DownloadItem> get items => _items;
  Stream<List<DownloadItem>> get updates => _controller.stream;

  void _emit() => _controller.add(List.unmodifiable(_items));

  Future<void> queueDownload({required String url, required String fileName, required String platform}) async {
    final item = DownloadItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      url: url,
      fileName: fileName,
      platform: platform,
      createdAt: DateTime.now(),
    );
    _items = [item, ..._items];
    _emit();
    await startDownload(item.id);
  }

  Future<void> startDownload(String id) async {
    final index = _items.indexWhere((e) => e.id == id);
    if (index == -1) return;
    final current = _items[index];
    final saveDir = await _storageService.videosDirectory();
    final savePath = p.join(saveDir.path, current.fileName);
    final file = File(savePath);

    final downloaded = await file.exists() ? await file.length() : 0;
    final token = CancelToken();
    _cancelTokens[id] = token;

    var lastBytes = downloaded;
    var lastTime = DateTime.now();

    _items[index] = current.copyWith(
      status: DownloadStatus.downloading,
      savePath: savePath,
      downloadedBytes: downloaded,
    );
    _emit();

    try {
      await _dio.download(
        current.url,
        savePath,
        cancelToken: token,
        options: Options(headers: downloaded > 0 ? {'range': 'bytes=$downloaded-'} : {}),
        deleteOnError: false,
        onReceiveProgress: (received, total) {
          final now = DateTime.now();
          final elapsed = now.difference(lastTime).inMilliseconds / 1000;
          final speed = elapsed > 0 ? (received - lastBytes) / elapsed : 0.0;
          lastBytes = received;
          lastTime = now;

          final i = _items.indexWhere((e) => e.id == id);
          if (i == -1) return;
          final totalWithOffset = total > 0 ? total + downloaded : 0;
          final downloadedTotal = received + downloaded;
          _items[i] = _items[i].copyWith(
            progress: totalWithOffset > 0 ? downloadedTotal / totalWithOffset : 0,
            downloadedBytes: downloadedTotal,
            totalBytes: totalWithOffset,
            speedBytesPerSec: speed,
          );
          _emit();
        },
      );

      final i = _items.indexWhere((e) => e.id == id);
      if (i == -1) return;
      final thumb = await _storageService.generateThumbnail(savePath);
      final video = VideoItem(
        id: id,
        url: _items[i].url,
        title: p.basename(savePath),
        platform: _items[i].platform,
        createdAt: DateTime.now(),
        localPath: savePath,
        thumbnailPath: thumb,
      );
      await _storageService.saveVideo(video);

      _items[i] = _items[i].copyWith(
        status: DownloadStatus.completed,
        progress: 1,
      );
      _emit();
    } on DioException catch (e) {
      final i = _items.indexWhere((entry) => entry.id == id);
      if (i == -1) return;
      final canceled = CancelToken.isCancel(e);
      _items[i] = _items[i].copyWith(
        status: canceled ? DownloadStatus.paused : DownloadStatus.failed,
        error: canceled ? null : e.message,
      );
      _emit();
    }
  }

  void pauseDownload(String id) {
    _cancelTokens[id]?.cancel('paused');
  }

  Future<void> resumeDownload(String id) async => startDownload(id);

  Future<void> cancelDownload(String id) async {
    _cancelTokens[id]?.cancel('canceled');
    final i = _items.indexWhere((e) => e.id == id);
    if (i == -1) return;
    final path = _items[i].savePath;
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
    _items[i] = _items[i].copyWith(status: DownloadStatus.canceled);
    _emit();
  }

  void dispose() {
    _controller.close();
  }
}
