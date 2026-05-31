import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:germany/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart'; 
import 'package:germany/features/auth/presentation/auth_provider.dart';
import 'package:germany/core/emus/error_enums.dart';
// 1. 使用 Riverpod 暴露全局唯一的 Dio 实例
final dioProvider = Provider<Dio>((ref) {
  
  // 2. 初始化配置 BaseOptions
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

  // 3. 挂载全局拦截器（自动化处理 Token 和 通用错误）
  dio.interceptors.add(
    InterceptorsWrapper(
      // 发送请求前的拦截：自动从本地注入 Token
      onRequest: (options, handler) async {
        final isNoAuthRoute = ApiConstants.whiteList.any((route) => options.path.contains(route));

        // 3. 如果当前请求【不在白名单】里，才去本地拿 Token 并挂载
        if (!isNoAuthRoute) {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(ApiConstants.keyToken); 
          
          if (token != null && token.isNotEmpty) {
            // 严格按照文档要求的格式：Bearer <access_token>
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            AppLogger.w('${ErrorMsg.errorNoAuth.message}: ${options.path}');
            
            // 使用 handler.reject 直接中断请求，并伪造一个 401 状态码的 Response
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
          }
        }
        return handler.next(options); 
      },
      

      // 响应响应后的拦截
      onResponse: (response, handler) {
        return handler.next(response);
      },
      
      // 发生错误时的拦截：统一处理 401 等通用错误
      // 路径: lib/core/networks/dio_client.dart (替换你的 onError 部分)

      onError: (DioException e, handler) async {
        String _asReadableMessage(dynamic value) {
          if (value == null) {
            return '';
          }
          if (value is String) {
            return value.trim();
          }
          if (value is List) {
            return value.map((item) => item.toString()).join(', ').trim();
          }
          if (value is Map) {
            final detail = value['detail'];
            if (detail != null && detail != value) {
              final nested = _asReadableMessage(detail);
              if (nested.isNotEmpty) {
                return nested;
              }
            }
            final message = value['message'];
            if (message != null && message != value) {
              final nested = _asReadableMessage(message);
              if (nested.isNotEmpty) {
                return nested;
              }
            }
          }
          return value.toString().trim();
        }

        // 1. 提取后端可能返回的具体错误文本，确保不会拿到 null
        String serverMessage = '';
        if (e.response?.data != null) {
          final data = e.response!.data;
          if (data is Map) {
            serverMessage = _asReadableMessage(data['detail']);
            if (serverMessage.isEmpty) {
              serverMessage = _asReadableMessage(data['message']);
            }
          } else {
            serverMessage = _asReadableMessage(data);
          }
        }
        if (serverMessage.isEmpty) {
          serverMessage = _asReadableMessage(e.message);
        }
        if (serverMessage.isEmpty) {
          serverMessage = 'No additional details provided by server';
        }

        // 2. 处理带有 HTTP 状态码的业务错误
        if (e.response != null) {
          final statusCode = e.response!.statusCode;
          
          switch (statusCode) {
            case 401:
              final isLoginRequest = e.requestOptions.path.contains(ApiConstants.authLogin);
              if (isLoginRequest) {
                // 登录接口自身的 401 (密码错误)，使用 [Auth] 标签
                AppLogger.i('[Auth] Login Validation Failed | Detail: $serverMessage');
              } else {
                // 正常使用中的 Token 失效
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
        } 
        // 3. 处理没有到达服务器的物理级网络错误
        else {
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


  // dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  dio.interceptors.add(LogInterceptor(
    request: true,           // 打印请求的基本信息
    requestHeader: true,     // 打印请求头（看看 Token 带上没）
    requestBody: true,       // 打印你发给后端的 JSON 数据
    responseHeader: false,   // 响应头通常很长，可以关掉
    responseBody: true,      // 打印后端返回的真实 JSON 数据
    error: true,             // 打印详细的错误信息
  ));
  return dio;
});