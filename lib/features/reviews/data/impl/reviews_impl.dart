import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:germany/core/storage/scene_cache.dart';
import 'package:germany/core/utils/error_utils.dart';
import 'package:germany/core/utils/logger.dart';

import '../../../home/data/models/home_models.dart';
import '../../../home/domain/entity/home_stats_entity.dart';
import '../../domain/entity/reviews_entity.dart';
import '../../domain/interface/reviews_interface.dart';
import '../models/reviews_model.dart';
import '../services/reviews_service.dart';

class ReviewsImpl implements ReviewsInterface {
  final ReviewsService _reviewsService;

  ReviewsImpl(this._reviewsService);

  @override
  Future<List<ReviewEntity>> fetchReviews() async {
    try {
      final result = await _reviewsService.fetchReviews();
      return result.map((item) => item.toEntity()).toList();
    } on DioException catch (e) {
      final message = ErrorUtils.extractDioMessage(e, operation: 'fetch due reviews');
      AppLogger.w('[ReviewsImpl] Failed to fetch due reviews: $message');
      throw Exception(message);
    } catch (e) {
      AppLogger.w('[ReviewsImpl] Failed to fetch due reviews: $e');
      throw Exception('Failed to fetch due reviews. Please try again.');
    }
  }

  @override
  Future<void> submitReview(ReviewPostModel reviewPost) async {
    try {
      await _reviewsService.submitReview(reviewPost);
    } on DioException catch (e) {
      final message = ErrorUtils.extractDioMessage(e, operation: 'submit review');
      AppLogger.w('[ReviewsImpl] Failed to submit review: $message');
      throw Exception(message);
    } catch (e) {
      AppLogger.w('[ReviewsImpl] Failed to submit review: $e');
      throw Exception('Failed to submit the review. Please try again.');
    }
  }

  @override
  Future<List<ReviewStateModel>> fetchReviewStats() async {
    try {
      return await _reviewsService.fetchReviewStats();
    } on DioException catch (e) {
      final message = ErrorUtils.extractDioMessage(e, operation: 'fetch review stats');
      AppLogger.w('[ReviewsImpl] Failed to fetch review stats: $message');
      throw Exception(message);
    } catch (e) {
      AppLogger.w('[ReviewsImpl] Failed to fetch review stats: $e');
      throw Exception('Failed to fetch review stats. Please try again.');
    }
  }

  @override
  Future<SceneEntity> fetchSceneForReview(String sceneId) async {
    try {
      final cachedScene = await SceneCache.getScene(sceneId);
      if (cachedScene != null) {
        return cachedScene.toEntity();
      }

      final model = await _reviewsService.fetchSceneById(sceneId);
      await _cacheScene(model);
      return model.toEntity();
    } on DioException catch (e) {
      final message = ErrorUtils.extractDioMessage(e, operation: 'fetch review scene');
      AppLogger.w('[ReviewsImpl] Failed to fetch review scene: $message');
      throw Exception(message);
    } catch (e) {
      AppLogger.w('[ReviewsImpl] Failed to fetch review scene: $e');
      throw Exception('Failed to fetch the review scene. Please try again.');
    }
  }

  @override
  int ratingFromOutcome(String outcome) {
    final key = outcome.trim().toLowerCase();
    switch (key) {
      case 'again':
      case 'forgot':
        return 1;
      case 'hard':
        return 2;
      case 'good':
        return 3;
      case 'easy':
      case 'mastered':
        return 4;
      default:
        final parsed = int.tryParse(key);
        if (parsed != null && parsed >= 1 && parsed <= 4) {
          return parsed;
        }
        return 3;
    }
  }

  Future<void> _cacheScene(SceneResponseModel scene) async {
    try {
      await SceneCache.saveScene(scene);
    } catch (e) {
      AppLogger.w('[ReviewsImpl] Failed to cache review scene: $e');
    }
  }
}

final reviewsInterfaceProvider = Provider<ReviewsInterface>((ref) {
  final service = ref.read(reviewsServiceProvider);
  return ReviewsImpl(service);
});
