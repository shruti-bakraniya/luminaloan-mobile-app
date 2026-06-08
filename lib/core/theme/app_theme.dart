import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData dark() => _buildTheme(Brightness.dark);
  static ThemeData light() => _buildTheme(Brightness.light);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData(brightness: brightness).textTheme,
    );
    return ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.steelBlue,
        brightness: brightness,
      ),
      textTheme: textTheme,
      useMaterial3: true,
      scaffoldBackgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBarTheme: AppBarTheme(
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
    );
  }
}

class LuminaTokens {
  final bool isDark;
  const LuminaTokens({required this.isDark});

  Color get text => isDark ? AppColors.darkText : AppColors.lightText;
  Color get subtext => isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
  Color get faint => isDark ? AppColors.darkFaint : AppColors.lightFaint;
  Color get glass => isDark ? AppColors.darkGlass : AppColors.lightGlass;
  Color get glassStrong => isDark ? AppColors.darkGlassStrong : AppColors.lightGlassStrong;
  Color get glassBorder => isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder;
  Color get glassHi => isDark ? AppColors.darkGlassHi : AppColors.lightGlassHi;
  Color get track => isDark ? AppColors.darkTrack : AppColors.lightTrack;
  Color get field => isDark ? AppColors.darkField : AppColors.lightField;
  Color get fieldBorder => isDark ? AppColors.darkFieldBorder : AppColors.lightFieldBorder;
  Color get principal => isDark ? AppColors.darkPrincipal : AppColors.lightPrincipal;
  Color get interest => isDark ? AppColors.darkInterest : AppColors.lightInterest;
  Color get grid => isDark ? AppColors.darkGrid : AppColors.lightGrid;
  Color get axis => isDark ? AppColors.darkAxis : AppColors.lightAxis;
  Color get error => isDark ? AppColors.darkError : AppColors.lightError;
  Color get errorBg => isDark ? AppColors.darkErrorBg : AppColors.lightErrorBg;
  Color get errorBorder => isDark ? AppColors.darkErrorBorder : AppColors.lightErrorBorder;
  Color get success => isDark ? AppColors.darkSuccess : AppColors.lightSuccess;
  Color get onAccent => Colors.white;

  List<Color> get accentGrad => [AppColors.steelBlueMid, AppColors.navyDark];
  List<Color> get bgGrad => isDark
      ? [const Color(0xFF0E1827), const Color(0xFF070B13)]
      : [const Color(0xFFF2F5FB), const Color(0xFFE8EDF5)];

  Color get tooltipBg => isDark
      ? const Color(0xD9121D32)
      : const Color(0xEBFFFFFF);

  BoxDecoration get glassBg => BoxDecoration(
        color: glass,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: glassBorder),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.42) : AppColors.deepNavy.withOpacity(0.16),
            blurRadius: isDark ? 30 : 34,
            offset: const Offset(0, 8),
          ),
        ],
      );

  BoxDecoration get glassStrongBg => BoxDecoration(
        color: glassStrong,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: glassBorder),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.42) : AppColors.deepNavy.withOpacity(0.16),
            blurRadius: isDark ? 30 : 34,
            offset: const Offset(0, 8),
          ),
        ],
      );

  LinearGradient get accentGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.steelBlueMid, AppColors.navyDark],
      );
}
