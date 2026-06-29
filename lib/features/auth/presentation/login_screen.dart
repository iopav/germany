import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:germany/core/utils/error_utils.dart';
import 'package:go_router/go_router.dart';
import 'auth_provider.dart';
import 'login_style.dart';
import 'register_screen.dart';

const String _rememberPasswordKey = 'auth_remember_password_v1';
const String _rememberedEmailKey = 'auth_remembered_email_v1';
const String _rememberedPasswordKey = 'auth_remembered_password_v1';
const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AnimationController _mosaicAnimationController;

  bool _obscurePassword = true;
  bool _rememberMe = false;

  // 用于背景动态呼吸效果
  @override
  void initState() {
    super.initState();
    _mosaicAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _restoreRememberedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _mosaicAnimationController.dispose();
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
          context.go('/home');
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
            backgroundColor: LoginStyle.errorColor(context),
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

    return Scaffold(
      backgroundColor: LoginStyle.backgroundColor(context),
      body: Stack(
        children: [
          // 背景光晕
          Positioned.fill(
            child: LoginMosaicPatch(
              opacity: 0.4,
              animation: _mosaicAnimationController,
            ),
          ),

          // 主体滚动视图，防止键盘遮挡
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: LoginStyle.scrollPadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo 和标题
                    Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(left: 4),
                      decoration: LoginStyle.logoDecorationFor(context),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 64,
                        height: 64,
                        fit: BoxFit.contain,
                        // color: LoginStyle.colors(context).onPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'app.name'.tr(),
                      style: LoginStyle.appNameTextStyleFor(context),
                    ),
                    const SizedBox(height: 40),

                    // 毛玻璃登录卡片
                    Container(
                      constraints: LoginStyle.panelConstraints,
                      decoration: LoginStyle.panelShadowDecoration,
                      child: ClipRRect(
                        borderRadius: LoginStyle.panelRadius,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: LoginStyle.panelPadding,
                            decoration: LoginStyle.panelDecorationFor(context),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'auth.login_page.title'.tr(),
                                  style: LoginStyle.titleTextStyleFor(context),
                                ),
                                const SizedBox(height: 32),

                                // 邮箱输入框
                                LoginInputLabel(
                                  text: 'auth.login_page.email_label'.tr(),
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
                                LoginInputLabel(
                                  text: 'auth.login_page.password_label'.tr(),
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

                                // 记住我和忘记密码
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
                                                activeColor: LoginStyle.colors(
                                                  context,
                                                ).primary,
                                                side: BorderSide(
                                                  color: LoginStyle.colors(
                                                    context,
                                                  ).outline,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      LoginStyle.checkboxRadius,
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
                                                style:
                                                    LoginStyle.rememberTextStyleFor(
                                                      context,
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
                                        style: LoginStyle
                                            .forgotPasswordButtonStyle,
                                        child: Text(
                                          'auth.login_page.forgot_password'
                                              .tr(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style:
                                              LoginStyle.forgotPasswordTextStyleFor(
                                                context,
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
                                    style: LoginStyle.loginButtonStyleFor(
                                      context,
                                    ),
                                    child: authState.isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: LoginStyle.onPrimary,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'auth.login_page.button'.tr(),
                                                style: LoginStyle
                                                    .loginButtonTextStyle,
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(
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
                          style: LoginStyle.registerPromptTextStyleFor(context),
                        ),
                        GestureDetector(
                          onTap: () {
                            // 跳转到注册页
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'auth.login_page.sign_up_now'.tr(),
                            style: LoginStyle.registerLinkTextStyleFor(context),
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
      style: LoginStyle.inputTextStyleFor(context),
      decoration: LoginStyle.inputDecorationFor(
        context,
        icon: icon,
        hintText: hintText,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: LoginStyle.colors(context).outline,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
      ),
    );
  }
}
