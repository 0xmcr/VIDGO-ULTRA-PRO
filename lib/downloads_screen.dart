import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidgo_ultra_pro/models/download_item.dart';
import 'package:vidgo_ultra_pro/models/video_item.dart';
import 'package:vidgo_ultra_pro/services/downloader_service.dart';
import 'package:vidgo_ultra_pro/services/storage_service.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({
    super.key,
    this.queuedUrl,
    this.queuedPlatform,
    this.suggestedName,
  });

  final String? queuedUrl;
  final String? queuedPlatform;
  final String? suggestedName;

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  final DownloaderService _downloader = DownloaderService();
  final StorageService _storage = StorageService();
  final List<DownloadItem> _downloads = [];

  @override
  void initState() {
    super.initState();
    if (widget.queuedUrl != null) {
      _enqueue(widget.queuedUrl!, widget.queuedPlatform ?? 'Other', widget.suggestedName ?? 'video.mp4');
    }
  }

  Future<void> _runDownload(DownloadItem item) async {
    await _downloader.startDownload(item, (updated) async {
      if (!mounted) return;
      setState(() {});
      if (updated.status == DownloadStatus.completed) {
        await _storage.saveVideo(VideoItem(
          id: updated.id,
          sourceUrl: updated.url,
          localPath: updated.savePath,
          platform: updated.platform,
          title: updated.fileName,
          thumbnailUrl: '',
          createdAt: DateTime.now(),
        ));
      }
      if (updated.status == DownloadStatus.failed) {
        if (!mounted) return;
        showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Download Error'),
            content: Text(updated.error ?? 'Unable to download this video.'),
          ),
        );
      }
    });
  }

  Future<void> _enqueue(String url, String platform, String fileName) async {
    final item = DownloadItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      url: url,
      fileName: fileName,
      platform: platform,
    );
    setState(() => _downloads.insert(0, item));
    await _runDownload(item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Download Manager')),
      body: _downloads.isEmpty
          ? const Center(child: Text('No downloads yet. Use browser to detect videos.'))
          : ListView.builder(
              itemCount: _downloads.length,
              itemBuilder: (context, i) {
                final d = _downloads[i];
                return ListTile(
                  title: Text(d.fileName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${d.platform} • ${describeEnum(d.status)}'),
                      LinearProgressIndicator(value: d.progress),
                      Text('Speed: ${d.speedMbps.toStringAsFixed(2)} Mbps • ETA: ${DateFormat.ms().format(DateTime(0).add(d.eta))}'),
                    ],
                  ),
                  trailing: Wrap(
                    spacing: 2,
                    children: [
                      if (d.status == DownloadStatus.downloading)
                        IconButton(
                          onPressed: () => _downloader.pause(d.id),
                          icon: const Icon(Icons.pause),
                        ),
                      if (d.status == DownloadStatus.paused)
                        IconButton(
                          onPressed: () => _runDownload(d),
                          icon: const Icon(Icons.play_arrow),
                        ),
                      IconButton(
                        onPressed: () => _downloader.cancel(d.id),
                        icon: const Icon(Icons.cancel),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openManualDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openManualDialog(BuildContext context) {
    final url = TextEditingController();
    final name = TextEditingController(text: 'manual_${DateTime.now().millisecondsSinceEpoch}.mp4');
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Download'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: url, decoration: const InputDecoration(labelText: 'Video URL')),
            TextField(controller: name, decoration: const InputDecoration(labelText: 'File name')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _enqueue(url.text.trim(), 'Manual', name.text.trim());
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }
}
