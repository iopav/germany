import 'package:flutter/material.dart';

import 'app_colors.dart';

enum AppPaletteKey {
  cool,
  warm;

  static AppPaletteKey fromName(String? name) {
    return AppPaletteKey.values.firstWhere(
      (key) => key.name == name,
      orElse: () => AppPaletteKey.warm,
    );
  }
}

class AppPalette extends ThemeExtension<AppPalette> {
  final AppPaletteKey key;
  final Color primary;
  final Color primaryHover;
  final Color primaryPressed;
  final Color primaryContainer;
  final Color onPrimary;
  final Color secondary;
  final Color secondaryContainer;
  final Color tertiary;
  final Color tertiaryContainer;
  final Color surface;
  final Color surfaceDim;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color surfaceContainerHover;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color mutedText;
  final Color outline;
  final Color outlineVariant;
  final Color cardBorder;
  final Color iconContainer;
  final Color error;
  final Color success;
  final Color warning;
  final Color accentGold;
  final Color accentBurntOrange;
  final Color accentTerracotta;
  final Color accentEspresso;
  final Color accentCocoa;
  final Color accentForest;
  final Color accentSlate;

  const AppPalette({
    required this.key,
    required this.primary,
    required this.primaryHover,
    required this.primaryPressed,
    required this.primaryContainer,
    required this.onPrimary,
    required this.secondary,
    required this.secondaryContainer,
    required this.tertiary,
    required this.tertiaryContainer,
    required this.surface,
    required this.surfaceDim,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.surfaceContainerHover,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.mutedText,
    required this.outline,
    required this.outlineVariant,
    required this.cardBorder,
    required this.iconContainer,
    required this.error,
    required this.success,
    required this.warning,
    required this.accentGold,
    required this.accentBurntOrange,
    required this.accentTerracotta,
    required this.accentEspresso,
    required this.accentCocoa,
    required this.accentForest,
    required this.accentSlate,
  });

  @override
  AppPalette copyWith({
    AppPaletteKey? key,
    Color? primary,
    Color? primaryHover,
    Color? primaryPressed,
    Color? primaryContainer,
    Color? onPrimary,
    Color? secondary,
    Color? secondaryContainer,
    Color? tertiary,
    Color? tertiaryContainer,
    Color? surface,
    Color? surfaceDim,
    Color? surfaceContainerLow,
    Color? surfaceContainer,
    Color? surfaceContainerHigh,
    Color? surfaceContainerHighest,
    Color? surfaceContainerHover,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? mutedText,
    Color? outline,
    Color? outlineVariant,
    Color? cardBorder,
    Color? iconContainer,
    Color? error,
    Color? success,
    Color? warning,
    Color? accentGold,
    Color? accentBurntOrange,
    Color? accentTerracotta,
    Color? accentEspresso,
    Color? accentCocoa,
    Color? accentForest,
    Color? accentSlate,
  }) {
    return AppPalette(
      key: key ?? this.key,
      primary: primary ?? this.primary,
      primaryHover: primaryHover ?? this.primaryHover,
      primaryPressed: primaryPressed ?? this.primaryPressed,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      tertiary: tertiary ?? this.tertiary,
      tertiaryContainer: tertiaryContainer ?? this.tertiaryContainer,
      surface: surface ?? this.surface,
      surfaceDim: surfaceDim ?? this.surfaceDim,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      surfaceContainerHighest:
          surfaceContainerHighest ?? this.surfaceContainerHighest,
      surfaceContainerHover:
          surfaceContainerHover ?? this.surfaceContainerHover,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      mutedText: mutedText ?? this.mutedText,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      cardBorder: cardBorder ?? this.cardBorder,
      iconContainer: iconContainer ?? this.iconContainer,
      error: error ?? this.error,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      accentGold: accentGold ?? this.accentGold,
      accentBurntOrange: accentBurntOrange ?? this.accentBurntOrange,
      accentTerracotta: accentTerracotta ?? this.accentTerracotta,
      accentEspresso: accentEspresso ?? this.accentEspresso,
      accentCocoa: accentCocoa ?? this.accentCocoa,
      accentForest: accentForest ?? this.accentForest,
      accentSlate: accentSlate ?? this.accentSlate,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) {
      return this;
    }

    return AppPalette(
      key: t < 0.5 ? key : other.key,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryHover: Color.lerp(primaryHover, other.primaryHover, t)!,
      primaryPressed: Color.lerp(primaryPressed, other.primaryPressed, t)!,
      primaryContainer: Color.lerp(
        primaryContainer,
        other.primaryContainer,
        t,
      )!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondaryContainer: Color.lerp(
        secondaryContainer,
        other.secondaryContainer,
        t,
      )!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      tertiaryContainer: Color.lerp(
        tertiaryContainer,
        other.tertiaryContainer,
        t,
      )!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceDim: Color.lerp(surfaceDim, other.surfaceDim, t)!,
      surfaceContainerLow: Color.lerp(
        surfaceContainerLow,
        other.surfaceContainerLow,
        t,
      )!,
      surfaceContainer: Color.lerp(
        surfaceContainer,
        other.surfaceContainer,
        t,
      )!,
      surfaceContainerHigh: Color.lerp(
        surfaceContainerHigh,
        other.surfaceContainerHigh,
        t,
      )!,
      surfaceContainerHighest: Color.lerp(
        surfaceContainerHighest,
        other.surfaceContainerHighest,
        t,
      )!,
      surfaceContainerHover: Color.lerp(
        surfaceContainerHover,
        other.surfaceContainerHover,
        t,
      )!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant: Color.lerp(
        onSurfaceVariant,
        other.onSurfaceVariant,
        t,
      )!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      iconContainer: Color.lerp(iconContainer, other.iconContainer, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      accentGold: Color.lerp(accentGold, other.accentGold, t)!,
      accentBurntOrange: Color.lerp(
        accentBurntOrange,
        other.accentBurntOrange,
        t,
      )!,
      accentTerracotta: Color.lerp(
        accentTerracotta,
        other.accentTerracotta,
        t,
      )!,
      accentEspresso: Color.lerp(accentEspresso, other.accentEspresso, t)!,
      accentCocoa: Color.lerp(accentCocoa, other.accentCocoa, t)!,
      accentForest: Color.lerp(accentForest, other.accentForest, t)!,
      accentSlate: Color.lerp(accentSlate, other.accentSlate, t)!,
    );
  }
}

class AppPalettes {
  AppPalettes._();

  static const AppPalette cool = AppPalette(
    key: AppPaletteKey.cool,
    primary: AppColors.primary,
    primaryHover: AppColors.primaryHover,
    primaryPressed: AppColors.primaryPressed,
    primaryContainer: AppColors.primaryFixedDim,
    onPrimary: Colors.white,
    secondary: AppColors.secondary,
    secondaryContainer: Color(0xFFEADDFF),
    tertiary: AppColors.tertiary,
    tertiaryContainer: AppColors.tertiaryContainer,
    surface: AppColors.surface,
    surfaceDim: AppColors.surfaceContainerHigh,
    surfaceContainerLow: AppColors.surfaceContainerLow,
    surfaceContainer: AppColors.surfaceContainer,
    surfaceContainerHigh: AppColors.surfaceContainerHigh,
    surfaceContainerHighest: AppColors.surfaceContainerHighest,
    surfaceContainerHover: AppColors.surfaceContainerHover,
    onSurface: AppColors.onSurface,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    mutedText: AppColors.outline,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    cardBorder: AppColors.cardBorder,
    iconContainer: AppColors.iconContainer,
    error: AppColors.error,
    success: Color(0xFF2E7D32),
    warning: Color(0xFFF57C00),
    accentGold: AppColors.accentGold,
    accentBurntOrange: AppColors.accentBurntOrange,
    accentTerracotta: AppColors.accentTerracotta,
    accentEspresso: AppColors.accentEspresso,
    accentCocoa: AppColors.accentCocoa,
    accentForest: AppColors.accentForest,
    accentSlate: AppColors.accentSlate,
  );

  static const AppPalette warm = AppPalette(
    key: AppPaletteKey.warm,
    primary: AppColorsWarm.primary,
    primaryHover: AppColorsWarm.primaryHover,
    primaryPressed: AppColorsWarm.primaryPressed,
    primaryContainer: AppColorsWarm.primaryContainer,
    onPrimary: AppColorsWarm.onPrimary,
    secondary: AppColorsWarm.secondary,
    secondaryContainer: AppColorsWarm.secondaryContainer,
    tertiary: AppColorsWarm.tertiary,
    tertiaryContainer: AppColorsWarm.tertiaryContainer,
    surface: AppColorsWarm.background,
    surfaceDim: AppColorsWarm.surfaceDim,
    surfaceContainerLow: AppColorsWarm.surfaceContainerLow,
    surfaceContainer: AppColorsWarm.surfaceContainer,
    surfaceContainerHigh: AppColorsWarm.surfaceContainerHigh,
    surfaceContainerHighest: AppColorsWarm.surfaceContainerHighest,
    surfaceContainerHover: AppColorsWarm.primaryContainer,
    onSurface: AppColorsWarm.onSurface,
    onSurfaceVariant: AppColorsWarm.onSurfaceVariant,
    mutedText: AppColorsWarm.mutedText,
    outline: AppColorsWarm.outline,
    outlineVariant: AppColorsWarm.outlineVariant,
    cardBorder: AppColorsWarm.cardBorder,
    iconContainer: AppColorsWarm.iconContainer,
    error: AppColorsWarm.error,
    success: AppColorsWarm.success,
    warning: AppColorsWarm.warning,
    accentGold: AppColorsWarm.accentGold,
    accentBurntOrange: AppColorsWarm.accentBurntOrange,
    accentTerracotta: AppColorsWarm.accentTerracotta,
    accentEspresso: AppColorsWarm.accentEspresso,
    accentCocoa: AppColorsWarm.accentCocoa,
    accentForest: AppColorsWarm.accentForest,
    accentSlate: AppColorsWarm.accentSlate,
  );

  static AppPalette byKey(AppPaletteKey key) {
    return switch (key) {
      AppPaletteKey.cool => cool,
      AppPaletteKey.warm => warm,
    };
  }

  static AppPalette of(BuildContext context) {
    return Theme.of(context).extension<AppPalette>() ?? cool;
  }
}
