import 'dart:convert';
import 'loan_params.dart';

class SavedCalculation {
  final String id;
  final double amount;
  final double rate;
  final int term;
  final PaymentType type;
  final String currency;
  final double monthly;
  final double total;
  final double interest;
  final String date;
  final List<double> sparkBalances;

  const SavedCalculation({
    required this.id,
    required this.amount,
    required this.rate,
    required this.term,
    required this.type,
    required this.currency,
    required this.monthly,
    required this.total,
    required this.interest,
    required this.date,
    required this.sparkBalances,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'rate': rate,
        'term': term,
        'type': type.name,
        'currency': currency,
        'monthly': monthly,
        'total': total,
        'interest': interest,
        'date': date,
        'sparkBalances': sparkBalances,
      };

  factory SavedCalculation.fromJson(Map<String, dynamic> json) => SavedCalculation(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        rate: (json['rate'] as num).toDouble(),
        term: json['term'] as int,
        type: PaymentType.values.firstWhere((e) => e.name == json['type'],
            orElse: () => PaymentType.annuity),
        currency: json['currency'] as String,
        monthly: (json['monthly'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
        interest: (json['interest'] as num).toDouble(),
        date: json['date'] as String,
        sparkBalances: (json['sparkBalances'] as List).map((e) => (e as num).toDouble()).toList(),
      );

  String toJsonString() => jsonEncode(toJson());
  static SavedCalculation fromJsonString(String s) =>
      SavedCalculation.fromJson(jsonDecode(s) as Map<String, dynamic>);

  LoanParams toLoanParams() => LoanParams(
        amount: amount,
        annualRate: rate,
        termMonths: term,
        type: type,
        currency: currency,
      );
}
