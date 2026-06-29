import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_palette.dart';

class AppShellStyle {
  static const double appBarHeight = 64;
  static const double appBarBlurSigma = 28;
  static const double bottomBarBlurSigma = 34;
  static const BorderRadius bottomBarRadius = BorderRadius.vertical(
    top: Radius.circular(20),
  );

  static const TextStyle titleTextStyle = TextStyle(
    fontFamily: 'Space Grotesk',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: Color(0xFF131B2E),
  );

  static const Color selectedItemColor = Color(0xFF004AC6);
  static const Color unselectedItemColor = Color(0xFF434655);

  static AppPalette colors(BuildContext context) => AppPalettes.of(context);

  static TextStyle titleTextStyleFor(BuildContext context) =>
      titleTextStyle.copyWith(color: colors(context).onSurface);

  static Color selectedItemColorFor(BuildContext context) =>
      colors(context).primary;

  static Color unselectedItemColorFor(BuildContext context) =>
      colors(context).onSurfaceVariant;

  static ImageFilter get appBarBlurFilter =>
      ImageFilter.blur(sigmaX: appBarBlurSigma, sigmaY: appBarBlurSigma);

  static ImageFilter get bottomBarBlurFilter =>
      ImageFilter.blur(sigmaX: bottomBarBlurSigma, sigmaY: bottomBarBlurSigma);

  static BoxDecoration get appBarDecoration => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withValues(alpha: 0.58),
        Colors.white.withValues(alpha: 0.34),
      ],
    ),
    border: Border(
      bottom: BorderSide(color: Colors.white.withValues(alpha: 0.42)),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 24,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.18),
        blurRadius: 10,
        offset: const Offset(0, 1),
      ),
    ],
  );

  static BoxDecoration appBarDecorationFor(BuildContext context) {
    final palette = colors(context);
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          palette.surfaceContainerLow.withValues(alpha: 0.72),
          palette.surface.withValues(alpha: 0.46),
        ],
      ),
      border: Border(
        bottom: BorderSide(
          color: palette.outlineVariant.withValues(alpha: 0.42),
        ),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.18),
          blurRadius: 10,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  static BoxDecoration get bottomBarDecoration => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withValues(alpha: 0.42),
        Colors.white.withValues(alpha: 0.62),
      ],
    ),
    border: Border(
      top: BorderSide(color: Colors.white.withValues(alpha: 0.52)),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.07),
        blurRadius: 30,
        offset: const Offset(0, -12),
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.18),
        blurRadius: 12,
        offset: const Offset(0, -1),
      ),
    ],
  );

  static BoxDecoration bottomBarDecorationFor(BuildContext context) {
    final palette = colors(context);
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          palette.surface.withValues(alpha: 0.56),
          palette.surfaceContainerLow.withValues(alpha: 0.72),
        ],
      ),
      border: Border(
        top: BorderSide(color: palette.outlineVariant.withValues(alpha: 0.52)),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.07),
          blurRadius: 30,
          offset: const Offset(0, -12),
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.18),
          blurRadius: 12,
          offset: const Offset(0, -1),
        ),
      ],
    );
  }

  static const String _iconPath = 'assets/images/icons';

  static Widget _navIcon(
    BuildContext context,
    String name, {
    required bool isActive,
  }) {
    final color = isActive
        ? selectedItemColorFor(context)
        : unselectedItemColorFor(context);
    final suffix = isActive ? '-filled' : '';
    final preserveOriginalColors = isActive && name == 'mosaic-tile';

    return SizedBox(
      width: 28,
      height: 28,
      child: Center(
        child: SvgPicture.asset(
          '$_iconPath/icon-$name$suffix.svg',
          width: 24,
          height: 24,
          fit: BoxFit.contain,
          colorFilter: preserveOriginalColors
              ? null
              : ColorFilter.mode(color, BlendMode.srcIn),
        ),
      ),
    );
  }

  static List<BottomNavigationBarItem> bottomNavigationItemsFor(
    BuildContext context,
  ) => [
    BottomNavigationBarItem(
      icon: _navIcon(context, 'home', isActive: false),
      activeIcon: _navIcon(context, 'home', isActive: true),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: _navIcon(context, 'reviews', isActive: false),
      activeIcon: _navIcon(context, 'reviews', isActive: true),
      label: 'Reviews',
    ),
    BottomNavigationBarItem(
      icon: _navIcon(context, 'mosaic-tile', isActive: false),
      activeIcon: _navIcon(context, 'mosaic-tile', isActive: true),
      label: 'Chat',
    ),
    BottomNavigationBarItem(
      icon: _navIcon(context, 'settings', isActive: false),
      activeIcon: _navIcon(context, 'settings', isActive: true),
      label: 'Settings',
    ),
  ];
  // static List<BottomNavigationBarItem> bottomNavigationItems = [
  //   BottomNavigationBarItem(
  //     icon: Icon(Icons.home_outlined),
  //     activeIcon: Icon(Icons.home),
  //     label: 'Home',
  //   ),
  //   BottomNavigationBarItem(
  //     icon: Icon(Icons.fact_check_outlined),
  //     activeIcon: Icon(Icons.fact_check),
  //     label: 'Reviews',
  //   ),
  //   BottomNavigationBarItem(
  //     icon: Icon(Icons.history_outlined),
  //     activeIcon: Icon(Icons.history),
  //     label: 'Scenes Chat',
  //   ),
  //   BottomNavigationBarItem(
  //     icon: Icon(Icons.person_outline),
  //     activeIcon: Icon(Icons.person),
  //     label: 'Settings',
  //   ),
  // ];
}
