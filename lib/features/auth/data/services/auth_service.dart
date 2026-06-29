//封装具体的 /auth/login, /auth/me 等 API 请求。
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:germany/core/constants/api_constants.dart';
import 'package:germany/core/networks/dio_client.dart';

import '../models/user_model.dart';

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<AuthResponseModel> register(Map<String, dynamic> requestBody) async {
    // 1. 发起真实的网络请求
    final response = await _dio.post(
      //从const里取出register的url
      ApiConstants.authRegister,
      data: requestBody,
    );

    // 2. 将返回的字典塞给 Model 的 fromJson
    return AuthResponseModel.fromJson(response.data);
  }
// "access_token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJmYWRhODk3NS05Y2ZiLTRmYzItYmFlYi1iZDhjOTJkYzM0Y2IiLCJleHAiOjE3ODE2MDM2MjV9.lhSOSdXn-xGx0yVJXdjXPbsCE6uKtW_rHnNcQk4mzwI","token_type":"bearer","user":{"id":"fada8975-9cfb-4fc2-baeb-bd8c92dc34cb"
  Future<AuthResponseModel> login(String email, String password) async {
    // print('baseurl+api${_dio.options.baseUrl + ApiConstants.authLogin}');
    final response = await _dio.post(
      ApiConstants.authLogin,
      data: {"email": email, "password": password},
    );
    return AuthResponseModel.fromJson(response.data);
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _dio.get(ApiConstants.authMe);
    return UserModel.fromJson(response.data);
  }

  Future<void> sendVerificationEmail(String email) async {
    await _dio.post(
      ApiConstants.authSendVerification,
      data: {},
    );
  }
}

final   authServiceProvider = Provider<AuthService>((ref) {
  // 从核心层拿全局唯一的 Dio 引擎
  final dio = ref.read(dioProvider);
  return AuthService(dio);
});
