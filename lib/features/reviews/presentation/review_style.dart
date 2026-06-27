import 'dart:ui';

import 'package:flutter/material.dart';

typedef ReviewPressableBuilder =
    Widget Function(BuildContext context, bool isHovered, bool isPressed);

class ReviewStyle {
  ReviewStyle._();

  static const Color primary = Color(0xFF004AC6);
  static const Color primaryFixedDim = Color(0xFFB4C5FF);
  static const Color primaryHover = Color(0xFF0B5BE8);
  static const Color primaryPressed = Color(0xFF003A99);
  static const Color secondary = Color(0xFF712AE2);
  static const Color tertiary = Color(0xFF943700);
  static const Color tertiaryContainer = Color(0xFFFFDBCE);
  static const Color surface = Color(0xFFFAF8FF);
  static const Color surfaceContainerLow = Color(0xFFF2F3FF);
  static const Color surfaceContainerHigh = Color(0xFFE2E7FF);
  static const Color surfaceContainerHighest = Color(0xFFEAEDFF);
  static const Color surfaceContainerHover = Color(0xFFDDE4FF);
  static const Color surfaceText = Color(0xFF131B2E);
  static const Color mutedText = Color(0xFF434655);
  static const Color outlineVariant = Color(0xFFC3C6D7);
  static const Color outlineSubtle = Color(0x4DC3C6D7);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color favorite = Color(0xFFBA1A1A);
  static const Color reviewBlueLight = Color(0xFF8FB3FF);
  static const Color black = Colors.black;
  static const Color white = Colors.white;
  static const Color white70 = Colors.white70;
  static const Color white54 = Colors.white54;
  static const Color white38 = Colors.white38;
  static const Color white30 = Colors.white30;
  static const Color white24 = Colors.white24;
  static const Color white10 = Colors.white10;
  static const Color transparent = Colors.transparent;

  static const Duration pressDuration = Duration(milliseconds: 90);
  static const Duration hoverDuration = Duration(milliseconds: 120);
  static const Curve pressCurve = Curves.easeOut;

  static final BorderRadius cardRadius = BorderRadius.circular(16);
  static final BorderRadius smallCardRadius = BorderRadius.circular(12);
  static final BorderRadius pillRadius = BorderRadius.circular(100);
  static final BorderRadius fullPillRadius = BorderRadius.circular(999);
  static final BorderRadius dialogRadius = BorderRadius.circular(24);
  static final BorderRadius reviewPanelRadius = BorderRadius.circular(40);
  static final BorderRadius reviewInputRadius = BorderRadius.circular(20);
  static final BorderRadius reviewSendButtonRadius = BorderRadius.circular(14);
  static final BorderRadius indicatorRadius = BorderRadius.circular(4);

  static const EdgeInsets favoritesPagePadding = EdgeInsets.only(
    top: 12,
    left: 16,
    right: 16,
    bottom: 100,
  );
  static const EdgeInsets heroPadding = EdgeInsets.all(24);
  static const EdgeInsets statCardPadding = EdgeInsets.all(16);
  static const EdgeInsets filterPadding = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets favoriteCardPadding = EdgeInsets.all(20);
  static const EdgeInsets levelBadgePadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 4,
  );
  static const EdgeInsets reviewHeaderPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );
  static const EdgeInsets reviewBottomOuterPadding = EdgeInsets.all(16);
  static const EdgeInsets reviewPanelPadding = EdgeInsets.all(24);
  static const EdgeInsets summaryPagePadding = EdgeInsets.symmetric(
    horizontal: 16,
  );
  static const EdgeInsets summaryCardPadding = EdgeInsets.all(20);
  static const EdgeInsets summaryGridCardPadding = EdgeInsets.symmetric(
    vertical: 16,
  );
  static const EdgeInsets summaryBottomBarPadding = EdgeInsets.fromLTRB(
    24,
    20,
    24,
    32,
  );

  static const TextStyle heroTitleTextStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: white,
  );

  static const TextStyle heroSubtitleTextStyle = TextStyle(
    fontSize: 14,
    color: primaryFixedDim,
    height: 1.4,
  );

  static const TextStyle primaryButtonLabelTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle statLabelTextStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: mutedText,
  );

  static const TextStyle listTitleTextStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: surfaceText,
  );

  static const TextStyle cardWordTextStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: surfaceText,
  );

  static final TextStyle cardTranslationTextStyle = TextStyle(
    fontSize: 14,
    color: mutedText.withValues(alpha: 0.7),
  );

  static const TextStyle exampleTextStyle = TextStyle(
    fontSize: 15,
    fontStyle: FontStyle.italic,
    height: 1.5,
    color: mutedText,
  );

  static const TextStyle reviewProgressLabelTextStyle = TextStyle(
    color: white70,
    fontSize: 10,
    letterSpacing: 1.5,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle reviewProgressCountTextStyle = TextStyle(
    color: white,
    fontSize: 12,
  );

  static const TextStyle currentObjectLabelTextStyle = TextStyle(
    color: primaryFixedDim,
    fontSize: 12,
    letterSpacing: 2.0,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle reviewPromptTextStyle = TextStyle(
    color: white,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    fontFamily: 'Space Grotesk',
  );

  static const TextStyle keyboardHintTextStyle = TextStyle(
    color: white38,
    fontSize: 12,
  );

  static const TextStyle summaryTitleTextStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: primary,
    fontFamily: 'Space Grotesk',
  );

  static const TextStyle summarySubtitleTextStyle = TextStyle(
    fontSize: 18,
    color: mutedText,
  );

  static const TextStyle summaryScoreTextStyle = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: primary,
    fontFamily: 'Space Grotesk',
  );

  static const TextStyle summaryMetricTitleTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: mutedText,
    letterSpacing: 1.2,
  );

  static const TextStyle summarySmallMutedTextStyle = TextStyle(
    fontSize: 12,
    color: mutedText,
  );

  static const TextStyle summarySmallPrimaryTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: primary,
  );

  static const TextStyle summaryStatValueTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: surfaceText,
  );

  static const TextStyle summaryStreakTitleTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: surfaceText,
  );

  static const TextStyle summaryActionTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static BoxDecoration heroDecoration = BoxDecoration(
    color: primary,
    borderRadius: cardRadius,
    boxShadow: [
      BoxShadow(
        color: primary.withValues(alpha: 0.3),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration statCardDecoration = BoxDecoration(
    color: surfaceContainerLow,
    borderRadius: smallCardRadius,
    border: Border.all(color: outlineVariant.withValues(alpha: 0.3)),
  );

  static BoxDecoration favoriteCardDecoration = BoxDecoration(
    color: Colors.white.withValues(alpha: 0.7),
    borderRadius: cardRadius,
    border: Border.all(color: cardBorder.withValues(alpha: 0.5)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.02),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration reviewPanelDecoration = BoxDecoration(
    color: surfaceText.withValues(alpha: 0.75),
    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
    borderRadius: reviewPanelRadius,
  );

  static BoxDecoration summaryGlassCardDecoration = BoxDecoration(
    color: Colors.white.withValues(alpha: 0.7),
    borderRadius: cardRadius,
    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration summaryStreakDecoration = BoxDecoration(
    color: Colors.white.withValues(alpha: 0.7),
    borderRadius: cardRadius,
    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
  );

  static BoxDecoration summaryOverlayDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withValues(alpha: 0.2),
        Colors.white.withValues(alpha: 0.4),
        surface,
      ],
      stops: const [0.0, 0.4, 0.9],
    ),
  );

  static LinearGradient summaryProgressGradient = const LinearGradient(
    colors: [primary, secondary],
  );

  static Color levelColor(String level) {
    switch (level.toUpperCase()) {
      case 'B2':
        return secondary;
      case 'C1':
      case 'C2':
        return tertiary;
      default:
        return primary;
    }
  }

  static Color levelBackgroundColor(String level) {
    switch (level.toUpperCase()) {
      case 'B2':
        return const Color(0xFFEADDFF);
      case 'C1':
      case 'C2':
        return const Color(0xFFFFDBCE);
      default:
        return surfaceContainerHigh;
    }
  }

  static ButtonStyle startReviewButtonStyle({required bool isElevated}) {
    return ElevatedButton.styleFrom(
      backgroundColor: white,
      foregroundColor: primary,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: pillRadius),
      elevation: isElevated ? 2 : 0,
    );
  }

  static ButtonStyle summaryPrimaryButtonStyle({required bool isElevated}) {
    return ElevatedButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: white,
      minimumSize: const Size(double.infinity, 54),
      shape: RoundedRectangleBorder(borderRadius: fullPillRadius),
      elevation: isElevated ? 6 : 4,
      shadowColor: primary.withValues(alpha: 0.3),
    );
  }

  static ButtonStyle summarySecondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primary,
    minimumSize: const Size(double.infinity, 54),
    side: const BorderSide(color: primary, width: 2),
    shape: RoundedRectangleBorder(borderRadius: fullPillRadius),
  );
}

class ReviewPressable extends StatefulWidget {
  final VoidCallback onTap;
  final ReviewPressableBuilder builder;
  final double pressedScale;

  const ReviewPressable({
    super.key,
    required this.onTap,
    required this.builder,
    this.pressedScale = 0.94,
  });

  @override
  State<ReviewPressable> createState() => _ReviewPressableState();
}

class _ReviewPressableState extends State<ReviewPressable> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapCancel: () => setState(() => _isPressed = false),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? widget.pressedScale : 1,
          duration: ReviewStyle.pressDuration,
          curve: ReviewStyle.pressCurve,
          child: widget.builder(context, _isHovered, _isPressed),
        ),
      ),
    );
  }
}

class ReviewActionChip extends StatelessWidget {
  final String label;
  final bool isSolid;
  final VoidCallback onTap;

  const ReviewActionChip({
    super.key,
    required this.label,
    required this.isSolid,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ReviewPressable(
      onTap: onTap,
      pressedScale: 0.97,
      builder: (context, isHovered, isPressed) {
        final active = isHovered || isPressed;
        final baseFill = isSolid ? 0.05 : 0.0;
        final hoverFill = isSolid ? 0.1 : 0.04;
        final pressedFill = isSolid ? 0.16 : 0.08;
        final fillOpacity = isPressed
            ? pressedFill
            : (active ? hoverFill : baseFill);
        final borderOpacity = isSolid
            ? (isPressed ? 0.22 : (active ? 0.18 : 0.1))
            : (active ? 0.12 : 0.0);
        final textColor = isSolid
            ? (isPressed ? Colors.white : Colors.white70)
            : (active ? Colors.white54 : Colors.white30);

        return AnimatedContainer(
          duration: ReviewStyle.hoverDuration,
          curve: ReviewStyle.pressCurve,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: fillOpacity),
            border: Border.all(
              color: Colors.white.withValues(alpha: borderOpacity),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}

class ReviewGlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  const ReviewGlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: ReviewPressable(
          onTap: onTap,
          builder: (context, isHovered, isPressed) {
            final opacity = isPressed ? 0.22 : (isHovered ? 0.16 : 0.1);
            return AnimatedContainer(
              duration: ReviewStyle.hoverDuration,
              curve: ReviewStyle.pressCurve,
              width: 40,
              height: 40,
              color: Colors.white.withValues(alpha: opacity),
              child: Icon(
                icon,
                color: isPressed ? iconColor : iconColor.withValues(alpha: 0.9),
                size: 20,
              ),
            );
          },
        ),
      ),
    );
  }
}

class ReviewSummaryGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ReviewSummaryGlassCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ReviewStyle.summaryGlassCardDecoration,
      child: ClipRRect(
        borderRadius: ReviewStyle.cardRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: padding ?? ReviewStyle.summaryCardPadding,
            child: child,
          ),
        ),
      ),
    );
  }
}
