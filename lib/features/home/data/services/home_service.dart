import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:germany/core/constants/api_constants.dart';
import 'package:germany/core/networks/dio_client.dart';
import 'package:germany/core/utils/logger.dart';

import '../models/home_models.dart';

class HomeService {
  final Dio _dio;

  HomeService(this._dio);

  Future<SceneResponseModel> createSceneFromImage({required XFile image}) async {
    try {
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
          receiveTimeout: const Duration(
            seconds: 60,
          ),
        ),
      );

      final responseJson = response.data is Map<String, dynamic>
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};

      return SceneResponseModel.fromJson(responseJson);
    } on DioException catch (e) {
      final message = _extractServerMessage(e);
      AppLogger.w('场景生成请求失败: ${message.isNotEmpty ? message : e.message}');
      throw Exception(
        message.isNotEmpty ? message : '场景生成失败，请稍后重试',
      );
    } catch (e) {
      AppLogger.w('场景生成请求失败: $e');
      rethrow;
    }
  }

  String _extractServerMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final detail = data['detail']?.toString() ?? '';
      if (detail.isNotEmpty) return detail;

      final message = data['message']?.toString() ?? '';
      if (message.isNotEmpty) return message;
    }

    return e.message ?? '';
  }
}

final homeServiceProvider = Provider<HomeService>((ref) {
  final dio = ref.read(dioProvider);
  return HomeService(dio);
});
