// lib/features/auth/presentation/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../core/emus/app_enums.dart';
import '../data/impl/auth_impl.dart';
import '../domain/entity/user_entity.dart';
import '../domain/interface/auth_interface.dart';

// 使用 AsyncNotifier 管理异步的认证状态
class AuthNotifier extends AsyncNotifier<UserEntity?> {
  
  // build 方法在 Provider 第一次被使用（App 启动）时会自动触发执行
  @override
  Future<UserEntity?> build() async {
    return _initializeAuth();
  }

  Future<UserEntity?> _initializeAuth() async {
    try {
      // 步骤 1：读取本地存储的 access_token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(ApiConstants.keyToken);
      // debug
      // final token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJmYWRhODk3NS05Y2ZiLTRmYzItYmFlYi1iZDhjOTJkYzM0Y2IiLCJleHAiOjE3ODE2MDM2MjV9.lhSOSdXn-xGx0yVJXdjXPbsCE6uKtW_rHnNcQk4mzwI";

      // 步骤 3：如果没有 token → 返回 null（代表未登录）
      if (token == null || token.isEmpty) {
        return null;
      }

      // 步骤 2：如果有 token → 调用获取当前用户接口
      // 这里通过依赖注入拿到接口履约者
      final AuthInterface authInterface = ref.read(authInterfaceProvider);
      
      // 执行 GET /auth/me 逻辑
      final userEntity = await authInterface.getCurrentUser();
      
      // 成功 → 返回用户实体，恢复登录状态
      return userEntity;
      
    } catch (e) {
      // 步骤 2-401：如果接口报错（如 401 认证失效），捕获后清空本地并返回未登录
      // 注：如果你已经在 Dio 拦截器里写了清除 Token 的逻辑，这里直接返回 null 即可
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(ApiConstants.keyToken);
      return null;
    }
  }

  // 供外部（如登录按钮）调用的手动登录方法
  Future<void> login(String email, String password) async {
    try {
      print('login in provider');
      final AuthInterface authInterface = ref.read(authInterfaceProvider);
      final authEntity = await authInterface.login(email, password);
      
      // 持久化 Token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(ApiConstants.keyToken, authEntity.accessToken);
      
      // 更新内存状态
      state = AsyncData(authEntity.user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> logout() async {
    // 1. 清除本地 Token
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConstants.keyToken);
    
    // 2. 更新内存状态为未登录
    state = const AsyncData(null);
  }

  Future<void> register({
    required String email,
    required String password,
    required L1Language l1Language,
    required CEFRLevel targetLevel,
  }) async {
    try {
      final AuthInterface authInterface = ref.read(authInterfaceProvider);
      final authEntity = await authInterface.register(
        email: email,
        password: password,
        l1Language: l1Language,
        targetLevel: targetLevel,
      );
      
      // 持久化 Token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(ApiConstants.keyToken, authEntity.accessToken);
      
      // 更新内存状态
      state = AsyncData(authEntity.user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}


final authProvider = AsyncNotifierProvider<AuthNotifier, UserEntity?>(() {
return AuthNotifier();
});