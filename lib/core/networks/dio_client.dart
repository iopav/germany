import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:germany/core/emus/error_enums.dart';
import 'package:germany/core/utils/error_utils.dart';
import 'package:germany/core/utils/logger.dart';
import 'package:germany/features/auth/presentation/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';

final dioProvider = Provider<Dio>((ref) {
  final options = BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: ApiConstants.defaultTimeoutSeconds),
    receiveTimeout: const Duration(seconds: ApiConstants.defaultTimeoutSeconds),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );

  final dio = Dio(options);

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final isNoAuthRoute = ApiConstants.whiteList.any(
          (route) => options.path.contains(route),
        );

        if (isNoAuthRoute) {
          return handler.next(options);
        }

        // final prefs = await SharedPreferences.getInstance();
        // final token = prefs.getString(ApiConstants.keyToken);
        String? token;
        token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJmYWRhODk3NS05Y2ZiLTRmYzItYmFlYi1iZDhjOTJkYzM0Y2IiLCJleHAiOjE3ODE2MDM2MjV9.lhSOSdXn-xGx0yVJXdjXPbsCE6uKtW_rHnNcQk4mzwI";

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          return handler.next(options);
        }

        AppLogger.w('${ErrorMsg.errorNoAuth.message}: ${options.path}');
        return handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            error: ErrorMsg.errorNoAuth.message,
            response: Response(
              requestOptions: options,
              statusCode: 401,
            ),
          ),
          true,
        );
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        final serverMessage = ErrorUtils.extractMessage(
          e,
          fallback: 'No additional details provided by server',
        );

        if (e.response != null) {
          final statusCode = e.response!.statusCode;

          switch (statusCode) {
            case 401:
              final isLoginRequest = e.requestOptions.path.contains(ApiConstants.authLogin);
              if (isLoginRequest) {
                AppLogger.i('[Auth] Login Validation Failed | Detail: $serverMessage');
              } else {
                AppLogger.w('[Network] 401 ${ErrorMsg.error401.message} | Detail: $serverMessage');
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove(ApiConstants.keyToken);
                ref.invalidate(authProvider);
              }
              break;
            case 400:
              AppLogger.e('[Network] 400 ${ErrorMsg.error400.message} | Detail: $serverMessage');
              break;
            case 403:
              AppLogger.e('[Network] 403 ${ErrorMsg.error403.message} | Detail: $serverMessage');
              break;
            case 422:
              AppLogger.e('[Network] 422 ${ErrorMsg.error422.message} | Detail: $serverMessage');
              break;
            case 404:
              AppLogger.e('[Network] 404 ${ErrorMsg.error404.message} | Path: ${e.requestOptions.path}');
              break;
            case 413:
              AppLogger.e('[Network] 413 ${ErrorMsg.error413.message} | Detail: $serverMessage');
              break;
            case 500:
            case 502:
            case 503:
              AppLogger.e('[Network] $statusCode ${ErrorMsg.error503.message} | Detail: $serverMessage');
              break;
            default:
              AppLogger.e('[Network] HTTP $statusCode | Detail: $serverMessage');
          }
        } else {
          switch (e.type) {
            case DioExceptionType.connectionTimeout:
            case DioExceptionType.sendTimeout:
            case DioExceptionType.receiveTimeout:
              AppLogger.e('[Network] ${ErrorMsg.errorTimeout.message} | Detail: $serverMessage');
              break;
            case DioExceptionType.connectionError:
              AppLogger.e('[Network] ${ErrorMsg.errorConnection.message} | Detail: $serverMessage');
              break;
            case DioExceptionType.cancel:
              AppLogger.w('[Network] ${ErrorMsg.errorCancel.message} | Path: ${e.requestOptions.path}');
              break;
            default:
              AppLogger.e('[Network] ${ErrorMsg.errorUnknown.message} | Detail: $serverMessage');
          }
        }

        return handler.next(e);
      },
    ),
  );

  dio.interceptors.add(
    LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
    ),
  );

  return dio;
});
