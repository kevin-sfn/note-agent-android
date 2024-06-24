class DoDashboardSalesPayment {
  final int totalCount;
  final int totalAmount;
  final int creditCardCount;
  final int creditCardAmount;
  final int cashCount;
  final int cashAmount;
  final int deliveryCount;
  final int deliveryAmount;
  final int othersCount;
  final int othersAmount;
  final int depositCount;
  final int depositAmount;

  DoDashboardSalesPayment({
    required this.totalCount,
    required this.totalAmount,
    required this.creditCardCount,
    required this.creditCardAmount,
    required this.cashCount,
    required this.cashAmount,
    required this.deliveryCount,
    required this.deliveryAmount,
    required this.othersCount,
    required this.othersAmount,
    required this.depositCount,
    required this.depositAmount,
  });

  factory DoDashboardSalesPayment.fromJson(Map<String, dynamic> json) {
    return DoDashboardSalesPayment(
      totalCount: json['totalCount'],
      totalAmount: json['totalAmount'],
      creditCardCount: json['creditCardCount'],
      creditCardAmount: json['creditCardAmount'],
      cashCount: json['cashCount'],
      cashAmount: json['cashAmount'],
      deliveryCount: json['deliveryCount'],
      deliveryAmount: json['deliveryAmount'],
      othersCount: json['othersCount'],
      othersAmount: json['othersAmount'],
      depositCount: json['depositCount'],
      depositAmount: json['depositAmount'],
    );
  }
}
