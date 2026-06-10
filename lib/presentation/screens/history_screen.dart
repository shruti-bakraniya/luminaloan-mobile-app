import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/entities/loan_params.dart';
import '../providers/history_provider.dart';
import '../providers/loan_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/charts/sparkline.dart';
import '../widgets/glass_card.dart';

class HistoryScreen extends ConsumerWidget {
  final VoidCallback onNavigateToCalc;

  const HistoryScreen({super.key, required this.onNavigateToCalc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final t = LuminaTokens(isDark: isDark);
    final history = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF0E1827), const Color(0xFF070B13)]
                    : [const Color(0xFFF2F5FB), const Color(0xFFE8EDF5)],
              ),
            ),
          ),
          SafeArea(
            child: history.isEmpty
                ? _EmptyState(t: t)
                : _HistoryList(t: t, history: history, onNavigateToCalc: onNavigateToCalc),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final LuminaTokens t;
  const _EmptyState({required this.t});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: t.glass,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: t.glassBorder),
                    ),
                    child: Icon(Icons.history_rounded, color: t.faint, size: 32),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('No saved calculations yet',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: t.text)),
              const SizedBox(height: 6),
              Text(
                'Tap "Save calculation" on a result and it will appear here for quick recall.',
                style: TextStyle(fontSize: 12.5, color: t.subtext),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}

class _HistoryList extends ConsumerWidget {
  final LuminaTokens t;
  final List history;
  final VoidCallback onNavigateToCalc;

  const _HistoryList({required this.t, required this.history, required this.onNavigateToCalc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
          child: Text(
            'History',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: t.text,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            itemCount: history.length,
            separatorBuilder: (_, __) => const SizedBox(height: 11),
            itemBuilder: (context, i) {
              final h = history[i];
              final cur = currencyOf(h.currency);
              String fmt(double v) => '${cur.symbol}${formatNumber(v, h.currency, decimals: 0)}';

              return GlassCard(
                t: t,
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    fmt(h.amount),
                                    style: TextStyle(
                                        fontSize: 17, fontWeight: FontWeight.w800, color: t.text, letterSpacing: -0.4),
                                  ),
                                  const SizedBox(width: 7),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(color: t.track, borderRadius: BorderRadius.circular(6)),
                                    child: Text(
                                      h.type == PaymentType.differentiated ? 'DIFF' : 'ANNUITY',
                                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: t.subtext),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${h.rate}% p.a. · ${termLabel(h.term)}',
                                style: TextStyle(fontSize: 11.5, color: t.subtext),
                              ),
                              const SizedBox(height: 7),
                              Row(
                                children: [
                                  Text('Monthly', style: TextStyle(fontSize: 11, color: t.subtext)),
                                  const SizedBox(width: 5),
                                  Text(
                                    fmt(h.monthly),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: t.principal,
                                      fontFeatures: const [FontFeature.tabularFigures()],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text('Interest', style: TextStyle(fontSize: 11, color: t.subtext)),
                                  const SizedBox(width: 5),
                                  Text(
                                    fmt(h.interest),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: t.interest,
                                      fontFeatures: const [FontFeature.tabularFigures()],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(h.date, style: TextStyle(fontSize: 10, color: t.faint)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              ref.read(loanCalculatorProvider.notifier).setAmount(h.amount);
                              ref.read(loanCalculatorProvider.notifier).setRate(h.rate);
                              ref.read(loanCalculatorProvider.notifier).setTerm(h.term);
                              ref.read(loanCalculatorProvider.notifier).setType(h.type);
                              ref.read(loanCalculatorProvider.notifier).setCurrency(h.currency);
                              onNavigateToCalc();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                gradient: t.accentGradient,
                                borderRadius: BorderRadius.circular(11),
                                boxShadow: const [
                                  BoxShadow(color: Color(0x593E5C8A), blurRadius: 12, offset: Offset(0, 4))
                                ],
                              ),
                              child: const Center(
                                child: Text('Open',
                                    style: TextStyle(
                                        fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => ref.read(historyProvider.notifier).delete(h.id),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: t.field,
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(color: t.glassBorder),
                            ),
                            child: Icon(Icons.delete_outline_rounded, color: t.error, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
