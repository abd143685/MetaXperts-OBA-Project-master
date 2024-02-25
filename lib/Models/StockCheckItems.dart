class StockCheckItemsModel {
  dynamic? id;
  dynamic? shopvisitId;
  String? itemDesc;
  dynamic? qty;

  StockCheckItemsModel({
    this.id,
    this.shopvisitId,
    this.itemDesc,
    this.qty,

  });

  factory StockCheckItemsModel.fromMap(Map<dynamic, dynamic> json) {
    return StockCheckItemsModel(
      id: json['id'],
      shopvisitId: json['shopvisitId'],
      itemDesc: json['itemDesc'],
      qty: json['qty'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shopvisitId':shopvisitId,
      'itemDesc': itemDesc,
      'qty': qty,
    };
  }
}