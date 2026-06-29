import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_shell_style.dart';

class AppShellScaffold extends StatelessWidget {
  final int currentIndex;
  final String title;
  final Widget child;

  const AppShellScaffold({
    super.key,
    required this.currentIndex,
    required this.title,
    required this.child,
  });

  void _goTo(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/reviews');
        break;
      case 2:
        context.go('/history');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  title,
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
      body: SafeArea(child: child),
      bottomNavigationBar: ClipRRect(
        borderRadius: AppShellStyle.bottomBarRadius,
        child: BackdropFilter(
          filter: AppShellStyle.bottomBarBlurFilter,
          child: Container(
            decoration: AppShellStyle.bottomBarDecorationFor(context),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
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
}
