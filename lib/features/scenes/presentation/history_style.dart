import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:germany/features/reviews/presentation/review_style.dart';

class HistoryStyle {
  HistoryStyle._();

  static const Color primary = Color(0xFF004AC6);
  static const Color surface = Color(0xFFFAF8FF);
  static const Color surfaceContainer = Color(0xFFEAEDFF);
  static const Color surfaceContainerHover = Color(0xFFDDE4FF);
  static const Color surfaceContainerHigh = Color(0xFFE2E7FF);
  static const Color onSurface = Color(0xFF131B2E);
  static const Color onSurfaceVariant = Color(0xFF434655);
  static const Color outline = Color(0xFF737686);
  static const Color outlineVariant = Color(0xFFC3C6D7);
  static const Color error = Color(0xFFBA1A1A);
  static const Color activeNav = Color(0xFF8A4CFC);

  static final BorderRadius cardRadius = BorderRadius.circular(12);
  static final BorderRadius pillRadius = BorderRadius.circular(100);
  static const BorderRadius bottomNavRadius = BorderRadius.vertical(
    top: Radius.circular(16),
  );

  static const EdgeInsets pagePadding = EdgeInsets.only(
    top: 12,
    left: 12,
    right: 12,
    bottom: 100,
  );
  static const EdgeInsets cardTextPadding = EdgeInsets.all(12);
  static const EdgeInsets statePadding = EdgeInsets.all(32);
  static const EdgeInsets activeNavPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 6,
  );

  static const TextStyle searchHintTextStyle = TextStyle(
    color: onSurfaceVariant,
    fontSize: 14,
  );

  static const TextStyle cardTitleTextStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: onSurface,
  );

  static const TextStyle cardDateTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: outline,
  );

  static const TextStyle stateMessageTextStyle = TextStyle(
    color: onSurfaceVariant,
    fontSize: 14,
  );

  static const TextStyle emptyTitleTextStyle = TextStyle(
    fontFamily: 'Space Grotesk',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: onSurface,
  );

  static const TextStyle emptyBodyTextStyle = TextStyle(
    fontSize: 16,
    color: outline,
    height: 1.5,
  );

  static const TextStyle navTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: onSurfaceVariant,
  );

  static const TextStyle activeNavTextStyle = TextStyle(
    fontSize: 12,
    color: Colors.white,
    fontWeight: FontWeight.w600,
  );

  static BoxDecoration searchDecoration = BoxDecoration(
    color: surfaceContainer,
    borderRadius: cardRadius,
  );

  static BoxDecoration refreshDecoration({required bool isActive}) {
    return BoxDecoration(
      color: isActive ? surfaceContainerHover : surfaceContainer,
      borderRadius: cardRadius,
    );
  }

  static BoxDecoration sceneCardDecoration({required bool isActive}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: cardRadius,
      border: Border.all(color: outlineVariant.withValues(alpha: 0.2)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isActive ? 0.09 : 0.05),
          blurRadius: isActive ? 24 : 20,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static ButtonStyle scannerButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: pillRadius),
    elevation: 4,
    shadowColor: primary.withValues(alpha: 0.2),
  );

  static BoxDecoration bottomNavDecoration = BoxDecoration(
    color: surface.withValues(alpha: 0.8),
    border: const Border(top: BorderSide(color: Color(0x1F737686), width: 0.5)),
  );

  static BoxDecoration activeNavDecoration = BoxDecoration(
    color: activeNav,
    borderRadius: pillRadius,
  );
}

class HistoryDeleteButton extends StatelessWidget {
  final VoidCallback onTap;

  const HistoryDeleteButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: HistoryStyle.pillRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.transparent,
          child: ReviewPressable(
            onTap: onTap,
            pressedScale: 0.9,
            builder: (context, isHovered, isPressed) {
              return AnimatedContainer(
                duration: ReviewStyle.hoverDuration,
                width: 32,
                height: 32,
                color: Colors.white.withValues(
                  alpha: isHovered || isPressed ? 0.9 : 0.7,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: HistoryStyle.error,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
