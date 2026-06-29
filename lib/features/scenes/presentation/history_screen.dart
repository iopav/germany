import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:germany/core/theme/app_motion.dart';
import 'package:germany/core/widgets/app_pressable.dart';
import 'package:germany/core/widgets/scene_image_cache.dart';
import 'package:germany/features/home/domain/entity/home_stats_entity.dart';
import 'package:germany/features/home/presentation/immersive_screen.dart';

import 'history_provider.dart';
import 'history_style.dart';

import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:germany/features/home/presentation/home_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _SceneHistoryScreenState();
}

class _SceneHistoryScreenState extends ConsumerState<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _isCreateMenuOpen = false;
  bool _isQuickGenerating = false;

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
              child: Text(
                'Delete',
                style: TextStyle(color: HistoryStyle.colors(context).error),
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

  void _toggleCreateMenu() {
    if (_isQuickGenerating) {
      return;
    }

    setState(() => _isCreateMenuOpen = !_isCreateMenuOpen);
  }

  Future<void> _showImageSourceSheet() async {
    setState(() => _isCreateMenuOpen = false);

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.24),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            padding: HistoryStyle.sourceSheetPadding,
            decoration: HistoryStyle.sourceSheetDecorationFor(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: HistoryStyle.sourceSheetHandlePadding,
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: HistoryStyle.sourceSheetHandleDecorationFor(
                        context,
                      ),
                    ),
                  ),
                ),
                Text(
                  'Choose image source',
                  style: HistoryStyle.sourceSheetTitleTextStyleFor(context),
                ),
                const SizedBox(height: 12),
                _buildImageSourceOption(
                  icon: Icons.photo_camera_outlined,
                  title: 'Camera',
                  subtitle: 'Take a new scene photo',
                  onTap: () =>
                      Navigator.of(sheetContext).pop(ImageSource.camera),
                ),
                const SizedBox(height: 10),
                _buildImageSourceOption(
                  icon: Icons.image_outlined,
                  title: 'Gallery',
                  subtitle: 'Choose an existing image',
                  onTap: () =>
                      Navigator.of(sheetContext).pop(ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) {
      return;
    }

    await _createSceneFromImage(source);
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: HistoryStyle.cardRadius,
      onTap: onTap,
      child: Container(
        padding: HistoryStyle.sourceOptionPadding,
        decoration: HistoryStyle.sourceOptionDecorationFor(context),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: HistoryStyle.sourceOptionIconDecorationFor(context),
              child: Icon(icon, color: HistoryStyle.colors(context).primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: HistoryStyle.sourceOptionTitleTextStyleFor(context),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: HistoryStyle.sourceOptionSubtitleTextStyleFor(
                      context,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: HistoryStyle.colors(context).outline,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createSceneFromImage(ImageSource source) async {
    setState(() {
      _isCreateMenuOpen = false;
      _isQuickGenerating = true;
    });

    try {
      final notifier = ref.read(homeProvider.notifier);
      final image = await notifier.pickImage(source);

      if (image == null) {
        return;
      }

      final scene = await notifier.generateScene();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              _openScene(scene);
            },
            child: const Text('Generation Finish.'),
          ),
        ),
      );

      await ref.read(sceneHistoryProvider.notifier).refresh();
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _isQuickGenerating = false);
      }
    }
  }

  void _goToTextScene() {
    setState(() => _isCreateMenuOpen = false);
    context.go('/chat');
  }

  @override
  Widget build(BuildContext context) {
    final scenesAsync = ref.watch(sceneHistoryProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      // appBar: _buildAppBar(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          scenesAsync.when(
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
          if (_isCreateMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => setState(() => _isCreateMenuOpen = false),
                child: const SizedBox.expand(),
              ),
            ),
          if (_isCreateMenuOpen)
            Positioned(
              right: HistoryStyle.createButtonRight,
              bottom: HistoryStyle.createMenuBottomFor(context),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 156,
                  decoration: BoxDecoration(
                    color: HistoryStyle.colors(context).surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: HistoryStyle.colors(context).outlineVariant,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.image_outlined),
                        title: const Text('Image'),
                        onTap: _showImageSourceSheet,
                      ),
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.text_fields),
                        title: const Text('Text'),
                        onTap: _goToTextScene,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            right: HistoryStyle.createButtonRight,
            bottom: HistoryStyle.createButtonBottomFor(context),
            child: AppPressable(
              onTap: _isQuickGenerating ? () {} : _toggleCreateMenu,
              pressedScale: 0.96,
              builder: (context, isHovered, isPressed) {
                final isActive = _isCreateMenuOpen || isHovered || isPressed;
                return AnimatedContainer(
                  duration: AppMotion.hoverDuration,
                  curve: AppMotion.pressCurve,
                  width: HistoryStyle.createButtonSize,
                  height: HistoryStyle.createButtonSize,
                  alignment: Alignment.center,
                  decoration: HistoryStyle.createButtonDecorationFor(
                    context,
                    isActive: isActive,
                  ),
                  child: _isQuickGenerating
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: HistoryStyle.colors(context).onPrimary,
                          ),
                        )
                      : Icon(
                          Icons.add,
                          color: HistoryStyle.colors(context).onPrimary,
                        ),
                );
              },
            ),
          ),
        ],
      ),
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
            decoration: HistoryStyle.searchDecorationFor(context),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search your history...',
                hintStyle: HistoryStyle.searchHintTextStyleFor(context),
                prefixIcon: Icon(
                  Icons.search,
                  color: HistoryStyle.colors(context).outline,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        AppPressable(
          onTap: () => ref.read(sceneHistoryProvider.notifier).refresh(),
          builder: (context, isHovered, isPressed) {
            return AnimatedContainer(
              duration: AppMotion.hoverDuration,
              curve: AppMotion.pressCurve,
              width: 48,
              height: 48,
              decoration: HistoryStyle.refreshDecorationFor(
                context,
                isActive: isHovered || isPressed,
              ),
              child: Icon(
                Icons.refresh,
                color: HistoryStyle.colors(context).onSurfaceVariant,
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

    return AppPressable(
      onTap: () => _openScene(scene),
      pressedScale: 0.98,
      builder: (context, isHovered, isPressed) {
        return AnimatedContainer(
          duration: AppMotion.hoverDuration,
          curve: AppMotion.pressCurve,
          decoration: HistoryStyle.sceneCardDecorationFor(
            context,
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
                            ? ColoredBox(
                                color: HistoryStyle.colors(
                                  context,
                                ).surfaceContainerHigh,
                              )
                            : CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    ColoredBox(
                                      color: HistoryStyle.colors(
                                        context,
                                      ).surfaceContainerHigh,
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
                        style: HistoryStyle.cardTitleTextStyleFor(context),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatSceneDate(scene.createdAt),
                        style: HistoryStyle.cardDateTextStyleFor(context),
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
    return Center(
      child: CircularProgressIndicator(
        color: HistoryStyle.colors(context).primary,
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: HistoryStyle.statePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: HistoryStyle.colors(context).error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: HistoryStyle.stateMessageTextStyleFor(context),
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
            Icon(
              Icons.history_toggle_off,
              size: 64,
              color: HistoryStyle.colors(context).outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No Scenes Yet',
              style: HistoryStyle.emptyTitleTextStyleFor(context),
            ),
            const SizedBox(height: 8),
            Text(
              'Start scanning objects around you to build your linguistic mosaic.',
              textAlign: TextAlign.center,
              style: HistoryStyle.emptyBodyTextStyleFor(context),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              style: HistoryStyle.scannerButtonStyleFor(context),
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
