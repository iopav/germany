import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:germany/core/utils/error_utils.dart';
import 'auth_provider.dart';
import 'register_screen.dart';

const String _rememberPasswordKey = 'auth_remember_password_v1';
const String _rememberedEmailKey = 'auth_remembered_email_v1';
const String _rememberedPasswordKey = 'auth_remembered_password_v1';
const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

///颜色体系
class _AppColors {
  static const Color background = Color(0xFFFAF8FF);
  static const Color primary = Color(0xFF004AC6);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF712AE2);
  static const Color tertiaryContainer = Color(0xFFBC4800);

  static const Color onSurface = Color(0xFF131B2E);
  static const Color onSurfaceVariant = Color(0xFF434655);
  static const Color outline = Color(0xFF737686);
  static const Color outlineVariant = Color(0xFFC3C6D7);
  static const Color surfaceContainerLow = Color(0xFFF2F3FF);
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  // 用于背景动态呼吸效果
  late final AnimationController _bgAnimationController;

  @override
  void initState() {
    super.initState();
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    _restoreRememberedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _bgAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) return;

    // 触发全局状态层的登录逻辑
    await ref.read(authProvider.notifier).login(email, password);

    if (!mounted) {
      return;
    }

    final nextState = ref.read(authProvider);
    nextState.whenOrNull(
      data: (user) {
        if (user != null) {
          _saveRememberedCredentials(email, password);
        }
      },
      error: (error, stack) {
        final message = ErrorUtils.extractMessage(
          error,
          fallback: 'auth.login_page.error_fallback'.tr(),
        );

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  Future<void> _restoreRememberedCredentials() async {
    final rememberPassword =
        await _secureStorage.read(key: _rememberPasswordKey) == 'true';
    final rememberedEmail = await _secureStorage.read(key: _rememberedEmailKey);
    final rememberedPassword = await _secureStorage.read(
      key: _rememberedPasswordKey,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _rememberMe = rememberPassword;
      if (rememberPassword) {
        _emailController.text = rememberedEmail ?? '';
        _passwordController.text = rememberedPassword ?? '';
      }
    });
  }

  Future<void> _saveRememberedCredentials(String email, String password) async {
    await _secureStorage.write(
      key: _rememberPasswordKey,
      value: _rememberMe ? 'true' : 'false',
    );

    if (_rememberMe) {
      await _secureStorage.write(key: _rememberedEmailKey, value: email);
      await _secureStorage.write(key: _rememberedPasswordKey, value: password);
      return;
    }

    await _secureStorage.delete(key: _rememberedEmailKey);
    await _secureStorage.delete(key: _rememberedPasswordKey);
  }

  Future<void> _showForgotPasswordDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: const Text(
            'Please send your account email to rozen@gmail.com to reset your password.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 监听状态，用于控制按钮的 Loading 以及弹出报错
    final authState = ref.watch(authProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: _AppColors.background,
      body: Stack(
        children: [
          // 背景光晕 (Atmospheric Background Elements)
          AnimatedBuilder(
            animation: _bgAnimationController,
            builder: (context, child) {
              final offset = _bgAnimationController.value * 20;
              return Stack(
                children: [
                  Positioned(
                    top: -screenHeight * 0.1 + offset,
                    left: -screenWidth * 0.1 - offset,
                    width: screenWidth * 0.8,
                    height: screenWidth * 0.8,
                    child: _buildBlurBlob(
                      _AppColors.primary.withValues(alpha: 0.08),
                    ),
                  ),
                  Positioned(
                    top: screenHeight * 0.4 - offset,
                    right: -screenWidth * 0.2 + offset,
                    width: screenWidth * 0.7,
                    height: screenWidth * 0.7,
                    child: _buildBlurBlob(
                      _AppColors.secondary.withValues(alpha: 0.08),
                    ),
                  ),
                  Positioned(
                    bottom: -screenHeight * 0.05 + offset,
                    left: screenWidth * 0.2 - offset,
                    width: screenWidth * 0.6,
                    height: screenWidth * 0.6,
                    child: _buildBlurBlob(
                      _AppColors.tertiaryContainer.withValues(alpha: 0.06),
                    ),
                  ),
                ],
              );
            },
          ),

          // 2. 主体滚动视图 (防止键盘遮挡)
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo 与 标题
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.language,
                        color: _AppColors.onPrimary,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'app.name'.tr(),
                      style: const TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 毛玻璃登录卡片 (Glassmorphic Panel)
                    Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.7),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'auth.login_page.title'.tr(),
                                  style: TextStyle(
                                    fontFamily: 'Space Grotesk',
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                    color: _AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // 邮箱输入框
                                _buildInputLabel(
                                  'auth.login_page.email_label'.tr(),
                                ),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _emailController,
                                  icon: Icons.mail_outline,
                                  hintText: 'auth.login_page.email_hint'.tr(),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 24),

                                // 密码输入框
                                _buildInputLabel(
                                  'auth.login_page.password_label'.tr(),
                                ),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _passwordController,
                                  icon: Icons.lock_outline,
                                  hintText: 'auth.login_page.password_hint'
                                      .tr(),
                                  obscureText: _obscurePassword,
                                  isPassword: true,
                                ),
                                const SizedBox(height: 24),

                                // 记住我 & 忘记密码
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(
                                          () => _rememberMe = !_rememberMe,
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: Checkbox(
                                                value: _rememberMe,
                                                onChanged: (val) => setState(
                                                  () => _rememberMe = val!,
                                                ),
                                                activeColor: _AppColors.primary,
                                                side: const BorderSide(
                                                  color: _AppColors.outline,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'auth.login_page.remember_me'
                                                    .tr(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 14,
                                                  color: _AppColors
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: TextButton(
                                        onPressed: _showForgotPasswordDialog,
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          'auth.login_page.forgot_password'
                                              .tr(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: _AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),

                                // 登录按钮
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: authState.isLoading
                                        ? null
                                        : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _AppColors.primary,
                                      foregroundColor: _AppColors.onPrimary,
                                      elevation: 8,
                                      shadowColor: _AppColors.primary
                                          .withValues(alpha: 0.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                    ),
                                    child: authState.isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: _AppColors.onPrimary,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'auth.login_page.button'.tr(),
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(
                                                Icons.arrow_forward,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 底部注册跳转
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'auth.login_page.dont_have_account'.tr(),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            color: _AppColors.onSurfaceVariant,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // 跳往注册页
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'auth.login_page.sign_up_now'.tr(),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 辅助构建：输入框上方的 Label
  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  // 辅助构建：高度定制的输入框
  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    bool obscureText = false,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        color: _AppColors.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: _AppColors.outlineVariant.withValues(alpha: 0.8),
        ),
        filled: true,
        fillColor: _AppColors.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        prefixIcon: Icon(icon, color: _AppColors.outline),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: _AppColors.outline,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildBlurBlob(Color color) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 100, // 对应 CSS blur-[100px]
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}
