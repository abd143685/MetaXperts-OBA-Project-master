
import 'package:order_booking_shop/Models/ProductsModel.dart';

class ReturnFormModel {

  dynamic? returnId;
  String? date;
  String? shopName;
  dynamic? returnAmount;
  dynamic? bookerId;
  dynamic? bookerName;

  ReturnFormModel({

    this.returnId,
    this.date,
    this.shopName,
    this.returnAmount,
    this.bookerId,
    this.bookerName

  });

  factory ReturnFormModel.fromMap(Map<dynamic, dynamic> json) {
    return ReturnFormModel(

      returnId: json['returnId'],
        date: json['date'],
        shopName: json['shopName'],
      returnAmount: json['returnAmount'],
      bookerId: json['bookerId'],
      bookerName: json['bookerName']
    );
  }

  Map<String, dynamic> toMap() {
    return {

      'returnId': returnId,
      'date': date,
      'shopName': shopName,
      'returnAmount':returnAmount,
      'bookerId':bookerId,
      'bookerName': bookerName

    };
  }
}
