import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:germany/core/constants/api_constants.dart';
import 'package:germany/core/networks/dio_client.dart';

import '../models/home_models.dart';

class HomeService {
  final Dio _dio;

  HomeService(this._dio);

  Future<SceneResponseModel> createSceneFromImage({required XFile image}) async {
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

    final responseJson = response.data is Map<String, dynamic>
        ? Map<String, dynamic>.from(response.data as Map)
        : <String, dynamic>{};

    return SceneResponseModel.fromJson(responseJson);
  }

  Future<SceneResponseModel> createSceneFromText({required String prompt}) async {
    final response = await _dio.post(
      ApiConstants.scenesGenerateText,
      data: {'description': prompt},
      options: Options(
        contentType: ApiConstants.jsonFormat,
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    final responseJson = response.data is Map<String, dynamic>
        ? Map<String, dynamic>.from(response.data as Map)
        : <String, dynamic>{};

    return SceneResponseModel.fromJson(responseJson);
  }
}

final homeServiceProvider = Provider<HomeService>((ref) {
  final dio = ref.read(dioProvider);
  return HomeService(dio);
});
