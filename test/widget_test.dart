import 'package:flutter_test/flutter_test.dart';
import 'package:luminaloan/domain/usecases/loan_calculator.dart';
import 'package:luminaloan/domain/entities/loan_params.dart';

void main() {
  group('LoanCalculator', () {
    const calc = LoanCalculator();

    test('annuity computes correct monthly payment', () {
      final result = calc.computeAnnuity(1000000, 12.0, 12);
      expect(result.monthly, closeTo(88849, 1));
    });

    test('differentiated first payment is higher than last', () {
      final result = calc.computeDifferentiated(1000000, 12.0, 12);
      expect(result.firstPayment, greaterThan(result.lastPayment));
    });

    test('validation rejects zero amount', () {
      final errors = calc.validate(0, 8.5, 12, 'INR');
      expect(errors.amount, isNotNull);
      expect(errors.isValid, isFalse);
    });

    test('validation rejects negative rate', () {
      final errors = calc.validate(100000, -1.0, 12, 'INR');
      expect(errors.rate, isNotNull);
    });

    test('validation rejects zero term', () {
      final errors = calc.validate(100000, 8.5, 0, 'INR');
      expect(errors.term, isNotNull);
    });

    test('amortization schedule has correct number of rows', () {
      final params = LoanParams(
        amount: 500000,
        annualRate: 10.0,
        termMonths: 24,
        type: PaymentType.annuity,
        currency: 'INR',
      );
      final schedule = calc.buildSchedule(params);
      expect(schedule.length, equals(24));
    });
  });
}
