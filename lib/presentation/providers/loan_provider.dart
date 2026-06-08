import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/amortization_row.dart';
import '../../domain/entities/loan_params.dart';
import '../../domain/entities/loan_result.dart';
import '../../domain/entities/validation_errors.dart';
import '../../domain/usecases/loan_calculator.dart';

// Currency ranges
const kCurrencyRanges = {
  'INR': (min: 0.0, max: 20000000.0, step: 10000.0, defaultAmount: 2500000.0),
  'USD': (min: 0.0, max: 1000000.0, step: 1000.0, defaultAmount: 250000.0),
  'EUR': (min: 0.0, max: 1000000.0, step: 1000.0, defaultAmount: 250000.0),
  'GBP': (min: 0.0, max: 1000000.0, step: 1000.0, defaultAmount: 250000.0),
};

class LoanState {
  final LoanParams params;
  final ValidationErrors errors;
  final LoanResult? result;
  final List<AmortizationRow> schedule;
  final String chartType; // 'line' | 'bar' | 'donut'

  const LoanState({
    required this.params,
    required this.errors,
    this.result,
    this.schedule = const [],
    this.chartType = 'line',
  });

  bool get isValid => errors.isValid;

  LoanState copyWith({
    LoanParams? params,
    ValidationErrors? errors,
    LoanResult? result,
    List<AmortizationRow>? schedule,
    String? chartType,
    bool clearResult = false,
  }) =>
      LoanState(
        params: params ?? this.params,
        errors: errors ?? this.errors,
        result: clearResult ? null : (result ?? this.result),
        schedule: schedule ?? this.schedule,
        chartType: chartType ?? this.chartType,
      );
}

final loanCalculatorProvider = StateNotifierProvider<LoanNotifier, LoanState>((ref) {
  return LoanNotifier(const LoanCalculator());
});

class LoanNotifier extends StateNotifier<LoanState> {
  final LoanCalculator _calculator;

  LoanNotifier(this._calculator)
      : super(LoanState(
          params: const LoanParams(
            amount: 2500000,
            annualRate: 8.5,
            termMonths: 240,
            type: PaymentType.annuity,
            currency: 'INR',
          ),
          errors: const ValidationErrors.empty(),
        )) {
    _recalculate();
  }

  void setAmount(double v) {
    final params = state.params.copyWith(amount: v);
    _update(params);
  }

  void setRate(double v) {
    final params = state.params.copyWith(annualRate: v);
    _update(params);
  }

  void setTerm(int v) {
    final params = state.params.copyWith(termMonths: v);
    _update(params);
  }

  void setType(PaymentType t) {
    final params = state.params.copyWith(type: t);
    _update(params);
  }

  void setCurrency(String code) {
    final range = kCurrencyRanges[code]!;
    final params = state.params.copyWith(
      currency: code,
      amount: range.defaultAmount,
    );
    _update(params);
  }

  void setChartType(String t) {
    state = state.copyWith(chartType: t);
  }

  void _update(LoanParams params) {
    final errors = _calculator.validate(
      params.amount,
      params.annualRate,
      params.termMonths,
      params.currency,
    );
    if (errors.isValid) {
      final result = _calculator.compute(params);
      final schedule = _calculator.buildSchedule(params);
      state = state.copyWith(
        params: params,
        errors: errors,
        result: result,
        schedule: schedule,
      );
    } else {
      state = state.copyWith(
        params: params,
        errors: errors,
        clearResult: true,
        schedule: [],
      );
    }
  }

  void _recalculate() => _update(state.params);
}
