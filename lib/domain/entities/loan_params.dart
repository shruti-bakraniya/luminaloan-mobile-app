enum PaymentType { annuity, differentiated }

class LoanParams {
  final double amount;
  final double annualRate;
  final int termMonths;
  final PaymentType type;
  final String currency;

  const LoanParams({
    required this.amount,
    required this.annualRate,
    required this.termMonths,
    required this.type,
    required this.currency,
  });

  LoanParams copyWith({
    double? amount,
    double? annualRate,
    int? termMonths,
    PaymentType? type,
    String? currency,
  }) => LoanParams(
        amount: amount ?? this.amount,
        annualRate: annualRate ?? this.annualRate,
        termMonths: termMonths ?? this.termMonths,
        type: type ?? this.type,
        currency: currency ?? this.currency,
      );
}
