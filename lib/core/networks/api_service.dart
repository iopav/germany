// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:easy_localization/easy_localization.dart';
// import '../constants/api_constants.dart';
// import '../utils/logger.dart';

// class ApiService {
//   late final Dio _dio;

//   ApiService() {
//     _dio = Dio(
//       BaseOptions(
//         baseUrl: ApiConstants.baseUrl,
//         connectTimeout: const Duration(seconds: ApiConstants.defaultTimeoutSeconds),
//         receiveTimeout: const Duration(seconds: ApiConstants.defaultTimeoutSeconds),
//         headers: {
//           ApiConstants.headerContentType: ApiConstants.jsonFormat,
//           ApiConstants.headerAccept: ApiConstants.jsonFormat,
//         },
//       ),
//     );

//     // 拦截器：自动附加 Token 与全局错误处理
//     _dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) async {
//           final prefs = await SharedPreferences.getInstance();
//           final token = prefs.getString(ApiConstants.keyToken);
//           if (token != null) {
//             options.headers[ApiConstants.headerAuthorization] = 'Bearer $token';
//           }
//           return handler.next(options);
//         },
//         onError: (DioException e, handler) {
//           if (e.response?.statusCode == 401) {
//             AppLogger.e('${'errors.token_expired'.tr()}: ${e.message}');
//           }
//           return handler.next(e);
//         },
//       ),
//     );
//   }

//   // =========================================================================
//   // 模块一：认证与用户 (Auth Module)
//   // =========================================================================

//   /// 1. 用户注册
//   Future<Map<String, dynamic>> register(String email, String password, String username) async {
//     try {
//       final response = await _dio.post(
//         ApiConstants.authRegister,
//         data: {'email': email, 'password': password, 'username': username},
//       );
//       return response.data;
//     } catch (e) { throw _handleError(e); }
//   }

//   /// 2. 用户登录 (返回信息并持久化 Token)
//   Future<Map<String, dynamic>> login(String email, String password) async {
//     try {
//       final response = await _dio.post(
//         ApiConstants.authLogin,
//         data: {'email': email, 'password': password},
//       );
      
//       // 保存 Token
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString(ApiConstants.keyToken, response.data['access_token']);
//       return response.data;
//     } catch (e) { throw _handleError(e); }
//   }

//   /// 3. 获取当前用户信息
//   Future<Map<String, dynamic>> getCurrentUser() async {
//     try {
//       final response = await _dio.get(ApiConstants.authMe);
//       return response.data;
//     } catch (e) { throw _handleError(e); }
//   }

//   /// 4. 更新用户信息 (例如修改难度等级)
//   Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> updateData) async {
//     try {
//       final response = await _dio.patch(ApiConstants.authMe, data: updateData);
//       return response.data;
//     } catch (e) { throw _handleError(e); }
//   }

//   /// 5. 登出本地账号 (清除 Token)
//   Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(ApiConstants.keyToken);
//   }

//   // =========================================================================
//   // 模块二：核心生成场景 (Scenes Module)
//   // =========================================================================

//   /// 1. 基于图片上传生成场景 (极度耗时)
//   Future<Map<String, dynamic>> createSceneFromImage(File imageFile, String level) async {
//     try {
//       final formData = FormData.fromMap({
//         'level': level,
//         ApiConstants.keyFile: await MultipartFile.fromFile(imageFile.path),
//       });

//       final response = await _dio.post(
//         ApiConstants.scenesBase,
//         data: formData,
//         options: Options(
//           receiveTimeout: const Duration(seconds: ApiConstants.uploadTimeoutSeconds),
//           contentType: ApiConstants.multipartFormat,
//         ),
//       );
//       return response.data;
//     } catch (e) { throw _handleError(e); }
//   }

//   /// 2. 基于纯文字生成场景 (极度耗时)
//   Future<Map<String, dynamic>> createSceneFromText(String prompt, String level) async {
//     try {
//       final response = await _dio.post(
//         ApiConstants.scenesGenerateText,
//         data: {'prompt': prompt, 'level': level},
//         options: Options(
//           receiveTimeout: const Duration(seconds: ApiConstants.generateTextTimeoutSeconds),
//         ),
//       );
//       return response.data;
//     } catch (e) { throw _handleError(e); }
//   }

//   /// 3. 获取历史场景列表 (支持分页)
//   Future<Map<String, dynamic>> getScenes({int skip = 0, int limit = 10}) async {
//     try {
//       final response = await _dio.get(
//         ApiConstants.scenesBase,
//         queryParameters: {'skip': skip, 'limit': limit},
//       );
//       return response.data;
//     } catch (e) { throw _handleError(e); }
//   }

//   /// 4. 获取单个场景详情 (包含多边形坐标和词卡)
//   Future<Map<String, dynamic>> getSceneDetail(String sceneId) async {
//     try {
//       final response = await _dio.get(ApiConstants.sceneDetail(sceneId));
//       return response.data;
//     } catch (e) { throw _handleError(e); }
//   }

//   // =========================================================================
//   // 模块三：词汇与卡片 (Cards Module)
//   // =========================================================================

//   /// 1. 获取基于 FSRS 算法今天需要复习的词卡
//   Future<List<dynamic>> getDueCards({int limit = 20}) async {
//     try {
//       final response = await _dio.get(
//         ApiConstants.cardsDue,
//         queryParameters: {'limit': limit},
//       );
//       return response.data;
//     } catch (e) { throw _handleError(e); }
//   }

//   /// 2. 获取收藏词汇表 (支持分页和等级过滤)
//   Future<Map<String, dynamic>> getCardsList({int skip = 0, int limit = 20, String? level}) async {
//     try {
//       final Map<String, dynamic> query = {'skip': skip, 'limit': limit};
//       if (level != null) query['level'] = level;

//       final response = await _dio.get(
//         ApiConstants.cardsBase,
//         queryParameters: query,
//       );
//       return response.data;
//     } catch (e) { throw _handleError(e); }
//   }

//   // =========================================================================
//   // 模块四：复习记录与统计 (Reviews Module)
//   // =========================================================================

//   /// 1. 提交单词复习结果 (rating: 1-忘记, 2-困难, 3-良好, 4-简单)
//   Future<Map<String, dynamic>> submitReview(String cardId, int rating, int durationMs) async {
//     try {
//       final response = await _dio.post(
//         ApiConstants.reviewsBase,
//         data: {
//           'card_id': cardId,
//           'rating': rating,
//           'duration_ms': durationMs
//         },
//       );
//       return response.data;
//     } catch (e) { throw _handleError(e); }
//   }

//   /// 2. 获取今日复习统计数据
//   Future<Map<String, dynamic>> getReviewStats() async {
//     try {
//       final response = await _dio.get(ApiConstants.reviewsStats);
//       return response.data;
//     } catch (e) { throw _handleError(e); }
//   }

//   // =========================================================================
//   // 错误分发处理器
//   // =========================================================================
//   Exception _handleError(dynamic e) {
//     if (e is DioException) {
//       final detail = e.response?.data?['detail'];
//       if (detail != null) return Exception(detail);
      
//       if (e.response?.statusCode == 413) return Exception('errors.image_too_large'.tr());
//       if (e.response?.statusCode == 429) return Exception('errors.rate_limit'.tr());
      
//       return Exception('${'errors.network'.tr()}: ${e.message}');
//     }
//     return Exception('errors.unknown'.tr());
//   }
// }