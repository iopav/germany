import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:germany/core/emus/app_enums.dart';
import 'package:germany/core/utils/error_utils.dart';
import 'package:germany/features/home/presentation/home_screen.dart';

import 'auth_provider.dart';

// ==========================================
// 1. 颜色与常量定义 (提取自 Tailwind 配置)
// ==========================================
class AppColors {
  static const Color background = Color(0xFFFAF8FF);
  static const Color surface = Color(0xFFFAF8FF);
  static const Color primary = Color(0xFF004AC6);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF131B2E);
  static const Color onSurfaceVariant = Color(0xFF434655);
  static const Color outlineVariant = Color(0xFFC3C6D7);
  static const Color primaryFixedDim = Color(0xFFB4C5FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color primaryFixed = Color(0xFFDBE1FF);
}

// ==========================================
// 2. 主页面 Screen
// ==========================================
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  int _currentLevelIndex = 0; // A1
  int _goalLevelIndex = 2; // B1

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _triggerSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('auth.register.empty_fields'.tr()),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await ref.read(authProvider.notifier).register(
      email: email,
      password: password,
      l1Language: L1Language.english,
      targetLevel: CEFRLevel.values[_goalLevelIndex],
    );

    if (!mounted) {
      return;
    }

    final nextState = ref.read(authProvider);
    nextState.whenOrNull(
      data: (user) {
        if (user == null) {
          return;
        }
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(authProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          final message = ErrorUtils.extractMessage(
            error,
            fallback: 'auth.register.error_fallback'.tr(),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red.shade800,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    });
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'app.name'.tr(),
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'auth.login'.tr(),
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Branding
              Text(
                'auth.register.title'.tr(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'auth.register.subtitle'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),

              // Basic Info Section (Glass Panel 模拟)
              _buildGlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('auth.register.email_label'.tr()),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      decoration: _inputDecoration('auth.register.email_hint'.tr()),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('auth.register.password_label'.tr()),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: _inputDecoration('auth.register.password_hint'.tr()).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: AppColors.outlineVariant,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Level Selectors (Glass Panel)
              _buildGlassPanel(
                child: Column(
                  children: [
                    // Current Level Dial
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.school, size: 18, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text(
                          'auth.register.current_level'.tr(),
                          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    LevelDialPicker(
                      selectedIndex: _currentLevelIndex,
                      onIndexChanged: (i) => setState(() => _currentLevelIndex = i),
                    ),
                    const SizedBox(height: 40),

                    // Goal Proficiency Dial
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.flag, size: 18, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text(
                          'auth.register.goal_level'.tr(),
                          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    LevelDialPicker(
                      selectedIndex: _goalLevelIndex,
                      onIndexChanged: (i) => setState(() => _goalLevelIndex = i),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action Button
              ElevatedButton(
                onPressed: _triggerSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 8,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('auth.register.button'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Footer
              Center(
                child: Column(
                  children: [
                    Text(
                      'auth.register.copyright'.tr(),
                      style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _footerLink('auth.register.privacy_policy'.tr()),
                        const SizedBox(width: 16),
                        _footerLink('auth.register.terms_of_service'.tr()),
                        const SizedBox(width: 16),
                        _footerLink('auth.register.help_center'.tr()),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
    );
  }

  Widget _buildGlassPanel({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0).withOpacity(0.6)),
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF737686)),
      filled: true,
      fillColor: AppColors.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  Widget _footerLink(String text) {
    return InkWell(
      onTap: () {},
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
// ==========================================
// 3. 自定义等级拨盘
// ==========================================
class LevelDialPicker extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  const LevelDialPicker({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  static const List<String> levels = ['A1', 'A2', 'B1', 'B2', 'C1'];
  static const List<double> angles = [-60, -30, 0, 30, 60];

  @override
  Widget build(BuildContext context) {
    final String currentLevel = levels[selectedIndex];
    final String description = 'auth.level_descriptions.$currentLevel'.tr();
    
    // 计算整个轮盘需要转动的角度
    final double wheelRotation = -angles[selectedIndex];

    return Column(
      children: [
        // 拨盘容器 (带渐变遮罩)
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.black, Colors.transparent],
              stops: [0.0, 0.6, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: SizedBox(
            height: 180,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // 顶部中心的高亮光晕
                Positioned(
                  top: 20,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.1),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 30),
                      ],
                    ),
                  ),
                ),
                // 顶部中心的指示线
                Positioned(
                  top: 10,
                  child: Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 10),
                      ],
                    ),
                  ),
                ),
                // ===============================================
                // 旋转的大轮盘
                // ===============================================
                Positioned(
                  
                  top: 56, 
                  child: AnimatedRotation(
                    turns: wheelRotation / 360,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutBack,
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.outlineVariant.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      // 绘制 5 个等级选项
                      child: Stack(
                        
                        clipBehavior: Clip.none, 
                        children: List.generate(levels.length, (index) {
                          final isActive = index == selectedIndex;
                          final itemAngle = angles[index];
                          
                          // 每个选项的逆向旋转角度（保证文字正立）
                          final counterRotation = -(wheelRotation + itemAngle);

                          return Positioned(
                            top: -26, 
                            left: 134, 
                            child: Transform.rotate(
                              angle: itemAngle * math.pi / 180,
                              origin: const Offset(0, 159), // 精确围绕圆心旋转
                              child: GestureDetector(
                                onTap: () => onIndexChanged(index),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOutBack,
                                  width: 48,
                                  height: 48,
                                  child: AnimatedRotation(
                                    turns: counterRotation / 360,
                                    duration: const Duration(milliseconds: 600),
                                    curve: Curves.easeOutBack,
                                    child: AnimatedScale(
                                      scale: isActive ? 1.2 : 1.0,
                                      duration: const Duration(milliseconds: 300),
                                      child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isActive ? AppColors.primary : Colors.white.withOpacity(0.9),
                                          border: Border.all(
                                            color: isActive ? AppColors.primaryFixed : AppColors.outlineVariant,
                                            width: 1,
                                          ),
                                          boxShadow: [
                                            if (isActive)
                                              BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8))
                                            else
                                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
                                          ],
                                        ),
                                        child: Text(
                                          levels[index],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: isActive ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // 动态展示当前选中的等级描述
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            '$currentLevel: $description',
            key: ValueKey(currentLevel),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}