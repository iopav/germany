import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/widgets/app_pressable.dart';

class HistoryStyle {
  HistoryStyle._();

  static const Color primary = AppColors.primary;
  static const Color surface = AppColors.surface;
  static const Color surfaceContainer = AppColors.surfaceContainer;
  static const Color surfaceContainerHover = AppColors.surfaceContainerHover;
  static const Color surfaceContainerHigh = AppColors.surfaceContainerHigh;
  static const Color onSurface = AppColors.onSurface;
  static const Color onSurfaceVariant = AppColors.onSurfaceVariant;
  static const Color outline = AppColors.outline;
  static const Color outlineVariant = AppColors.outlineVariant;
  static const Color error = AppColors.error;
  static const Color activeNav = Color(0xFF8A4CFC);

  static final BorderRadius cardRadius = AppRadii.md;
  static final BorderRadius pillRadius = AppRadii.pill;
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
          child: AppPressable(
            onTap: onTap,
            pressedScale: 0.9,
            builder: (context, isHovered, isPressed) {
              return AnimatedContainer(
                duration: AppMotion.hoverDuration,
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
