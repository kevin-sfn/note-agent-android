class DODeliveryAnalysisSales {
  int totalSalesCount;
  int totalSalesAmount;
  int totalDeliveryFeeAmount;
  int totalDepositAmount;
  int lastMonthTotalSalesCount;
  int lastMonthTotalSalesAmount;
  int lastMonthTotalDeliveryFeeAmount;
  int lastMonthTotalDepositAmount;
  double rateOfSalesCount;
  double rateOfSalesAmount;
  double rateOfDeliveryFeeAmount;
  double rateOfDepositAmount;
  List<DeliverySales>? deliverySalesList;
  List<dynamic>? deliverySalesRateList;

  DODeliveryAnalysisSales({
    required this.totalSalesCount,
    required this.totalSalesAmount,
    required this.totalDeliveryFeeAmount,
    required this.totalDepositAmount,
    required this.lastMonthTotalSalesCount,
    required this.lastMonthTotalSalesAmount,
    required this.lastMonthTotalDeliveryFeeAmount,
    required this.lastMonthTotalDepositAmount,
    required this.rateOfSalesCount,
    required this.rateOfSalesAmount,
    required this.rateOfDeliveryFeeAmount,
    required this.rateOfDepositAmount,
    this.deliverySalesList,
    this.deliverySalesRateList,
  });

  factory DODeliveryAnalysisSales.fromJson(Map<String, dynamic> json) {
    var list = json['deliverySalesList'] as List?;
    List<DeliverySales>? deliverySalesList = list != null ? list.map((i) => DeliverySales.fromJson(i)).toList() : null;

    return DODeliveryAnalysisSales(
      totalSalesCount: json['totalSalesCount'],
      totalSalesAmount: json['totalSalesAmount'],
      totalDeliveryFeeAmount: json['totalDeliveryFeeAmount'],
      totalDepositAmount: json['totalDepositAmount'],
      lastMonthTotalSalesCount: json['lastMonthTotalSalesCount'],
      lastMonthTotalSalesAmount: json['lastMonthTotalSalesAmount'],
      lastMonthTotalDeliveryFeeAmount: json['lastMonthTotalDeliveryFeeAmount'],
      lastMonthTotalDepositAmount: json['lastMonthTotalDepositAmount'],
      rateOfSalesCount: json['rateOfSalesCount'].toDouble(),
      rateOfSalesAmount: json['rateOfSalesAmount'].toDouble(),
      rateOfDeliveryFeeAmount: json['rateOfDeliveryFeeAmount'].toDouble(),
      rateOfDepositAmount: json['rateOfDepositAmount'].toDouble(),
      deliverySalesList: deliverySalesList,
      deliverySalesRateList: json['deliverySalesRateList'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSalesCount': totalSalesCount,
      'totalSalesAmount': totalSalesAmount,
      'totalDeliveryFeeAmount': totalDeliveryFeeAmount,
      'totalDepositAmount': totalDepositAmount,
      'lastMonthTotalSalesCount': lastMonthTotalSalesCount,
      'lastMonthTotalSalesAmount': lastMonthTotalSalesAmount,
      'lastMonthTotalDeliveryFeeAmount': lastMonthTotalDeliveryFeeAmount,
      'lastMonthTotalDepositAmount': lastMonthTotalDepositAmount,
      'rateOfSalesCount': rateOfSalesCount,
      'rateOfSalesAmount': rateOfSalesAmount,
      'rateOfDeliveryFeeAmount': rateOfDeliveryFeeAmount,
      'rateOfDepositAmount': rateOfDepositAmount,
      'deliverySalesList': deliverySalesList?.map((e) => e.toJson()).toList(),
      'deliverySalesRateList': deliverySalesRateList,
    };
  }
}

class DeliverySales {
  String channelType;
  String channelTypeName;
  int salesCount;
  int salesAmount;
  int deliveryFeeAmount;
  int depositAmount;
  LastMonthSales lastMonthSales;

  DeliverySales({
    required this.channelType,
    required this.channelTypeName,
    required this.salesCount,
    required this.salesAmount,
    required this.deliveryFeeAmount,
    required this.depositAmount,
    required this.lastMonthSales,
  });

  factory DeliverySales.fromJson(Map<String, dynamic> json) {
    return DeliverySales(
      channelType: json['channelType'],
      channelTypeName: json['channelTypeName'],
      salesCount: json['salesCount'],
      salesAmount: json['salesAmount'],
      deliveryFeeAmount: json['deliveryFeeAmount'],
      depositAmount: json['depositAmount'],
      lastMonthSales: LastMonthSales.fromJson(json['lastMonthSales']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'channelType': channelType,
      'channelTypeName': channelTypeName,
      'salesCount': salesCount,
      'salesAmount': salesAmount,
      'deliveryFeeAmount': deliveryFeeAmount,
      'depositAmount': depositAmount,
      'lastMonthSales': lastMonthSales.toJson(),
    };
  }
}

class LastMonthSales {
  int salesAmount;
  int salesCount;
  int feeAmount;
  int depositAmount;
  int average;
  int rate;

  LastMonthSales({
    required this.salesAmount,
    required this.salesCount,
    required this.feeAmount,
    required this.depositAmount,
    required this.average,
    required this.rate,
  });

  factory LastMonthSales.fromJson(Map<String, dynamic> json) {
    return LastMonthSales(
      salesAmount: json['salesAmount'],
      salesCount: json['salesCount'],
      feeAmount: json['feeAmount'],
      depositAmount: json['depositAmount'],
      average: json['average'],
      rate: json['rate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'salesAmount': salesAmount,
      'salesCount': salesCount,
      'feeAmount': feeAmount,
      'depositAmount': depositAmount,
      'average': average,
      'rate': rate,
    };
  }
}
