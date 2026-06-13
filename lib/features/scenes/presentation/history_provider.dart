import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:germany/core/storage/scene_cache.dart';
import 'package:germany/core/utils/error_utils.dart';
import 'package:germany/core/utils/logger.dart';
import 'package:germany/features/home/domain/entity/home_stats_entity.dart';

import '../data/services/scene_service.dart';

class SceneHistoryNotifier extends AsyncNotifier<List<SceneEntity>> {
  @override
  Future<List<SceneEntity>> build() async {
    return _fetchScenes();
  }

  Future<List<SceneEntity>> _fetchScenes() async {
    final service = ref.read(sceneServiceProvider);
    final scenes = await service.fetchScenes();
    for (final scene in scenes) {
      try {
        await SceneCache.saveScene(scene);
      } catch (e) {
        AppLogger.w('[SceneHistory] Failed to cache scene ${scene.id}: $e');
      }
    }
    return scenes.map((scene) => scene.toEntity()).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      state = AsyncData(await _fetchScenes());
    } catch (e, stack) {
      state = AsyncError(
        ErrorUtils.extractMessage(
          e,
          fallback: 'Failed to fetch scene history. Please try again.',
        ),
        stack,
      );
    }
  }

  Future<void> deleteScene(String id) async {
    final current = state.value ?? const <SceneEntity>[];
    state = AsyncData(current.where((scene) => scene.id != id).toList());

    try {
      await ref.read(sceneServiceProvider).deleteScene(id);
      await SceneCache.removeScene(id);
    } catch (e, stack) {
      state = AsyncData(current);
      Error.throwWithStackTrace(
        ErrorUtils.extractMessage(
          e,
          fallback: 'Failed to delete scene. Please try again.',
        ),
        stack,
      );
    }
  }
}

final sceneHistoryProvider =
    AsyncNotifierProvider<SceneHistoryNotifier, List<SceneEntity>>(
      SceneHistoryNotifier.new,
    );
