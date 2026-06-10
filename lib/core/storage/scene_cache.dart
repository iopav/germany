import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/home/data/models/home_models.dart';

class SceneCache {
  SceneCache._();

  static const String _scenesKey = 'cached_scenes_v1';

  static Future<void> saveScene(SceneResponseModel scene) async {
    final prefs = await SharedPreferences.getInstance();
    final scenes = await _readScenes(prefs);
    final sceneId = scene.id.trim();

    if (sceneId.isEmpty) {
      return;
    }

    scenes.removeWhere((item) => _sceneIdOf(item) == sceneId);
    scenes.add(Map<String, dynamic>.from(scene.raw));

    await prefs.setStringList(
      _scenesKey,
      scenes.map(jsonEncode).toList(),
    );
  }

  static Future<SceneResponseModel?> getScene(String sceneId) async {
    final prefs = await SharedPreferences.getInstance();
    final scenes = await _readScenes(prefs);

    for (final scene in scenes) {
      if (_sceneIdOf(scene) == sceneId) {
        return SceneResponseModel.fromJson(scene);
      }
    }

    return null;
  }

  static Future<List<SceneResponseModel>> getScenes() async {
    final prefs = await SharedPreferences.getInstance();
    final scenes = await _readScenes(prefs);
    return scenes.map(SceneResponseModel.fromJson).toList();
  }

  static Future<bool> hasScene(String sceneId) async {
    return (await getScene(sceneId)) != null;
  }

  static Future<void> removeScene(String sceneId) async {
    final prefs = await SharedPreferences.getInstance();
    final scenes = await _readScenes(prefs);
    final updatedScenes = scenes.where((scene) => _sceneIdOf(scene) != sceneId).toList();

    await prefs.setStringList(
      _scenesKey,
      updatedScenes.map(jsonEncode).toList(),
    );
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scenesKey);
  }

  static Future<List<Map<String, dynamic>>> _readScenes(
    SharedPreferences prefs,
  ) async {
    final rawScenes = prefs.getStringList(_scenesKey) ?? const <String>[];
    return rawScenes
        .map((item) {
          try {
            final decoded = jsonDecode(item);
            if (decoded is Map<String, dynamic>) {
              return Map<String, dynamic>.from(decoded);
            }
            if (decoded is Map) {
              return Map<String, dynamic>.from(decoded);
            }
          } catch (_) {}
          return <String, dynamic>{};
        })
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static String _sceneIdOf(Map<String, dynamic> scene) {
    final id = scene['id']?.toString() ?? scene['scene_id']?.toString() ?? '';
    return id.trim();
  }
}