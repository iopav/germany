import 'dart:ui';

import 'package:flutter/material.dart';

class ImmersiveStyle {
  static const Color black = Colors.black;
  static const Color black12 = Colors.black12;
  static const Color white = Colors.white;
  static const Color white10 = Colors.white10;
  static const Color white24 = Colors.white24;
  static const Color white70 = Colors.white70;
  static const Color amberAccent = Colors.amberAccent;

  static final Color scrim = Colors.black.withValues(alpha: 0.15);
  static final Color warningBackground = Colors.amber.withValues(alpha: 0.16);
  static final Color warningBorder = Colors.amber.withValues(alpha: 0.4);
  static final Color articleTagBackground = Colors.blue.withValues(alpha: 0.3);
  static final Color articleTagText = Colors.blue.shade200;
  static final Color infoPanelBackground = Colors.white.withValues(alpha: 0.05);
  static final Color infoPanelBorder = Colors.white.withValues(alpha: 0.1);
  static final Color errorPanelBackground = Colors.red.withValues(alpha: 0.08);
  static final Color errorPanelBorder = Colors.red.withValues(alpha: 0.2);
  static final Color activeCardBackground = Colors.white.withValues(
    alpha: 0.25,
  );
  static final Color inactiveCardBackground = Colors.white.withValues(
    alpha: 0.1,
  );

  static final BorderRadius summaryRadius = BorderRadius.circular(24);
  static final BorderRadius glassPillRadius = BorderRadius.circular(30);
  static final BorderRadius detailPanelRadius = BorderRadius.circular(20);
  static final BorderRadius infoPanelRadius = BorderRadius.circular(12);
  static final BorderRadius tagRadius = BorderRadius.circular(20);
  static final BorderRadius cardRadius = BorderRadius.circular(16);
  static final BorderRadius miniBadgeRadius = BorderRadius.circular(4);
  static const BorderRadius bottomSheetRadius = BorderRadius.vertical(
    top: Radius.circular(24),
  );
  static const BorderRadius cardImageRadius = BorderRadius.vertical(
    top: Radius.circular(16),
  );

  static const EdgeInsets sceneSummaryPadding = EdgeInsets.only(top: 10);
  static const EdgeInsets warningPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 6,
  );
  static const EdgeInsets summaryPanelPadding = EdgeInsets.all(16);
  static const EdgeInsets detailPanelPadding = EdgeInsets.all(20);
  static const EdgeInsets bottomSheetPadding = EdgeInsets.symmetric(
    vertical: 12,
  );
  static const EdgeInsets bottomListPadding = EdgeInsets.symmetric(
    horizontal: 24,
  );
  static const EdgeInsets detailSlidePadding = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 16.0,
  );
  static const EdgeInsets pillPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,
  );
  static const EdgeInsets sectionPanelPadding = EdgeInsets.all(16);
  static const EdgeInsets tagPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 4,
  );
  static const EdgeInsets miniBadgePadding = EdgeInsets.symmetric(
    horizontal: 4,
    vertical: 2,
  );
  static const EdgeInsets cardTextPadding = EdgeInsets.fromLTRB(8, 6, 8, 6);

  static const TextStyle sceneSummaryTextStyle = TextStyle(
    color: white,
    fontSize: 16,
    height: 1.4,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle warningTextStyle = TextStyle(
    color: amberAccent,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle summaryTitleTextStyle = TextStyle(
    color: white,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  static const TextStyle modePillTextStyle = TextStyle(
    color: white,
    fontSize: 10,
    letterSpacing: 1.5,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle detailWordTextStyle = TextStyle(
    color: white,
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle detailIpaTextStyle = TextStyle(
    color: Colors.white.withValues(alpha: 0.75),
    fontSize: 14,
    fontStyle: FontStyle.italic,
  );

  static final TextStyle detailTranslationTextStyle = TextStyle(
    color: Colors.white.withValues(alpha: 0.7),
    fontSize: 16,
    fontStyle: FontStyle.italic,
  );

  static const TextStyle sectionTitleTextStyle = TextStyle(
    color: white,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle sectionBodyTextStyle = TextStyle(
    color: Colors.white.withValues(alpha: 0.78),
    fontSize: 13,
    height: 1.4,
  );

  static const TextStyle sentenceDeTextStyle = TextStyle(
    color: white,
    fontSize: 16,
    height: 1.5,
  );

  static final TextStyle sentenceEnTextStyle = TextStyle(
    color: Colors.white.withValues(alpha: 0.5),
    fontSize: 14,
  );

  static const TextStyle tagTextStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  static const TextStyle miniBadgeTextStyle = TextStyle(
    color: white,
    fontSize: 8,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle miniBadgeSoftTextStyle = TextStyle(
    color: Colors.white.withValues(alpha: 0.9),
    fontSize: 8,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle cardTitleTextStyle = TextStyle(
    color: white,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle cardSubtitleTextStyle = TextStyle(
    color: Colors.white.withValues(alpha: 0.5),
    fontSize: 9,
  );

  static const TextStyle discoveryChipTextStyle = TextStyle(
    color: white,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle glassButtonTextStyle = TextStyle(
    color: white,
    fontWeight: FontWeight.w500,
  );

  static BoxDecoration warningDecoration = BoxDecoration(
    color: warningBackground,
    borderRadius: BorderRadius.circular(999),
    border: Border.all(color: warningBorder),
  );

  static BoxDecoration infoPanelDecoration = BoxDecoration(
    color: infoPanelBackground,
    borderRadius: infoPanelRadius,
    border: Border.all(color: infoPanelBorder),
  );

  static BoxDecoration errorPanelDecoration = BoxDecoration(
    color: errorPanelBackground,
    borderRadius: infoPanelRadius,
    border: Border.all(color: errorPanelBorder),
  );
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double borderOpacity;
  final Color bgColor;
  final BorderRadius borderRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 12.0,
    this.borderOpacity = 0.2,
    this.bgColor = const Color(0x1AFFFFFF),
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: borderRadius,
            border: Border.all(
              color: Colors.white.withValues(alpha: borderOpacity),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
