class ValidationErrors {
  final String? amount;
  final String? rate;
  final String? term;

  const ValidationErrors({this.amount, this.rate, this.term});

  bool get isValid => amount == null && rate == null && term == null;

  const ValidationErrors.empty() : amount = null, rate = null, term = null;
}
