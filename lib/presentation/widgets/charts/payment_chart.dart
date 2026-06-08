import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/amortization_row.dart';
import '../../../domain/entities/loan_result.dart';
import 'bar_chart.dart';
import 'donut_chart.dart';
import 'line_area_chart.dart';

class PaymentChart extends StatelessWidget {
  final String type; // 'line' | 'bar' | 'donut'
  final List<AmortizationRow> schedule;
  final LoanResult result;
  final LuminaTokens t;
  final String currency;

  const PaymentChart({
    super.key,
    required this.type,
    required this.schedule,
    required this.result,
    required this.t,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildChart(),
    );
  }

  Widget _buildChart() {
    switch (type) {
      case 'donut':
        return DonutChart(
          key: ValueKey('donut-${t.isDark}'),
          principal: result.principal,
          interest: result.interest,
          t: t,
          currency: currency,
        );
      case 'bar':
        return BarChart(
          key: ValueKey('bar-${schedule.length}-${t.isDark}'),
          schedule: schedule,
          t: t,
          currency: currency,
        );
      default:
        return LineAreaChart(
          key: ValueKey('line-${schedule.length}-${t.isDark}'),
          schedule: schedule,
          t: t,
          currency: currency,
        );
    }
  }
}
