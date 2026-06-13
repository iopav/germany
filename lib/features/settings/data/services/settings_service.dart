import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:germany/core/constants/api_constants.dart';
import 'package:germany/core/networks/dio_client.dart';

import '../../../auth/data/models/user_model.dart';
import '../models/settings_model.dart';

class SettingsService {
  final Dio _dio;

  SettingsService(this._dio);

  Future<UserModel> updateUserInfo(UpdateUserRequestModel request) async {
    final response = await _dio.patch(
      ApiConstants.authMe,
      data: request.toJson(),
    );
    return UserModel.fromJson(_readPayload(response.data));
  }

  Future<UserModel> fetchUserInfo() async {
    final response = await _dio.get(ApiConstants.authMe);
    return UserModel.fromJson(_readPayload(response.data));
  }

  Map<String, dynamic> _readPayload(dynamic value) {
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      if (map['data'] is Map) {
        return Map<String, dynamic>.from(map['data'] as Map);
      }
      return map;
    }

    return <String, dynamic>{};
  }
}

final settingsServiceProvider = Provider<SettingsService>((ref) {
  final dio = ref.read(dioProvider);
  return SettingsService(dio);
});
