class CardDeposit {
  String cardCompanyName;
  int salesCount;
  int salesAmount;
  int feeAmount;
  int depositAmount;

  CardDeposit({
    required this.cardCompanyName,
    required this.salesCount,
    required this.salesAmount,
    required this.feeAmount,
    required this.depositAmount,
  });

  factory CardDeposit.fromJson(Map<String, dynamic> json) {
    return CardDeposit(
      cardCompanyName: json['cardCompanyName'],
      salesCount: json['salesCount'],
      salesAmount: json['salesAmount'],
      feeAmount: json['feeAmount'],
      depositAmount: json['depositAmount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardCompanyName': cardCompanyName,
      'salesCount': salesCount,
      'salesAmount': salesAmount,
      'feeAmount': feeAmount,
      'depositAmount': depositAmount,
    };
  }
}

class DeliveryDeposit {
  String channelName;
  int salesCount;
  int salesAmount;
  int feeAmount;
  int depositAmount;

  DeliveryDeposit({
    required this.channelName,
    required this.salesCount,
    required this.salesAmount,
    required this.feeAmount,
    required this.depositAmount,
  });

  factory DeliveryDeposit.fromJson(Map<String, dynamic> json) {
    return DeliveryDeposit(
      channelName: json['channelName'],
      salesCount: json['salesCount'],
      salesAmount: json['salesAmount'],
      feeAmount: json['feeAmount'],
      depositAmount: json['depositAmount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'channelName': channelName,
      'salesCount': salesCount,
      'salesAmount': salesAmount,
      'feeAmount': feeAmount,
      'depositAmount': depositAmount,
    };
  }
}

class DOSettlementAnalysisDeposit {
  int totalCardDepositAmount;
  int totalDeliveryDepositAmount;
  List<CardDeposit> cardDepositList;
  List<DeliveryDeposit> deliveryDepositList;

  DOSettlementAnalysisDeposit({
    required this.totalCardDepositAmount,
    required this.totalDeliveryDepositAmount,
    required this.cardDepositList,
    required this.deliveryDepositList,
  });

  factory DOSettlementAnalysisDeposit.fromJson(Map<String, dynamic> json) {
    var cardDepositsFromJson = json['cardDepositList'] as List;
    List<CardDeposit> cardDepositList = cardDepositsFromJson.map((i) => CardDeposit.fromJson(i)).toList();

    var deliveryDepositsFromJson = json['deliveryDepositList'] as List;
    List<DeliveryDeposit> deliveryDepositList = deliveryDepositsFromJson.map((i) => DeliveryDeposit.fromJson(i)).toList();

    return DOSettlementAnalysisDeposit(
      totalCardDepositAmount: json['totalCardDepositAmount'],
      totalDeliveryDepositAmount: json['totalDeliveryDepositAmount'],
      cardDepositList: cardDepositList,
      deliveryDepositList: deliveryDepositList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCardDepositAmount': totalCardDepositAmount,
      'totalDeliveryDepositAmount': totalDeliveryDepositAmount,
      'cardDepositList': cardDepositList.map((e) => e.toJson()).toList(),
      'deliveryDepositList': deliveryDepositList.map((e) => e.toJson()).toList(),
    };
  }
}

class DOMonthlyDeposit {
  int saleCount;
  int saleAmount;
  int feeAmount;
  int depositAmount;

  DOMonthlyDeposit({
    required this.saleCount,
    required this.saleAmount,
    required this.feeAmount,
    required this.depositAmount,
  });

  factory DOMonthlyDeposit.fromJson(Map<String, dynamic> json) {
    return DOMonthlyDeposit(
      saleCount: json['saleCount'],
      saleAmount: json['saleAmount'],
      feeAmount: json['feeAmount'],
      depositAmount: json['depositAmount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'saleCount': saleCount,
      'saleAmount': saleAmount,
      'feeAmount': feeAmount,
      'depositAmount': depositAmount,
    };
  }
}
