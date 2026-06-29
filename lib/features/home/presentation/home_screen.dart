import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/scene_image_cache.dart';
import '../domain/entity/home_stats_entity.dart';
import 'chat_provider.dart';
import 'home_style.dart';
import 'immersive_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final bool showChrome;

  const HomeScreen({super.key, this.showChrome = true});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(ref.read(chatProvider.notifier).cleanupDuplicates());
      }
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submitPrompt() {
    final currentState = ref.read(chatProvider).value;
    if (currentState?.hasPending ?? false) {
      return;
    }

    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe a scene first.')),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    _promptController.clear();
    unawaited(ref.read(chatProvider.notifier).sendPrompt(prompt));
    _scrollToBottomSoon();
  }

  void _fillPrompt(String text) {
    _promptController.text = text;
    _promptController.selection = TextSelection.collapsed(offset: text.length);
  }

  void _openScene(SceneEntity scene) {
    unawaited(SceneImageCache.precacheScene(context, scene));
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ImmersiveScreen(scene: scene)));
  }

  void _scrollToBottomSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<ChatState>>(chatProvider, (previous, next) {
      final previousCount = previous?.value?.messages.length ?? 0;
      final nextCount = next.value?.messages.length ?? 0;
      if (nextCount != previousCount) {
        _scrollToBottomSoon();
      }
    });

    final chatState = ref.watch(chatProvider);
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final inputBottom = keyboardOpen ? 12.0 : 8.0;
    final listBottom = inputBottom + 118.0;

    return Scaffold(
      backgroundColor: HomeStyle.backgroundColor(context),
      body: chatState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ChatStateMessage(
          icon: Icons.error_outline,
          text: error.toString(),
        ),
        data: (state) {
          return Stack(
            children: [
              ListView(
                controller: _scrollController,
                padding: HomeStyle.chatPagePadding.copyWith(bottom: listBottom),
                children: [
                  _ChatHeader(onPromptSelected: _fillPrompt),
                  const SizedBox(height: 18),
                  if (state.messages.isEmpty)
                    const _ChatStateMessage(
                      icon: Icons.auto_awesome,
                      text: 'Describe a place or moment to generate a scene.',
                    )
                  else
                    ...state.messages.map(
                      (message) => _ChatMessageBubble(
                        message: message,
                        onOpenScene: _openScene,
                        onRetry: () =>
                            ref.read(chatProvider.notifier).retry(message),
                      ),
                    ),
                ],
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: inputBottom,
                child: _ChatInputBar(
                  controller: _promptController,
                  hasPending: state.hasPending,
                  onSubmit: state.hasPending ? null : _submitPrompt,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  final ValueChanged<String> onPromptSelected;

  const _ChatHeader({required this.onPromptSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text('Chat', style: HomeStyle.titleTextStyleFor(context)),
        const SizedBox(height: 8),
        Text(
          'Send an instruction. Scene generation can take a while, and completed scenes will appear here and in History.',
          style: HomeStyle.subtitleTextStyleFor(context),
        ),
        // const SizedBox(height: 14),
        // SingleChildScrollView(
        //   scrollDirection: Axis.horizontal,
        //   child: Row(
        //     children: [
        //       HomeQuickStarter(
        //         label: 'Bakery',
        //         onTap: () => onPromptSelected(
        //           'A busy bakery in Berlin during morning rush.',
        //         ),
        //       ),
        //       HomeQuickStarter(
        //         label: 'Train Station',
        //         onTap: () => onPromptSelected(
        //           'A rainy evening at a train station in Munich.',
        //         ),
        //       ),
        //       HomeQuickStarter(
        //         label: 'Park',
        //         onTap: () =>
        //             onPromptSelected('A sunny weekend at the Tiergarten park.'),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool hasPending;
  final VoidCallback? onSubmit;

  const _ChatInputBar({
    required this.controller,
    required this.hasPending,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: HomeStyle.promptPanelPadding,
      decoration: HomeStyle.inputBarDecorationFor(context),
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              decoration: HomeStyle.promptInputDecorationFor(context),
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSubmit?.call(),
                style: HomeStyle.promptInputTextStyleFor(context),
                decoration: HomeStyle.promptInputDecorationDataFor(context),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onSubmit,
            child: Container(
              height: 48,
              width: 48,
              decoration: HomeStyle.submitButtonDecorationFor(context),
              child: Icon(
                hasPending ? Icons.hourglass_top : Icons.arrow_upward,
                color: HomeStyle.colors(context).onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final ValueChanged<SceneEntity> onOpenScene;
  final VoidCallback onRetry;

  const _ChatMessageBubble({
    required this.message,
    required this.onOpenScene,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = message.isUser
        ? Alignment.centerRight
        : Alignment.centerLeft;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.78;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth.clamp(260.0, 560.0)),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: switch (message.kind) {
            ChatMessageKind.userText => _TextBubble(message: message),
            ChatMessageKind.scenePending => _PendingSceneBubble(
              message: message,
            ),
            ChatMessageKind.sceneReady => _SceneReadyCard(
              message: message,
              onOpenScene: onOpenScene,
            ),
            ChatMessageKind.error => _ErrorBubble(
              message: message,
              onRetry: onRetry,
            ),
          },
        ),
      ),
    );
  }
}

class _TextBubble extends StatelessWidget {
  final ChatMessage message;

  const _TextBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: HomeStyle.messagePadding,
      decoration: message.isUser
          ? HomeStyle.userMessageDecorationFor(context)
          : HomeStyle.assistantMessageDecorationFor(context),
      child: Text(
        message.text,
        style: message.isUser
            ? HomeStyle.userMessageTextStyleFor(context)
            : HomeStyle.messageTextStyleFor(context),
      ),
    );
  }
}

class _PendingSceneBubble extends StatelessWidget {
  final ChatMessage message;

  const _PendingSceneBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final palette = HomeStyle.colors(context);
    return Container(
      padding: HomeStyle.messagePadding,
      decoration: HomeStyle.assistantMessageDecorationFor(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: palette.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generating scene',
                  style: HomeStyle.sceneTitleTextStyleFor(context),
                ),
                const SizedBox(height: 6),
                Text(
                  message.prompt,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: HomeStyle.messageTextStyleFor(context),
                ),
                const SizedBox(height: 6),
                Text(
                  'This can take a while. You can visit other pages; the scene will be saved to History when ready.',
                  style: HomeStyle.sceneMetaTextStyleFor(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SceneReadyCard extends StatelessWidget {
  final ChatMessage message;
  final ValueChanged<SceneEntity> onOpenScene;

  const _SceneReadyCard({required this.message, required this.onOpenScene});

  @override
  Widget build(BuildContext context) {
    final scene = message.scene;
    if (scene == null) {
      return const SizedBox.shrink();
    }

    final imageUrl = SceneImageCache.resolveSceneImageUrl(scene);
    final title = _sceneTitle(scene, message.prompt);
    final prompt = message.prompt.trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: HomeStyle.sceneCardRadius,
        onTap: () => onOpenScene(scene),
        child: Container(
          padding: HomeStyle.sceneCardPadding,
          decoration: HomeStyle.sceneCardDecorationFor(context),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 76,
                  height: 76,
                  child: imageUrl.isEmpty
                      ? ColoredBox(
                          color: HomeStyle.colors(
                            context,
                          ).surfaceContainerHighest,
                          child: Icon(
                            Icons.image_outlined,
                            color: HomeStyle.colors(context).onSurfaceVariant,
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => ColoredBox(
                            color: HomeStyle.colors(
                              context,
                            ).surfaceContainerHighest,
                          ),
                          errorWidget: (context, url, error) => ColoredBox(
                            color: HomeStyle.colors(
                              context,
                            ).surfaceContainerHighest,
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: HomeStyle.colors(context).onSurfaceVariant,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: HomeStyle.sceneTitleTextStyleFor(context),
                    ),
                    if (prompt.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        prompt,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: HomeStyle.messageTextStyleFor(context),
                      ),
                    ],
                    if (message.text.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        message.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: HomeStyle.sceneMetaTextStyleFor(context),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      '${scene.cards.length} words | Tap to immerse',
                      style: HomeStyle.sceneMetaTextStyleFor(context).copyWith(
                        color: HomeStyle.colors(context).primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: HomeStyle.colors(context).onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _sceneTitle(SceneEntity scene, String prompt) {
    final firstTag = scene.cards
        .expand((card) => card.sceneTags)
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .cast<String?>()
        .firstWhere((tag) => tag != null, orElse: () => null);
    if (firstTag != null) {
      return firstTag;
    }
    final trimmedPrompt = prompt.trim();
    if (trimmedPrompt.isNotEmpty) {
      return trimmedPrompt;
    }
    return 'Generated scene';
  }
}

class _ErrorBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback onRetry;

  const _ErrorBubble({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final palette = HomeStyle.colors(context);
    return Container(
      padding: HomeStyle.messagePadding,
      decoration: HomeStyle.assistantMessageDecorationFor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: palette.error, size: 20),
              const SizedBox(width: 8),
              Text(
                'Generation failed',
                style: HomeStyle.sceneTitleTextStyleFor(
                  context,
                ).copyWith(color: palette.error),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(message.text, style: HomeStyle.messageTextStyleFor(context)),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _ChatStateMessage extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ChatStateMessage({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: HomeStyle.colors(context).onSurfaceVariant),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: HomeStyle.sceneMetaTextStyleFor(context),
            ),
          ],
        ),
      ),
    );
  }
}
