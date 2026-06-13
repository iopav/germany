import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:germany/core/widgets/scene_image_cache.dart';
import 'package:germany/core/utils/error_utils.dart';
import 'package:go_router/go_router.dart';

import '../../home/domain/entity/home_stats_entity.dart';
import '../domain/entity/reviews_entity.dart';
import 'review_style.dart';
import 'reviews_provider.dart';
import 'sessionsummary_screen.dart';

// 复习卡片主页面。
//
// 这个页面负责把 reviewsProvider 提供的复习会话状态渲染成一个沉浸式 UI：
// 1. 背景显示当前场景图片。
// 2. 中间显示当前需要回忆的物体检测框。
// 3. 底部让用户输入德语答案，或直接选择掌握/不知道。
// 4. 本轮复习结束后跳转到 SessionSummaryScreen。
//
// 使用 ConsumerStatefulWidget 的原因：
// - Consumer 能直接读取/监听 Riverpod provider。
// - Stateful 能管理 TextEditingController、动画控制器和局部反馈状态。
class ReviewCardScreen extends ConsumerStatefulWidget {
  const ReviewCardScreen({super.key});

  @override
  ConsumerState<ReviewCardScreen> createState() => _ReviewCardScreenState();
}

class _ReviewCardScreenState extends ConsumerState<ReviewCardScreen>
    with TickerProviderStateMixin {
  // 底部德语答案输入框的控制器。
  // 用于读取当前输入内容，以及答对后主动清空输入框。
  final TextEditingController _textController = TextEditingController();

  // 动画控制器：_shakeController 负责答错时左右抖动输入框。
  late AnimationController _shakeController;

  // 页面内部 UI 状态：错误态、成功态，以及防止复习完成后重复跳转总结页的标记。
  bool _isError = false;
  bool _isSuccess = false;
  bool _navigatedToSummary = false;
  bool _isExitDialogShowing = false;
  String? _answerFeedbackText;

  @override
  void initState() {
    super.initState();

    // 创建输入错误时的抖动动画，只在提交错误答案时手动触发。
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // 首帧渲染后加载当前 review 关联的 scene，避免在 build 前直接触发异步 UI 更新。
    //
    // 为什么放到 addPostFrameCallback：
    // - initState 中可以读取 notifier，但异步加载会改 provider 状态。
    // - 放到首帧之后，能减少页面初始化阶段的状态更新和 build 互相打架。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(reviewsProvider.notifier).ensureCurrentSceneLoaded();
    });
  }

  // 页面销毁时释放输入框和动画控制器，避免内存泄漏。
  @override
  void dispose() {
    _textController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  // 处理用户提交的输入答案：空输入只提示，答对提交 rating=3，答错提交 rating=2。
  // 输入和标准答案都会 trim + lowercase，减少大小写和前后空格对校验的影响。
  //
  // rating 含义按当前页面约定：
  // - 1: 用户点击 I don't know，完全不会。
  // - 2: 用户输入了答案但答错。
  // - 3: 用户输入答案并答对。
  // - 4: 用户点击 Mastered，认为已经掌握。
  Future<void> _handleSubmit(String value, String answer) async {
    final input = value.trim().toLowerCase();
    final normalizedAnswer = answer.trim().toLowerCase();

    if (input.isEmpty) {
      // 空输入不提交到后端，只给本地错误反馈。
      setState(() {
        _isError = true;
        _isSuccess = false;
        _answerFeedbackText = answer;
      });
      _shakeController.forward(from: 0.0);
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) {
        return;
      }
      setState(() {
        _isError = false;
        _answerFeedbackText = null;
      });
      _textController.clear();
      return;
    }

    if (input == normalizedAnswer) {
      // 答案匹配：先显示成功态，再把评分提交给 provider。
      setState(() {
        _isSuccess = true;
        _isError = false;
        _answerFeedbackText = null;
      });

      await ref.read(reviewsProvider.notifier).submitRating(3);

      if (!mounted) {
        return;
      }

      // 答对后保留 1 秒绿色反馈，再清空输入并恢复普通状态。
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _isSuccess = false);
          _textController.clear();
        }
      });
    } else {
      // 答案不匹配：显示错误态并提交较低评分。
      setState(() {
        _isError = true;
        _isSuccess = false;
        _answerFeedbackText = answer;
      });
      _shakeController.forward(from: 0.0); // 触发输入框抖动，提示用户答案不匹配。

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) {
        return;
      }

      setState(() {
        _isError = false;
        _answerFeedbackText = null;
      });
      _textController.clear();
      await ref.read(reviewsProvider.notifier).submitRating(2);
    }
  }

  Future<void> _handleExitRequested() async {
    final shouldExit = await _confirmExitReview();
    if (!mounted || !shouldExit) {
      return;
    }

    context.go('/reviews');
  }

  Future<void> _handleForgottenAnswer(String answer) async {
    setState(() {
      _isError = true;
      _isSuccess = false;
      _answerFeedbackText = answer;
    });
    _shakeController.forward(from: 0.0);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) {
      return;
    }

    setState(() {
      _isError = false;
      _answerFeedbackText = null;
    });
    _textController.clear();
    await ref.read(reviewsProvider.notifier).submitRating(1);
  }

  Future<void> _handleMasteredAnswer() async {
    setState(() {
      _isSuccess = true;
      _isError = false;
      _answerFeedbackText = null;
    });

    await ref.read(reviewsProvider.notifier).submitRating(4);

    if (!mounted) {
      return;
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isSuccess = false);
        _textController.clear();
      }
    });
  }

  Future<bool> _confirmExitReview() async {
    if (_isExitDialogShowing) {
      return false;
    }

    _isExitDialogShowing = true;
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF131B2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Leave review?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Your completed cards have been saved. You can continue this session later.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'Stay',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Leave',
                style: TextStyle(color: Color(0xFF8FB3FF)),
              ),
            ),
          ],
        );
      },
    );
    _isExitDialogShowing = false;
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // 监听 provider 中的一次性错误消息，出现新的 errorMessage 时用 SnackBar 提示。
    ref.listen<AsyncValue<ReviewsState>>(reviewsProvider, (previous, next) {
      final previousMessage = previous?.asData?.value.errorMessage;
      final nextMessage = next.asData?.value.errorMessage;
      if (nextMessage == null ||
          nextMessage.isEmpty ||
          nextMessage == previousMessage) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(nextMessage)));
    });

    // watch 当前复习会话状态；AsyncValue 会自动区分 loading / error / data 三种 UI。
    final reviewsAsync = ref.watch(reviewsProvider);

    return reviewsAsync.when(
      loading: () => _buildLoadingScaffold(),
      error: (error, _) => _buildErrorScaffold(
        ErrorUtils.extractMessage(
          error,
          fallback: 'Failed to fetch due reviews. Please try again.',
        ),
      ),
      data: (state) {
        // 当本轮复习完成时跳转到总结页。用 _navigatedToSummary 避免 build 多次触发重复导航。
        if (state.sessionCompleted && !_navigatedToSummary) {
          _navigatedToSummary = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const SessionSummaryScreen()),
            );
          });
        }

        final currentReview = state.currentReview;
        final currentScene = state.currentScene;

        // 当前卡片存在但 scene 还没加载时，补发一次 scene 加载请求。
        if (currentReview != null &&
            currentScene == null &&
            !state.isLoadingScene) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ref.read(reviewsProvider.notifier).ensureCurrentSceneLoaded();
            }
          });
        }

        if (state.isEmptySession) {
          // 队列为空时不展示主复习 UI，直接展示空状态。
          return _buildEmptyScaffold();
        }

        // 主复习界面。
        //
        // Stack 从底到顶的层级：
        // 1. _PositionedSceneViewer：整屏 scene 图片，并把当前 bbox 移到答题栏上方。
        // 2. ParticleBackground：半透明粒子氛围层。
        // 3. 顶部 header：关闭按钮和进度。
        // 4. 底部 glass panel：答案输入和快捷评分。
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              return;
            }
            _handleExitRequested();
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              fit: StackFit.expand,
              children: [
                // 场景图层：只渲染一张 scene 图片，支持拖动缩放，并只画当前单词匹配的 bbox。
                _PositionedSceneViewer(
                  scene: currentScene,
                  focusLabel:
                      currentReview?.objectLabel ?? currentReview?.lemma ?? '',
                ),

                // 动态粒子层：在背景图之上叠加细小白色漂浮点，营造扫描/科技感。
                const ParticleBackground(),

                // 顶部导航和进度条：左侧关闭按钮，中间 session 进度，右侧更多按钮。
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  // SafeArea 避开刘海屏、状态栏等系统区域。
                  child: SafeArea(child: _buildHeader(state)),
                ),

                // 底部毛玻璃输入面板：展示英文提示、德语冠词、输入框和快捷评价按钮。
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      // 底部面板和屏幕边缘保留 16px 间距，让毛玻璃卡片不会贴边。
                      padding: const EdgeInsets.all(16.0),
                      child: _buildBottomGlassPanel(currentReview),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 加载态 UI：进入页面或刷新队列时显示黑底白色 loading。
  Widget _buildLoadingScaffold() {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  // 空会话 UI：当前没有可复习卡片时，给用户一个刷新入口。
  Widget _buildEmptyScaffold() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: TextButton(
          onPressed: () => ref.read(reviewsProvider.notifier).refresh(),
          child: const Text(
            'No cards. Refresh',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  // 错误态 UI：展示错误图标、错误文案和 Retry 按钮，便于重新拉取复习队列。
  Widget _buildErrorScaffold(String error) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 12),
              Text(
                error,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(reviewsProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 顶部进度栏组件：左边是关闭按钮，中间显示本轮复习进度，右边预留更多操作按钮。
  Widget _buildHeader(ReviewsState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          _buildGlassIconButton(Icons.close, onTap: _handleExitRequested),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 文字行：左侧是固定标题，右侧是「已完成 / 总数」。
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'SESSION PROGRESS',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${state.completedCount} of ${state.totalCount} words',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // 线性进度条：value 来自 ReviewsState.progress，范围 0.0 到 1.0。
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: state.progress,
                      minHeight: 6,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF004ac6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 更多按钮：目前没有绑定实际菜单，作为后续扩展入口。
          _buildGlassIconButton(Icons.more_vert, onTap: () {}),
        ],
      ),
    );
  }

  // 底部毛玻璃输入面板：展示英文提示、输入框、回车提示，以及 Mastered / I don't know 快捷按钮。
  Widget _buildBottomGlassPanel(ReviewEntity? review) {
    // englishHint 是给用户看的提示，比如后端传来的英文翻译。
    final englishHint = _resolveEnglishHint(review);
    // answer 是标准德语答案，用来和用户输入做本地比对。
    final answer = review?.lemma ?? '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        // BackdropFilter 会模糊它背后的背景图，形成毛玻璃质感。
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF131B2E).withValues(alpha: 0.75),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(40),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 小标题：说明当前大字显示的是需要识别/回忆的物体。
              const Text(
                'CURRENT OBJECT',
                style: TextStyle(
                  color: Color(0xFFb4c5ff),
                  fontSize: 12,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              // 英文提示主标题：优先显示后端英文翻译，缺失时用默认占位文案。
              Text(
                englishHint.isNotEmpty ? englishHint : 'The Table',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Space Grotesk',
                ),
              ),
              const SizedBox(height: 24),

              // 带有抖动动画的输入框：错误提交时 AnimatedBuilder 会驱动左右位移。
              AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  final offset = sin(_shakeController.value * pi * 4) * 8;
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: child,
                  );
                },
                child: _buildInputRow(answer),
              ),

              const SizedBox(height: 16),
              // 回车提示行：告诉用户键盘 Enter 也可以提交答案。
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.keyboard_return, color: Colors.white38, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Press Enter to Check',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 快捷评分按钮行：
              // Mastered 跳过输入并提交最高评分；I don't know 提交最低评分。
              Row(
                children: [
                  Expanded(
                    child: _buildActionChip(
                      'Mastered',
                      isSolid: true,
                      onTap: _handleMasteredAnswer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionChip(
                      'I don\'t know',
                      isSolid: false,
                      onTap: () => _handleForgottenAnswer(answer),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 德语答案输入行：左侧显示冠词，中间输入名词，右侧箭头按钮提交答案。
  // 边框颜色会根据 _isSuccess / _isError 切换成绿色或红色。
  Widget _buildInputRow(String answer) {
    // 默认边框是浅色；成功变绿，错误变红。
    Color borderColor = Colors.white10;
    if (_isSuccess) borderColor = Colors.green.withValues(alpha: 0.5);
    if (_isError) borderColor = Colors.red.withValues(alpha: 0.5);
    final feedbackText = _answerFeedbackText;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Row(
        children: [
          // 冠词区域：显示 der/die/das 或后端给到的 article/gender。
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 8.0),
            child: Text(
              _resolveArticle(
                review: ref.read(reviewsProvider).value?.currentReview,
              ),
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Expanded(
            // 用户输入区域：输入德语名词，回车时触发 _handleSubmit。
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                TextField(
                  controller: _textController,
                  autofocus: true,
                  style: TextStyle(
                    color: feedbackText == null
                        ? Colors.white
                        : Colors.transparent,
                    fontSize: 24,
                  ),
                  decoration: const InputDecoration(border: InputBorder.none),
                  cursorColor: feedbackText == null
                      ? const Color(0xFF004ac6)
                      : Colors.transparent,
                  onSubmitted: (value) => _handleSubmit(value, answer),
                ),
                if (feedbackText != null)
                  IgnorePointer(
                    child: Text(
                      feedbackText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            // 箭头按钮：点击时使用当前输入框文本提交答案。
            child: ReviewPressable(
              onTap: () => _handleSubmit(_textController.text, answer),
              builder: (context, isHovered, isPressed) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOut,
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isPressed
                        ? const Color(0xFF003A99)
                        : isHovered
                        ? const Color(0xFF0B5BE8)
                        : const Color(0xFF004ac6),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isHovered || isPressed
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFF004ac6,
                              ).withValues(alpha: 0.3),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: const Icon(Icons.arrow_forward, color: Colors.white),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 毛玻璃图标按钮：用于顶部关闭按钮和更多按钮，保持和页面整体玻璃拟态风格一致。
  Widget _buildGlassIconButton(IconData icon, {required VoidCallback onTap}) {
    return ReviewGlassIconButton(icon: icon, onTap: onTap);
  }

  // 底部快捷评价按钮：Mastered 直接提交 rating=4，I don't know 直接提交 rating=1。
  Widget _buildActionChip(
    String label, {
    required bool isSolid,
    required VoidCallback onTap,
  }) {
    return ReviewActionChip(label: label, isSolid: isSolid, onTap: onTap);
  }

  // 从 review.content 中按优先级解析英文提示；如果后端字段缺失，则退回到 objectLabel 或 lemma。
  String _resolveEnglishHint(ReviewEntity? review) {
    final content = review?.content ?? const <String, dynamic>{};
    // 兼容后端可能出现的不同字段名，越靠前优先级越高。
    final candidates = [
      content['translation_l1'],
      content['en'],
      content['word_en'],
      content['english'],
      review?.objectLabel,
      review?.lemma,
    ];

    for (final candidate in candidates) {
      final value = candidate?.toString().trim() ?? '';
      if (value.isNotEmpty) {
        return value;
      }
    }

    return '';
  }

  // 解析德语冠词：优先使用 article，其次使用 gender，仍然没有时默认显示 der。
  String _resolveArticle({ReviewEntity? review}) {
    final content = review?.content ?? const <String, dynamic>{};
    // article 通常会是 der/die/das；gender 可能是后端旧字段或替代字段。
    final candidates = [content['article'], content['gender']];

    for (final candidate in candidates) {
      final value = candidate?.toString().trim() ?? '';
      if (value.isNotEmpty) {
        return value;
      }
    }

    return 'der';
  }
}

// 可定位场景图组件：只渲染一张 scene 原图，并把当前单词对应的 bbox 移到答题栏上方。
//
// 和旧逻辑不同：
// - 不再额外绘制一张中央裁剪图。
// - bbox 框直接画在同一张 scene 图片上。
// - 图片和 bbox 放在同一个 InteractiveViewer 里，所以用户拖动/缩放时两者会一起移动。
class _PositionedSceneViewer extends StatefulWidget {
  final SceneEntity? scene;
  final String focusLabel;

  const _PositionedSceneViewer({required this.scene, required this.focusLabel});

  @override
  State<_PositionedSceneViewer> createState() => _PositionedSceneViewerState();
}

class _PositionedSceneViewerState extends State<_PositionedSceneViewer> {
  final TransformationController _transformationController =
      TransformationController();

  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;
  ImageInfo? _imageInfo;
  String? _lastImageUrl;
  String? _lastTransformKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant _PositionedSceneViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene?.id != widget.scene?.id ||
        oldWidget.focusLabel != widget.focusLabel) {
      _lastTransformKey = null;
      _resolveImage();
    }
  }

  @override
  void dispose() {
    _detachListener();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageInfo = _imageInfo;
    if (imageInfo == null) {
      return Container(
        color: Colors.black,
        child: CustomPaint(painter: ScannerBoxPainter()),
      );
    }

    final imageWidth = imageInfo.image.width.toDouble();
    final imageHeight = imageInfo.image.height.toDouble();
    final detection = _resolveFocusedDetection(widget.scene, widget.focusLabel);

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportSize = Size(constraints.maxWidth, constraints.maxHeight);
        _scheduleInitialTransform(
          viewportSize: viewportSize,
          imageSize: Size(imageWidth, imageHeight),
          detection: detection,
        );

        return Container(
          color: Colors.black,
          child: InteractiveViewer(
            transformationController: _transformationController,
            constrained: false,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            minScale: 0.1,
            maxScale: 12,
            child: SizedBox(
              width: imageWidth,
              height: imageHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  RawImage(image: imageInfo.image, fit: BoxFit.fill),
                  if (detection != null && detection.bbox.length >= 4)
                    Positioned(
                      left: detection.left,
                      top: detection.top,
                      width: detection.width,
                      height: detection.height,
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFF004ac6),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF004ac6,
                                ).withValues(alpha: 0.35),
                                blurRadius: 18,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _resolveImage() {
    final imageUrl = _resolveImageUrl(widget.scene);
    if (imageUrl.isEmpty) {
      _detachListener();
      return;
    }

    if (_lastImageUrl == imageUrl && _imageInfo != null) {
      return;
    }

    _detachListener();
    _lastImageUrl = imageUrl;

    final provider = SceneImageCache.provider(imageUrl);
    final stream = provider.resolve(createLocalImageConfiguration(context));
    _imageStreamListener = ImageStreamListener(
      (info, _) {
        if (!mounted) {
          return;
        }
        setState(() {
          _imageInfo = info;
          _lastTransformKey = null;
        });
      },
      onError: (error, stackTrace) {
        if (!mounted) {
          return;
        }
        setState(() {
          _imageInfo = null;
          _lastTransformKey = null;
        });
      },
    );
    stream.addListener(_imageStreamListener!);
    _imageStream = stream;
  }

  void _detachListener() {
    if (_imageStream != null && _imageStreamListener != null) {
      _imageStream!.removeListener(_imageStreamListener!);
    }
    _imageStream = null;
    _imageStreamListener = null;
    _imageInfo = null;
  }

  void _scheduleInitialTransform({
    required Size viewportSize,
    required Size imageSize,
    required SceneDetectionEntity? detection,
  }) {
    if (viewportSize.width <= 0 ||
        viewportSize.height <= 0 ||
        imageSize.width <= 0 ||
        imageSize.height <= 0) {
      return;
    }

    final key = [
      widget.scene?.id ?? '',
      widget.focusLabel,
      viewportSize.width.toStringAsFixed(1),
      viewportSize.height.toStringAsFixed(1),
      imageSize.width.toStringAsFixed(1),
      imageSize.height.toStringAsFixed(1),
      detection?.id ?? 'none',
    ].join('|');

    if (_lastTransformKey == key) {
      return;
    }
    _lastTransformKey = key;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _transformationController.value = _buildInitialMatrix(
        viewportSize: viewportSize,
        imageSize: imageSize,
        detection: detection,
      );
    });
  }

  Matrix4 _buildInitialMatrix({
    required Size viewportSize,
    required Size imageSize,
    required SceneDetectionEntity? detection,
  }) {
    final containScale = min(
      viewportSize.width / imageSize.width,
      viewportSize.height / imageSize.height,
    );

    if (detection == null ||
        detection.bbox.length < 4 ||
        detection.width <= 0 ||
        detection.height <= 0) {
      final scale = containScale * 0.92;
      final dx = (viewportSize.width - imageSize.width * scale) / 2;
      final dy = _upperImageOffset(viewportSize, imageSize, scale);
      return _matrixFromScaleAndOffset(scale, dx, dy);
    }

    final safeTop = MediaQuery.paddingOf(context).top + 88;
    final visibleBottom = max(safeTop + 120, viewportSize.height * 0.58);
    final visibleHeight = max(120.0, visibleBottom - safeTop);
    final targetCenter = Offset(
      viewportSize.width / 2,
      safeTop + visibleHeight * 0.42,
    );

    final desiredBoxWidth = min(viewportSize.width * 0.42, 190.0);
    final desiredBoxHeight = min(visibleHeight * 0.32, 120.0);
    final focusScale = min(
      desiredBoxWidth / detection.width,
      desiredBoxHeight / detection.height,
    );
    final scale = max(containScale * 0.92, min(focusScale, containScale * 2.2));

    final bboxCenter = Offset(
      detection.left + detection.width / 2,
      detection.top + detection.height / 2,
    );

    final scaledWidth = imageSize.width * scale;
    final scaledHeight = imageSize.height * scale;
    var dx = targetCenter.dx - bboxCenter.dx * scale;
    var dy = targetCenter.dy - bboxCenter.dy * scale;

    dx = _clampImageOffset(dx, viewportSize.width, scaledWidth);
    dy = _clampImageOffset(dy, viewportSize.height, scaledHeight);

    return _matrixFromScaleAndOffset(scale, dx, dy);
  }

  double _clampImageOffset(double offset, double viewport, double scaledImage) {
    if (scaledImage <= viewport) {
      return (viewport - scaledImage) / 2;
    }
    return offset.clamp(viewport - scaledImage, 0.0).toDouble();
  }

  double _upperImageOffset(Size viewportSize, Size imageSize, double scale) {
    final scaledHeight = imageSize.height * scale;
    if (scaledHeight >= viewportSize.height) {
      return 0;
    }
    final safeTop = MediaQuery.paddingOf(context).top + 72;
    final targetTop = min(safeTop, (viewportSize.height - scaledHeight) / 2);
    return targetTop.clamp(0.0, viewportSize.height - scaledHeight).toDouble();
  }

  Matrix4 _matrixFromScaleAndOffset(double scale, double dx, double dy) {
    return Matrix4.identity()
      ..setEntry(0, 0, scale)
      ..setEntry(1, 1, scale)
      ..setEntry(0, 3, dx)
      ..setEntry(1, 3, dy);
  }

  SceneDetectionEntity? _resolveFocusedDetection(
    SceneEntity? scene,
    String focusLabel,
  ) {
    final detections = scene?.detectionResult ?? const <SceneDetectionEntity>[];
    if (detections.isEmpty) {
      return null;
    }

    final normalizedFocus = focusLabel.trim().toLowerCase();
    if (normalizedFocus.isEmpty) {
      return null;
    }

    for (final detection in detections) {
      if (detection.label.trim().toLowerCase() == normalizedFocus) {
        return detection;
      }
    }

    return null;
  }

  String _resolveImageUrl(SceneEntity? scene) {
    return SceneImageCache.resolveSceneImageUrl(scene);
  }
}

// 扫描框绘制器：当 scene 图片或 bbox 不可用时，绘制一个蓝色科技感边角框和中线。
//
// 它是 CustomPainter，不依赖任何图片资源；scene 加载前也能给用户一个稳定的视觉占位。
class ScannerBoxPainter extends CustomPainter {
  // 绘制四个角的扫描框边线，以及中间一条半透明扫描线。
  @override
  void paint(Canvas canvas, Size size) {
    // 主画笔：蓝色描边，用于四个角的扫描框。
    final paint = Paint()
      ..color = const Color(0xFF004ac6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const double cornerLength = 24.0;
    const double radius = 16.0;

    // 左上角边线。
    canvas.drawPath(
      Path()
        ..moveTo(0, cornerLength)
        ..lineTo(0, radius)
        ..quadraticBezierTo(0, 0, radius, 0)
        ..lineTo(cornerLength, 0),
      paint,
    );
    // 右上角边线。
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerLength, 0)
        ..lineTo(size.width - radius, 0)
        ..quadraticBezierTo(size.width, 0, size.width, radius)
        ..lineTo(size.width, cornerLength),
      paint,
    );
    // 左下角边线。
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - cornerLength)
        ..lineTo(0, size.height - radius)
        ..quadraticBezierTo(0, size.height, radius, size.height)
        ..lineTo(cornerLength, size.height),
      paint,
    );
    // 右下角边线。
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerLength, size.height)
        ..lineTo(size.width - radius, size.height)
        ..quadraticBezierTo(
          size.width,
          size.height,
          size.width,
          size.height - radius,
        )
        ..lineTo(size.width, size.height - cornerLength),
      paint,
    );

    // 绘制中部微弱的扫描线。
    // 这里使用横向透明渐变，让扫描线中心更亮、两侧慢慢消失。
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF004ac6).withValues(alpha: 0.5),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height))
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      gradientPaint,
    );
  }

  @override
  // 静态扫描框不依赖外部状态，所以不需要重复 repaint。
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 动态粒子背景组件：在页面上叠加缓慢移动的白色小点，作为氛围层。
//
// 它放在背景图之上、主要内容之下：
// - 不响应点击。
// - 每帧更新粒子坐标。
// - 通过 CustomPaint 画出轻微漂浮的点状效果。
class ParticleBackground extends StatefulWidget {
  const ParticleBackground({super.key});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  // 粒子动画控制器和粒子列表；controller 每帧驱动粒子位置更新。
  late AnimationController _controller;
  List<_Particle> particles = [];

  @override
  void initState() {
    super.initState();
    // controller 只作为帧驱动器使用；每次 tick 时 AnimatedBuilder 会重建并更新粒子位置。
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (particles.isEmpty) {
      // 首次拿到屏幕尺寸后初始化 40 个粒子。
      // 放在 didChangeDependencies 是因为这里可以安全读取 MediaQuery。
      final size = MediaQuery.of(context).size;
      particles = List.generate(40, (index) => _Particle(size));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // 每一帧先更新粒子位置，再交给 _ParticlePainter 绘制。
        for (var p in particles) {
          p.update(MediaQuery.of(context).size);
        }
        return CustomPaint(painter: _ParticlePainter(particles));
      },
    );
  }
}

// 单个粒子的数据模型：记录位置、速度、大小和透明度。
class _Particle {
  // x/y：当前位置。
  // speedX/speedY：每帧移动速度。
  // size：圆点半径。
  // opacity：透明度，制造远近层次感。
  double x, y, speedX, speedY, size, opacity;

  _Particle(Size bounds)
    // 随机初始位置，让粒子均匀散落在屏幕范围内。
    : x = Random().nextDouble() * bounds.width,
      y = Random().nextDouble() * bounds.height,
      // 半径 0.5 到 2.5，避免粒子太抢眼。
      size = Random().nextDouble() * 2 + 0.5,
      // 速度很小，让背景是轻微漂浮，而不是明显运动。
      speedX = Random().nextDouble() * 0.5 - 0.25,
      speedY = Random().nextDouble() * 0.5 - 0.25,
      opacity = Random().nextDouble() * 0.5;

  // 每一帧根据速度移动粒子，超出屏幕边界后从另一侧重新出现。
  void update(Size bounds) {
    x += speedX;
    y += speedY;
    // 越界后从对侧出现，形成无缝循环的漂浮效果。
    if (x > bounds.width) x = 0;
    if (x < 0) x = bounds.width;
    if (y > bounds.height) y = 0;
    if (y < 0) y = bounds.height;
  }
}

// 粒子绘制器：遍历粒子列表，在 canvas 上画出对应透明度和大小的圆点。
class _ParticlePainter extends CustomPainter {
  // 当前所有粒子的数据，由 ParticleBackground 每帧更新后传入。
  final List<_Particle> particles;

  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      // 每个粒子使用自己的透明度，画成白色圆点。
      final paint = Paint()..color = Colors.white.withValues(alpha: p.opacity);
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
