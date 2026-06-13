import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:germany/core/utils/error_utils.dart';
import 'package:germany/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/reviews_model.dart';
import '../data/impl/reviews_impl.dart';
import '../domain/entity/reviews_entity.dart';
import '../../home/domain/entity/home_stats_entity.dart';

const String _reviewQueueKey = 'review_session_queue_v1';
const String _reviewIndexKey = 'review_session_index_v1';

class ReviewsState {
  final List<ReviewEntity> queue;
  final int currentIndex;
  final Map<String, SceneEntity> scenesById;
  final bool isLoadingScene;
  final bool isSubmitting;
  final bool sessionCompleted;
  final String? errorMessage;
  final List<int> submittedRatings;

  const ReviewsState({
    required this.queue,
    required this.currentIndex,
    required this.scenesById,
    this.isLoadingScene = false,
    this.isSubmitting = false,
    this.sessionCompleted = false,
    this.errorMessage,
    this.submittedRatings = const <int>[],
  });

  ReviewEntity? get currentReview {
    if (queue.isEmpty || currentIndex < 0 || currentIndex >= queue.length) {
      return null;
    }
    return queue[currentIndex];
  }

  SceneEntity? get currentScene {
    final review = currentReview;
    if (review == null) {
      return null;
    }
    return scenesById[review.sceneId];
  }

  int get totalCount => queue.length;

  int get completedCount => currentIndex.clamp(0, queue.length);

  int get remainingCount => (totalCount - completedCount).clamp(0, totalCount);

  double get progress {
    if (totalCount == 0) {
      return 0;
    }
    return completedCount / totalCount;
  }

  bool get isEmptySession => queue.isEmpty;

  int get masteredCount =>
      submittedRatings.where((rating) => rating >= 3).length;

  int get forgottenCount =>
      submittedRatings.where((rating) => rating <= 2).length;

  double get accuracy {
    if (submittedRatings.isEmpty) {
      return 0;
    }
    return masteredCount / submittedRatings.length;
  }

  ReviewsState copyWith({
    List<ReviewEntity>? queue,
    int? currentIndex,
    Map<String, SceneEntity>? scenesById,
    bool? isLoadingScene,
    bool? isSubmitting,
    bool? sessionCompleted,
    String? errorMessage,
    List<int>? submittedRatings,
    bool clearError = false,
  }) {
    return ReviewsState(
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      scenesById: scenesById ?? this.scenesById,
      isLoadingScene: isLoadingScene ?? this.isLoadingScene,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      sessionCompleted: sessionCompleted ?? this.sessionCompleted,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      submittedRatings: submittedRatings ?? this.submittedRatings,
    );
  }
}

class ReviewsNotifier extends AsyncNotifier<ReviewsState> {
  final Set<String> _loadingSceneIds = <String>{};

  @override
  Future<ReviewsState> build() async {
    // 进入 Review 页后，UI 会 watch reviewsProvider。
    // AsyncNotifier 第一次被 watch 时会自动执行 build()，这里就是“自动 fetch review 队列”的入口。
    return _restoreOrFetchSession();
  }

  Future<ReviewsState> _restoreOrFetchSession({
    bool forceRefresh = false,
  }) async {
    // 默认优先恢复本地 session，避免用户切走再回来时重新向后端要同一批卡片。
    if (!forceRefresh) {
      final cached = await _ReviewSessionCache.load();
      if (cached != null && cached.queue.isNotEmpty) {
        final normalizedIndex = cached.currentIndex.clamp(
          0,
          cached.queue.length,
        );
        if (normalizedIndex < cached.queue.length) {
          final restored = ReviewsState(
            queue: cached.queue,
            currentIndex: normalizedIndex,
            scenesById: const <String, SceneEntity>{},
          );
          return restored;
        }

        await _ReviewSessionCache.clear();
      }
    }

    // 没有可用缓存，或者用户手动 refresh 时，才会真正调用后端 /cardsDue。
    // 首次进入 Review 后自动拉取 review queue 的网络请求位置。
    final reviewsInterface = ref.read(reviewsInterfaceProvider);
    final queue = await reviewsInterface.fetchReviews();
    final initial = ReviewsState(
      queue: queue,
      currentIndex: 0,
      scenesById: const <String, SceneEntity>{},
    );
    await _ReviewSessionCache.save(queue: queue, currentIndex: 0);
    return initial;
  }

  Future<void> refresh() async {
    // 手动刷新会跳过缓存，强制重新 fetchReviews()。
    state = const AsyncLoading();
    try {
      state = AsyncData(await _restoreOrFetchSession(forceRefresh: true));
      await ensureCurrentSceneLoaded();
    } catch (e, stack) {
      state = AsyncError(
        ErrorUtils.extractMessage(
          e,
          fallback: 'Failed to fetch due reviews. Please try again.',
        ),
        stack,
      );
    }
  }

  Future<void> ensureCurrentSceneLoaded() async {
    final current = state.value;
    final review = current?.currentReview;
    if (current == null || review == null) {
      return;
    }

    if (current.scenesById.containsKey(review.sceneId)) {
      return;
    }

    // build/initState 都可能请求加载当前 scene；用 sceneId 做并发保护，避免同一个 scene 重复请求。
    if (_loadingSceneIds.contains(review.sceneId)) {
      return;
    }

    _loadingSceneIds.add(review.sceneId);
    state = AsyncData(current.copyWith(isLoadingScene: true, clearError: true));

    try {
      final reviewsInterface = ref.read(reviewsInterfaceProvider);
      final scene = await reviewsInterface.fetchSceneForReview(review.sceneId);
      final updatedScenes = Map<String, SceneEntity>.from(current.scenesById)
        ..[review.sceneId] = scene;
      state = AsyncData(
        current.copyWith(
          scenesById: updatedScenes,
          isLoadingScene: false,
          clearError: true,
        ),
      );
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          isLoadingScene: false,
          errorMessage: ErrorUtils.extractMessage(
            e,
            fallback: 'Failed to fetch the review scene. Please try again.',
          ),
        ),
      );
    } finally {
      _loadingSceneIds.remove(review.sceneId);
    }
  }

  Future<List<SceneEntity>> prefetchUpcomingScenes({int count = 3}) async {
    final current = state.value;
    if (current == null || current.queue.isEmpty || count <= 0) {
      return const <SceneEntity>[];
    }

    final reviewsInterface = ref.read(reviewsInterfaceProvider);
    final updatedScenes = Map<String, SceneEntity>.from(current.scenesById);
    final prefetchedScenes = <SceneEntity>[];
    final endIndex = (current.currentIndex + count)
        .clamp(0, current.queue.length)
        .toInt();

    for (var index = current.currentIndex; index < endIndex; index++) {
      final review = current.queue[index];
      final cachedScene = updatedScenes[review.sceneId];
      if (cachedScene != null) {
        prefetchedScenes.add(cachedScene);
        continue;
      }

      if (_loadingSceneIds.contains(review.sceneId)) {
        continue;
      }

      _loadingSceneIds.add(review.sceneId);
      try {
        final scene = await reviewsInterface.fetchSceneForReview(
          review.sceneId,
        );
        updatedScenes[review.sceneId] = scene;
        prefetchedScenes.add(scene);
      } catch (e) {
        AppLogger.w(
          '[ReviewsProvider] prefetch scene failed scene=${review.sceneId}: $e',
        );
      } finally {
        _loadingSceneIds.remove(review.sceneId);
      }
    }

    final latest = state.value;
    if (latest != null) {
      state = AsyncData(
        latest.copyWith(
          scenesById: {...latest.scenesById, ...updatedScenes},
          clearError: true,
        ),
      );
    }

    return prefetchedScenes;
  }

  Future<void> submitTypedAnswer(String typedAnswer) async {
    final current = state.value;
    final review = current?.currentReview;
    if (current == null || review == null) {
      return;
    }

    final normalizedInput = _normalizeText(typedAnswer);
    final normalizedAnswer = _normalizeText(review.lemma);
    final rating = normalizedInput.isEmpty
        ? 1
        : normalizedInput == normalizedAnswer
        ? 3
        : 2;

    await submitRating(rating);
  }

  Future<void> submitRating(int rating) async {
    final current = state.value;
    final review = current?.currentReview;
    if (current == null || review == null) {
      return;
    }

    state = AsyncData(current.copyWith(isSubmitting: true, clearError: true));

    try {
      final reviewsInterface = ref.read(reviewsInterfaceProvider);
      AppLogger.i(
        '[ReviewsProvider] submit review card=${review.id}, rating=$rating',
      );
      debugPrint(
        '[ReviewsProvider] submit review card=${review.id}, rating=$rating',
      );
      await reviewsInterface.submitReview(
        ReviewPostModel(cardId: review.id, rating: rating),
      );
      AppLogger.i(
        '[ReviewsProvider] submit review success card=${review.id}, rating=$rating',
      );
      debugPrint(
        '[ReviewsProvider] submit review success card=${review.id}, rating=$rating',
      );

      final shouldReviewAgain = rating <= 2;
      final updatedQueue = shouldReviewAgain
          ? [...current.queue, review]
          : current.queue;
      final nextIndex = current.currentIndex + 1;
      final finished = nextIndex >= updatedQueue.length;

      final updated = current.copyWith(
        queue: updatedQueue,
        currentIndex: nextIndex.clamp(0, updatedQueue.length),
        isSubmitting: false,
        sessionCompleted: finished,
        submittedRatings: [...current.submittedRatings, rating],
        clearError: true,
      );
      state = AsyncData(updated);

      if (finished) {
        await _ReviewSessionCache.clear();
      } else {
        await _ReviewSessionCache.save(
          queue: updated.queue,
          currentIndex: updated.currentIndex,
        );
      }

      await ensureCurrentSceneLoaded();
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          isSubmitting: false,
          errorMessage: ErrorUtils.extractMessage(
            e,
            fallback: 'Failed to submit the review. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> resetSession() async {
    await _ReviewSessionCache.clear();
    state = AsyncData(
      ReviewsState(
        queue: const <ReviewEntity>[],
        currentIndex: 0,
        scenesById: const <String, SceneEntity>{},
      ),
    );
  }

  String _normalizeText(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }
}

final reviewsProvider = AsyncNotifierProvider<ReviewsNotifier, ReviewsState>(
  ReviewsNotifier.new,
);

class ReviewCardsNotifier extends AsyncNotifier<List<ReviewEntity>> {
  @override
  Future<List<ReviewEntity>> build() async {
    return _fetchCards();
  }

  Future<List<ReviewEntity>> _fetchCards() async {
    final reviewsInterface = ref.read(reviewsInterfaceProvider);
    return reviewsInterface.fetchCards();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      state = AsyncData(await _fetchCards());
    } catch (e, stack) {
      state = AsyncError(
        ErrorUtils.extractMessage(
          e,
          fallback: 'Failed to fetch cards. Please try again.',
        ),
        stack,
      );
    }
  }
}

final reviewCardsProvider =
    AsyncNotifierProvider<ReviewCardsNotifier, List<ReviewEntity>>(
      ReviewCardsNotifier.new,
    );

class _ReviewSessionSnapshot {
  final List<ReviewEntity> queue;
  final int currentIndex;

  const _ReviewSessionSnapshot({
    required this.queue,
    required this.currentIndex,
  });
}

class _ReviewSessionCache {
  static Future<void> save({
    required List<ReviewEntity> queue,
    required int currentIndex,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _reviewQueueKey,
      queue.map((item) => item.toJson()).toList(),
    );
    await prefs.setInt(_reviewIndexKey, currentIndex);
  }

  static Future<_ReviewSessionSnapshot?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawQueue = prefs.getStringList(_reviewQueueKey) ?? const <String>[];
    if (rawQueue.isEmpty) {
      return null;
    }

    final queue = rawQueue
        .map((item) {
          try {
            return ReviewEntity.fromJson(item);
          } catch (_) {
            return null;
          }
        })
        .whereType<ReviewEntity>()
        .toList();

    if (queue.isEmpty) {
      return null;
    }

    final currentIndex = prefs.getInt(_reviewIndexKey) ?? 0;
    return _ReviewSessionSnapshot(queue: queue, currentIndex: currentIndex);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_reviewQueueKey);
    await prefs.remove(_reviewIndexKey);
  }
}
