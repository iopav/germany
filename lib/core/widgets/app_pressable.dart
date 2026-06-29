import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

typedef AppPressableBuilder =
    Widget Function(BuildContext context, bool isHovered, bool isPressed);

class AppPressable extends StatefulWidget {
  final VoidCallback onTap;
  final AppPressableBuilder builder;
  final double pressedScale;

  const AppPressable({
    super.key,
    required this.onTap,
    required this.builder,
    this.pressedScale = 0.94,
  });

  @override
  State<AppPressable> createState() => _AppPressableState();
}

class _AppPressableState extends State<AppPressable> {
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
          duration: AppMotion.pressDuration,
          curve: AppMotion.pressCurve,
          child: widget.builder(context, _isHovered, _isPressed),
        ),
      ),
    );
  }
}
