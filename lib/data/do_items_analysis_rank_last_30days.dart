class DOItemsAnalysisRankLast30Days {
  final int totalQuantity;
  final List<ItemRank> itemRankList;

  DOItemsAnalysisRankLast30Days({
    required this.totalQuantity,
    required this.itemRankList,
  });

  factory DOItemsAnalysisRankLast30Days.fromJson(Map<String, dynamic> json) {
    var list = json['itemRankList'] as List;
    List<ItemRank> itemList = list.map((i) => ItemRank.fromJson(i)).toList();

    return DOItemsAnalysisRankLast30Days(
      totalQuantity: json['totalQuantity'],
      itemRankList: itemList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalQuantity': totalQuantity,
      'itemRankList': itemRankList.map((item) => item.toJson()).toList(),
    };
  }
}

class ItemRank {
  final String itemName;
  final int quantity;
  final int rate;

  ItemRank({
    required this.itemName,
    required this.quantity,
    required this.rate,
  });

  factory ItemRank.fromJson(Map<String, dynamic> json) {
    return ItemRank(
      itemName: json['itemName'],
      quantity: json['quantity'],
      rate: json['rate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'quantity': quantity,
      'rate': rate,
    };
  }
}