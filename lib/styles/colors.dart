import 'package:flutter/material.dart';

class AppColors {
  // Brand / Accents
  static const Color tealHighlightLight = Color(0xFF1B8198);
  static const Color tealHighlightDark = Color(0xFF38B4CA);
  static const Color navyPrimaryLight = Color(0xFF212F45);
  static const Color navyPrimaryDark = Color(0xFF2B3A54);
  static const Color redDelete = Color(0xFFE53935);
  
  // Light Theme Palette
  static const Color lightScaffold = Color(0xFFEAECEF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTrackInactive = Color(0xFFD1D5DB);
  static const Color lightCardShadow = Color(0x1A000000); // 10% opacity
  
  // Dark Theme Palette
  static const Color darkScaffold = Color(0xFF0F121A);
  static const Color darkSurface = Color(0xFF181E2B);
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTrackInactive = Color(0xFF374151);
  static const Color darkCardShadow = Color(0x40000000); // 25% opacity

  // ── App Bar ──
  static const Color lightAppBarBackground = lightSurface;
  static const Color darkAppBarBackground = darkSurface;

  // ── Currency / Theme Button ──
  static const Color lightCurrencyBtnBorder = Color(0x4D212F45); // navyPrimaryLight 30%
  static const Color darkCurrencyBtnBorder = Color(0x669CA3AF); // darkTextSecondary 40%
  static const Color lightCurrencyBtnBackground = Color(0x00000000); // transparent
  static const Color darkCurrencyBtnBackground = Color(0x4D2B3A54); // navyPrimaryDark 30%

  // ── Currency Dropdown ──
  static const Color lightDropdownBackground = lightSurface;
  static const Color darkDropdownBackground = darkSurface;
  static const Color lightDropdownSelectedBg = Color(0x1A212F45); // navyPrimaryLight 10%
  static const Color darkDropdownSelectedBg = Color(0x662B3A54); // navyPrimaryDark 40%
  static const Color lightCurrencyIconBg = navyPrimaryLight;
  static const Color darkCurrencyIconBg = navyPrimaryDark;

  // ── Brand Accent (for "Loan" text) ──
  static const Color lightBrandAccent = tealHighlightLight;
  static const Color darkBrandAccent = tealHighlightDark;
}

