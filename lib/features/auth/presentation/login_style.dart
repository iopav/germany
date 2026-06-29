import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';

class LoginStyle {
  static const Color background = Color(0xFFFAF8FF);
  static const Color primary = Color(0xFF004AC6);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF712AE2);
  static const Color tertiaryContainer = Color(0xFFBC4800);

  static const Color onSurface = Color(0xFF131B2E);
  static const Color onSurfaceVariant = Color(0xFF434655);
  static const Color outline = Color(0xFF737686);
  static const Color outlineVariant = Color(0xFFC3C6D7);
  static const Color surfaceContainerLow = Color(0xFFF2F3FF);

  static const Color error = Color(0xFFC62828);
  static const Color boxShadow = Color(0xFF000000);
  static const Color panelColor = Color(0xFFFFFFFF);
  static const Color panelBorder = Color(0xFFFFFFFF);

  static final BorderRadius panelRadius = BorderRadius.circular(24);
  static final BorderRadius logoRadius = BorderRadius.circular(16);
  static final BorderRadius inputRadius = BorderRadius.circular(12);
  static final BorderRadius checkboxRadius = BorderRadius.circular(4);
  static final BorderRadius pillRadius = BorderRadius.circular(999);

  static const EdgeInsets scrollPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 40,
  );
  static const EdgeInsets panelPadding = EdgeInsets.all(32);
  static const EdgeInsets inputContentPadding = EdgeInsets.symmetric(
    vertical: 16,
  );
  static const EdgeInsets inputLabelPadding = EdgeInsets.only(left: 4);

  static const BoxConstraints panelConstraints = BoxConstraints(maxWidth: 400);

  static const TextStyle appNameTextStyle = TextStyle(
    fontFamily: 'Space Grotesk',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: primary,
    letterSpacing: -0.5,
  );

  static const TextStyle titleTextStyle = TextStyle(
    fontFamily: 'Space Grotesk',
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: onSurface,
  );

  static const TextStyle inputLabelTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: onSurfaceVariant,
  );

  static const TextStyle inputTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    color: onSurface,
  );

  static final TextStyle inputHintTextStyle = TextStyle(
    color: outlineVariant.withValues(alpha: 0.8),
  );

  static const TextStyle rememberTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    color: onSurfaceVariant,
  );

  static const TextStyle forgotPasswordTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: primary,
  );

  static const TextStyle loginButtonTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle registerPromptTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    color: onSurfaceVariant,
  );

  static const TextStyle registerLinkTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: primary,
  );

  static BoxDecoration logoDecoration = BoxDecoration(
    color: primary,
    borderRadius: logoRadius,
    boxShadow: [
      BoxShadow(
        color: primary.withValues(alpha: 0.3),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static AppPalette colors(BuildContext context) => AppPalettes.of(context);

  static Color backgroundColor(BuildContext context) => colors(context).surface;

  static Color errorColor(BuildContext context) => colors(context).error;

  static TextStyle appNameTextStyleFor(BuildContext context) =>
      appNameTextStyle.copyWith(color: colors(context).primary);

  static TextStyle titleTextStyleFor(BuildContext context) =>
      titleTextStyle.copyWith(color: colors(context).onSurface);

  static TextStyle inputLabelTextStyleFor(BuildContext context) =>
      inputLabelTextStyle.copyWith(color: colors(context).onSurfaceVariant);

  static TextStyle inputTextStyleFor(BuildContext context) =>
      inputTextStyle.copyWith(color: colors(context).onSurface);

  static TextStyle inputHintTextStyleFor(BuildContext context) =>
      TextStyle(color: colors(context).outlineVariant.withValues(alpha: 0.82));

  static TextStyle rememberTextStyleFor(BuildContext context) =>
      rememberTextStyle.copyWith(color: colors(context).onSurfaceVariant);

  static TextStyle forgotPasswordTextStyleFor(BuildContext context) =>
      forgotPasswordTextStyle.copyWith(color: colors(context).primary);

  static TextStyle registerPromptTextStyleFor(BuildContext context) =>
      registerPromptTextStyle.copyWith(color: colors(context).onSurfaceVariant);

  static TextStyle registerLinkTextStyleFor(BuildContext context) =>
      registerLinkTextStyle.copyWith(color: colors(context).primary);

  static BoxDecoration logoDecorationFor(BuildContext context) {
    final palette = colors(context);
    return BoxDecoration(
      color: palette.primary,
      borderRadius: logoRadius,
      boxShadow: [
        BoxShadow(
          color: palette.primary.withValues(alpha: 0.28),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration panelDecorationFor(BuildContext context) {
    final palette = colors(context);
    return BoxDecoration(
      color: palette.surfaceContainerLow.withValues(alpha: 0.76),
      border: Border.all(color: palette.outlineVariant.withValues(alpha: 0.38)),
      borderRadius: panelRadius,
    );
  }

  static BoxDecoration panelShadowDecoration = BoxDecoration(
    borderRadius: panelRadius,
    boxShadow: [
      BoxShadow(
        color: boxShadow.withValues(alpha: 0.05),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration panelDecoration = BoxDecoration(
    color: panelColor.withValues(alpha: 0.7),
    border: Border.all(color: panelBorder.withValues(alpha: 0.4)),
    borderRadius: panelRadius,
  );

  static ButtonStyle forgotPasswordButtonStyle = TextButton.styleFrom(
    padding: EdgeInsets.zero,
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  static ButtonStyle loginButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: onPrimary,
    elevation: 8,
    shadowColor: primary.withValues(alpha: 0.5),
    shape: RoundedRectangleBorder(borderRadius: pillRadius),
  );

  static ButtonStyle loginButtonStyleFor(BuildContext context) {
    final palette = colors(context);
    return ElevatedButton.styleFrom(
      backgroundColor: palette.primary,
      foregroundColor: palette.onPrimary,
      elevation: 8,
      shadowColor: palette.primary.withValues(alpha: 0.42),
      shape: RoundedRectangleBorder(borderRadius: pillRadius),
    );
  }

  static InputDecoration inputDecoration({
    required IconData icon,
    required String hintText,
    required Widget? suffixIcon,
  }) {
    final border = OutlineInputBorder(
      borderRadius: inputRadius,
      borderSide: BorderSide(color: outlineVariant.withValues(alpha: 0.5)),
    );

    return InputDecoration(
      hintText: hintText,
      hintStyle: inputHintTextStyle,
      filled: true,
      fillColor: surfaceContainerLow,
      contentPadding: inputContentPadding,
      prefixIcon: Icon(icon, color: outline),
      suffixIcon: suffixIcon,
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: const BorderSide(color: primary, width: 2),
      ),
    );
  }

  static InputDecoration inputDecorationFor(
    BuildContext context, {
    required IconData icon,
    required String hintText,
    required Widget? suffixIcon,
  }) {
    final palette = colors(context);
    final border = OutlineInputBorder(
      borderRadius: inputRadius,
      borderSide: BorderSide(
        color: palette.outlineVariant.withValues(alpha: 0.55),
      ),
    );

    return InputDecoration(
      hintText: hintText,
      hintStyle: inputHintTextStyleFor(context),
      filled: true,
      fillColor: palette.surfaceContainerLow,
      contentPadding: inputContentPadding,
      prefixIcon: Icon(icon, color: palette.outline),
      suffixIcon: suffixIcon,
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: BorderSide(color: palette.primary, width: 2),
      ),
    );
  }
}

class LoginInputLabel extends StatelessWidget {
  final String text;

  const LoginInputLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: LoginStyle.inputLabelPadding,
      child: Text(text, style: LoginStyle.inputLabelTextStyleFor(context)),
    );
  }
}

class LoginBlurBlob extends StatelessWidget {
  final Color color;

  const LoginBlurBlob({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 20)],
      ),
    );
  }
}
