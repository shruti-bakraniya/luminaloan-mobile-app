# LuminaLoan — Loan & Mortgage Calculator

[Download Android APK](https://github.com/shruti-bakraniya/luminaloan-mobile-app/releases/download/v0.0.1/luminaloan_v1.apk)

A premium Flutter mobile app for calculating **annuity** and **differentiated** loan payments with real-time results, interactive data visualizations, multi-currency support, and a glassmorphic UI with dark/light theming.

---

## 📱 App Flow

```
main.dart
 └─ ProviderScope (Riverpod)
     └─ LuminaLoanApp (ConsumerWidget)
         └─ MaterialApp (light + dark ThemeData)
             └─ MainScreen (IndexedStack + BottomNav)
                 ├─ CalculatorScreen  ←  Tab 0 (default)
                 │   ├─ Header (logo · currency selector · theme toggle)
                 │   ├─ HeroCard (animated monthly payment + totals)
                 │   ├─ InputsCard (sliders: amount · rate · term + payment type toggle)
                 │   ├─ BreakdownCard (line / bar / donut chart + amortization schedule sheet)
                 │   └─ SaveButton → saves to history
                 │
                 └─ HistoryScreen  ←  Tab 1
                     ├─ EmptyState (no saved calculations)
                     └─ HistoryList (saved cards with sparklines, open / delete actions)
```

### User Journey

1. **Open app** → lands on `CalculatorScreen` with sensible defaults (₹25,00,000 · 8.5% · 20 yrs · Annuity).
2. **Adjust inputs** via interactive sliders (loan amount, interest rate, term) and switch between **Annuity** / **Differentiated** repayment modes.
3. **Live results** update instantly in the `HeroCard` — monthly payment (animated number), total payment, and total interest overpayment.
4. **Explore charts** — toggle between Line, Bar, and Donut visualizations. Drag the Line/Bar charts for month-level tooltips.
5. **View amortization schedule** — tap to open a full bottom sheet showing every month's principal, interest, and remaining balance.
6. **Switch currency** — select from INR, USD, EUR, GBP; slider ranges and formatting adapt automatically.
7. **Save calculation** → persisted to `SharedPreferences` and viewable in `HistoryScreen`.
8. **Recall from history** — tap **Open** on any saved card to restore those exact parameters back into the calculator.
9. **Toggle theme** — switch between dark and light modes via the header button.

---

## 🏛 Architecture — Clean Architecture + MVVM

The codebase follows a strict **three-layer Clean Architecture** with a clear separation of concerns:

```
lib/
├── main.dart                          # App entry, ProviderScope, SystemChrome
│
├── core/                              # Shared utilities & design system
│   ├── theme/
│   │   ├── app_colors.dart            # Full dark + light color palette
│   │   └── app_theme.dart             # ThemeData builder + LuminaTokens design token class
│   └── utils/
│       └── currency_formatter.dart    # CurrencyInfo, formatCurrency(), formatNumber(), termLabel()
│
├── domain/                            # Pure business logic (zero Flutter imports)
│   ├── entities/
│   │   ├── loan_params.dart           # LoanParams + PaymentType enum (annuity | differentiated)
│   │   ├── loan_result.dart           # LoanResult (monthly, total, interest, principal)
│   │   ├── amortization_row.dart      # AmortizationRow (month, payment, principal, interest, balance)
│   │   ├── saved_calculation.dart     # SavedCalculation (JSON serializable, sparkline balances)
│   │   └── validation_errors.dart     # ValidationErrors (amount, rate, term)
│   └── usecases/
│       └── loan_calculator.dart       # LoanCalculator — computeAnnuity(), computeDifferentiated(),
│                                      #   buildSchedule(), validate()
│
├── data/                              # Data persistence
│   └── repositories/
│       └── history_repository.dart    # HistoryRepository (abstract) + SharedPrefsHistoryRepository
│
└── presentation/                      # UI layer
    ├── providers/                     # Riverpod state management
    │   ├── loan_provider.dart         # LoanNotifier (StateNotifier<LoanState>) — central calculator state
    │   ├── history_provider.dart      # HistoryNotifier — CRUD for saved calculations
    │   └── theme_provider.dart        # ThemeNotifier — dark/light toggle
    ├── screens/
    │   ├── main_screen.dart           # Shell with IndexedStack + BottomNav
    │   ├── calculator_screen.dart     # Full calculator UI (header, hero, inputs, charts, schedule sheet)
    │   └── history_screen.dart        # Saved calculation list + restore-to-calculator flow
    └── widgets/
        ├── animated_number.dart       # Smooth animated value transitions
        ├── bottom_nav.dart            # Glassmorphic bottom navigation bar
        ├── glass_card.dart            # Reusable glassmorphism card wrapper
        ├── segmented_control.dart     # Annuity / Differentiated toggle
        ├── slider_row.dart            # Custom slider with editable text field + validation
        └── charts/
            ├── payment_chart.dart     # Chart router (AnimatedSwitcher between chart types)
            ├── line_area_chart.dart   # Stacked area chart (principal vs. interest over time)
            ├── bar_chart.dart         # Stacked bar chart with touch-to-inspect tooltips
            ├── donut_chart.dart       # Animated donut with principal/interest split
            └── sparkline.dart         # Mini sparkline used in history cards
```

### Data Flow

```
User Input (Slider/TextField)
    │
    ▼
LoanNotifier.setAmount() / setRate() / setTerm() / setType()
    │
    ├─► LoanCalculator.validate()  →  ValidationErrors
    │
    ├─► LoanCalculator.compute()   →  LoanResult (monthly, total, interest)
    │
    └─► LoanCalculator.buildSchedule()  →  List<AmortizationRow>
            │
            ▼
        LoanState (params + errors + result + schedule + chartType)
            │
            ▼
        UI rebuilds via ref.watch(loanCalculatorProvider)
```

---

## ⚙️ State Management — Riverpod

| Provider | Type | Purpose |
|---|---|---|
| `loanCalculatorProvider` | `StateNotifierProvider<LoanNotifier, LoanState>` | Central loan parameters, validation, result, schedule, and chart type |
| `historyProvider` | `StateNotifierProvider<HistoryNotifier, List<SavedCalculation>>` | CRUD for saved calculations (backed by `SharedPreferences`) |
| `themeProvider` | `StateNotifierProvider<ThemeNotifier, ThemeMode>` | Dark / light theme toggle |
| `sharedPrefsProvider` | `FutureProvider<SharedPreferences>` | Async initialisation of `SharedPreferences` |
| `historyRepositoryProvider` | `Provider<HistoryRepository?>` | Depends on `sharedPrefsProvider`; creates `SharedPrefsHistoryRepository` |

---

## 🚀 Core Features

- **Dual Calculation Engine** — Annuity (fixed payments) and Differentiated (decreasing payments) formulas computed in pure Dart with zero third-party math dependencies.
- **Real-Time Updates** — slider and text-field inputs instantly re-compute results without any button press.
- **Full Amortization Schedule** — month-by-month breakdown of payment, principal, interest, and remaining balance presented in a scrollable bottom sheet.
- **Input Validation** — per-field error messages for edge cases (zero amount, negative rate, term > 600 months, unrealistic values).

## ✨ Advanced Features

- **Interactive Visualizations** — three chart types (Line/Area, Bar, Donut) built with custom `CustomPainter` implementations, including touch-to-inspect tooltips and animated transitions.
- **Calculation History** — save, recall, and delete past calculations. Each history card includes a sparkline preview of the balance curve.
- **Multi-Currency** — INR (Indian grouping), USD, EUR, GBP with per-currency slider ranges, default amounts, and formatted output.
- **Glassmorphic UI** — frosted-glass cards, backdrop filters, and a cohesive dark/light design system via `LuminaTokens`.
- **Theme Switching** — full dark and light modes with smooth toggling.
- **Animated Numbers** — smooth value interpolation on the hero card for a polished feel.

---

## 🛠 Tech Stack

| Category | Technology |
|---|---|
| **Framework** | Flutter (Dart SDK ≥ 3.10.4) |
| **State Management** | `flutter_riverpod` ^3.3.1 (StateNotifier pattern) |
| **Persistence** | `shared_preferences` ^2.5.5 |
| **Typography** | `google_fonts` ^8.1.0 (Plus Jakarta Sans) + bundled font assets |
| **Charts** | Custom `CustomPainter` (no third-party chart library) |
| **Linting** | `flutter_lints` ^6.0.0 + `riverpod_lint` ^3.1.3 |
| **Design** | Material 3, Glassmorphism, custom `LuminaTokens` design token system |

---

## 📋 Getting Started

```bash
# Clone the repository
git clone <repository-url>
cd luminaloan-mobile-app

# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Run tests
flutter test
```

### Requirements

- Flutter SDK ≥ 3.10.4
- Dart SDK ≥ 3.10.4
- Android / iOS simulator or physical device