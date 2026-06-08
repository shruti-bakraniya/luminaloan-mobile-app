import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/entities/loan_params.dart';
import '../../domain/entities/saved_calculation.dart';
import '../providers/history_provider.dart';
import '../providers/loan_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/animated_number.dart';
import '../widgets/charts/payment_chart.dart';
import '../widgets/glass_card.dart';
import '../widgets/segmented_control.dart';
import '../widgets/slider_row.dart';

class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  bool _scheduleOpen = false;
  bool _showToast = false;
  bool _currencyMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final t = LuminaTokens(isDark: isDark);
    final loan = ref.watch(loanCalculatorProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _Background(t: t),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _Content(
                    t: t,
                    loan: loan,
                    onOpenSchedule: () => setState(() => _scheduleOpen = true),
                    onSave: _handleSave,
                    currencyMenuOpen: _currencyMenuOpen,
                    onToggleCurrencyMenu: () =>
                        setState(() => _currencyMenuOpen = !_currencyMenuOpen),
                    onCloseCurrencyMenu: () =>
                        setState(() => _currencyMenuOpen = false),
                  ),
                ),
              ],
            ),
          ),
          if (_scheduleOpen)
            _ScheduleSheet(
              t: t,
              open: _scheduleOpen,
              onClose: () => setState(() => _scheduleOpen = false),
              loan: loan,
            ),
          _Toast(t: t, show: _showToast, label: 'Saved to history'),
        ],
      ),
    );
  }

  void _handleSave() {
    final loan = ref.read(loanCalculatorProvider);
    if (!loan.isValid || loan.result == null) return;
    final p = loan.params;
    final r = loan.result!;
    final sparks = loan.schedule
        .where((row) => row.month % (loan.schedule.length ~/ 40 + 1) == 1 || loan.schedule.length <= 40)
        .map((row) => row.balance)
        .toList();
    final now = DateTime.now();
    final date = '${now.day.toString().padLeft(2, '0')} ${_monthName(now.month)}';

    final calc = SavedCalculation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: p.amount,
      rate: p.annualRate,
      term: p.termMonths,
      type: p.type,
      currency: p.currency,
      monthly: r.firstPayment,
      total: r.total,
      interest: r.interest,
      date: date,
      sparkBalances: sparks,
    );
    ref.read(historyProvider.notifier).save(calc);
    setState(() => _showToast = true);
    Future.delayed(const Duration(milliseconds: 1900), () {
      if (mounted) setState(() => _showToast = false);
    });
  }

  String _monthName(int m) =>
      ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m - 1];
}

class _Background extends StatelessWidget {
  final LuminaTokens t;
  const _Background({required this.t});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: t.isDark
                ? [const Color(0xFF0E1827), const Color(0xFF070B13)]
                : [const Color(0xFFF2F5FB), const Color(0xFFE8EDF5)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              left: -40,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.steelBlue.withOpacity(t.isDark ? 0.46 : 0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -30,
              right: -50,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.deepNavy.withOpacity(t.isDark ? 0.62 : 0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class _Content extends ConsumerWidget {
  final LuminaTokens t;
  final LoanState loan;
  final VoidCallback onOpenSchedule;
  final VoidCallback onSave;
  final bool currencyMenuOpen;
  final VoidCallback onToggleCurrencyMenu;
  final VoidCallback onCloseCurrencyMenu;

  const _Content({
    required this.t,
    required this.loan,
    required this.onOpenSchedule,
    required this.onSave,
    required this.currencyMenuOpen,
    required this.onToggleCurrencyMenu,
    required this.onCloseCurrencyMenu,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Column(
        children: [
          _Header(
            t: t,
            currency: loan.params.currency,
            currencyMenuOpen: currencyMenuOpen,
            onToggleCurrencyMenu: onToggleCurrencyMenu,
            onCloseCurrencyMenu: onCloseCurrencyMenu,
          ),
          const SizedBox(height: 12),
          _HeroCard(t: t, loan: loan),
          const SizedBox(height: 13),
          _InputsCard(t: t, loan: loan),
          const SizedBox(height: 13),
          _BreakdownCard(t: t, loan: loan, onOpenSchedule: onOpenSchedule),
          const SizedBox(height: 13),
          _SaveButton(t: t, loan: loan, onSave: onSave),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends ConsumerWidget {
  final LuminaTokens t;
  final String currency;
  final bool currencyMenuOpen;
  final VoidCallback onToggleCurrencyMenu;
  final VoidCallback onCloseCurrencyMenu;

  const _Header({
    required this.t,
    required this.currency,
    required this.currencyMenuOpen,
    required this.onToggleCurrencyMenu,
    required this.onCloseCurrencyMenu,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeProvider.notifier);
    final isDark = t.isDark;
    final cur = currencyOf(currency);

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: t.accentGradient,
            borderRadius: BorderRadius.circular(11),
            boxShadow: const [BoxShadow(color: Color(0x733E5C8A), blurRadius: 16, offset: Offset(0, 6))],
          ),
          child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 9),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Lumina',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: t.text,
                ),
              ),
              WidgetSpan(
                child: ShaderMask(
                  shaderCallback: (b) => t.accentGradient.createShader(b),
                  child: Text(
                    'Loan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Stack(
          clipBehavior: Clip.none,
          children: [
            _GlassButton(
              t: t,
              onTap: onToggleCurrencyMenu,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cur.symbol, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: t.text)),
                  const SizedBox(width: 5),
                  Text(cur.code, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.subtext)),
                ],
              ),
            ),
            if (currencyMenuOpen) ...[
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onCloseCurrencyMenu,
                  behavior: HitTestBehavior.translucent,
                ),
              ),
              Positioned(
                top: 46,
                right: 0,
                child: _CurrencyMenu(t: t, selected: currency, onClose: onCloseCurrencyMenu),
              ),
            ],
          ],
        ),
        const SizedBox(width: 8),
        _GlassButton(
          t: t,
          onTap: themeNotifier.toggle,
          child: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            size: 20,
            color: t.text,
          ),
        ),
      ],
    );
  }
}

class _GlassButton extends StatelessWidget {
  final LuminaTokens t;
  final VoidCallback onTap;
  final Widget child;

  const _GlassButton({required this.t, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: t.glass,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: t.glassBorder),
              ),
              child: Center(child: child),
            ),
          ),
        ),
      );
}

class _CurrencyMenu extends ConsumerWidget {
  final LuminaTokens t;
  final String selected;
  final VoidCallback onClose;

  const _CurrencyMenu({required this.t, required this.selected, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          width: 184,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: t.glassStrong,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: t.glassBorder),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: kCurrencies.map((c) {
              final isSelected = c.code == selected;
              return GestureDetector(
                onTap: () {
                  ref.read(loanCalculatorProvider.notifier).setCurrency(c.code);
                  onClose();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  decoration: BoxDecoration(
                    color: isSelected ? t.track : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          gradient: t.accentGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(c.symbol,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.code,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.text)),
                          Text(c.name,
                              style: TextStyle(fontSize: 10.5, color: t.subtext)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ─── Hero Card ────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final LuminaTokens t;
  final LoanState loan;

  const _HeroCard({required this.t, required this.loan});

  @override
  Widget build(BuildContext context) {
    final p = loan.params;
    final r = loan.result;
    final cur = currencyOf(p.currency);
    final isValid = loan.isValid;

    return GlassCard(
      t: t,
      strong: true,
      padding: const EdgeInsets.all(18),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.steelBlue.withOpacity(t.isDark ? 0.22 : 0.16),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    p.type == PaymentType.differentiated
                        ? 'First monthly payment'
                        : 'Monthly payment',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: t.subtext),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(color: t.track, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          p.type == PaymentType.differentiated ? Icons.stairs_rounded : Icons.bolt_rounded,
                          size: 13,
                          color: p.type == PaymentType.differentiated ? t.interest : t.principal,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          p.type == PaymentType.differentiated ? 'Differentiated' : 'Annuity',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: t.subtext),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 46,
                child: isValid && r != null
                    ? AnimatedNumber(
                        value: r.firstPayment,
                        render: (v) =>
                            '${cur.symbol}${formatNumber(v, p.currency, decimals: 0)}',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.5,
                          color: t.text,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      )
                    : Text(
                        '${cur.symbol}—',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: t.faint,
                          letterSpacing: -1,
                        ),
                      ),
              ),
              const SizedBox(height: 2),
              Text(
                isValid && r != null
                    ? 'over ${termLabel(p.termMonths)} · ${p.annualRate.toStringAsFixed(1)}% p.a.'
                        '${p.type == PaymentType.differentiated ? ' · ends at ${cur.symbol}${formatNumber(r.lastPayment, p.currency, decimals: 0)}' : ''}'
                    : 'Enter valid details to calculate',
                style: TextStyle(fontSize: 11.5, color: t.subtext),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      t: t,
                      label: 'Total payment',
                      valid: isValid,
                      value: r?.total ?? 0,
                      cur: cur,
                      currency: p.currency,
                    ),
                  ),
                  Container(width: 1, height: 36, color: t.glassBorder),
                  Expanded(
                    child: _StatItem(
                      t: t,
                      label: 'Total interest',
                      valid: isValid,
                      value: r?.interest ?? 0,
                      cur: cur,
                      currency: p.currency,
                      accent: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final LuminaTokens t;
  final String label;
  final bool valid;
  final double value;
  final CurrencyInfo cur;
  final String currency;
  final bool accent;

  const _StatItem({
    required this.t,
    required this.label,
    required this.valid,
    required this.value,
    required this.cur,
    required this.currency,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: t.subtext)),
            const SizedBox(height: 3),
            valid
                ? AnimatedNumber(
                    value: value,
                    render: (v) => '${cur.symbol}${formatNumber(v, currency, decimals: 0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: accent ? t.interest : t.text,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  )
                : Text(
                    '${cur.symbol}—',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: t.faint,
                    ),
                  ),
          ],
        ),
      );
}

// ─── Inputs Card ─────────────────────────────────────────────────────────────

class _InputsCard extends ConsumerWidget {
  final LuminaTokens t;
  final LoanState loan;

  const _InputsCard({required this.t, required this.loan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(loanCalculatorProvider.notifier);
    final p = loan.params;
    final e = loan.errors;
    final cur = currencyOf(p.currency);
    final range = kCurrencyRanges[p.currency]!;

    return GlassCard(
      t: t,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REPAYMENT METHOD',
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: t.subtext, letterSpacing: 0.4),
          ),
          const SizedBox(height: 9),
          LuminaSegmented<PaymentType>(
            t: t,
            selected: p.type,
            onChanged: notifier.setType,
            options: const [
              SegmentedOption(value: PaymentType.annuity, label: 'Annuity', icon: Icons.bolt_rounded),
              SegmentedOption(value: PaymentType.differentiated, label: 'Differentiated', icon: Icons.stairs_rounded),
            ],
          ),
          const SizedBox(height: 18),
          SliderRow(
            label: 'Loan amount',
            hint: 'up to ${formatCurrency(range.max, p.currency, compact: true)}',
            value: p.amount,
            min: range.min,
            max: range.max,
            step: range.step,
            onChanged: notifier.setAmount,
            format: (v) => formatNumber(v, p.currency, decimals: 0),
            error: e.amount,
            prefix: cur.symbol,
          ),
          const SizedBox(height: 16),
          SliderRow(
            label: 'Interest rate',
            hint: 'annual rate',
            value: p.annualRate,
            min: 0,
            max: 36,
            step: 0.1,
            onChanged: notifier.setRate,
            format: (v) => v.toStringAsFixed(1),
            error: e.rate,
            suffix: '% p.a.',
          ),
          const SizedBox(height: 16),
          SliderRow(
            label: 'Loan term',
            hint: termLabel(p.termMonths),
            value: p.termMonths.toDouble(),
            min: 1,
            max: 360,
            step: 1,
            onChanged: (v) => notifier.setTerm(v.round()),
            format: (v) => v.round().toString(),
            error: e.term,
            suffix: ' mo',
          ),
        ],
      ),
    );
  }
}

// ─── Breakdown / Chart Card ───────────────────────────────────────────────────

class _BreakdownCard extends ConsumerWidget {
  final LuminaTokens t;
  final LoanState loan;
  final VoidCallback onOpenSchedule;

  const _BreakdownCard({required this.t, required this.loan, required this.onOpenSchedule});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(loanCalculatorProvider.notifier);
    final isValid = loan.isValid;
    final chartType = loan.chartType;

    return GlassCard(
      t: t,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Payment structure', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: t.text)),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(color: t.track, borderRadius: BorderRadius.circular(11)),
                child: Row(
                  children: [
                    for (final entry in [('line', 'Line'), ('bar', 'Bar'), ('donut', 'Split')])
                      GestureDetector(
                        onTap: () => notifier.setChartType(entry.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: chartType == entry.$1 ? t.accentGradient : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            entry.$2,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: chartType == entry.$1 ? Colors.white : t.subtext,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isValid && loan.result != null) ...[
            PaymentChart(
              type: chartType,
              schedule: loan.schedule,
              result: loan.result!,
              t: t,
              currency: loan.params.currency,
            ),
            if (chartType != 'donut') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  _LegendDot(color: t.principal, label: 'Principal', t: t),
                  const SizedBox(width: 16),
                  _LegendDot(color: t.interest, label: 'Interest', t: t),
                  const Spacer(),
                  Text('drag chart to inspect',
                      style: TextStyle(fontSize: 10.5, color: t.faint)),
                ],
              ),
            ],
            const SizedBox(height: 14),
            GestureDetector(
              onTap: onOpenSchedule,
              child: Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: t.field,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: t.fieldBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'View full amortization schedule',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.text),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.chevron_right_rounded, size: 16, color: t.text),
                  ],
                ),
              ),
            ),
          ] else
            SizedBox(
              height: 188,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.show_chart_rounded, size: 28, color: t.faint),
                  const SizedBox(height: 8),
                  Text('Chart appears once inputs are valid',
                      style: TextStyle(fontSize: 12.5, color: t.faint)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final LuminaTokens t;

  const _LegendDot({required this.color, required this.label, required this.t});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 11.5, color: t.subtext)),
        ],
      );
}

// ─── Save Button ─────────────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  final LuminaTokens t;
  final LoanState loan;
  final VoidCallback onSave;

  const _SaveButton({required this.t, required this.loan, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final valid = loan.isValid;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: valid ? 1.0 : 0.6,
      child: GestureDetector(
        onTap: valid ? onSave : null,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: valid ? t.accentGradient : null,
            color: valid ? null : t.track,
            borderRadius: BorderRadius.circular(16),
            boxShadow: valid
                ? [const BoxShadow(color: Color(0x733E5C8A), blurRadius: 26, offset: Offset(0, 10))]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.save_rounded, color: Colors.white, size: 19),
              const SizedBox(width: 8),
              const Text(
                'Save calculation',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Schedule Sheet ──────────────────────────────────────────────────────────

class _ScheduleSheet extends StatelessWidget {
  final LuminaTokens t;
  final bool open;
  final VoidCallback onClose;
  final LoanState loan;

  const _ScheduleSheet({
    required this.t,
    required this.open,
    required this.onClose,
    required this.loan,
  });

  @override
  Widget build(BuildContext context) {
    final p = loan.params;
    final r = loan.result;
    if (r == null) return const SizedBox.shrink();
    final cur = currencyOf(p.currency);
    String fmt(double v) => '${cur.symbol}${formatNumber(v, p.currency, decimals: 0)}';

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 420),
      curve: Curves.fastOutSlowIn,
      left: 0,
      right: 0,
      bottom: 0,
      top: open ? 54 : MediaQuery.of(context).size.height,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            decoration: BoxDecoration(
              color: t.glassStrong,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
              border: Border.all(color: t.glassBorder),
              boxShadow: const [BoxShadow(color: Color(0x4D000000), blurRadius: 50, offset: Offset(0, -20))],
            ),
            child: Column(
              children: [
                const SizedBox(height: 9),
                Container(width: 38, height: 4, decoration: BoxDecoration(color: t.faint, borderRadius: BorderRadius.circular(4))),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: onClose,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(color: t.field, borderRadius: BorderRadius.circular(10)),
                          child: Icon(Icons.arrow_back_rounded, color: t.text, size: 22),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Amortization schedule',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: t.text, letterSpacing: -0.3)),
                          Text(
                            '${loan.schedule.length} payments · ${p.type == PaymentType.differentiated ? 'Differentiated' : 'Annuity'}',
                            style: TextStyle(fontSize: 11, color: t.subtext),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      _Chip(t: t, label: 'Total paid', value: fmt(r.total)),
                      const SizedBox(width: 8),
                      _Chip(t: t, label: 'Principal', value: fmt(r.principal), color: t.principal),
                      const SizedBox(width: 8),
                      _Chip(t: t, label: 'Interest', value: fmt(r.interest), color: t.interest),
                    ],
                  ),
                ),
                // table header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: t.glass,
                    border: Border(bottom: BorderSide(color: t.glassBorder)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 30, child: Text('#', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: t.subtext))),
                      for (final label in ['Payment', 'Principal', 'Interest', 'Balance'])
                        Expanded(
                          child: Text(
                            label.toUpperCase(),
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: t.subtext, letterSpacing: 0.3),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: loan.schedule.length,
                    itemBuilder: (context, i) {
                      final row = loan.schedule[i];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                        color: i.isOdd
                            ? (t.isDark ? Colors.white.withOpacity(0.02) : const Color(0xFF3E5C8A).withOpacity(0.03))
                            : Colors.transparent,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 30,
                              child: Text('${row.month}',
                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: t.faint,
                                      fontFeatures: const [FontFeature.tabularFigures()])),
                            ),
                            _Cell(value: fmt(row.payment), color: t.text, t: t),
                            _Cell(value: fmt(row.principal), color: t.principal, t: t),
                            _Cell(value: fmt(row.interest), color: t.interest, t: t),
                            _Cell(value: fmt(row.balance), color: t.subtext, t: t),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final LuminaTokens t;
  final String label;
  final String value;
  final Color? color;

  const _Chip({required this.t, required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: t.glass,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: t.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 9.5, color: t.subtext)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: color ?? t.text,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  )),
            ],
          ),
        ),
      );
}

class _Cell extends StatelessWidget {
  final String value;
  final Color color;
  final LuminaTokens t;

  const _Cell({required this.value, required this.color, required this.t});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 11.5,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      );
}

// ─── Toast ────────────────────────────────────────────────────────────────────

class _Toast extends StatelessWidget {
  final LuminaTokens t;
  final bool show;
  final String label;

  const _Toast({required this.t, required this.show, required this.label});

  @override
  Widget build(BuildContext context) => Positioned(
        left: 0,
        right: 0,
        bottom: 96,
        child: IgnorePointer(
          child: Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: show ? 1 : 0,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 400),
                scale: show ? 1 : 0.9,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: t.accentGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(color: Color(0x803E5C8A), blurRadius: 30, offset: Offset(0, 10))
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_rounded, color: Colors.white, size: 17),
                      const SizedBox(width: 8),
                      Text(label,
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
