import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:germany/core/widgets/scene_image_cache.dart';
import 'package:germany/features/home/domain/entity/home_stats_entity.dart';
import 'package:germany/features/home/presentation/immersive_screen.dart';
import 'package:germany/features/reviews/presentation/review_style.dart';

import 'history_provider.dart';

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
                style: TextStyle(color: Color(0xFFBA1A1A)),
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
        padding: EdgeInsets.only(
          top: 12,
          left: 12.0,
          right: 12.0,
          bottom: 100.0,
        ),
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
            decoration: BoxDecoration(
              color: const Color(0xFFEAEDFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Search your history...',
                hintStyle: TextStyle(color: Color(0xFF434655), fontSize: 14),
                prefixIcon: Icon(
                  Icons.search,
                  color: Color(0xFF737686),
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
              decoration: BoxDecoration(
                color: isHovered || isPressed
                    ? const Color(0xFFDDE4FF)
                    : const Color(0xFFEAEDFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.refresh, color: Color(0xFF434655)),
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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFC3C6D7).withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isHovered || isPressed ? 0.09 : 0.05,
                ),
                blurRadius: isHovered || isPressed ? 24 : 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: imageUrl.isEmpty
                            ? const ColoredBox(color: Color(0xFFE2E7FF))
                            : CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    const ColoredBox(color: Color(0xFFE2E7FF)),
                              ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: ReviewPressable(
                              onTap: () => _deleteScene(scene),
                              pressedScale: 0.9,
                              builder: (context, isHovered, isPressed) {
                                return AnimatedContainer(
                                  duration: ReviewStyle.hoverDuration,
                                  width: 32,
                                  height: 32,
                                  color: Colors.white.withValues(
                                    alpha: isHovered || isPressed ? 0.9 : 0.7,
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: Color(0xFFBA1A1A),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _sceneTitle(scene),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF131B2E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatSceneDate(scene.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF737686),
                        ),
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
      child: CircularProgressIndicator(color: Color(0xFF004AC6)),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Color(0xFFBA1A1A)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF434655), fontSize: 14),
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
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history_toggle_off,
              size: 64,
              color: Color(0xFF737686),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Scenes Yet',
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF131B2E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start scanning objects around you to build your linguistic mosaic.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF737686),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004AC6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                elevation: 4,
                shadowColor: const Color(0xFF004AC6).withValues(alpha: 0.2),
              ),
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

  Widget _buildBottomNav() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFFAF8FF).withValues(alpha: 0.8),
            border: const Border(
              top: BorderSide(color: Color(0x1F737686), width: 0.5),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_outlined, 'Home', false),
                _buildActiveNavItem(Icons.history, 'History'),
                _buildNavItem(Icons.photo_camera_outlined, 'Scanner', false),
                _buildNavItem(Icons.person_outline, 'Profile', false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: const Color(0xFF434655)),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF434655),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveNavItem(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF8A4CFC),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
