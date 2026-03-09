import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidgo_ultra_pro/models/video_item.dart';

class StorageService {
  static const _acceptedTermsKey = 'accepted_terms';
  static const _tutorialSeenKey = 'tutorial_seen';
  static const _videosKey = 'saved_videos';

  Future<bool> getAcceptedTerms() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_acceptedTermsKey) ?? false;
  }

  Future<void> setAcceptedTerms(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_acceptedTermsKey, value);
  }

  Future<bool> getTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tutorialSeenKey) ?? false;
  }

  Future<void> setTutorialSeen(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialSeenKey, value);
  }

  Future<List<VideoItem>> getSavedVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_videosKey) ?? <String>[];
    return raw
        .map((e) => VideoItem.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveVideo(VideoItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final videos = await getSavedVideos();
    videos.removeWhere((v) => v.id == item.id);
    videos.add(item);
    await prefs.setStringList(
      _videosKey,
      videos.map((v) => jsonEncode(v.toJson())).toList(),
    );
  }

  Future<void> deleteVideo(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final videos = await getSavedVideos();
    videos.removeWhere((v) => v.id == id);
    await prefs.setStringList(
      _videosKey,
      videos.map((v) => jsonEncode(v.toJson())).toList(),
    );
  }
}
