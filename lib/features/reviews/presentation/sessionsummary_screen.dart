import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'review_style.dart';
import 'reviews_provider.dart';

class _SessionSummaryData {
  final int reviewed;
  final int total;
  final int mastered;
  final int forgotten;
  final double progress;
  final double accuracy;

  const _SessionSummaryData({
    required this.reviewed,
    required this.total,
    required this.mastered,
    required this.forgotten,
    required this.progress,
    required this.accuracy,
  });
}

class SessionSummaryScreen extends ConsumerStatefulWidget {
  const SessionSummaryScreen({super.key});

  @override
  ConsumerState<SessionSummaryScreen> createState() =>
      _SessionSummaryScreenState();
}

class _SessionSummaryScreenState extends ConsumerState<SessionSummaryScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _confettiController;
  final List<_ConfettiParticle> _confettiParticles = [];

  @override
  void initState() {
    super.initState();

    // 奖杯浮动动画
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // 五彩碎纸粒子动画引擎
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // 初始生成一部分碎纸屑
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _burstConfetti();
    });
  }

  void _burstConfetti() {
    final size = MediaQuery.of(context).size;
    setState(() {
      for (int i = 0; i < 60; i++) {
        _confettiParticles.add(_ConfettiParticle(size));
      }
    });
  }

  void _handleContinueHomePressed() {
    context.go('/app/home');
  }

  void _handleReviewHistoryPressed() {
    context.go('/reviews');
  }

  _SessionSummaryData _resolveSummary() {
    final state = ref.watch(reviewsProvider).asData?.value;
    final total = state?.totalCount ?? 0;
    final reviewed = state?.submittedRatings.length ?? 0;
    final mastered = state?.masteredCount ?? 0;
    final forgotten = state?.forgottenCount ?? 0;
    final progress = total == 0 ? 0.0 : reviewed / total;
    final accuracy = state?.accuracy ?? 0;

    return _SessionSummaryData(
      reviewed: reviewed,
      total: total,
      mastered: mastered,
      forgotten: forgotten,
      progress: progress.clamp(0.0, 1.0),
      accuracy: accuracy.clamp(0.0, 1.0),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final summary = _resolveSummary();

    return Scaffold(
      body: Stack(
        children: [
          // 1. 阿尔卑斯山背景层 + 渐变滤镜
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=2070&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.4),
                    const Color(0xFFFAF8FF),
                  ],
                  stops: const [0.0, 0.4, 0.9],
                ),
              ),
            ),
          ),

          // 2. 顶层动态五彩纸屑
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              for (var particle in _confettiParticles) {
                particle.update(screenSize);
              }
              // 定时补充纸屑，维持喜庆氛围
              if (_confettiParticles.length < 20) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _confettiParticles.length < 20) {
                    _burstConfetti();
                  }
                });
              }
              return Positioned.fill(
                child: CustomPaint(
                  painter: _ConfettiPainter(_confettiParticles),
                ),
              );
            },
          ),

          // 3. 顶部导航栏 (AppBar)
          // Positioned(
          //   top: 0,
          //   left: 0,
          //   right: 0,
          //   child: SafeArea(
          //     child: Padding(
          //       padding: const EdgeInsets.symmetric(
          //         horizontal: 16.0,
          //         vertical: 8.0,
          //       ),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           ReviewPressable(
          //             onTap: _handleClosePressed,
          //             builder: (context, isHovered, isPressed) {
          //               return IgnorePointer(
          //                 child: IconButton(
          //                   icon: const Icon(
          //                     Icons.close,
          //                     color: Color(0xFF004AC6),
          //                   ),
          //                   onPressed: _handleClosePressed,
          //                 ),
          //               );
          //             },
          //           ),
          //           const Text(
          //             'Szenen',
          //             style: TextStyle(
          //               color: Color(0xFF004AC6),
          //               fontSize: 24,
          //               fontWeight: FontWeight.bold,
          //               fontFamily: 'Space Grotesk',
          //             ),
          //           ),
          //           ReviewPressable(
          //             onTap: _handleReviewHistoryPressed,
          //             builder: (context, isHovered, isPressed) {
          //               return IgnorePointer(
          //                 child: IconButton(
          //                   icon: const Icon(
          //                     Icons.notifications_outlined,
          //                     color: Color(0xFF434655),
          //                   ),
          //                   onPressed: _handleReviewHistoryPressed,
          //                 ),
          //               );
          //             },
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),

          // 4. 主体滚动内容区
          Positioned.fill(
            // top: kToolbarHeight + 40,
            bottom: 160,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildScrollableSummaryPanel(summary),
            ),
          ),

          // 5. 底部固定操作栏
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomActionBar(),
          ),
        ],
      ),
    );
  }

  // --- 细节组件抽取 ---

  Widget _buildScrollableSummaryPanel(_SessionSummaryData summary) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          color: Colors.white.withValues(alpha: 0.08),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // 奖杯 Hero 区
              _buildTrophyHero(),
              const SizedBox(height: 24),

              // 核心数据：今日掌握单词
              _buildMainScoreCard(summary),
              const SizedBox(height: 16),

              // 次要数据：网格布局
              _buildStatsGrid(summary),
              const SizedBox(height: 16),

              // 连续签到成就卡片
              _buildStreakCard(summary),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrophyHero() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            final double offset = sin(_floatController.value * pi * 2) * 10;
            final double rotation = sin(_floatController.value * pi * 2) * 0.04;
            return Transform.translate(
              offset: Offset(0, offset),
              child: Transform.rotate(angle: rotation, child: child),
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF004AC6).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(color: Colors.transparent),
                ),
              ),
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 54,
                  color: Color(0xFF004AC6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Excellent Work!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Color(0xFF004AC6),
            fontFamily: 'Space Grotesk',
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Daily Goal Reached!',
          style: TextStyle(fontSize: 18, color: Color(0xFF434655)),
        ),
      ],
    );
  }

  Widget _buildMainScoreCard(_SessionSummaryData summary) {
    return _GlassCard(
      child: Column(
        children: [
          Text(
            '${summary.mastered}',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: Color(0xFF004AC6),
              fontFamily: 'Space Grotesk',
            ),
          ),
          const Text(
            'WORDS MASTERED TODAY',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF434655),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily Goal',
                style: TextStyle(fontSize: 12, color: Color(0xFF434655)),
              ),
              Text(
                '${(summary.progress * 100).round()}% Complete',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004AC6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 带有平滑缓冲加载动画的进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 8,
              width: double.infinity,
              color: const Color(0xFFC3C6D7).withValues(alpha: 0.3),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: summary.progress),
                duration: const Duration(milliseconds: 1500),
                curve: const Cubic(0.34, 1.56, 0.64, 1), // 完美复刻 CSS 的回弹曲线
                builder: (context, value, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: value,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF004AC6), Color(0xFF712AE2)],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(_SessionSummaryData summary) {
    return Row(
      children: [
        Expanded(
          child: _GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                const Icon(Icons.gps_fixed, color: Color(0xFF712AE2)),
                const SizedBox(height: 8),
                Text(
                  '${(summary.accuracy * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF131B2E),
                  ),
                ),
                const Text(
                  'Accuracy',
                  style: TextStyle(fontSize: 12, color: Color(0xFF434655)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                const Icon(Icons.timer_outlined, color: Color(0xFF943700)),
                const SizedBox(height: 8),
                Text(
                  '${summary.reviewed}/${summary.total}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF131B2E),
                  ),
                ),
                const Text(
                  'Reviewed',
                  style: TextStyle(fontSize: 12, color: Color(0xFF434655)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard(_SessionSummaryData summary) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Row(
            children: [
              Container(width: 4, height: 82, color: const Color(0xFF943700)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFDBCD),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_fire_department,
                          color: Color(0xFF943700),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${summary.reviewed} Cards Reviewed',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF131B2E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'You\'re on fire! Keep it up.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF434655),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Color(0xFFC3C6D7)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          color: Colors.white.withValues(alpha: 0.9),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ReviewPressable(
                onTap: _handleContinueHomePressed,
                pressedScale: 0.98,
                builder: (context, isHovered, isPressed) {
                  return IgnorePointer(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004AC6),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        elevation: isHovered || isPressed ? 6 : 4,
                        shadowColor: const Color(
                          0xFF004AC6,
                        ).withValues(alpha: 0.3),
                      ),
                      onPressed: _handleContinueHomePressed,
                      child: const Text(
                        'Continue to Home',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              ReviewPressable(
                onTap: _handleReviewHistoryPressed,
                pressedScale: 0.98,
                builder: (context, isHovered, isPressed) {
                  return IgnorePointer(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF004AC6),
                        minimumSize: const Size(double.infinity, 54),
                        side: const BorderSide(
                          color: Color(0xFF004AC6),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      onPressed: _handleReviewHistoryPressed,
                      child: const Text(
                        'Review History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 辅助通用毛玻璃卡片容器
// ==========================================
class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const _GlassCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20.0),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 高性能核心：碎纸屑计算模型与绘图器
// ==========================================
class _ConfettiParticle {
  double x, y, size, speedX, speedY, gravity, rotation, rotationSpeed;
  Color color;

  _ConfettiParticle(Size bounds)
    : x = bounds.width / 2, // 喷发起点在中上部奖杯处
      y = bounds.height / 3,
      size = Random().nextDouble() * 6 + 4,
      speedX = Random().nextDouble() * 12 - 6,
      speedY = Random().nextDouble() * -12 - 4,
      gravity = 0.25,
      rotation = Random().nextDouble() * 360,
      rotationSpeed = Random().nextDouble() * 8 - 4,
      color = HSVColor.fromAHSV(
        1.0,
        Random().nextDouble() * 360,
        0.7,
        0.9,
      ).toColor();

  void update(Size bounds) {
    speedY += gravity;
    x += speedX;
    y += speedY;
    rotation += rotationSpeed;
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < particles.length; i++) {
      final p = particles[i];
      if (p.y > size.height) {
        particles.removeAt(i);
        i--;
        continue;
      }

      final paint = Paint()..color = p.color;
      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation * pi / 180);
      // 绘制带旋转的小正方形碎纸屑
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
