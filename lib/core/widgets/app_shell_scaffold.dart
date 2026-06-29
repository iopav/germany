import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/chat_provider.dart';
import '../notifications/app_notification_service.dart';
import 'app_shell_style.dart';

class AppShellScaffold extends ConsumerStatefulWidget {
  final int currentIndex;
  final String title;
  final Widget child;

  const AppShellScaffold({
    super.key,
    required this.currentIndex,
    required this.title,
    required this.child,
  });

  @override
  ConsumerState<AppShellScaffold> createState() => _AppShellScaffoldState();
}

class _AppShellScaffoldState extends ConsumerState<AppShellScaffold> {
  ChatMessage? _notice;
  Timer? _noticeTimer;
  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;
  late final _AppLifecycleObserver _lifecycleObserver;

  @override
  void initState() {
    super.initState();
    _lifecycleObserver = _AppLifecycleObserver(_onLifecycle);
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
  }

  @override
  void dispose() {
    _noticeTimer?.cancel();
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }

  void _onLifecycle(AppLifecycleState state) {
    _lifecycleState = state;
  }

  void _goTo(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/reviews');
        break;
      case 2:
        context.go('/chat');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }

  void _showSceneNotice(ChatMessage message) {
    _noticeTimer?.cancel();
    setState(() => _notice = message);
    _noticeTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => _notice = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<ChatState>>(chatProvider, (previous, next) {
      final previousMessages = previous?.value?.messages;
      final nextMessages = next.value?.messages;
      if (previousMessages == null || nextMessages == null) {
        return;
      }

      final previousReadyIds = previousMessages
          .where((message) => message.isReady)
          .map((message) => message.id)
          .toSet();
      final newReadyMessages = nextMessages.where(
        (message) => message.isReady && !previousReadyIds.contains(message.id),
      );
      if (newReadyMessages.isNotEmpty) {
        _notifySceneReady(newReadyMessages.last);
      }
    });

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(AppShellStyle.appBarHeight),
        child: ClipRect(
          child: BackdropFilter(
            filter: AppShellStyle.appBarBlurFilter,
            child: Container(
              decoration: AppShellStyle.appBarDecorationFor(context),
              child: AppBar(
                title: Text(
                  widget.title,
                  style: AppShellStyle.titleTextStyleFor(context),
                ),
                centerTitle: false,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
                toolbarHeight: AppShellStyle.appBarHeight,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: SafeArea(child: widget.child)),
          Positioned(
            top:
                MediaQuery.paddingOf(context).top +
                AppShellStyle.appBarHeight +
                10,
            right: 12,
            child: _SceneReadyNotice(message: _notice),
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: AppShellStyle.bottomBarRadius,
        child: BackdropFilter(
          filter: AppShellStyle.bottomBarBlurFilter,
          child: Container(
            decoration: AppShellStyle.bottomBarDecorationFor(context),
            child: BottomNavigationBar(
              currentIndex: widget.currentIndex,
              onTap: (index) => _goTo(context, index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppShellStyle.selectedItemColorFor(context),
              unselectedItemColor: AppShellStyle.unselectedItemColorFor(
                context,
              ),
              selectedFontSize: 11,
              unselectedFontSize: 11,
              iconSize: 28,
              items: AppShellStyle.bottomNavigationItemsFor(context),
            ),
          ),
        ),
      ),
    );
  }

  void _notifySceneReady(ChatMessage message) {
    if (_lifecycleState == AppLifecycleState.resumed) {
      _showSceneNotice(message);
      return;
    }

    final sceneId = message.scene?.id ?? message.id;
    unawaited(
      AppNotificationService.showSceneReady(
        sceneId: sceneId,
        title: 'Scene is ready',
        body: 'Your generated scene is available in Chat and History.',
      ),
    );
  }
}

class _AppLifecycleObserver extends WidgetsBindingObserver {
  final ValueChanged<AppLifecycleState> onChanged;

  _AppLifecycleObserver(this.onChanged);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    onChanged(state);
  }
}

class _SceneReadyNotice extends StatelessWidget {
  final ChatMessage? message;

  const _SceneReadyNotice({required this.message});

  @override
  Widget build(BuildContext context) {
    final palette = AppShellStyle.colors(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: message == null
          ? const SizedBox.shrink()
          : ConstrainedBox(
              key: ValueKey(message!.id),
              constraints: const BoxConstraints(maxWidth: 310),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: palette.primary.withValues(alpha: 0.24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: palette.onSurface.withValues(alpha: 0.16),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: palette.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Scene is ready. It is now available in Chat and History.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: palette.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
