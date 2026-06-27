import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';

class AppShellScaffold extends StatelessWidget {
  // 当前底部导航栏选中的按钮索引：0 Home，1 Reviews，2 History，3 Settings
  final int currentIndex;

  // 顶部 AppBar 显示的标题文字
  final String title;

  // 当前页面真正显示的内容，由外部页面传进来
  final Widget child;

  const AppShellScaffold({
    super.key,
    required this.currentIndex,
    required this.title,
    required this.child,
  });

  // 底部导航栏点击后的跳转逻辑开始
  void _goTo(BuildContext context, int index) {
    switch (index) {
      case 0:
        // Home 按钮：跳转到首页
        context.go('/app/home');
        break;
      case 1:
        // Reviews 按钮：跳转到复习页
        context.go('/reviews');
        break;
      case 2:
        // History 按钮：跳转到历史页
        context.go('/history');
        break;
      case 3:
        // Settings 按钮：跳转到设置页
        context.go('/settings');
        break;
    }
  }
  // 底部导航栏点击后的跳转逻辑结束

  @override
  Widget build(BuildContext context) {
    // 整个 App 外壳开始：包含顶部栏、页面内容、底部导航栏
    return Scaffold(
      // 允许 body 延伸到底部导航栏后面，用来做半透明玻璃效果
      extendBody: true,

      // 允许 body 延伸到 AppBar 后面，用来做顶部半透明玻璃效果
      extendBodyBehindAppBar: true,

      // 顶部 AppBar 区域开始
      appBar: PreferredSize(
        // 顶部栏高度
        preferredSize: const Size.fromHeight(64),

        // 裁剪顶部栏区域，避免模糊效果溢出
        child: ClipRect(
          // 顶部毛玻璃模糊层开始
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),

            // 顶部栏背景容器开始：负责渐变、边框和阴影
            child: Container(
              decoration: BoxDecoration(
                // 顶部栏半透明白色渐变背景开始
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    // 渐变起点颜色：顶部更明显的半透明白色
                    Colors.white.withValues(alpha: 0.58),
                    // 渐变终点颜色：底部更淡的半透明白色
                    Colors.white.withValues(alpha: 0.34),
                  ],
                ),
                // 顶部栏半透明白色渐变背景结束

                // 顶部栏底部分割线开始
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.42),
                  ),
                ),
                // 顶部栏底部分割线结束

                // 顶部栏阴影开始
                boxShadow: [
                  // 黑色柔和阴影：让顶部栏和内容略微分离
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                  // 白色高光阴影：增强玻璃质感
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 1),
                  ),
                ],
                // 顶部栏阴影结束
              ),

              // 真正的 AppBar 组件开始
              child: AppBar(
                // 顶部标题开始
                title: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF131B2E),
                  ),
                ),
                // 顶部标题结束

                // 标题靠左显示
                centerTitle: false,

                // AppBar 自身背景透明，显示外层 Container 的玻璃背景
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,

                // AppBar 工具栏高度
                toolbarHeight: 64,
              ),
              // 真正的 AppBar 组件结束
            ),
            // 顶部栏背景容器结束
          ),
          // 顶部毛玻璃模糊层结束
        ),
      ),
      // 顶部 AppBar 区域结束

      // 页面主体内容开始：这里显示外部传进来的 child 页面
      body: SafeArea(child: child),
      // 页面主体内容结束

      // 底部导航栏区域开始
      bottomNavigationBar: ClipRRect(
        // 底部导航栏顶部圆角
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),

        // 底部导航栏毛玻璃模糊层开始
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 34, sigmaY: 34),

          // 底部导航栏背景容器开始：负责渐变、边框和阴影
          child: Container(
            decoration: BoxDecoration(
              // 底部导航栏半透明白色渐变背景开始
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  // 渐变起点颜色：顶部较淡的半透明白色
                  Colors.white.withValues(alpha: 0.42),
                  // 渐变终点颜色：底部更明显的半透明白色
                  Colors.white.withValues(alpha: 0.62),
                ],
              ),
              // 底部导航栏半透明白色渐变背景结束

              // 底部导航栏顶部分割线开始
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.52)),
              ),
              // 底部导航栏顶部分割线结束

              // 底部导航栏阴影开始
              boxShadow: [
                // 黑色柔和阴影：让底部导航栏浮在内容上方
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 30,
                  offset: const Offset(0, -12),
                ),
                // 白色高光阴影：增强玻璃质感
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, -1),
                ),
              ],
              // 底部导航栏阴影结束
            ),

            // 真正的底部导航栏组件开始
            child: BottomNavigationBar(
              // 当前选中的底部按钮
              currentIndex: currentIndex,

              // 点击底部按钮时，调用 _goTo 进行页面跳转
              onTap: (index) => _goTo(context, index),

              // 固定显示 4 个底部按钮
              type: BottomNavigationBarType.fixed,

              // 导航栏自身背景透明，显示外层 Container 的玻璃背景
              backgroundColor: Colors.transparent,
              elevation: 0,

              // 选中按钮的颜色
              selectedItemColor: const Color(0xFF004AC6),

              // 未选中按钮的颜色
              unselectedItemColor: const Color(0xFF434655),

              // 底部 4 个按钮开始
              items: const [
                // Home 按钮开始
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                // Home 按钮结束

                // Reviews 按钮开始
                BottomNavigationBarItem(
                  icon: Icon(Icons.fact_check_outlined),
                  activeIcon: Icon(Icons.fact_check),
                  label: 'Reviews',
                ),
                // Reviews 按钮结束

                // History 按钮开始
                BottomNavigationBarItem(
                  icon: Icon(Icons.history_outlined),
                  activeIcon: Icon(Icons.history),
                  label: 'History',
                ),
                // History 按钮结束

                // Settings 按钮开始
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Settings',
                ),
                // Settings 按钮结束
              ],
              // 底部 4 个按钮结束
            ),
            // 真正的底部导航栏组件结束
          ),
          // 底部导航栏背景容器结束
        ),
        // 底部导航栏毛玻璃模糊层结束
      ),
      // 底部导航栏区域结束
    );
    // 整个 App 外壳结束
  }
}
