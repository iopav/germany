import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:germany/core/constants/api_constants.dart';
import 'package:germany/core/networks/dio_client.dart';
import 'package:germany/features/home/data/models/home_models.dart';

class SceneService {
  final Dio _dio;

  SceneService(this._dio);

  Future<List<SceneResponseModel>> fetchScenes() async {
    final response = await _dio.get(ApiConstants.scenesBase);
    final raw = response.data;
    final items = _readSceneItems(raw);

    return items
        .whereType<Map>()
        .map(
          (item) =>
              SceneResponseModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<void> deleteScene(String id) async {
    await _dio.delete(ApiConstants.deleteScene(id));
  }

  List<dynamic> _readSceneItems(dynamic raw) {
    if (raw is List<dynamic>) {
      return raw;
    }

    if (raw is Map) {
      for (final key in ['items', 'item', 'scenes', 'data', 'results']) {
        final value = raw[key];
        if (value is List<dynamic>) {
          return value;
        }
      }
    }

    return const <dynamic>[];
  }
}

final sceneServiceProvider = Provider<SceneService>((ref) {
  final dio = ref.read(dioProvider);
  return SceneService(dio);
});
