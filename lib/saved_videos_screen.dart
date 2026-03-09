import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'models/video_item.dart';
import 'services/storage_service.dart';
import 'video_player_screen.dart';

class SavedVideosScreen extends StatefulWidget {
  const SavedVideosScreen({super.key});

  @override
  State<SavedVideosScreen> createState() => _SavedVideosScreenState();
}

class _SavedVideosScreenState extends State<SavedVideosScreen> {
  final _storage = StorageService();
  String _filter = 'all';
  bool _grid = true;

  Future<List<VideoItem>> _load() async {
    final list = await _storage.getSavedVideos();
    if (_filter == 'all') return list;
    return list.where((e) => e.platform == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Videos'),
        actions: [
          IconButton(onPressed: () => setState(() => _grid = !_grid), icon: Icon(_grid ? Icons.view_list : Icons.grid_view)),
          PopupMenuButton<String>(
            onSelected: (v) => setState(() => _filter = v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'all', child: Text('All')),
              PopupMenuItem(value: 'instagram', child: Text('Instagram')),
              PopupMenuItem(value: 'tiktok', child: Text('TikTok')),
              PopupMenuItem(value: 'facebook', child: Text('Facebook')),
              PopupMenuItem(value: 'twitter', child: Text('Twitter/X')),
              PopupMenuItem(value: 'whatsapp', child: Text('WhatsApp')),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<VideoItem>>(
        future: _load(),
        builder: (_, snapshot) {
          final items = snapshot.data ?? [];
          if (items.isEmpty) return const Center(child: Text('No saved videos.'));
          if (_grid) {
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: .85, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemCount: items.length,
              itemBuilder: (_, i) => _VideoTile(item: items[i], onChanged: () => setState(() {}), storage: _storage),
            );
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) => _VideoTile(item: items[i], onChanged: () => setState(() {}), storage: _storage),
          );
        },
      ),
    );
  }
}

class _VideoTile extends StatelessWidget {
  final VideoItem item;
  final VoidCallback onChanged;
  final StorageService storage;

  const _VideoTile({required this.item, required this.onChanged, required this.storage});

  @override
  Widget build(BuildContext context) {
    final thumb = item.thumbnailPath != null ? File(item.thumbnailPath!) : null;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPlayerScreen(video: item))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: thumb != null && thumb.existsSync()
                  ? Image.file(thumb, width: double.infinity, fit: BoxFit.cover)
                  : Container(color: Colors.black12, child: const Center(child: Icon(Icons.play_circle, size: 48))),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: () => Share.shareXFiles([XFile(item.localPath)]), icon: const Icon(Icons.share)),
                IconButton(
                  onPressed: () async {
                    await storage.deleteVideo(item);
                    onChanged();
                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
