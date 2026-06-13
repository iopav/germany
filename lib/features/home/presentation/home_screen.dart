import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:germany/core/widgets/scene_image_cache.dart';
import 'package:image_picker/image_picker.dart';

import 'home_provider.dart';
import 'immersive_screen.dart';

/// Maps directly to the provided Tailwind theme configuration
class _AppColors {
  static const Color background = Color(0xFFFAF8FF);
  static const Color primary = Color(0xFF004AC6);
  static const Color onSurface = Color(0xFF131B2E);
  static const Color onSurfaceVariant = Color(0xFF434655);
  static const Color outlineVariant = Color(0xFFC3C6D7);
  static const Color surfaceContainerHigh = Color(0xFFE2E7FF);
  static const Color surfaceContainerHighest = Color(0xFFDAE2FD);
}

class HomeScreen extends ConsumerStatefulWidget {
  final bool showChrome;

  const HomeScreen({super.key, this.showChrome = true});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _promptController = TextEditingController();

  bool _isMenuOpen = false;
  Offset? _particleTouchPoint;

  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _promptController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _fillPrompt(String text) {
    setState(() {
      _promptController.text = text;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ref.read(homeProvider.notifier).pickImage(source);
    if (!mounted) return;

    setState(() => _isMenuOpen = false);
    final error = ref.read(homeProvider).errorMessage;
    if (error != null && error.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    if (pickedImage == null) {
      return;
    }

    await _startGeneration();
  }

  Future<void> _startGeneration() async {
    final validationError = await ref
        .read(homeProvider.notifier)
        .validateSelectedImage();
    if (validationError != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationError)));
      return;
    }

    try {
      final scene = await ref.read(homeProvider.notifier).generateScene();
      if (!mounted) return;

      await SceneImageCache.precacheScene(context, scene);
      if (!mounted) return;

      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => ImmersiveScreen(scene: scene)));
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _generateFromText() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a scene description.')),
      );
      return;
    }

    // 隐藏键盘
    FocusScope.of(context).unfocus();

    try {
      // 1. 调用 Notifier 里的生成方法（确保你在 Notifier 里处理了接口请求，并返回了结果数据）
      // 假设你的接口返回一个 ScenarioModel 或者 String 格式的生成内容
      final generatedResult = await ref
          .read(homeProvider.notifier)
          .generateFromText(
            prompt,
            // 如果你的 LevelWheelPicker 维护了一个本地变量或状态，把它传过去
            // level: _selectedLevel,
          );

      if (!mounted) return;

      await SceneImageCache.precacheScene(context, generatedResult);
      if (!mounted) return;

      // 清空输入框
      _promptController.clear();

      // 2. 把接口返回的数据通过构造函数直接送入 ImmersiveScreen 渲染
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ImmersiveScreen(scene: generatedResult),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    // final bodyPaddingTop = widget.showChrome ? MediaQuery.of(context).padding.top + 80 : 24.0;
    final bodyPaddingBottom = widget.showChrome ? 120.0 : 24.0;
    //TODO ref listen
    return Scaffold(
      backgroundColor: _AppColors.background,
      extendBodyBehindAppBar: true,
      extendBody: true,

      // // 1. Top AppBar (Frosted Glass)
      // appBar: widget.showChrome
      //     ? PreferredSize(
      //         preferredSize: const Size.fromHeight(64),
      //         child: ClipRRect(
      //           child: BackdropFilter(
      //             filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      //             child: AppBar(
      //               backgroundColor: _AppColors.surface.withOpacity(0.8),
      //               elevation: 0,
      //               bottom: PreferredSize(
      //                 preferredSize: const Size.fromHeight(1),
      //                 child: Container(
      //                   color: _AppColors.outlineVariant.withOpacity(0.3),
      //                   height: 1,
      //                 ),
      //               ),
      //               title: const Row(
      //                 children: [
      //                   Icon(Icons.language, color: _AppColors.primary),
      //                   SizedBox(width: 12),
      //                   Text(
      //                     'Scenes',
      //                     style: TextStyle(
      //                       fontFamily: 'Space Grotesk',
      //                       fontSize: 24,
      //                       fontWeight: FontWeight.w700,
      //                       color: _AppColors.primary,
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //               actions: [
      //                 IconButton(
      //                   icon: const Icon(
      //                     Icons.help_outline,
      //                     color: _AppColors.onSurfaceVariant,
      //                   ),
      //                   onPressed: () {},
      //                 ),
      //                 const SizedBox(width: 8),
      //               ],
      //             ),
      //           ),
      //         ),
      //       )
      //     : null,

      // 2. Main Content
      body: LayoutBuilder(
        builder: (context, constraints) {
          final uploadAreaHeight = _uploadAreaHeight(
            context,
            bodyPaddingBottom,
            constraints.maxHeight,
          );

          return ListView(
            padding: EdgeInsets.only(
              // top: bodyPaddingTop,
              left: 16,
              right: 16,
              bottom: bodyPaddingBottom,
            ),
            children: [
              // Header Texts
              const Text(
                'Create Scene',
                style: TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: _AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Capture the world or describe a moment to start your immersion journey.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: _AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // 3. Image Upload Area
              SizedBox(
                height: uploadAreaHeight,
                child: MouseRegion(
                  onHover: (event) =>
                      setState(() => _particleTouchPoint = event.localPosition),
                  onExit: (_) => setState(() => _particleTouchPoint = null),
                  child: GestureDetector(
                    onPanUpdate: (details) => setState(
                      () => _particleTouchPoint = details.localPosition,
                    ),
                    onPanEnd: (_) => setState(() => _particleTouchPoint = null),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: _AppColors.surfaceContainerHigh
                                  .withOpacity(0.35),
                              borderRadius: BorderRadius.circular(32),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.58),
                                  _AppColors.surfaceContainerHigh.withOpacity(
                                    0.34,
                                  ),
                                  _AppColors.surfaceContainerHighest
                                      .withOpacity(0.28),
                                ],
                              ),
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _shimmerController,
                            builder: (context, _) {
                              return CustomPaint(
                                painter: _UploadParticlePainter(
                                  progress: _shimmerController.value,
                                  touchPoint: _particleTouchPoint,
                                  primary: _AppColors.primary,
                                  accent: const Color(0xFF7C8CF8),
                                ),
                              );
                            },
                          ),
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _DashedRRectPainter(
                                radius: 32,
                                color: _AppColors.primary.withOpacity(0.34),
                              ),
                            ),
                          ),

                          // Center Add Button & Menu
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () => setState(
                                    () => _isMenuOpen = !_isMenuOpen,
                                  ),
                                  child: _buildGlassContainer(
                                    radius: 24,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 32,
                                    ),
                                    child: const Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo,
                                          size: 36,
                                          color: _AppColors.primary,
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'Add Scene Image',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: _AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Expandable Menu
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  child: _isMenuOpen
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                            top: 16,
                                          ),
                                          child: _buildGlassContainer(
                                            radius: 16,
                                            padding: EdgeInsets.zero,
                                            child: Column(
                                              children: [
                                                _buildMenuOption(
                                                  Icons.photo_camera,
                                                  'Camera',
                                                  () => _pickImage(
                                                    ImageSource.camera,
                                                  ),
                                                ),
                                                Divider(
                                                  height: 1,
                                                  color: _AppColors
                                                      .outlineVariant
                                                      .withOpacity(0.3),
                                                ),
                                                _buildMenuOption(
                                                  Icons.image,
                                                  'Gallery',
                                                  () => _pickImage(
                                                    ImageSource.gallery,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            ),
                          ),

                          if (homeState.selectedImage != null)
                            Positioned(
                              right: 18,
                              bottom: 16,
                              child: _buildGlassContainer(
                                radius: 999,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: _AppColors.primary,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Image selected',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _AppColors.primary,
                                      ),
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
              const SizedBox(height: 16),

              // 4. Generation Dialogue Panel
              _buildGlassContainer(
                radius: 28,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Input Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: _promptController,
                              onSubmitted: homeState.isGenerating
                                  ? null
                                  : (_) => _generateFromText(),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                color: _AppColors.onSurface,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Describe a scene...',
                                hintStyle: TextStyle(color: Colors.black38),
                                prefixIcon: Icon(
                                  Icons.auto_awesome,
                                  color: _AppColors.primary,
                                  size: 20,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Level Picker Strip
                        // Container(
                        //   height: 48,
                        //   padding: const EdgeInsets.all(4),
                        //   decoration: BoxDecoration(
                        //     color: Colors.black.withOpacity(0.05),
                        //     borderRadius: BorderRadius.circular(12),
                        //   ),
                        //   child:

                        // LevelWheelPicker(
                        //   levels: const ['A1', 'A2', 'B1', 'B2', 'C1'],
                        //   initialLevel: 'A1',
                        //   onLevelChanged: (newLevel) {
                        //     ScaffoldMessenger.of(context).clearSnackBars();
                        //     ScaffoldMessenger.of(context).showSnackBar(
                        //       SnackBar(
                        //         content: Text('change to $newLevel'),
                        //         behavior: SnackBarBehavior.floating,
                        //         duration: const Duration(seconds: 1),
                        //       ),
                        //     );
                        //   },
                        // ),

                        // ),
                        // Row(
                        //   children: ['A1', 'A2', 'B1'].map((level) {
                        //     final isSelected = _selectedLevel == level;
                        //     return GestureDetector(
                        //       onTap: () => setState(() => _selectedLevel = level),
                        //       child: Container(
                        //         padding: const EdgeInsets.symmetric(horizontal: 12),
                        //         alignment: Alignment.center,
                        //         decoration: BoxDecoration(
                        //           color: isSelected ? Colors.white : Colors.transparent,
                        //           borderRadius: BorderRadius.circular(8),
                        //           boxShadow: isSelected
                        //               ? [const BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))]
                        //               : null,
                        //         ),
                        //         child: Text(
                        //           level,
                        //           style: TextStyle(
                        //             fontFamily: 'Inter',
                        //             fontSize: 14,
                        //             fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        //             color: isSelected ? _AppColors.primary : _AppColors.onSurfaceVariant,
                        //           ),
                        //         ),
                        //       ),
                        //     );
                        //   }).toList(),
                        // ),
                        const SizedBox(width: 8),

                        // Submit Button
                        GestureDetector(
                          onTap: homeState.isGenerating
                              ? null
                              : _generateFromText,
                          child: Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF007AFF),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF007AFF,
                                  ).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: homeState.isGenerating
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.arrow_upward,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Quick Starters
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildQuickStarter(
                            'Bakery',
                            'A busy bakery in Berlin during morning rush.',
                          ),
                          _buildQuickStarter(
                            'Train Station',
                            'A rainy evening at a train station in Munich.',
                          ),
                          _buildQuickStarter(
                            'Park',
                            'A sunny weekend at the Tiergarten park.',
                          ),
                        ],
                      ),
                    ),

                    // Loading Shimmer Effect
                    if (homeState.isGenerating)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: SizedBox(
                            height: 4,
                            child: AnimatedBuilder(
                              animation: _shimmerController,
                              builder: (context, child) {
                                return FractionalTranslation(
                                  translation: Offset(
                                    (_shimmerController.value * 2) - 1,
                                    0,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          _AppColors.primary.withOpacity(0),
                                          _AppColors.primary.withOpacity(0.5),
                                          _AppColors.primary.withOpacity(0),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    if (homeState.isGenerating)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'AI is generating...',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: _AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),

      // 5. Bottom Navigation Bar
      // bottomNavigationBar: widget.showChrome
      //     ? ClipRRect(
      //         child: BackdropFilter(
      //           filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
      //           child: Container(
      //             height: 84,
      //             decoration: BoxDecoration(
      //               color: Colors.white.withOpacity(0.7),
      //               border: Border(
      //                 top: BorderSide(color: Colors.black.withOpacity(0.05)),
      //               ),
      //             ),
      //             child: Row(
      //               mainAxisAlignment: MainAxisAlignment.spaceAround,
      //               children: [
      //                 _buildNavItem(Icons.home, 'Home', true),
      //                 _buildNavItem(Icons.favorite_border, 'Favorites', false),
      //                 _buildNavItem(Icons.person_outline, 'Profile', false),
      //               ],
      //             ),
      //           ),
      //         ),
      //       )
      //     : null,
    );
  }

  double _uploadAreaHeight(
    BuildContext context,
    double bodyPaddingBottom,
    double viewportHeight,
  ) {
    final mediaQuery = MediaQuery.of(context);
    final shortestSide = mediaQuery.size.shortestSide;

    // 对话框贴近底部 nav，上传区吃掉中间剩余空间。
    // 这些估算值对应标题、说明、固定间距、底部输入面板和 navbar 避让。
    final reservedHeight =
        bodyPaddingBottom + 28.0 + 8.0 + 44.0 + 32.0 + 16.0 + 118.0;
    final preferredHeight = viewportHeight - reservedHeight;
    final minHeight = shortestSide < 360 ? 150.0 : 180.0;

    return math.max(preferredHeight, minHeight).toDouble();
  }

  // Helper: Frosted Glass Panel
  Widget _buildGlassContainer({
    required Widget child,
    required double radius,
    required EdgeInsets padding,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
          ),
          child: child,
        ),
      ),
    );
  }

  // Helper: Menu Button inside Image Area
  Widget _buildMenuOption(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _AppColors.primary, size: 20),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: _AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper: Quick Starter Chip
  Widget _buildQuickStarter(String label, String promptData) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => _fillPrompt(promptData),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _AppColors.outlineVariant.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✨', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: _AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper: Bottom Nav Item
  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Expanded(
      child: InkWell(
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 26,
              color: isActive
                  ? _AppColors.primary
                  : _AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isActive
                    ? _AppColors.primary
                    : _AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  final double radius;
  final Color color;

  const _DashedRRectPainter({required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(1.5),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final metric = path.computeMetrics().first;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const dash = 10.0;
    const gap = 8.0;
    var distance = 0.0;
    while (distance < metric.length) {
      final nextDistance = math.min(distance + dash, metric.length);
      canvas.drawPath(metric.extractPath(distance, nextDistance), paint);
      distance += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.radius != radius || oldDelegate.color != color;
  }
}

class _UploadParticlePainter extends CustomPainter {
  final double progress;
  final Offset? touchPoint;
  final Color primary;
  final Color accent;

  const _UploadParticlePainter({
    required this.progress,
    required this.touchPoint,
    required this.primary,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final count = size.shortestSide < 220 ? 22 : 34;

    for (var index = 0; index < count; index++) {
      final seed = index * 37.0;
      final baseX = (math.sin(seed) * 0.5 + 0.5) * size.width;
      final baseY = (math.cos(seed * 1.7) * 0.5 + 0.5) * size.height;
      final drift = progress * math.pi * 2;
      final phase = seed * 0.17;
      var point = Offset(
        baseX + math.sin(drift + phase) * 9 + math.sin(drift * 2 + phase) * 2,
        baseY + math.cos(drift + phase) * 7 + math.cos(drift * 2 + phase) * 1.5,
      );

      if (touchPoint != null) {
        final delta = touchPoint! - point;
        final distance = delta.distance;
        if (distance < 120 && distance > 0) {
          point += delta / distance * (120 - distance) * 0.16;
        }
      }

      final opacity = 0.14 + (math.sin(drift + phase) * 0.5 + 0.5) * 0.18;
      final radius = 1.8 + (index % 4) * 0.55;
      final paint = Paint()
        ..color = Color.lerp(
          primary,
          accent,
          (index % 7) / 6,
        )!.withOpacity(opacity);

      canvas.drawCircle(point, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _UploadParticlePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.touchPoint != touchPoint ||
        oldDelegate.primary != primary ||
        oldDelegate.accent != accent;
  }
}
