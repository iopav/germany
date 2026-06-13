import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:germany/core/constants/api_constants.dart';
import 'package:germany/core/networks/dio_client.dart';

import '../models/home_models.dart';

class HomeService {
  final Dio _dio;

  HomeService(this._dio);

  Future<SceneResponseModel> createSceneFromImage({
    required XFile image,
  }) async {
    final imageBytes = await image.readAsBytes();

    final formData = FormData.fromMap({
      ApiConstants.keyFile: MultipartFile.fromBytes(
        imageBytes,
        filename: image.name,
      ),
    });

    final response = await _dio.post(
      ApiConstants.scenesBase,
      data: formData,
      options: Options(
        contentType: ApiConstants.multipartFormat,
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    final responseJson = _readResponseMap(response.data);

    return SceneResponseModel.fromJson(responseJson);
  }

  Future<SceneResponseModel> createSceneFromText({
    required String prompt,
  }) async {
    final response = await _dio.post(
      ApiConstants.scenesGenerateText,
      data: {'description': prompt},
      options: Options(
        contentType: ApiConstants.jsonFormat,
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    final responseJson = _readResponseMap(response.data);

    final createdScene = SceneResponseModel.fromJson(responseJson);
    return pollSceneUntilReady(createdScene.id, initialScene: createdScene);
  }

  Future<SceneResponseModel> fetchSceneById(String sceneId) async {
    final response = await _dio.get(ApiConstants.sceneDetail(sceneId));
    final responseJson = _readResponseMap(response.data);

    return SceneResponseModel.fromJson(responseJson);
  }

  Future<SceneResponseModel> pollSceneUntilReady(
    String sceneId, {
    SceneResponseModel? initialScene,
    Duration interval = const Duration(seconds: 2),
    Duration timeout = const Duration(seconds: 120),
  }) async {
    if (sceneId.isEmpty) {
      throw Exception('Scene generation did not return a scene id.');
    }

    var latestScene = initialScene;
    final deadline = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(deadline)) {
      if (latestScene != null) {
        if (_isFailed(latestScene)) {
          final message = latestScene.errorMessage.isNotEmpty
              ? latestScene.errorMessage
              : 'Scene generation failed. Please try again.';
          throw Exception(message);
        }
        if (_isReady(latestScene)) {
          return latestScene;
        }
      }

      await Future.delayed(interval);
      latestScene = await fetchSceneById(sceneId);
    }

    throw Exception(
      'Scene generation is taking longer than expected. Please try again later.',
    );
  }

  bool _isReady(SceneResponseModel scene) {
    final normalizedStatus = scene.status.trim().toLowerCase();
    if (normalizedStatus == 'completed' ||
        normalizedStatus == 'complete' ||
        normalizedStatus == 'success' ||
        normalizedStatus == 'succeeded') {
      return _hasGeneratedContent(scene);
    }

    if (normalizedStatus == 'processing' ||
        normalizedStatus == 'pending' ||
        normalizedStatus == 'queued') {
      return false;
    }

    return _hasGeneratedContent(scene);
  }

  bool _isFailed(SceneResponseModel scene) {
    final normalizedStatus = scene.status.trim().toLowerCase();
    return normalizedStatus == 'failed' ||
        normalizedStatus == 'failure' ||
        normalizedStatus == 'error';
  }

  bool _hasGeneratedContent(SceneResponseModel scene) {
    return scene.sourceImageUrl.isNotEmpty &&
        (scene.cards.isNotEmpty ||
            scene.llmResult.isNotEmpty ||
            scene.detectionResult.isNotEmpty);
  }

  Map<String, dynamic> _readResponseMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }
}

final homeServiceProvider = Provider<HomeService>((ref) {
  final dio = ref.read(dioProvider);
  return HomeService(dio);
});
