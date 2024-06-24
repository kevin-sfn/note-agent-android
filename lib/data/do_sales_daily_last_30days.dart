import 'dart:convert';

class DOSaleDetail {
  final String saleDate;
  final int totalAmount;
  final int storeAmount;
  final int deliveryAmount;
  final int totalQuantity;
  final int storeQuantity;
  final int deliveryQuantity;
  final int storeRate;
  final int deliveryRate;

  DOSaleDetail({
    required this.saleDate,
    required this.totalAmount,
    required this.storeAmount,
    required this.deliveryAmount,
    required this.totalQuantity,
    required this.storeQuantity,
    required this.deliveryQuantity,
    required this.storeRate,
    required this.deliveryRate,
  });

  factory DOSaleDetail.fromJson(Map<String, dynamic> json) {
    return DOSaleDetail(
      saleDate: json['saleDate'],
      totalAmount: json['totalAmount'],
      storeAmount: json['storeAmount'],
      deliveryAmount: json['deliveryAmount'],
      totalQuantity: json['totalQuantity'],
      storeQuantity: json['storeQuantity'],
      deliveryQuantity: json['deliveryQuantity'],
      storeRate: json['storeRate'],
      deliveryRate: json['deliveryRate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'saleDate': saleDate,
      'totalAmount': totalAmount,
      'storeAmount': storeAmount,
      'deliveryAmount': deliveryAmount,
      'totalQuantity': totalQuantity,
      'storeQuantity': storeQuantity,
      'deliveryQuantity': deliveryQuantity,
      'storeRate': storeRate,
      'deliveryRate': deliveryRate,
    };
  }
}

class DOSalesDailyLast30Days {
  final int lastMonthTotalAmount;
  final int thisMonthTotalAmount;
  final int changesFromLastMonth;
  final int detailSum;
  final List<DOSaleDetail> detail;

  DOSalesDailyLast30Days({
    required this.lastMonthTotalAmount,
    required this.thisMonthTotalAmount,
    required this.changesFromLastMonth,
    required this.detailSum,
    required this.detail,
  });

  factory DOSalesDailyLast30Days.fromJson(Map<String, dynamic> json) {
    return DOSalesDailyLast30Days(
      lastMonthTotalAmount: json['lastMonthTotalAmount'],
      thisMonthTotalAmount: json['thisMonthTotalAmount'],
      changesFromLastMonth: json['changesFromLastMonth'],
      detailSum: json['detailSum'],
      detail: List<DOSaleDetail>.from(json['detail'].map((item) => DOSaleDetail.fromJson(item))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastMonthTotalAmount': lastMonthTotalAmount,
      'thisMonthTotalAmount': thisMonthTotalAmount,
      'changesFromLastMonth': changesFromLastMonth,
      'detailSum': detailSum,
      'detail': detail.map((item) => item.toJson()).toList(),
    };
  }
}