import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:germany/core/emus/app_enums.dart';
import 'package:germany/core/utils/error_utils.dart';
import 'package:germany/core/utils/logger.dart';
import '../../domain/entity/user_entity.dart';
import '../../domain/interface/auth_interface.dart';
import '../services/auth_service.dart';

//实现 interface，调用 service 拿到 model，转成 entity。
class AuthImplementation implements AuthInterface {
  final AuthService _authService;

  AuthImplementation(this._authService);

  @override
  Future<AuthEntity> register({
    required String email,
    required String password,
    required L1Language l1Language,
    required CEFRLevel targetLevel,
  }) async {
    try {
      // JSON Body
      final requestBody = {
        'email': email,
        'password': password,
        'l1_language': l1Language.value,
        'target_level': targetLevel.value,
      };

      AppLogger.i('注册请求已发起: $requestBody');
      final authModel = await _authService.register(requestBody);
      return authModel.toEntity();
    } on DioException catch (e) {
      AppLogger.e('注册失败', e);
      throw Exception(
        ErrorUtils.extractMessage(
          e,
          fallback: 'auth.register.error_fallback'.tr(),
        ),
      );
    } catch (e) {
      AppLogger.e('注册失败', e);
      throw Exception('auth.register.error_fallback'.tr());
    }
  }

  @override
  Future<AuthEntity> login(String email, String password) async {
    try {
      // print('$email $password in impl');
      final authModel = await _authService.login(email, password);
      return authModel.toEntity();
    } on DioException catch (e) {
      throw Exception(
        ErrorUtils.extractMessage(
          e,
          fallback: 'auth.login_page.error_fallback'.tr(),
        ),
      );
    } catch (e) {
      throw Exception('auth.login_page.error_fallback'.tr());
    }
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    try {
      final userModel = await _authService.getCurrentUser();
      return userModel.toEntity();
    } catch (e) {
      AppLogger.e('获取用户信息失败', e);
      rethrow;
    }
  }


}
final authInterfaceProvider = Provider<AuthInterface>((ref) {
final service = ref.read(authServiceProvider); 
return AuthImplementation(service);
});