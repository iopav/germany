import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
static const String _iconPath = 'assets/images/icons';

static List<BottomNavigationBarItem> get bottomNavigationItems => [
  BottomNavigationBarItem(
    icon: SvgPicture.asset('$_iconPath/icon-home.svg', width: 24, height: 24),
    activeIcon: SvgPicture.asset('$_iconPath/icon-home-filled.svg', width: 24, height: 24),
    label: 'Home',
  ),
  BottomNavigationBarItem(
    icon: SvgPicture.asset('$_iconPath/icon-reviews.svg', width: 24, height: 24),
    activeIcon: SvgPicture.asset('$_iconPath/icon-reviews-filled.svg', width: 24, height: 24),
    label: 'Reviews',
  ),
  BottomNavigationBarItem(
    icon: SvgPicture.asset('$_iconPath/icon-chat.svg', width: 24, height: 24),
    activeIcon: SvgPicture.asset('$_iconPath/icon-chat-filled.svg', width: 24, height: 24),
    label: 'Chat',
  ),
  BottomNavigationBarItem(
    icon: SvgPicture.asset('$_iconPath/icon-settings.svg', width: 24, height: 24),
    activeIcon: SvgPicture.asset('$_iconPath/icon-settings-filled.svg', width: 24, height: 24),
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
