import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Supported currencies with their display properties.
enum Currency {
  inr(code: 'INR', name: 'Indian Rupee', symbol: '₹'),
  usd(code: 'USD', name: 'US Dollar', symbol: '\$'),
  eur(code: 'EUR', name: 'Euro', symbol: '€'),
  gbp(code: 'GBP', name: 'Pound Sterling', symbol: '£');

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
  });

  final String code;
  final String name;
  final String symbol;
}

/// Manages the currently selected currency.
class CurrencyNotifier extends Notifier<Currency> {
  @override
  Currency build() => Currency.inr;

  void setCurrency(Currency currency) {
    state = currency;
  }
}

/// Global provider for the selected currency.
final currencyProvider =
    NotifierProvider<CurrencyNotifier, Currency>(CurrencyNotifier.new);
