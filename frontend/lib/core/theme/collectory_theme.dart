import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../motion/collectory_motion.dart';
import 'collectory_tokens.dart';

/// 与 design-export/design_tokens.json、collectory-ui-handoff.md 一致（编译期常量）
class CollectoryColors {
  static const Color bgApp = Color(0xFFF7F1E7);
  static const Color bgSecondary = Color(0xFFEDE2D2);
  static const Color bgCard = Color(0xFFF4EBDD);
  static const Color textPrimary = Color(0xFF171512);
  static const Color textSecondary = Color(0xFF7C7469);
  static const Color textLabel = Color(0xFFA8643A);
  static const Color borderLight = Color(0xFFD4C8B8);
  static const Color borderDark = Color(0xFFB8A996);
  static const Color btnPrimaryBg = Color(0xFF171512);
  static const Color btnPrimaryText = Color(0xFFFFF8EE);
  static const Color catVinyl = Color(0xFFC7A679);
  static const Color catVinylBlack = Color(0xFF17120F);
  static const Color catTicket = Color(0xFFC98250);
  static const Color catMemory = Color(0xFFC9D9D5);
  static const Color catMineral = Color(0xFF55746A);
  static const Color catLavender = Color(0xFFD8D1E8);
  static const Color room01 = Color(0xFFE8D7BD);
  static const Color room02 = Color(0xFFD5E0DC);
  static const Color room03 = Color(0xFFDCD5EA);

  static const double screenPadding = CollectorySpacing.screenHorizontal;
  static const double bottomNavHeight = CollectorySpacing.bottomNavHeight;

  /// 启动时校验 design-export token 资源可读（数值以本文件常量为准，供 const 组件使用）
  static Future<void> loadFromDesignExport() async {
    try {
      final raw = await rootBundle.loadString(
        'assets/design_tokens.json',
      );
      jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      // 使用上方默认常量（与 handoff 相同）
    }
  }
}

Color categoryAccent(String? slug) {
  switch (slug) {
    case 'mineral':
      return CollectoryColors.catMineral;
    case 'crystal':
      return CollectoryColors.catLavender;
    case 'vinyl':
      return CollectoryColors.catVinyl;
    case 'ticket':
      return CollectoryColors.catTicket;
    case 'postcard':
    case 'souvenir':
    case 'stamp':
      return CollectoryColors.catMemory;
    default:
      return CollectoryColors.borderLight;
  }
}

ThemeData buildCollectoryTheme() {
  final base = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: CollectoryColors.bgApp,
  );
  const fadeBuilder = CollectoryPageTransitionsBuilder();
  return base.copyWith(
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: fadeBuilder,
        TargetPlatform.iOS: fadeBuilder,
        TargetPlatform.macOS: fadeBuilder,
        TargetPlatform.windows: fadeBuilder,
        TargetPlatform.linux: fadeBuilder,
        TargetPlatform.fuchsia: fadeBuilder,
      },
    ),
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: CollectoryColors.textPrimary,
      displayColor: CollectoryColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: CollectoryColors.bgApp,
      foregroundColor: CollectoryColors.textPrimary,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: CollectoryColors.bgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: CollectoryRadius.cardBorder,
        side: const BorderSide(color: CollectoryColors.borderLight),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: CollectoryTypography.primaryButton,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: CollectoryColors.textSecondary,
        backgroundColor: CollectoryColors.bgApp,
        side: const BorderSide(color: CollectoryColors.borderLight),
        shape: RoundedRectangleBorder(
          borderRadius: CollectoryRadius.pillBorder,
        ),
      ),
    ),
  );
}
