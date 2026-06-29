//定义登录、登出、获取当前用户的标准契约。
import 'package:germany/core/emus/app_enums.dart';

import '../entity/user_entity.dart';

abstract class AuthInterface {

  
  Future<AuthEntity> register({
    required String email,
    required String password,
    required L1Language l1Language,
    required CEFRLevel targetLevel,
  });
  Future<AuthEntity> login(String email, String password);
  Future<UserEntity> getCurrentUser();
  Future<void> sendVerificationEmail(String email);
}