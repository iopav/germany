import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_palette.dart';
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
  static final BorderRadius sheetRadius = BorderRadius.circular(24);
  static final BorderRadius createButtonRadius = BorderRadius.circular(18);
  static const BorderRadius bottomNavRadius = BorderRadius.vertical(
    top: Radius.circular(16),
  );

  static const double createButtonSize = 56;
  static const double createButtonRight = 24;
  static const double createButtonBottom = 104;
  static const double createMenuBottom = 176;

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
  static const EdgeInsets sourceSheetPadding = EdgeInsets.fromLTRB(
    16,
    12,
    16,
    24,
  );
  static const EdgeInsets sourceSheetHandlePadding = EdgeInsets.only(
    bottom: 12,
  );
  static const EdgeInsets sourceOptionPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 14,
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

  static const TextStyle sourceSheetTitleTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: onSurface,
  );

  static const TextStyle sourceOptionTitleTextStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: onSurface,
  );

  static const TextStyle sourceOptionSubtitleTextStyle = TextStyle(
    fontSize: 12,
    color: onSurfaceVariant,
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

  static AppPalette colors(BuildContext context) => AppPalettes.of(context);

  static TextStyle searchHintTextStyleFor(BuildContext context) =>
      searchHintTextStyle.copyWith(color: colors(context).onSurfaceVariant);

  static TextStyle cardTitleTextStyleFor(BuildContext context) =>
      cardTitleTextStyle.copyWith(color: colors(context).onSurface);

  static TextStyle cardDateTextStyleFor(BuildContext context) =>
      cardDateTextStyle.copyWith(color: colors(context).outline);

  static TextStyle stateMessageTextStyleFor(BuildContext context) =>
      stateMessageTextStyle.copyWith(color: colors(context).onSurfaceVariant);

  static TextStyle emptyTitleTextStyleFor(BuildContext context) =>
      emptyTitleTextStyle.copyWith(color: colors(context).onSurface);

  static TextStyle emptyBodyTextStyleFor(BuildContext context) =>
      emptyBodyTextStyle.copyWith(color: colors(context).outline);

  static TextStyle sourceSheetTitleTextStyleFor(BuildContext context) =>
      sourceSheetTitleTextStyle.copyWith(color: colors(context).onSurface);

  static TextStyle sourceOptionTitleTextStyleFor(BuildContext context) =>
      sourceOptionTitleTextStyle.copyWith(color: colors(context).onSurface);

  static TextStyle sourceOptionSubtitleTextStyleFor(BuildContext context) =>
      sourceOptionSubtitleTextStyle.copyWith(
        color: colors(context).onSurfaceVariant,
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

  static BoxDecoration searchDecorationFor(BuildContext context) {
    final palette = colors(context);
    return BoxDecoration(
      color: palette.surfaceContainer,
      borderRadius: cardRadius,
    );
  }

  static BoxDecoration refreshDecorationFor(
    BuildContext context, {
    required bool isActive,
  }) {
    final palette = colors(context);
    return BoxDecoration(
      color: isActive
          ? palette.surfaceContainerHover
          : palette.surfaceContainer,
      borderRadius: cardRadius,
    );
  }

  static BoxDecoration sceneCardDecorationFor(
    BuildContext context, {
    required bool isActive,
  }) {
    final palette = colors(context);
    return BoxDecoration(
      color: palette.surfaceContainerLow.withValues(alpha: 0.86),
      borderRadius: cardRadius,
      border: Border.all(color: palette.outlineVariant.withValues(alpha: 0.28)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isActive ? 0.09 : 0.05),
          blurRadius: isActive ? 24 : 20,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static ButtonStyle scannerButtonStyleFor(BuildContext context) {
    final palette = colors(context);
    return ElevatedButton.styleFrom(
      backgroundColor: palette.primary,
      foregroundColor: palette.onPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: pillRadius),
      elevation: 4,
      shadowColor: palette.primary.withValues(alpha: 0.2),
    );
  }

  static BoxDecoration sourceSheetDecorationFor(BuildContext context) {
    final palette = colors(context);
    return BoxDecoration(
      color: palette.surface,
      borderRadius: BorderRadius.vertical(top: sheetRadius.topLeft),
      border: Border(
        top: BorderSide(color: palette.outlineVariant.withValues(alpha: 0.45)),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 28,
          offset: const Offset(0, -10),
        ),
      ],
    );
  }

  static BoxDecoration sourceSheetHandleDecorationFor(BuildContext context) {
    return BoxDecoration(
      color: colors(context).outlineVariant.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(999),
    );
  }

  static BoxDecoration sourceOptionDecorationFor(BuildContext context) {
    final palette = colors(context);
    return BoxDecoration(
      color: palette.surfaceContainerLow.withValues(alpha: 0.86),
      borderRadius: cardRadius,
      border: Border.all(color: palette.cardBorder.withValues(alpha: 0.72)),
    );
  }

  static BoxDecoration sourceOptionIconDecorationFor(BuildContext context) {
    final palette = colors(context);
    return BoxDecoration(
      color: palette.primary.withValues(alpha: 0.1),
      shape: BoxShape.circle,
    );
  }

  static BoxDecoration createButtonDecorationFor(
    BuildContext context, {
    required bool isActive,
  }) {
    final palette = colors(context);
    return BoxDecoration(
      color: isActive ? palette.primaryPressed : palette.primary,
      borderRadius: createButtonRadius,
      border: Border.all(color: palette.onPrimary.withValues(alpha: 0.18)),
    );
  }
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
                child: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: HistoryStyle.colors(context).error,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
