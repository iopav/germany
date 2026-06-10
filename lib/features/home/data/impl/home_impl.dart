import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:germany/core/storage/scene_cache.dart';
import 'package:germany/core/utils/error_utils.dart';
import 'package:germany/core/utils/logger.dart';

import '../../domain/entity/home_stats_entity.dart';
import '../../domain/interface/home_interface.dart';
import '../models/home_models.dart';
import '../services/home_service.dart';

class HomeImplementation implements HomeInterface {
  final HomeService _homeService;

  HomeImplementation(this._homeService);

  @override
  Future<SceneEntity> createSceneFromImage({required XFile image}) async {
    try {
      final model = await _homeService.createSceneFromImage(image: image);
      await _cacheScene(model);
      return model.toEntity();
    } on DioException catch (e) {
      final message = ErrorUtils.extractDioMessage(
        e,
        operation: 'create a scene from the image',
      );
      AppLogger.w('[HomeImpl] Failed to create a scene from the image: $message');
      throw Exception(message);
    } catch (e) {
      AppLogger.w('[HomeImpl] Scene creation from image failed: $e');
      throw Exception('Failed to create a scene from the image. Please try again.');
    }
  }

  @override
  Future<SceneEntity> createSceneFromText({required String prompt}) async {
    try {
      final model = await _homeService.createSceneFromText(prompt: prompt);
      await _cacheScene(model);
      return model.toEntity();
    } on DioException catch (e) {
      final message = ErrorUtils.extractDioMessage(
        e,
        operation: 'create a scene from the prompt',
      );
      AppLogger.w('[HomeImpl] Failed to create a scene from the prompt: $message');
      throw Exception(message);
    } catch (e) {
      AppLogger.w('[HomeImpl] Scene creation from text failed: $e');
      throw Exception('Failed to create a scene from the prompt. Please try again.');
    }
  }

  Future<void> _cacheScene(SceneResponseModel model) async {
    try {
      await SceneCache.saveScene(model);
    } catch (e) {
      AppLogger.w('[HomeImpl] Failed to cache scene: $e');
    }
  }
}

final homeInterfaceProvider = Provider<HomeInterface>((ref) {
  final service = ref.read(homeServiceProvider);
  return HomeImplementation(service);
});
