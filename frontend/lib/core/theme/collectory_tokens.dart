import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'collectory_theme.dart';

/// collectory-ui-handoff.md + design-export/design_tokens.json
abstract final class CollectorySpacing {
  static const double unit = 8;
  static const double screenHorizontal = 28;
  static const double sectionGap = 24;
  static const double sectionGapLarge = 32;
  static const double cardPadding = 16;
  static const double cardPaddingLarge = 18;
  static const double labelToTitleGap = 8;
  static const double titleToBodyGap = 12;
  static const double bottomNavHeight = 50;

  static const EdgeInsets screen = EdgeInsets.symmetric(
    horizontal: screenHorizontal,
  );

  static EdgeInsets screenVertical({double top = 0, double bottom = 0}) =>
      EdgeInsets.fromLTRB(screenHorizontal, top, screenHorizontal, bottom);
}

abstract final class CollectoryRadius {
  static const double card = 8;
  static const double pill = 20;
  static const double frame = 28;
  static const double image = 6;

  static BorderRadius get cardBorder => BorderRadius.circular(card);
  static BorderRadius get pillBorder => BorderRadius.circular(pill);
}

abstract final class CollectoryShadows {
  /// handoff §6 — 0 10px 24px rgba(23,18,15,0.10)
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x1A17120F),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];

  /// handoff §6 — elevated object
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x2E17120F),
      blurRadius: 24,
      offset: Offset(0, 14),
    ),
    BoxShadow(
      color: Color(0x1A17120F),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
}

abstract final class CollectoryNavTokens {
  static const List<String> labels = ['Home', 'Gallery', 'Add', 'Profile'];
  static const double activeIndicatorWidth = 28;
  static const double activeIndicatorHeight = 3;
  static const Color activeIndicatorColor = CollectoryColors.textLabel;
}

/// Inter 字阶 — handoff §3 + design_tokens.json
abstract final class CollectoryTypography {
  static TextStyle _inter({
    required double size,
    required FontWeight weight,
    required double height,
    required Color color,
    double letterSpacing = 0,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );

  /// Page title: 36–44px Bold → token 40
  static TextStyle get pageTitle => _inter(
        size: 40,
        weight: FontWeight.w700,
        height: 1.15,
        color: CollectoryColors.textPrimary,
      );

  /// Section title: 22–26px Bold → token 24
  static TextStyle get sectionTitle => _inter(
        size: 24,
        weight: FontWeight.w700,
        height: 1.2,
        color: CollectoryColors.textPrimary,
      );

  /// Card title: 18–22px Semi Bold → token 20
  static TextStyle get cardTitle => _inter(
        size: 20,
        weight: FontWeight.w600,
        height: 1.25,
        color: CollectoryColors.textPrimary,
      );

  /// Body: 14–16px Regular → token 15
  static TextStyle get body => _inter(
        size: 15,
        weight: FontWeight.w400,
        height: 1.5,
        color: CollectoryColors.textPrimary,
      );

  /// Secondary body — handoff 14px 档
  static TextStyle get bodySecondary => _inter(
        size: 14,
        weight: FontWeight.w400,
        height: 1.5,
        color: CollectoryColors.textSecondary,
      );

  /// Metadata label: 10–12px Medium uppercase → token 11
  static TextStyle get metaLabel => _inter(
        size: 11,
        weight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.6,
        color: CollectoryColors.textLabel,
      );

  /// Bottom nav: 12px — handoff §10
  static TextStyle bottomNav({required bool active}) => _inter(
        size: 12,
        weight: active ? FontWeight.w600 : FontWeight.w400,
        height: 1.2,
        color: active
            ? CollectoryColors.textPrimary
            : CollectoryColors.textSecondary,
      );

  static TextStyle get brandMark => _inter(
        size: 13,
        weight: FontWeight.w700,
        height: 1.2,
        letterSpacing: 0.4,
        color: CollectoryColors.textPrimary,
      );

  static TextStyle get navContext => _inter(
        size: 13,
        weight: FontWeight.w400,
        height: 1.2,
        color: CollectoryColors.textSecondary,
      );

  static TextStyle get backLabel => _inter(
        size: 15,
        weight: FontWeight.w600,
        height: 1.2,
        color: CollectoryColors.textPrimary,
      );

  /// handoff §7 主按钮
  static ButtonStyle get primaryButton => FilledButton.styleFrom(
        backgroundColor: CollectoryColors.btnPrimaryBg,
        foregroundColor: CollectoryColors.btnPrimaryText,
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: CollectoryRadius.pillBorder,
        ),
        textStyle: _inter(
          size: 14,
          weight: FontWeight.w600,
          height: 1.2,
          color: CollectoryColors.btnPrimaryText,
        ),
      );

  /// handoff §8 标签 pill
  static ButtonStyle tagPill({required bool active}) {
    return TextButton.styleFrom(
      minimumSize: const Size(0, 28),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      backgroundColor: active ? CollectoryColors.btnPrimaryBg : Colors.transparent,
      foregroundColor:
          active ? CollectoryColors.btnPrimaryText : CollectoryColors.textPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: CollectoryRadius.pillBorder,
        side: active
            ? BorderSide.none
            : const BorderSide(color: CollectoryColors.borderLight),
      ),
      textStyle: _inter(
        size: 13,
        weight: FontWeight.w500,
        height: 1.2,
        color: active
            ? CollectoryColors.btnPrimaryText
            : CollectoryColors.textPrimary,
      ),
    );
  }
}
