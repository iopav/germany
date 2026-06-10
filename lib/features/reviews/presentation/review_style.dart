import 'dart:ui';

import 'package:flutter/material.dart';

typedef ReviewPressableBuilder =
    Widget Function(BuildContext context, bool isHovered, bool isPressed);

class ReviewStyle {
  ReviewStyle._();

  static const Color primary = Color(0xFF004AC6);
  static const Color primaryHover = Color(0xFF0B5BE8);
  static const Color primaryPressed = Color(0xFF003A99);
  static const Color surfaceText = Color(0xFF131B2E);
  static const Color mutedText = Color(0xFF434655);

  static const Duration pressDuration = Duration(milliseconds: 90);
  static const Duration hoverDuration = Duration(milliseconds: 120);
  static const Curve pressCurve = Curves.easeOut;
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
