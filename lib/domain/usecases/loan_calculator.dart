import '../entities/amortization_row.dart';
import '../entities/loan_params.dart';
import '../entities/loan_result.dart';
import '../entities/validation_errors.dart';

class LoanCalculator {
  const LoanCalculator();

  double _monthlyRate(double annualPct) => annualPct / 100 / 12;

  LoanResult computeAnnuity(double p, double annualPct, int n) {
    final r = _monthlyRate(annualPct);
    final double monthly;
    if (r == 0) {
      monthly = p / n;
    } else {
      double powN = 1.0;
      for (int i = 0; i < n; i++) {
        powN *= (1 + r);
      }
      monthly = (p * r * powN) / (powN - 1);
    }
    final total = monthly * n;
    final interest = total - p;
    return LoanResult(
      firstPayment: monthly,
      lastPayment: monthly,
      monthly: monthly,
      total: total,
      interest: interest,
    );
  }

  LoanResult computeDifferentiated(double p, double annualPct, int n) {
    final r = _monthlyRate(annualPct);
    final principalPart = p / n;
    double balance = p;
    double total = 0;
    double first = 0, last = 0;
    for (int m = 1; m <= n; m++) {
      final interestM = balance * r;
      final pay = principalPart + interestM;
      if (m == 1) first = pay;
      if (m == n) last = pay;
      total += pay;
      balance -= principalPart;
    }
    final interest = total - p;
    return LoanResult(
      firstPayment: first,
      lastPayment: last,
      monthly: first,
      total: total,
      interest: interest,
    );
  }

  LoanResult compute(LoanParams params) {
    if (params.type == PaymentType.differentiated) {
      return computeDifferentiated(params.amount, params.annualRate, params.termMonths);
    }
    return computeAnnuity(params.amount, params.annualRate, params.termMonths);
  }

  List<AmortizationRow> buildSchedule(LoanParams params) {
    final r = _monthlyRate(params.annualRate);
    final rows = <AmortizationRow>[];
    double balance = params.amount;

    if (params.type == PaymentType.differentiated) {
      final principalPart = params.amount / params.termMonths;
      for (int m = 1; m <= params.termMonths; m++) {
        final interestM = balance * r;
        final pay = principalPart + interestM;
        balance -= principalPart;
        rows.add(AmortizationRow(
          month: m,
          payment: pay,
          principal: principalPart,
          interest: interestM,
          balance: balance < 0 ? 0 : balance,
        ));
      }
    } else {
      final monthly = computeAnnuity(params.amount, params.annualRate, params.termMonths).monthly;
      for (int m = 1; m <= params.termMonths; m++) {
        final interestM = balance * r;
        final principalM = monthly - interestM;
        balance -= principalM;
        rows.add(AmortizationRow(
          month: m,
          payment: monthly,
          principal: principalM,
          interest: interestM,
          balance: balance < 0 ? 0 : balance,
        ));
      }
    }
    return rows;
  }

  ValidationErrors validate(double amount, double rate, int term, String currency) {
    String? amountErr;
    String? rateErr;
    String? termErr;

    if (amount <= 0) {
      amountErr = amount == 0 ? 'Amount must be greater than zero' : 'Amount must be positive';
    } else if (amount > 200000000) {
      amountErr = 'Amount looks too large';
    }

    if (rate < 0) {
      rateErr = "Rate can't be negative";
    } else if (rate > 100) {
      rateErr = 'Rate seems unrealistic (>100%)';
    }

    if (term <= 0) {
      termErr = 'Term must be at least 1 month';
    } else if (term > 600) {
      termErr = 'Term is too long';
    }

    return ValidationErrors(amount: amountErr, rate: rateErr, term: termErr);
  }
}
