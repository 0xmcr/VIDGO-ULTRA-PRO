import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../models/video_item.dart';

class StorageService {
  static const _savedVideosKey = 'saved_videos';

  Future<Directory> videosDirectory() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'downloads'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<List<VideoItem>> getSavedVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_savedVideosKey) ?? [];
    return jsonList
        .map((j) => VideoItem.fromMap(jsonDecode(j) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveVideo(VideoItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getSavedVideos();
    final updated = [item, ...items.where((e) => e.id != item.id)]
        .map((e) => jsonEncode(e.toMap()))
        .toList();
    await prefs.setStringList(_savedVideosKey, updated);
  }

  Future<void> deleteVideo(VideoItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getSavedVideos();
    final updated = items.where((e) => e.id != item.id).toList();
    await prefs.setStringList(
      _savedVideosKey,
      updated.map((e) => jsonEncode(e.toMap())).toList(),
    );
    final file = File(item.localPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<String?> generateThumbnail(String videoPath) async {
    return VideoThumbnail.thumbnailFile(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 720,
      quality: 85,
    );
  }
}
