import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';

class RegisterStyle {
  static const Color background = Color(0xFFFAF8FF);
  static const Color surface = Color(0xFFFAF8FF);
  static const Color primary = Color(0xFF004AC6);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF131B2E);
  static const Color onSurfaceVariant = Color(0xFF434655);
  static const Color outline = Color(0xFF737686);
  static const Color outlineVariant = Color(0xFFC3C6D7);
  static const Color primaryFixed = Color(0xFFDBE1FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color glassBorder = Color(0xFFE2E8F0);

  static final BorderRadius glassPanelRadius = BorderRadius.circular(24);
  static final BorderRadius inputRadius = BorderRadius.circular(12);
  static final BorderRadius buttonRadius = BorderRadius.circular(28);
  static final BorderRadius indicatorRadius = BorderRadius.circular(4);

  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 32.0,
  );
  static const EdgeInsets glassPanelPadding = EdgeInsets.all(24);
  static const EdgeInsets labelPadding = EdgeInsets.only(left: 4.0);
  static const EdgeInsets inputContentPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 16,
  );

  static const TextStyle appBarTitleTextStyle = TextStyle(
    color: primary,
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: -0.5,
  );

  static const TextStyle loginActionTextStyle = TextStyle(
    color: primary,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  static const TextStyle heroTitleTextStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: onSurface,
    height: 1.2,
  );

  static const TextStyle heroSubtitleTextStyle = TextStyle(
    fontSize: 16,
    color: onSurfaceVariant,
  );

  static const TextStyle labelTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: onSurface,
  );

  static const TextStyle sectionTitleTextStyle = TextStyle(
    fontWeight: FontWeight.w600,
    color: onSurfaceVariant,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle copyrightTextStyle = TextStyle(
    color: onSurfaceVariant,
    fontSize: 12,
  );

  static const TextStyle footerLinkTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: onSurfaceVariant,
  );

  static const TextStyle levelTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primary,
  );

  static Color appBarBackgroundColor = surface.withValues(alpha: 0.8);

  static AppPalette colors(BuildContext context) => AppPalettes.of(context);

  static Color backgroundColor(BuildContext context) => colors(context).surface;

  static Color appBarBackgroundColorFor(BuildContext context) =>
      colors(context).surface.withValues(alpha: 0.86);

  static TextStyle appBarTitleTextStyleFor(BuildContext context) =>
      appBarTitleTextStyle.copyWith(color: colors(context).primary);

  static TextStyle loginActionTextStyleFor(BuildContext context) =>
      loginActionTextStyle.copyWith(color: colors(context).primary);

  static TextStyle heroTitleTextStyleFor(BuildContext context) =>
      heroTitleTextStyle.copyWith(color: colors(context).onSurface);

  static TextStyle heroSubtitleTextStyleFor(BuildContext context) =>
      heroSubtitleTextStyle.copyWith(color: colors(context).onSurfaceVariant);

  static TextStyle labelTextStyleFor(BuildContext context) =>
      labelTextStyle.copyWith(color: colors(context).onSurface);

  static TextStyle sectionTitleTextStyleFor(BuildContext context) =>
      sectionTitleTextStyle.copyWith(color: colors(context).onSurfaceVariant);

  static TextStyle copyrightTextStyleFor(BuildContext context) =>
      copyrightTextStyle.copyWith(color: colors(context).onSurfaceVariant);

  static TextStyle footerLinkTextStyleFor(BuildContext context) =>
      footerLinkTextStyle.copyWith(color: colors(context).onSurfaceVariant);

  static TextStyle levelTextStyleFor(BuildContext context) =>
      levelTextStyle.copyWith(color: colors(context).primary);

  static BoxDecoration glassPanelDecoration = BoxDecoration(
    color: Colors.white.withValues(alpha: 0.7),
    borderRadius: glassPanelRadius,
    border: Border.all(color: glassBorder.withValues(alpha: 0.6)),
  );

  static BoxDecoration glassPanelDecorationFor(BuildContext context) {
    final palette = colors(context);
    return BoxDecoration(
      color: palette.surfaceContainerLow.withValues(alpha: 0.76),
      borderRadius: glassPanelRadius,
      border: Border.all(color: palette.cardBorder.withValues(alpha: 0.62)),
    );
  }

  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: onPrimary,
    minimumSize: const Size(double.infinity, 56),
    shape: RoundedRectangleBorder(borderRadius: buttonRadius),
    elevation: 8,
    shadowColor: primary.withValues(alpha: 0.4),
  );

  static ButtonStyle primaryButtonStyleFor(BuildContext context) {
    final palette = colors(context);
    return ElevatedButton.styleFrom(
      backgroundColor: palette.primary,
      foregroundColor: palette.onPrimary,
      minimumSize: const Size(double.infinity, 56),
      shape: RoundedRectangleBorder(borderRadius: buttonRadius),
      elevation: 8,
      shadowColor: palette.primary.withValues(alpha: 0.36),
    );
  }

  static InputDecoration inputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: outline),
      filled: true,
      fillColor: surfaceContainerLowest,
      contentPadding: inputContentPadding,
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: const BorderSide(color: outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: const BorderSide(color: primary, width: 2),
      ),
    );
  }

  static InputDecoration inputDecorationFor(
    BuildContext context,
    String hint, {
    Widget? suffixIcon,
  }) {
    final palette = colors(context);
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: palette.outline),
      filled: true,
      fillColor: palette.surfaceContainerLow,
      contentPadding: inputContentPadding,
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: BorderSide(color: palette.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: BorderSide(color: palette.primary, width: 2),
      ),
    );
  }

  static BoxDecoration levelGlowDecoration = BoxDecoration(
    shape: BoxShape.circle,
    color: primary.withValues(alpha: 0.1),
    boxShadow: [
      BoxShadow(color: primary.withValues(alpha: 0.3), blurRadius: 30),
    ],
  );

  static BoxDecoration levelIndicatorDecoration = BoxDecoration(
    color: primary,
    borderRadius: indicatorRadius,
    boxShadow: [
      BoxShadow(color: primary.withValues(alpha: 0.5), blurRadius: 10),
    ],
  );

  static BoxDecoration levelWheelDecoration = BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(color: outlineVariant.withValues(alpha: 0.5), width: 2),
  );

  static BoxDecoration levelItemDecoration({required bool isActive}) {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: isActive ? primary : Colors.white.withValues(alpha: 0.9),
      border: Border.all(
        color: isActive ? primaryFixed : outlineVariant,
        width: 1,
      ),
      boxShadow: [
        if (isActive)
          BoxShadow(
            color: primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        else
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
      ],
    );
  }

  static BoxDecoration levelGlowDecorationFor(BuildContext context) {
    final palette = colors(context);
    return BoxDecoration(
      shape: BoxShape.circle,
      color: palette.primary.withValues(alpha: 0.1),
      boxShadow: [
        BoxShadow(
          color: palette.primary.withValues(alpha: 0.28),
          blurRadius: 30,
        ),
      ],
    );
  }

  static BoxDecoration levelIndicatorDecorationFor(BuildContext context) {
    final palette = colors(context);
    return BoxDecoration(
      color: palette.primary,
      borderRadius: indicatorRadius,
      boxShadow: [
        BoxShadow(
          color: palette.primary.withValues(alpha: 0.42),
          blurRadius: 10,
        ),
      ],
    );
  }

  static BoxDecoration levelWheelDecorationFor(BuildContext context) {
    final palette = colors(context);
    return BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: palette.outlineVariant.withValues(alpha: 0.55),
        width: 2,
      ),
    );
  }

  static BoxDecoration levelItemDecorationFor(
    BuildContext context, {
    required bool isActive,
  }) {
    final palette = colors(context);
    return BoxDecoration(
      shape: BoxShape.circle,
      color: isActive
          ? palette.primary
          : palette.surfaceContainerLow.withValues(alpha: 0.92),
      border: Border.all(
        color: isActive ? palette.primaryContainer : palette.outlineVariant,
        width: 1,
      ),
      boxShadow: [
        if (isActive)
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        else
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
      ],
    );
  }

  static TextStyle levelItemTextStyle({required bool isActive}) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: isActive ? onPrimary : onSurfaceVariant,
    );
  }

  static TextStyle levelItemTextStyleFor(
    BuildContext context, {
    required bool isActive,
  }) {
    final palette = colors(context);
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: isActive ? palette.onPrimary : palette.onSurfaceVariant,
    );
  }
}

class RegisterLabel extends StatelessWidget {
  final String text;

  const RegisterLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: RegisterStyle.labelPadding,
      child: Text(text, style: RegisterStyle.labelTextStyleFor(context)),
    );
  }
}

class RegisterGlassPanel extends StatelessWidget {
  final Widget child;

  const RegisterGlassPanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: RegisterStyle.glassPanelPadding,
      decoration: RegisterStyle.glassPanelDecorationFor(context),
      child: child,
    );
  }
}

class RegisterFooterLink extends StatelessWidget {
  final String text;

  const RegisterFooterLink({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Text(text, style: RegisterStyle.footerLinkTextStyleFor(context)),
    );
  }
}
