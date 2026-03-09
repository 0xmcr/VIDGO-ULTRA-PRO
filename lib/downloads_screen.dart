import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'models/download_item.dart';
import 'services/downloader_service.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  final _downloader = DownloaderService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Download Manager')),
      body: StreamBuilder<List<DownloadItem>>(
        stream: _downloader.updates,
        initialData: _downloader.items,
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No downloads yet.'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
              final eta = (item.totalBytes > 0 && item.speedBytesPerSec > 0)
                  ? Duration(seconds: ((item.totalBytes - item.downloadedBytes) / item.speedBytesPerSec).round())
                  : null;
              return Card(
                child: ListTile(
                  title: Text(item.fileName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(value: item.progress),
                      Text('${(item.progress * 100).toStringAsFixed(1)}%  •  ${(item.speedBytesPerSec / 1024).toStringAsFixed(1)} KB/s${eta == null ? '' : ' • ETA ${DateFormat('mm:ss').format(DateTime(0).add(eta))}'}'),
                      Text(item.status.name.toUpperCase()),
                    ],
                  ),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(icon: const Icon(Icons.pause), onPressed: () => _downloader.pauseDownload(item.id)),
                      IconButton(icon: const Icon(Icons.play_arrow), onPressed: () => _downloader.resumeDownload(item.id)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => _downloader.cancelDownload(item.id)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
