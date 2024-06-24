
class DOItemsAnalysisRank {
  final int totalQuantity;
  final int totalAmount;
  final List<ItemRank> itemRankList;

  DOItemsAnalysisRank({
    required this.totalQuantity,
    required this.totalAmount,
    required this.itemRankList,
  });

  factory DOItemsAnalysisRank.fromJson(Map<String, dynamic> json) {
    var list = json['itemRankList'] as List;
    List<ItemRank> itemList = list.map((i) => ItemRank.fromJson(i)).toList();

    return DOItemsAnalysisRank(
      totalQuantity: json['totalQuantity'],
      totalAmount: json['totalAmount'],
      itemRankList: itemList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalQuantity': totalQuantity,
      'totalAmount': totalAmount,
      'itemRankList': itemRankList.map((item) => item.toJson()).toList(),
    };
  }
}

class ItemRank {
  final int itemId;
  final String itemName;
  final int quantity;
  final int amount;

  ItemRank({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.amount,
  });

  factory ItemRank.fromJson(Map<String, dynamic> json) {
    return ItemRank(
      itemId: json['itemId'],
      itemName: json['itemName'],
      quantity: json['quantity'],
      amount: json['amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'quantity': quantity,
      'amount': amount,
    };
  }
}
