# LuminaLoan — Loan & Mortgage Calculator

[Download Android APK](https://github.com/shruti-bakraniya/luminaloan-mobile-app/releases/download/v0.0.1/luminaloan_v1.apk)

A premium Flutter mobile app for calculating **annuity** and **differentiated** loan payments with real-time results, interactive data visualizations, multi-currency support, and a glassmorphic UI with dark/light theming.

## App Preview

![App Flow Walkthrough](assets/videos/walk_through.mp4)

## ✨ Features

* **Dual Calculation Engine:** Supports both Annuity (fixed) and Differentiated (decreasing) repayment formulas.
* **Real-Time Results:** Sliders and inputs instantly re-compute monthly payments, total interest, and the full amortization schedule.
* **Interactive Charts:** Custom-built Line, Bar, and Donut visualizations with touch-to-inspect tooltips.
* **Calculation History:** Save, recall, and manage past calculations with visual sparkline previews.
* **Multi-Currency:** Built-in support for INR, USD, EUR, and GBP with localized formatting and dynamic slider ranges.
* **Modern UI:** Glassmorphic design, smooth number animations, and seamless dark/light theme switching.

## 🏛 Architecture

Built using a strict **Clean Architecture + MVVM** pattern to ensure a clear separation of concerns:

* **Domain Layer:** Pure business logic, loan entities, validation rules, and calculation use cases (zero Flutter imports).
* **Data Layer:** Data persistence handled via abstract repositories (`HistoryRepository`).
* **Presentation Layer:** UI components, custom painters, and MVVM state management using Riverpod (`StateNotifier`).

## 🛠 Dependencies

* **Framework:** Flutter (Dart SDK ≥ 3.10.4)
* **State Management:** `flutter_riverpod` ^3.3.1
* **Persistence:** `shared_preferences` ^2.5.5
* **Typography:** `google_fonts` ^8.1.0 (Plus Jakarta Sans)
* **Charts:** Native `CustomPainter` implementations (No third-party chart libraries)