import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// 定义与 Tailwind Config 完全对齐的颜色常量
class _AppColors {
  static const Color background = Color(0xFFFAF8FF);
  static const Color surface = Color(0xFFFAF8FF);
  static const Color primary = Color(0xFF004AC6);
  static const Color onSurface = Color(0xFF131B2E);
  static const Color onSurfaceVariant = Color(0xFF434655);
  static const Color surfaceContainerHigh = Color(0xFFE2E7FF);
  static const Color outline = Color(0xFF737686);
  static const Color outlineVariant = Color(0xFFC3C6D7);
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _breatheController;
  late final AnimationController _progressController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _breatheOpacityAnimation;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // 1. 入场动画控制器 1.2s cubic-bezier(0.22, 1, 0.36, 1) )
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutQuart),
    );

    //translateY(10px) 到 0
    _slideAnimation = Tween<double>(begin: 10.0, end: 0.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutQuart),
    );

    // 呼吸动画控制器 (4s 周期)
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    _breatheOpacityAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    // 进度条动画控制器 (2s 线性循环)
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // translateX(-100%) 到 translateX(250%)
    // 进度条总宽 192，内部条宽 64。起始位置 -64，结束位置 192 + 64*1.5 
    _progressAnimation = Tween<double>(begin: -64.0, end: 256.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // 启动入场动画
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _breatheController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.background,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 背景高斯模糊光晕 (Glassmorphic Accent) — 使用 Align 保证居中
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _AppColors.primary.withOpacity(0.05),
                boxShadow: [
                  BoxShadow(
                    color: _AppColors.primary.withOpacity(0.05),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          // 主体内层 (应用入场动画)
          AnimatedBuilder(
            animation: _entranceController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo 区域 (应用呼吸动画)
                AnimatedBuilder(
                  animation: _breatheController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _breatheOpacityAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 32),
                    width: 128, // HTML 中的 w-32
                    height: 128,
                    decoration: BoxDecoration(
                      color: _AppColors.surface,
                      borderRadius: BorderRadius.circular(12), // rounded-xl
                      border: Border.all(
                        color: _AppColors.outlineVariant.withOpacity(0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.broken_image, color: _AppColors.outlineVariant),
                      ),
                    ),
                  ),
                ),

                // name
                 Text(
                  'app.name'.tr(),
                  style: const TextStyle(
                    fontFamily: 'Space Grotesk', // 需在 pubspec.yaml 中配置
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: _AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'splash.intro'.tr(),
                  textAlign: TextAlign.center,
                    style:const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _AppColors.onSurfaceVariant,
                    letterSpacing: 0.14,
                  ),
                ),
                
                const SizedBox(height: 64), // mt-16

                // 自定义进度条
                Container(
                  width: 192, // w-48
                  height: 4, // h-1
                  decoration: BoxDecoration(
                    color: _AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return Stack(
                        children: [
                          Positioned(
                            left: _progressAnimation.value,
                            top: 0,
                            bottom: 0,
                            width: 64, // w-1/3
                            child: Container(
                              decoration: BoxDecoration(
                                color: _AppColors.primary,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: _AppColors.primary.withOpacity(0.4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 底部角标
          Positioned(
            bottom: 48, // bottom-12
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_user_outlined, // 对应 Material Symbols
                  color: _AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'splash.ai'.tr(),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _AppColors.outline,
                    letterSpacing: 1.2, // tracking-widest
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}