class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;
  const CurrencyInfo({required this.code, required this.symbol, required this.name});
}

const kCurrencies = [
  CurrencyInfo(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
  CurrencyInfo(code: 'USD', symbol: '\$', name: 'US Dollar'),
  CurrencyInfo(code: 'EUR', symbol: '€', name: 'Euro'),
  CurrencyInfo(code: 'GBP', symbol: '£', name: 'Pound Sterling'),
];

CurrencyInfo currencyOf(String code) =>
    kCurrencies.firstWhere((c) => c.code == code, orElse: () => kCurrencies.first);

String _groupIndian(String intStr) {
  if (intStr.length <= 3) return intStr;
  final last3 = intStr.substring(intStr.length - 3);
  var rest = intStr.substring(0, intStr.length - 3);
  final buf = StringBuffer();
  for (var i = 0; i < rest.length; i++) {
    if (i > 0 && (rest.length - i) % 2 == 0) buf.write(',');
    buf.write(rest[i]);
  }
  return '${buf.toString()},$last3';
}

String _groupWestern(String intStr) {
  final buf = StringBuffer();
  for (var i = 0; i < intStr.length; i++) {
    if (i > 0 && (intStr.length - i) % 3 == 0) buf.write(',');
    buf.write(intStr[i]);
  }
  return buf.toString();
}

String formatNumber(double value, String code, {int decimals = 0}) {
  final sign = value < 0 ? '-' : '';
  final abs = value.abs();
  final fixed = abs.toStringAsFixed(decimals);
  final parts = fixed.split('.');
  final intPart = code == 'INR' ? _groupIndian(parts[0]) : _groupWestern(parts[0]);
  return '$sign$intPart${parts.length > 1 && decimals > 0 ? '.${parts[1]}' : ''}';
}

String formatCurrency(double value, String code, {int decimals = 0, bool compact = false}) {
  final sym = currencyOf(code).symbol;
  if (compact) {
    final abs = value.abs();
    if (code == 'INR') {
      if (abs >= 1e7) return '$sym${(value / 1e7).toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')} Cr';
      if (abs >= 1e5) return '$sym${(value / 1e5).toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')} L';
      if (abs >= 1e3) return '$sym${(value / 1e3).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}K';
    } else {
      if (abs >= 1e9) return '$sym${(value / 1e9).toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}B';
      if (abs >= 1e6) return '$sym${(value / 1e6).toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}M';
      if (abs >= 1e3) return '$sym${(value / 1e3).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}K';
    }
    return '$sym${formatNumber(value, code, decimals: 0)}';
  }
  return '$sym${formatNumber(value, code, decimals: decimals)}';
}

String termLabel(int months) {
  final y = months ~/ 12;
  final m = months % 12;
  if (y == 0) return '${m}mo';
  if (m == 0) return y == 1 ? '1 yr' : '$y yrs';
  return '${y}y ${m}m';
}
