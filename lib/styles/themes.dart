import 'package:flutter/material.dart';

import 'colors.dart';
import 'sizes.dart';
import 'styles.dart';

ThemeData get lightTheme {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: AppStyles.fontFamily,
    scaffoldBackgroundColor: AppColors.lightScaffold,
    colorScheme: const ColorScheme.light(
      primary: AppColors.navyPrimaryLight,
      secondary: AppColors.tealHighlightLight,
      surface: AppColors.lightSurface,
      error: AppColors.redDelete,
      onPrimary: Colors.white,
      onSurface: AppColors.lightTextPrimary,
    ),
    textTheme: TextTheme(
      displayLarge: AppStyles.getTextStyle(color: AppColors.lightTextPrimary, fontSize: 36, fontWeight: FontWeight.bold),
      displayMedium: AppStyles.getTextStyle(color: AppColors.lightTextPrimary, fontSize: 28, fontWeight: FontWeight.bold),
      displaySmall: AppStyles.getTextStyle(color: AppColors.lightTextPrimary, fontSize: 24, fontWeight: FontWeight.bold),
      headlineMedium: AppStyles.getTextStyle(color: AppColors.lightTextPrimary, fontSize: 20, fontWeight: FontWeight.w600),
      titleLarge: AppStyles.getTextStyle(color: AppColors.lightTextPrimary, fontSize: 18, fontWeight: FontWeight.w600),
      titleMedium: AppStyles.getTextStyle(color: AppColors.lightTextPrimary, fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: AppStyles.getTextStyle(color: AppColors.lightTextPrimary, fontSize: 16, fontWeight: FontWeight.normal),
      bodyMedium: AppStyles.getTextStyle(color: AppColors.lightTextSecondary, fontSize: 14, fontWeight: FontWeight.normal),
      bodySmall: AppStyles.getTextStyle(color: AppColors.lightTextSecondary, fontSize: 12, fontWeight: FontWeight.normal),
      labelLarge: AppStyles.getTextStyle(color: AppColors.lightTextPrimary, fontSize: 14, fontWeight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppSizes.brLarge),
      margin: AppSizes.paddingZero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.navyPrimaryLight,
        foregroundColor: Colors.white,
        shape: AppStyles.buttonShape,
        elevation: 0,
        padding: AppSizes.paddingAll16,
        textStyle: AppStyles.getTextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.navyPrimaryLight,
      inactiveTrackColor: AppColors.lightTrackInactive,
      thumbColor: Colors.white,
      overlayColor: AppColors.navyPrimaryLight.withValues(alpha: 0.1),
      trackHeight: 6.0,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) => Colors.white),
      trackColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected) ? AppColors.navyPrimaryLight : AppColors.lightTrackInactive
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
      titleTextStyle: AppStyles.getTextStyle(color: AppColors.lightTextPrimary, fontSize: 20, fontWeight: FontWeight.w600),
    ),
  );
}

ThemeData get darkTheme {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: AppStyles.fontFamily,
    scaffoldBackgroundColor: AppColors.darkScaffold,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.navyPrimaryDark,
      secondary: AppColors.tealHighlightDark,
      surface: AppColors.darkSurface,
      error: AppColors.redDelete,
      onPrimary: Colors.white,
      onSurface: AppColors.darkTextPrimary,
    ),
    textTheme: TextTheme(
      displayLarge: AppStyles.getTextStyle(color: AppColors.darkTextPrimary, fontSize: 36, fontWeight: FontWeight.bold),
      displayMedium: AppStyles.getTextStyle(color: AppColors.darkTextPrimary, fontSize: 28, fontWeight: FontWeight.bold),
      displaySmall: AppStyles.getTextStyle(color: AppColors.darkTextPrimary, fontSize: 24, fontWeight: FontWeight.bold),
      headlineMedium: AppStyles.getTextStyle(color: AppColors.darkTextPrimary, fontSize: 20, fontWeight: FontWeight.w600),
      titleLarge: AppStyles.getTextStyle(color: AppColors.darkTextPrimary, fontSize: 18, fontWeight: FontWeight.w600),
      titleMedium: AppStyles.getTextStyle(color: AppColors.darkTextPrimary, fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: AppStyles.getTextStyle(color: AppColors.darkTextPrimary, fontSize: 16, fontWeight: FontWeight.normal),
      bodyMedium: AppStyles.getTextStyle(color: AppColors.darkTextSecondary, fontSize: 14, fontWeight: FontWeight.normal),
      bodySmall: AppStyles.getTextStyle(color: AppColors.darkTextSecondary, fontSize: 12, fontWeight: FontWeight.normal),
      labelLarge: AppStyles.getTextStyle(color: AppColors.darkTextPrimary, fontSize: 14, fontWeight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppSizes.brLarge),
      margin: AppSizes.paddingZero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.navyPrimaryDark,
        foregroundColor: Colors.white,
        shape: AppStyles.buttonShape,
        elevation: 0,
        padding: AppSizes.paddingAll16,
        textStyle: AppStyles.getTextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.navyPrimaryDark,
      inactiveTrackColor: AppColors.darkTrackInactive,
      thumbColor: Colors.white,
      overlayColor: AppColors.navyPrimaryDark.withValues(alpha: 0.1),
      trackHeight: 6.0,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) => Colors.white),
      trackColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected) ? AppColors.navyPrimaryDark : AppColors.darkTrackInactive
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      titleTextStyle: AppStyles.getTextStyle(color: AppColors.darkTextPrimary, fontSize: 20, fontWeight: FontWeight.w600),
    ),
  );
}
