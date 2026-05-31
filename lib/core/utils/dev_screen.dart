import 'package:flutter/material.dart';
import 'package:germany/core/utils/splash_screen.dart';
import 'package:germany/features/auth/presentation/login_screen.dart';

import '../../features/auth/presentation/register_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/immersive_screen.dart';

class DevScreen extends StatelessWidget {
  const DevScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Debug Menu'),
        backgroundColor: const Color.fromARGB(255, 147, 147, 147), // 用醒目的颜色区分正式页面
      ),
      body: ListView(
        children: [
          _buildDebugRoute(context, ' (Splash)', const SplashScreen()),
          _buildDebugRoute(context, ' (login)', const LoginScreen()),
          _buildDebugRoute(context, ' (Register)', const RegisterScreen()),
          _buildDebugRoute(context, ' (Home)', const HomeScreen()),
          _buildDebugRoute(context,' (Immersive Screen)', const ImmersiveScreen()),
           // 替换成 ReviewerDashboard() when it's ready
          
        ],
      ),
    );
  }

  Widget _buildDebugRoute(BuildContext context, String title, Widget targetScreen) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // 使用最基础的 Navigator.push 进行硬跳转，绕过所有业务路由验证
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => targetScreen),
        );
      },
    );
  }
}