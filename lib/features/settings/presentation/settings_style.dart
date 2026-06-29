import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';

class SettingsStyle {
  SettingsStyle._();

  static const Color primary = AppColors.primary;
  static const Color secondary = AppColors.secondary;
  static const Color background = AppColors.surface;
  static const Color onSurface = AppColors.onSurface;
  static const Color onSurfaceVariant = AppColors.onSurfaceVariant;
  static const Color outline = AppColors.outline;
  static const Color surfaceContainer = AppColors.surfaceContainer;
  static const Color cardBorder = AppColors.cardBorder;
  static const Color targetTrack = Color(0xFFEADDFF);
  static const Color error = AppColors.error;
  static const Color streakContainer = Color(0xFFFFDBCD);

  static final BorderRadius cardRadius = AppRadii.md;
  static final BorderRadius badgeRadius = AppRadii.md;
  static final BorderRadius signOutRadius = BorderRadius.circular(30);

  static const EdgeInsets pagePadding = EdgeInsets.only(
    top: 16,
    left: 16,
    right: 16,
    bottom: 100,
  );
  static const EdgeInsets avatarPadding = EdgeInsets.all(4);
  static const EdgeInsets proBadgePadding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 2,
  );
  static const EdgeInsets largeCardPadding = EdgeInsets.all(24);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets levelLabelPadding = EdgeInsets.symmetric(
    horizontal: 4,
  );
  static const EdgeInsets sectionLabelPadding = EdgeInsets.only(
    left: 8,
    bottom: 16,
  );

  static const TextStyle proBadgeTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle emailTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: onSurface,
  );

  static const TextStyle memberSinceTextStyle = TextStyle(
    fontSize: 14,
    color: onSurfaceVariant,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle cardTitleTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle fieldLabelTextStyle = TextStyle(
    fontSize: 14,
    color: onSurfaceVariant,
  );

  static const TextStyle primaryLevelTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: primary,
  );

  static const TextStyle secondaryLevelTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: secondary,
  );

  static const TextStyle levelTickTextStyle = TextStyle(
    fontSize: 12,
    color: outline,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle tileTitleTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle tileSubtitleTextStyle = TextStyle(
    fontSize: 13,
    color: onSurfaceVariant,
  );

  static const TextStyle sectionLabelTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: outline,
  );

  static const TextStyle signOutTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  static TextStyle versionTextStyle = TextStyle(
    fontSize: 12,
    color: outline.withValues(alpha: 0.6),
    fontWeight: FontWeight.w600,
  );

  static BoxDecoration avatarDecoration = BoxDecoration(
    color: surfaceContainer,
    shape: BoxShape.circle,
    border: Border.all(color: primary.withValues(alpha: 0.2), width: 4),
  );

  static BoxDecoration proBadgeDecoration = BoxDecoration(
    color: primary,
    borderRadius: badgeRadius,
    border: Border.all(color: background, width: 2),
    boxShadow: const [
      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
    ],
  );

  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white.withValues(alpha: 0.7),
    borderRadius: cardRadius,
    border: Border.all(color: cardBorder.withValues(alpha: 0.8)),
  );

  static BoxDecoration iconCircleDecoration = BoxDecoration(
    color: primary.withValues(alpha: 0.1),
    shape: BoxShape.circle,
  );

  static SliderThemeData currentSliderTheme(BuildContext context) {
    return SliderTheme.of(context).copyWith(
      activeTrackColor: surfaceContainer,
      inactiveTrackColor: surfaceContainer,
      thumbColor: primary,
      overlayColor: primary.withValues(alpha: 0.2),
      trackHeight: 8,
    );
  }

  static SliderThemeData targetSliderTheme(BuildContext context) {
    return SliderTheme.of(context).copyWith(
      activeTrackColor: targetTrack,
      inactiveTrackColor: targetTrack,
      thumbColor: secondary,
      overlayColor: secondary.withValues(alpha: 0.2),
      trackHeight: 8,
    );
  }

  static ButtonStyle signOutButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: error,
    side: const BorderSide(color: error, width: 2),
    minimumSize: const Size(double.infinity, 56),
    shape: RoundedRectangleBorder(borderRadius: signOutRadius),
  );
}
