import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_radii.dart';

class HomeStyle {
  static const Color background = AppColors.surface;
  static const Color primary = AppColors.primary;
  static const Color onSurface = AppColors.onSurface;
  static const Color onSurfaceVariant = AppColors.onSurfaceVariant;
  static const Color outlineVariant = AppColors.outlineVariant;
  static const Color surfaceContainerHigh = AppColors.surfaceContainerHigh;
  static const Color surfaceContainerHighest =
      AppColors.surfaceContainerHighest;
  static const Color uploadAccent = Color(0xFF7C8CF8);
  static const Color submitButton = Color(0xFF007AFF);

  static final BorderRadius uploadRadius = BorderRadius.circular(32);
  static final BorderRadius promptPanelRadius = BorderRadius.circular(28);
  static final BorderRadius uploadButtonRadius = BorderRadius.circular(24);
  static final BorderRadius menuRadius = AppRadii.lg;
  static final BorderRadius promptInputRadius = AppRadii.lg;
  static final BorderRadius quickStarterRadius = AppRadii.sm;
  static final BorderRadius pillRadius = AppRadii.pill;

  static const EdgeInsets uploadButtonPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 32,
  );
  static const EdgeInsets promptPanelPadding = EdgeInsets.all(16);
  static const EdgeInsets selectedBadgePadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
  );
  static const EdgeInsets menuOptionPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 16,
  );
  static const EdgeInsets quickStarterPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  );
  static const EdgeInsets promptInputContentPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );

  static const TextStyle titleTextStyle = TextStyle(
    fontFamily: 'Space Grotesk',
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: onSurface,
  );

  static const TextStyle subtitleTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    color: onSurfaceVariant,
  );

  static const TextStyle uploadButtonTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: primary,
  );

  static const TextStyle selectedBadgeTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: primary,
  );

  static const TextStyle promptInputTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    color: onSurface,
  );

  static const TextStyle generatingTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    color: onSurfaceVariant,
  );

  static const TextStyle menuOptionTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    color: onSurface,
  );

  static const TextStyle quickStarterTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    color: onSurfaceVariant,
  );

  static AppPalette colors(BuildContext context) => AppPalettes.of(context);

  static Color backgroundColor(BuildContext context) => colors(context).surface;

  static Color primaryColor(BuildContext context) => colors(context).primary;

  static Color uploadAccentColor(BuildContext context) =>
      colors(context).secondary;

  static Color submitButtonColor(BuildContext context) =>
      colors(context).primary;

  static TextStyle titleTextStyleFor(BuildContext context) =>
      titleTextStyle.copyWith(color: colors(context).onSurface);

  static TextStyle subtitleTextStyleFor(BuildContext context) =>
      subtitleTextStyle.copyWith(color: colors(context).onSurfaceVariant);

  static TextStyle uploadButtonTextStyleFor(BuildContext context) =>
      uploadButtonTextStyle.copyWith(color: colors(context).primary);

  static TextStyle selectedBadgeTextStyleFor(BuildContext context) =>
      selectedBadgeTextStyle.copyWith(color: colors(context).primary);

  static TextStyle promptInputTextStyleFor(BuildContext context) =>
      promptInputTextStyle.copyWith(color: colors(context).onSurface);

  static TextStyle generatingTextStyleFor(BuildContext context) =>
      generatingTextStyle.copyWith(color: colors(context).onSurfaceVariant);

  static TextStyle menuOptionTextStyleFor(BuildContext context) =>
      menuOptionTextStyle.copyWith(color: colors(context).onSurface);

  static TextStyle quickStarterTextStyleFor(BuildContext context) =>
      quickStarterTextStyle.copyWith(color: colors(context).onSurfaceVariant);

  static BoxDecoration uploadBackgroundDecoration = BoxDecoration(
    color: surfaceContainerHigh.withValues(alpha: 0.35),
    borderRadius: uploadRadius,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.58),
        surfaceContainerHigh.withValues(alpha: 0.34),
        surfaceContainerHighest.withValues(alpha: 0.28),
      ],
    ),
  );

  static BoxDecoration promptInputDecoration = BoxDecoration(
    color: Colors.black.withValues(alpha: 0.05),
    borderRadius: promptInputRadius,
  );

  static BoxDecoration submitButtonDecoration = BoxDecoration(
    color: submitButton,
    borderRadius: promptInputRadius,
    boxShadow: [
      BoxShadow(
        color: submitButton.withValues(alpha: 0.3),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static InputDecoration promptInputDecorationData = const InputDecoration(
    hintText: 'Describe a scene...',
    hintStyle: TextStyle(color: Colors.black38),
    prefixIcon: Icon(Icons.auto_awesome, color: primary, size: 20),
    border: InputBorder.none,
    contentPadding: promptInputContentPadding,
  );

  static BoxDecoration uploadBackgroundDecorationFor(BuildContext context) {
    final palette = colors(context);
    return BoxDecoration(
      color: palette.surfaceContainerHigh.withValues(alpha: 0.35),
      borderRadius: uploadRadius,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          palette.surfaceContainerLow.withValues(alpha: 0.72),
          palette.surfaceContainerHigh.withValues(alpha: 0.42),
          palette.surfaceContainerHighest.withValues(alpha: 0.28),
        ],
      ),
    );
  }

  static BoxDecoration promptInputDecorationFor(BuildContext context) {
    final palette = colors(context);
    return BoxDecoration(
      color: palette.onSurface.withValues(alpha: 0.05),
      borderRadius: promptInputRadius,
    );
  }

  static BoxDecoration submitButtonDecorationFor(BuildContext context) {
    final palette = colors(context);
    return BoxDecoration(
      color: palette.primary,
      borderRadius: promptInputRadius,
      boxShadow: [
        BoxShadow(
          color: palette.primary.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static InputDecoration promptInputDecorationDataFor(BuildContext context) {
    final palette = colors(context);
    return InputDecoration(
      hintText: 'Describe a scene...',
      hintStyle: TextStyle(color: palette.onSurface.withValues(alpha: 0.38)),
      prefixIcon: Icon(Icons.auto_awesome, color: palette.primary, size: 20),
      border: InputBorder.none,
      contentPadding: promptInputContentPadding,
    );
  }
}

class HomeGlassContainer extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsets padding;

  const HomeGlassContainer({
    super.key,
    required this.child,
    required this.radius,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: HomeStyle.colors(
              context,
            ).surfaceContainerLow.withValues(alpha: 0.62),
            border: Border.all(
              color: HomeStyle.colors(
                context,
              ).outlineVariant.withValues(alpha: 0.32),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class HomeMenuOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const HomeMenuOption({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: HomeStyle.menuOptionPadding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: HomeStyle.primaryColor(context), size: 20),
            const SizedBox(width: 16),
            Text(title, style: HomeStyle.menuOptionTextStyleFor(context)),
          ],
        ),
      ),
    );
  }
}

class HomeQuickStarter extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const HomeQuickStarter({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: HomeStyle.quickStarterRadius,
        child: Container(
          padding: HomeStyle.quickStarterPadding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: HomeStyle.quickStarterRadius,
            border: Border.all(
              color: HomeStyle.colors(
                context,
              ).outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✨', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(label, style: HomeStyle.quickStarterTextStyleFor(context)),
            ],
          ),
        ),
      ),
    );
  }
}
