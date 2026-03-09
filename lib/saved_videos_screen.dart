import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vidgo_ultra_pro/models/video_item.dart';
import 'package:vidgo_ultra_pro/services/storage_service.dart';
import 'package:vidgo_ultra_pro/video_player_screen.dart';

class SavedVideosScreen extends StatefulWidget {
  const SavedVideosScreen({super.key});

  @override
  State<SavedVideosScreen> createState() => _SavedVideosScreenState();
}

class _SavedVideosScreenState extends State<SavedVideosScreen> {
  final StorageService _storage = StorageService();
  List<VideoItem> _videos = [];
  String _platform = 'All';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final videos = await _storage.getSavedVideos();
    if (mounted) setState(() => _videos = videos.reversed.toList());
  }

  @override
  Widget build(BuildContext context) {
    final platforms = {'All', ..._videos.map((e) => e.platform)};
    final filtered = _platform == 'All' ? _videos : _videos.where((v) => v.platform == _platform).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Videos'),
        actions: [
          DropdownButton<String>(
            value: _platform,
            items: platforms.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            onChanged: (value) => setState(() => _platform = value ?? 'All'),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: filtered.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.78,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, i) {
          final video = filtered[i];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => VideoPlayerScreen(videoPath: video.localPath, title: video.title)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: Colors.black12,
                      child: const Icon(Icons.video_file, size: 50),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(video.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(onPressed: () => Share.shareXFiles([XFile(video.localPath)]), icon: const Icon(Icons.share)),
                      IconButton(
                        onPressed: () async {
                          File(video.localPath).deleteSync(recursive: false);
                          await _storage.deleteVideo(video.id);
                          _load();
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
