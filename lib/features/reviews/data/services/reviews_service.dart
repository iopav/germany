import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:germany/core/constants/api_constants.dart';
import 'package:germany/core/networks/dio_client.dart';

import '../../../home/data/models/home_models.dart';
import '../models/reviews_model.dart';

class ReviewsService {
  final Dio _dio;

  ReviewsService(this._dio);

  Future<List<ReviewResponseModel>> fetchReviews() async {
    final response = await _dio.get(ApiConstants.cardsDue);
    final responseJson = _readList(response.data);

    return responseJson
        .map(
          (json) => ReviewResponseModel.fromMap(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<ReviewResponseModel>> fetchCards() async {
    final response = await _dio.get(ApiConstants.cardsList);
    final responseJson = _readList(response.data);

    return responseJson
        .map(
          (json) => ReviewResponseModel.fromMap(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<SceneResponseModel> fetchSceneById(String sceneId) async {
    final response = await _dio.get(ApiConstants.sceneDetail(sceneId));
    final responseJson = response.data is Map<String, dynamic>
        ? Map<String, dynamic>.from(response.data as Map)
        : <String, dynamic>{};

    return SceneResponseModel.fromJson(responseJson);
  }

  Future<void> submitReview(ReviewPostModel reviewPost) async {
    await _dio.post(ApiConstants.reviewsSubmit, data: reviewPost.toMap());
  }

  Future<List<ReviewStateModel>> fetchReviewStats() async {
    final response = await _dio.get(ApiConstants.reviewsStats);
    final statsJson = _readList(response.data);

    return statsJson
        .map((json) => ReviewStateModel.fromMap(json as Map<String, dynamic>))
        .toList();
  }

  List<dynamic> _readList(dynamic payload) {
    if (payload is List) {
      return payload;
    }

    if (payload is Map) {
      for (final key in const ['data', 'items', 'results', 'cards']) {
        final value = payload[key];
        if (value is List) {
          return value;
        }
        if (value is Map) {
          final nested = _readList(value);
          if (nested.isNotEmpty) {
            return nested;
          }
        }
      }
    }

    throw FormatException('Expected list response, got ${payload.runtimeType}');
  }
}

final reviewsServiceProvider = Provider<ReviewsService>((ref) {
  final dio = ref.read(dioProvider);
  return ReviewsService(dio);
});
