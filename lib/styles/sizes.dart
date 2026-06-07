import 'package:flutter/material.dart';

class AppSizes {
  // Padding & Margins
  static const double p4 = 4.0;
  static const double p8 = 8.0;
  static const double p12 = 12.0;
  static const double p16 = 16.0;
  static const double p20 = 20.0;
  static const double p24 = 24.0;
  static const double p32 = 32.0;
  static const double p40 = 40.0;
  static const double p48 = 48.0;

  // Edge Insets
  static const EdgeInsets paddingZero = EdgeInsets.zero;
  static const EdgeInsets paddingAll8 = EdgeInsets.all(p8);
  static const EdgeInsets paddingAll12 = EdgeInsets.all(p12);
  static const EdgeInsets paddingAll16 = EdgeInsets.all(p16);
  static const EdgeInsets paddingAll20 = EdgeInsets.all(p20);
  static const EdgeInsets paddingAll24 = EdgeInsets.all(p24);
  static const EdgeInsets paddingH16 = EdgeInsets.symmetric(horizontal: p16);
  static const EdgeInsets paddingH24 = EdgeInsets.symmetric(horizontal: p24);
  static const EdgeInsets paddingV16 = EdgeInsets.symmetric(vertical: p16);
  static const EdgeInsets paddingV24 = EdgeInsets.symmetric(vertical: p24);
  static const EdgeInsets paddingH12 = EdgeInsets.symmetric(horizontal: p12);
  static const EdgeInsets paddingV8 = EdgeInsets.symmetric(vertical: p8);

  // Border Radii
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusXLarge = 32.0;
  static const double radiusCircular = 100.0;

  static final BorderRadius brSmall = BorderRadius.circular(radiusSmall);
  static final BorderRadius brMedium = BorderRadius.circular(radiusMedium);
  static final BorderRadius brLarge = BorderRadius.circular(radiusLarge);
  static final BorderRadius brXLarge = BorderRadius.circular(radiusXLarge);
  static final BorderRadius brCircular = BorderRadius.circular(radiusCircular);

  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;

  // Gaps (SizedBox)
  static const SizedBox gap4 = SizedBox.square(dimension: p4);
  static const SizedBox gap8 = SizedBox.square(dimension: p8);
  static const SizedBox gap12 = SizedBox.square(dimension: p12);
  static const SizedBox gap16 = SizedBox.square(dimension: p16);
  static const SizedBox gap20 = SizedBox.square(dimension: p20);
  static const SizedBox gap24 = SizedBox.square(dimension: p24);
  static const SizedBox gap32 = SizedBox.square(dimension: p32);

  // ── App Bar ──
  static const double appBarHeight = 64.0;
  static const double appBarLogoSize = 40.0;
  static const double currencyBtnHeight = 36.0;
  static const double currencyIconSize = 36.0;
  static const double dropdownWidth = 200.0;
}