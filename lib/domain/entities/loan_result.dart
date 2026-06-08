class LoanResult {
  final double firstPayment;
  final double lastPayment;
  final double monthly;
  final double total;
  final double interest;

  const LoanResult({
    required this.firstPayment,
    required this.lastPayment,
    required this.monthly,
    required this.total,
    required this.interest,
  });

  double get principal => total - interest;
}
