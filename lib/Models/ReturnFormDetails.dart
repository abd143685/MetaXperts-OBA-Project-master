class ReturnFormDetailsModel {
  dynamic? id;
  dynamic? returnformId;
  String? productName;
 dynamic? bookerId;

  dynamic? reason;
  dynamic? quantity;
  ReturnFormDetailsModel({
    this.id,
    this.returnformId,
    this.productName,
    this.bookerId,
    this.reason,
    this.quantity,

  });

  factory ReturnFormDetailsModel.fromMap(Map<dynamic, dynamic> json) {
    return ReturnFormDetailsModel(
      id: json['id'],
      returnformId: json['returnformId'],
      productName: json['productName'],
      bookerId: json['bookerId'],
      reason: json['reason'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'returnformId':returnformId,
      'productName': productName,
      'bookerId':bookerId,
      'reason': reason,
      'quantity': quantity,
    };
  }
}