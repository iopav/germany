import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:germany/core/widgets/scene_image_cache.dart';
import 'package:germany/features/home/domain/entity/home_stats_entity.dart';
import 'package:germany/features/home/presentation/immersive_screen.dart';
import 'package:germany/features/reviews/presentation/review_style.dart';

import 'history_provider.dart';
import 'history_style.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _SceneHistoryScreenState();
}

class _SceneHistoryScreenState extends ConsumerState<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteScene(SceneEntity scene) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Scene'),
          content: const Text(
            'Are you sure you want to delete this scene from your history?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: HistoryStyle.error),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    try {
      await ref.read(sceneHistoryProvider.notifier).deleteScene(scene.id);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _openScene(SceneEntity scene) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ImmersiveScreen(scene: scene)));
  }

  @override
  Widget build(BuildContext context) {
    final scenesAsync = ref.watch(sceneHistoryProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      // appBar: _buildAppBar(),
      body: scenesAsync.when(
        loading: _buildLoadingState,
        error: (error, _) => _buildErrorState(error.toString()),
        data: (scenes) {
          final filteredScenes = _filterScenes(scenes);
          if (filteredScenes.isEmpty) {
            return _buildEmptyState();
          }
          return _buildMainContent(filteredScenes);
        },
      ),
      // bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildMainContent(List<SceneEntity> scenes) {
    return RefreshIndicator(
      onRefresh: () => ref.read(sceneHistoryProvider.notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: HistoryStyle.pagePadding,
        child: Column(
          children: [
            _buildSearchAndFilterBar(),
            const SizedBox(height: 24),
            _buildSceneGrid(scenes),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: HistoryStyle.searchDecoration,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Search your history...',
                hintStyle: HistoryStyle.searchHintTextStyle,
                prefixIcon: Icon(
                  Icons.search,
                  color: HistoryStyle.outline,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ReviewPressable(
          onTap: () => ref.read(sceneHistoryProvider.notifier).refresh(),
          builder: (context, isHovered, isPressed) {
            return AnimatedContainer(
              duration: ReviewStyle.hoverDuration,
              curve: ReviewStyle.pressCurve,
              width: 48,
              height: 48,
              decoration: HistoryStyle.refreshDecoration(
                isActive: isHovered || isPressed,
              ),
              child: const Icon(
                Icons.refresh,
                color: HistoryStyle.onSurfaceVariant,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSceneGrid(List<SceneEntity> scenes) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: scenes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 4 / 5,
      ),
      itemBuilder: (context, index) {
        final scene = scenes[index];
        return _buildSceneCard(scene);
      },
    );
  }

  Widget _buildSceneCard(SceneEntity scene) {
    final imageUrl = SceneImageCache.resolveSceneImageUrl(scene);

    return ReviewPressable(
      onTap: () => _openScene(scene),
      pressedScale: 0.98,
      builder: (context, isHovered, isPressed) {
        return AnimatedContainer(
          duration: ReviewStyle.hoverDuration,
          curve: ReviewStyle.pressCurve,
          decoration: HistoryStyle.sceneCardDecoration(
            isActive: isHovered || isPressed,
          ),
          child: ClipRRect(
            borderRadius: HistoryStyle.cardRadius,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: imageUrl.isEmpty
                            ? const ColoredBox(
                                color: HistoryStyle.surfaceContainerHigh,
                              )
                            : CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    const ColoredBox(
                                      color: HistoryStyle.surfaceContainerHigh,
                                    ),
                              ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: HistoryDeleteButton(
                          onTap: () => _deleteScene(scene),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: HistoryStyle.cardTextPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _sceneTitle(scene),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: HistoryStyle.cardTitleTextStyle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatSceneDate(scene.createdAt),
                        style: HistoryStyle.cardDateTextStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: HistoryStyle.primary),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: HistoryStyle.statePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 56,
              color: HistoryStyle.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: HistoryStyle.stateMessageTextStyle,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () =>
                  ref.read(sceneHistoryProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: HistoryStyle.statePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history_toggle_off,
              size: 64,
              color: HistoryStyle.outline,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Scenes Yet',
              style: HistoryStyle.emptyTitleTextStyle,
            ),
            const SizedBox(height: 8),
            const Text(
              'Start scanning objects around you to build your linguistic mosaic.',
              textAlign: TextAlign.center,
              style: HistoryStyle.emptyBodyTextStyle,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              style: HistoryStyle.scannerButtonStyle,
              child: const Text(
                'Go to Scanner',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<SceneEntity> _filterScenes(List<SceneEntity> scenes) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return scenes;
    }

    return scenes.where((scene) {
      final haystack = [
        scene.id,
        scene.sourceType,
        _sceneTitle(scene),
        ...scene.detectionResult.map((item) => item.label),
        ..._sceneTags(scene),
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  String _sceneTitle(SceneEntity scene) {
    final llmScene = scene.llmResult['scene'];
    if (llmScene is Map) {
      for (final key in ['title', 'description', 'summary']) {
        final value = llmScene[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }

    final rawTitle = scene.raw['title'];
    if (rawTitle is String && rawTitle.trim().isNotEmpty) {
      return rawTitle.trim();
    }

    if (scene.detectionResult.isNotEmpty) {
      return scene.detectionResult.first.label;
    }

    return 'Scene ${scene.id.isNotEmpty ? scene.id : ''}'.trim();
  }

  List<String> _sceneTags(SceneEntity scene) {
    final llmScene = scene.llmResult['scene'];
    if (llmScene is Map) {
      final tags = llmScene['scene_tags'];
      if (tags is List) {
        return tags.map((tag) => tag.toString()).toList();
      }
    }
    return const <String>[];
  }

  String _formatSceneDate(DateTime? value) {
    if (value == null) {
      return 'Unknown date';
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[value.month - 1]} ${value.day}, ${value.year}';
  }
}
