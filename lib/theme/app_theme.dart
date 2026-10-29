import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemeData {
  final String name;
  final Brightness brightness;
  final Color bgPrimary;
  final Color bgCard;
  final Color bgCardLight;
  final Color focusColor;
  final Color shortBreakColor;
  final Color longBreakColor;
  final Color accentColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color cardBorder;
  final Color shadowColor;
  final Color flipCardBg;
  final Color flipCardSeam;
  final Color flipDigitColor;
  final String scenicType;
  final LinearGradient bgGradient;

  const AppThemeData({
    required this.name,
    required this.brightness,
    required this.bgPrimary,
    required this.bgCard,
    required this.bgCardLight,
    required this.focusColor,
    required this.shortBreakColor,
    required this.longBreakColor,
    required this.accentColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.cardBorder,
    required this.shadowColor,
    required this.flipCardBg,
    required this.flipCardSeam,
    required this.flipDigitColor,
    required this.scenicType,
    required this.bgGradient,
  });

  Color getModeColor(String mode) {
    switch (mode) {
      case 'shortBreak':
        return shortBreakColor;
      case 'longBreak':
        return longBreakColor;
      case 'focus':
      default:
        return focusColor;
    }
  }

  ThemeData toThemeData() {
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: Colors.transparent,
      primaryColor: focusColor,
      cardColor: bgCard,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: focusColor,
        onPrimary: brightness == Brightness.dark ? Colors.black : Colors.white,
        secondary: accentColor,
        onSecondary: Colors.white,
        error: Colors.redAccent,
        onError: Colors.white,
        surface: bgCard,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class AppThemes {
  static const List<AppThemeData> themes = [
    // 0: Classic Obsidian Flip Clock (Play Store Center Top)
    AppThemeData(
      name: 'Classic Obsidian',
      brightness: Brightness.dark,
      bgPrimary: Color(0xFF14161B),
      bgCard: Color(0xFF1F222A),
      bgCardLight: Color(0xFF2A2D37),
      focusColor: Color(0xFFDFE4EC),
      shortBreakColor: Color(0xFF4ADE80),
      longBreakColor: Color(0xFFFBBF24),
      accentColor: Color(0xFF94A3B8),
      textPrimary: Color(0xFFF1F5F9),
      textSecondary: Color(0xFF94A3B8),
      cardBorder: Color(0xFF2E323E),
      shadowColor: Color(0x44000000),
      flipCardBg: Color(0xFF242730),
      flipCardSeam: Color(0xFF131418),
      flipDigitColor: Color(0xFFE2E6ED),
      scenicType: 'minimal_dark',
      bgGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF17181E), Color(0xFF1E2128), Color(0xFF131418)],
      ),
    ),

    // 1: Crimson Forest (Play Store Top Right)
    AppThemeData(
      name: 'Crimson Forest',
      brightness: Brightness.dark,
      bgPrimary: Color(0xFF1C0D13),
      bgCard: Color(0xFF26141B),
      bgCardLight: Color(0xFF351C26),
      focusColor: Color(0xFFFF4848),
      shortBreakColor: Color(0xFF2DD4BF),
      longBreakColor: Color(0xFFA78BFA),
      accentColor: Color(0xFFFF6B6B),
      textPrimary: Color(0xFFFFF0F3),
      textSecondary: Color(0xFFE2A8B6),
      cardBorder: Color(0xFF3F212D),
      shadowColor: Color(0x55FF4848),
      flipCardBg: Color(0xFF2B1820),
      flipCardSeam: Color(0xFF150A0E),
      flipDigitColor: Color(0xFFFF4848),
      scenicType: 'crimson_forest',
      bgGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF240E17), Color(0xFF381523), Color(0xFF190910)],
      ),
    ),

    // 2: Ocean Teal Pines (Play Store Bottom Left)
    AppThemeData(
      name: 'Ocean Teal',
      brightness: Brightness.dark,
      bgPrimary: Color(0xFF0C2026),
      bgCard: Color(0xFF15333C),
      bgCardLight: Color(0xFF1F4450),
      focusColor: Color(0xFF7FE6DA),
      shortBreakColor: Color(0xFF38BDF8),
      longBreakColor: Color(0xFFFBBF24),
      accentColor: Color(0xFF5EEAD4),
      textPrimary: Color(0xFFE6FAF8),
      textSecondary: Color(0xFF86BCB5),
      cardBorder: Color(0xFF224854),
      shadowColor: Color(0x447FE6DA),
      flipCardBg: Color(0xFF193A42),
      flipCardSeam: Color(0xFF0C1F24),
      flipDigitColor: Color(0xFF7FE6DA),
      scenicType: 'ocean_teal',
      bgGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0B1F25), Color(0xFF173D47), Color(0xFF0A181D)],
      ),
    ),

    // 3: Winter Moon (Play Store Bottom Center)
    AppThemeData(
      name: 'Winter Moon',
      brightness: Brightness.dark,
      bgPrimary: Color(0xFF111722),
      bgCard: Color(0xFF1C2434),
      bgCardLight: Color(0xFF263146),
      focusColor: Color(0xFFF4F7FC),
      shortBreakColor: Color(0xFF67E8F9),
      longBreakColor: Color(0xFFFCD34D),
      accentColor: Color(0xFF93C5FD),
      textPrimary: Color(0xFFF8FAFC),
      textSecondary: Color(0xFF94A3B8),
      cardBorder: Color(0xFF2D3B52),
      shadowColor: Color(0x44FFFFFF),
      flipCardBg: Color(0xFF232C3A),
      flipCardSeam: Color(0xFF121720),
      flipDigitColor: Color(0xFFF4F7FC),
      scenicType: 'winter_moon',
      bgGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF121926), Color(0xFF1E293B), Color(0xFF101520)],
      ),
    ),

    // 4: Midnight Blue (Play Store Top Left)
    AppThemeData(
      name: 'Midnight Navy',
      brightness: Brightness.dark,
      bgPrimary: Color(0xFF141828),
      bgCard: Color(0xFF1F263E),
      bgCardLight: Color(0xFF2A3454),
      focusColor: Color(0xFF818CF8),
      shortBreakColor: Color(0xFF34D399),
      longBreakColor: Color(0xFFF59E0B),
      accentColor: Color(0xFFA5B4FC),
      textPrimary: Color(0xFFF1F5F9),
      textSecondary: Color(0xFF94A3B8),
      cardBorder: Color(0xFF2E395D),
      shadowColor: Color(0x44818CF8),
      flipCardBg: Color(0xFF28324E),
      flipCardSeam: Color(0xFF161C2C),
      flipDigitColor: Color(0xFFF0F4FA),
      scenicType: 'midnight_city',
      bgGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF131726), Color(0xFF20273F), Color(0xFF121524)],
      ),
    ),

    // 5: Sunset Peach (Play Store Bottom Right)
    AppThemeData(
      name: 'Sunset Peach',
      brightness: Brightness.light,
      bgPrimary: Color(0xFFFF8573),
      bgCard: Color(0xFF144044),
      bgCardLight: Color(0xFF1C5257),
      focusColor: Color(0xFF144044),
      shortBreakColor: Color(0xFF0F766E),
      longBreakColor: Color(0xFFB45309),
      accentColor: Color(0xFFFFFFFF),
      textPrimary: Color(0xFF1D2939),
      textSecondary: Color(0xFF475467),
      cardBorder: Color(0xFFFFAFA2),
      shadowColor: Color(0x22000000),
      flipCardBg: Color(0xFF144044),
      flipCardSeam: Color(0xFF0B2527),
      flipDigitColor: Color(0xFFFFFFFF),
      scenicType: 'sunset_peach',
      bgGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFF7E6B), Color(0xFFFFA085), Color(0xFFFF8975)],
      ),
    ),
  ];

  static AppThemeData getTheme(int index) {
    if (index >= 0 && index < themes.length) {
      return themes[index];
    }
    return themes[0];
  }
}

class AppFonts {
  static TextStyle flipNumber({
    double? fontSize,
    Color? color,
    double? letterSpacing,
    List<Shadow>? shadows,
  }) {
    return GoogleFonts.bebasNeue(
      fontSize: fontSize,
      color: color,
      letterSpacing: letterSpacing ?? 1.5,
      shadows: shadows,
    );
  }

  static TextStyle mono({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    List<Shadow>? shadows,
  }) {
    return GoogleFonts.robotoMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      shadows: shadows,
    );
  }

  static TextStyle sans({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }
}
