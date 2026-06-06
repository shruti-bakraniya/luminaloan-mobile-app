import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';
import 'sizes.dart';

class AppStyles {
  // Use a modern geometric sans-serif font
  static const String fontFamily = 'PlusJakartaSans'; // Ensure you have this in pubspec.yaml

  // Text Styles Generator for easy reuse
  static TextStyle getTextStyle({
    required Color color,
    double fontSize = 14.0,
    FontWeight fontWeight = FontWeight.w400,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
    );
  }

  // Common Button Shape
  static final RoundedRectangleBorder buttonShape = RoundedRectangleBorder(
    borderRadius: AppSizes.brLarge,
  );

  // Input Decoration for TextFields
  static InputDecoration getBaseInputDecoration({required bool isDark}) {
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final hintColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final fillColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    
    return InputDecoration(
      filled: true,
      fillColor: fillColor,
      hintStyle: getTextStyle(color: hintColor, fontSize: 14.0),
      labelStyle: getTextStyle(color: textColor, fontSize: 14.0),
      contentPadding: AppSizes.paddingAll16,
      border: OutlineInputBorder(
        borderRadius: AppSizes.brLarge,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppSizes.brLarge,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppSizes.brLarge,
        borderSide: BorderSide.none,
      ),
    );
  }

  // Soft Box Shadow for Neumorphic/Soft-UI effect
  static List<BoxShadow> getCardShadow({required bool isDark}) {
    return [
      BoxShadow(
        color: isDark ? AppColors.darkCardShadow : AppColors.lightCardShadow,
        blurRadius: 24.0,
        offset: const Offset(0, 8),
        spreadRadius: 0.0,
      )
    ];
  }
}

// System styles for status bar
const kStatusBarLight = SystemUiOverlayStyle(
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
);

const kStatusBarDark = SystemUiOverlayStyle(
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
);
