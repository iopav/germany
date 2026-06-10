// lib/core/presentation/root_wrapper.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/app_shell_scaffold.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import 'splash_screen.dart';

class RootWrapper extends ConsumerWidget {
  const RootWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 实时监听全局的认证状态
    final authState = ref.watch(authProvider);

    // 根据不同的异步状态，直接返回（分流）不同的界面
    return authState.when(
      // 情况 A：正在读取 Token 或正在调用 /auth/me（加载中）
      loading: () => const SplashScreen(), // 展示闪屏页，盖住后面的白屏
      
      // 情况 B：网络请求失败或发生致命错误
      error: (err, stack) => const LoginScreen(),  //ref listen
      
      // 情况 C：数据明确返回（成功拿到结果）
      data: (user) {
        // 如果用户实体为空，说明本地没 Token 或者 401 被清空了
        if (user == null) {
          return const LoginScreen(); // 渲染登录/注册页
        }

        // 如果用户实体存在，根据 role 角色初始化路由和主页
        if (user.role == 'reviewer') {
          return const AppShellScaffold(
            currentIndex: 0,
            title: 'Scenes',//style?
            
            child: HomeScreen(showChrome: false),
          ); // 审核员工作台
          // return const ReviewerDashboard(); // 审核员工作台
        } else {
          return const AppShellScaffold(
            currentIndex: 0,
            title: 'Scenes',
            child: HomeScreen(showChrome: false),
          ); // 普通用户首页
        }
      },
    );
  }
}