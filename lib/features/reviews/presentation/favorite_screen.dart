import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:germany/core/widgets/scene_image_cache.dart';
import 'package:go_router/go_router.dart';

import '../domain/entity/reviews_entity.dart';
import 'review_style.dart';
import 'reviews_provider.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  final List<String> _filters = ['All Levels', 'A1', 'A2', 'B1', 'B2', 'C1'];
  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(reviewCardsProvider.future);
        _warmUpReviewImages();
      }
    });
  }

  Future<void> _warmUpReviewImages() async {
    await ref.read(reviewsProvider.future);
    if (!mounted) {
      return;
    }

    final scenes = await ref
        .read(reviewsProvider.notifier)
        .prefetchUpcomingScenes(count: 4);
    if (!mounted) {
      return;
    }

    for (final scene in scenes) {
      await SceneImageCache.precacheScene(context, scene);
      if (!mounted) {
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(reviewsProvider);
    final cardsAsync = ref.watch(reviewCardsProvider);
    final reviewState = reviewsAsync.asData?.value;
    final dueQueue = reviewState?.queue ?? const <ReviewEntity>[];
    final cards = cardsAsync.asData?.value ?? const <ReviewEntity>[];
    final filteredCards = _filterCardsBySelectedLevel(cards);

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true, // 允许内容滚动到自定义底部导航栏的毛玻璃下方
      // appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: ReviewStyle.favoritesPagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(dueQueue.length),
            const SizedBox(height: 16),
            // _buildStatsRow(cards, reviewState?.masteredCount ?? 0),
            // const SizedBox(height: 24),
            _buildFilters(),
            const SizedBox(height: 24),
            _buildListHeader(),
            const SizedBox(height: 16),
            _buildVocabList(filteredCards),
          ],
        ),
      ),
      // bottomNavigationBar: _buildBottomNav(),
    );
  }

  Future<void> _startReview() async {
    final current = ref.read(reviewsProvider).asData?.value;
    if (current == null ||
        current.sessionCompleted ||
        current.currentReview == null) {
      await ref.read(reviewsProvider.notifier).refresh();
    }

    if (!mounted) {
      return;
    }

    final updated = ref.read(reviewsProvider).asData?.value;
    if (updated == null || updated.currentReview == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No cards due for review right now.')),
      );
      return;
    }

    context.go('/reviews/session');
  }

  void _handleLevelFilterChanged(int index) {
    setState(() => _selectedFilterIndex = index);
    // TODO: 后续如需服务端筛选，在这里补充按等级重新拉取/过滤收藏词卡的逻辑。
  }

  void _handleDeleteCard(ReviewEntity review) {
    // TODO: 后续补充删除收藏词卡/移出复习列表的接口调用。
  }

  void _handleSortPressed() {
    // TODO: 后续补充收藏词卡排序方式切换逻辑。
  }

  List<ReviewEntity> _filterCardsBySelectedLevel(List<ReviewEntity> cards) {
    if (_selectedFilterIndex == 0) {
      return cards;
    }
    final selectedLevel = _filters[_selectedFilterIndex];
    return cards
        .where((card) => card.cefrLevel.value.toUpperCase() == selectedLevel)
        .toList();
  }

  // ====== AppBar (带毛玻璃效果) ======
  // PreferredSizeWidget _buildAppBar() {
  //   return PreferredSize(
  //     preferredSize: const Size.fromHeight(kToolbarHeight),
  //     child: ClipRRect(
  //       child: BackdropFilter(
  //         filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
  //         child: AppBar(
  //           backgroundColor: const Color(0xFFFAF8FF).withOpacity(0.8),
  //           elevation: 0,
  //           scrolledUnderElevation: 1,
  //           shadowColor: Colors.black.withOpacity(0.1),
  //           title: const Row(
  //             children: [
  //               Icon(Icons.language, color: Color(0xFF004AC6)),
  //               SizedBox(width: 8),
  //               Text(
  //                 'Szenen',
  //                 style: TextStyle(
  //                   fontSize: 24,
  //                   fontWeight: FontWeight.bold,
  //                   color: Color(0xFF004AC6),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           actions: [
  //             IconButton(
  //               icon: const Icon(Icons.notifications_outlined, color: Color(0xFF434655)),
  //               onPressed: () {},
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // ====== 顶部 Hero 卡片 ======
  Widget _buildHeroSection(int dueCount) {
    return Container(
      width: double.infinity,
      padding: ReviewStyle.heroPadding,
      decoration: ReviewStyle.heroDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Flashcard Review', style: ReviewStyle.heroTitleTextStyle),
          const SizedBox(height: 8),
          Text(
            'Strengthen your memory with $dueCount new favorites waiting for review.',
            style: ReviewStyle.heroSubtitleTextStyle,
          ),
          const SizedBox(height: 20),
          ReviewPressable(
            onTap: () => _startReview(),
            pressedScale: 0.97,
            builder: (context, isHovered, isPressed) {
              return IgnorePointer(
                child: ElevatedButton.icon(
                  onPressed: () => _startReview(),
                  icon: const Icon(Icons.bolt, color: ReviewStyle.primary),
                  label: const Text(
                    'Start Review',
                    style: ReviewStyle.primaryButtonLabelTextStyle,
                  ),
                  style: ReviewStyle.startReviewButtonStyle(
                    isElevated: isHovered || isPressed,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ====== 横向滚动过滤器 ======
  Widget _buildFilters() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterIndex == index;
          return ReviewPressable(
            onTap: () => _handleLevelFilterChanged(index),
            pressedScale: 0.96,
            builder: (context, isHovered, isPressed) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: ReviewStyle.filterPadding,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? ReviewStyle.primary
                      : isHovered || isPressed
                      ? ReviewStyle.surfaceContainerHover
                      : ReviewStyle.surfaceContainerHighest,
                  borderRadius: ReviewStyle.pillRadius,
                ),
                child: Text(
                  _filters[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? ReviewStyle.white
                        : ReviewStyle.mutedText,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ====== 列表标题 ======
  Widget _buildListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Your Favorites', style: ReviewStyle.listTitleTextStyle),
        ReviewPressable(
          onTap: _handleSortPressed,
          pressedScale: 0.97,
          builder: (context, isHovered, isPressed) {
            return IgnorePointer(
              child: TextButton.icon(
                onPressed: _handleSortPressed,
                icon: const Icon(Icons.sort, size: 18),
                label: const Text('Recent'),
                style: TextButton.styleFrom(
                  foregroundColor: ReviewStyle.primary,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ====== 词汇卡片列表 ======
  Widget _buildVocabList(List<ReviewEntity> cards) {
    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        for (final card in cards) ...[
          VocabCard(
            level: card.cefrLevel.value,
            levelColor: _levelColor(card.cefrLevel.value),
            levelBgColor: _levelBgColor(card.cefrLevel.value),
            word: _resolveDisplayWord(card),
            translation: _resolveTranslation(card),
            examplePre: _resolveExampleParts(card).pre,
            exampleHighlight: _resolveExampleParts(card).highlight,
            examplePost: _resolveExampleParts(card).post,
            onDelete: () => _handleDeleteCard(card),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  String _resolveDisplayWord(ReviewEntity card) {
    final article = _readContentString(card, ['article', 'gender']);
    if (article.isEmpty) {
      return card.lemma;
    }
    return '$article ${card.lemma}';
  }

  String _resolveTranslation(ReviewEntity card) {
    final translation = _readContentString(card, [
      'translation_l1',
      'en',
      'word_en',
      'english',
      'translation',
    ]);
    return translation.isNotEmpty ? translation : card.objectLabel;
  }

  _ExampleParts _resolveExampleParts(ReviewEntity card) {
    final example = _readExample(card);
    if (example.isEmpty) {
      return _ExampleParts(pre: '"', highlight: card.lemma, post: '."');
    }

    final lowerExample = example.toLowerCase();
    final lowerLemma = card.lemma.toLowerCase();
    final index = lowerExample.indexOf(lowerLemma);
    if (index < 0) {
      return _ExampleParts(pre: '"$example"', highlight: '', post: '');
    }

    return _ExampleParts(
      pre: '"${example.substring(0, index)}',
      highlight: example.substring(index, index + card.lemma.length),
      post: '${example.substring(index + card.lemma.length)}"',
    );
  }

  String _readExample(ReviewEntity card) {
    final content = card.content ?? const <String, dynamic>{};
    final example = content['example_sentence'];
    if (example is String) {
      return example.trim();
    }
    if (example is Map) {
      for (final key in ['de', 'sentence', 'text', 'example']) {
        final value = example[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }
    return _readContentString(card, ['example', 'sentence']);
  }

  String _readContentString(ReviewEntity card, List<String> keys) {
    final content = card.content ?? const <String, dynamic>{};
    for (final key in keys) {
      final value = content[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
  }

  Color _levelColor(String level) {
    return ReviewStyle.levelColor(level);
  }

  Color _levelBgColor(String level) {
    return ReviewStyle.levelBackgroundColor(level);
  }

  // ====== 自定义底部毛玻璃导航栏 ======
  // Widget _buildBottomNav() {
  //   return ClipRRect(
  //     borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
  //     child: BackdropFilter(
  //       filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
  //       child: Container(
  //         decoration: BoxDecoration(
  //           color: const Color(0xFFFAF8FF).withOpacity(0.9),
  //           border: const Border(top: BorderSide(color: Color(0x33C3C6D7))),
  //         ),
  //         child: SafeArea(
  //           child: Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceAround,
  //               children: [
  //                 _buildNavIcon(Icons.home_outlined, 'Home', false),
  //                 _buildActiveNavPill(Icons.favorite, 'Favorites'),
  //                 _buildNavIcon(Icons.person_outline, 'Profile', false),
  //                 _buildNavIcon(Icons.settings_outlined, 'Settings', false),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildNavIcon(IconData icon, String label, bool isActive) {
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       Icon(icon, color: const Color(0xFF434655)),
  //       const SizedBox(height: 4),
  //       Text(
  //         label,
  //         style: const TextStyle(fontSize: 10, color: Color(0xFF434655)),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildActiveNavPill(IconData icon, String label) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
  //     decoration: BoxDecoration(
  //       color: const Color(0xFF8A4CFC), // secondary-container
  //       borderRadius: BorderRadius.circular(100),
  //     ),
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Icon(icon, color: Colors.white, size: 20),
  //         const SizedBox(height: 2),
  //         const Text(
  //           'Favorites',
  //           style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

// ==========================================
// 独立的词汇卡片组件 (包含点赞的动画交互)
// ==========================================
class _ExampleParts {
  final String pre;
  final String highlight;
  final String post;

  const _ExampleParts({
    required this.pre,
    required this.highlight,
    required this.post,
  });
}

class VocabCard extends StatefulWidget {
  final String level;
  final Color levelColor;
  final Color levelBgColor;
  final String word;
  final String translation;
  final String examplePre;
  final String exampleHighlight;
  final String examplePost;
  final VoidCallback onDelete;

  const VocabCard({
    super.key,
    required this.level,
    required this.levelColor,
    required this.levelBgColor,
    required this.word,
    required this.translation,
    required this.examplePre,
    required this.exampleHighlight,
    required this.examplePost,
    required this.onDelete,
  });

  @override
  State<VocabCard> createState() => _VocabCardState();
}

class _VocabCardState extends State<VocabCard>
    with SingleTickerProviderStateMixin {
  bool _isFavorite = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ReviewStyle.favoriteCardPadding,
      decoration: ReviewStyle.favoriteCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部：等级标签 + 操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: ReviewStyle.levelBadgePadding,
                decoration: BoxDecoration(
                  color: widget.levelBgColor,
                  borderRadius: ReviewStyle.pillRadius,
                ),
                child: Text(
                  widget.level,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: widget.levelColor,
                  ),
                ),
              ),
              Row(
                children: [
                  ReviewPressable(
                    onTap: _toggleFavorite,
                    pressedScale: 0.9,
                    builder: (context, isHovered, isPressed) {
                      return ScaleTransition(
                        scale: _scaleAnimation,
                        child: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite
                              ? ReviewStyle.favorite
                              : ReviewStyle.mutedText.withValues(
                                  alpha: isHovered || isPressed ? 0.7 : 0.5,
                                ),
                          size: 26,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  ReviewPressable(
                    onTap: widget.onDelete,
                    pressedScale: 0.9,
                    builder: (context, isHovered, isPressed) {
                      return Icon(
                        Icons.delete_outline,
                        color: ReviewStyle.mutedText.withValues(
                          alpha: isHovered || isPressed ? 0.7 : 0.5,
                        ),
                        size: 26,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          // 中间：单词及翻译
          Text(widget.word, style: ReviewStyle.cardWordTextStyle),
          const SizedBox(height: 2),
          Text(widget.translation, style: ReviewStyle.cardTranslationTextStyle),
          const SizedBox(height: 1),
          const Divider(color: ReviewStyle.outlineSubtle),
          const SizedBox(height: 1),
          // 底部：例句 (使用 RichText 高亮目标词汇)
          RichText(
            text: TextSpan(
              style: ReviewStyle.exampleTextStyle,
              children: [
                TextSpan(text: widget.examplePre),
                TextSpan(
                  text: widget.exampleHighlight,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.levelColor,
                  ),
                ),
                TextSpan(text: widget.examplePost),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
