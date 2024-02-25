import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

class ShopVisitModel {
  dynamic? id;
  String? date;
  String? userId;
  String? shopName;
  String? bookerName;
  String? brand;
  dynamic? walkthrough;
  dynamic? planogram;
  dynamic? signage;
  dynamic? productReviewed;
  Uint8List? body;
  String? feedback;
  dynamic? latitude;
  dynamic? longitude;
  dynamic? address;

  ShopVisitModel({

    this.id,
    this.date,
    this.shopName,
    this.userId,
    this.bookerName,
    this.brand,
    this.walkthrough,
    this.planogram,
    this.signage,
    this.productReviewed,
    this.body,
    this.feedback,
    this.longitude,
    this.latitude,
    this.address
  });

  factory ShopVisitModel.fromMap(Map<dynamic, dynamic> json) {
    return ShopVisitModel(
        id: json['id'],
        date: json['date'],
        shopName: json['shopName'],
        userId: json['userId'],
        bookerName: json['bookerName'],
        brand: json['brand'],
        walkthrough: json['walkthrough'] == 1 || json['walkthrough'] == 'true' || json['walkthrough'] == true,
        planogram: json['planogram'] == 1 || json['planogram'] == 'true' || json['planogram'] == true,
        signage: json['signage'] == 1 || json['signage'] == 'true' || json['signage'] == true,
        productReviewed: json['productReviewed'] == 1 || json['productReviewed'] == 'true' || json['productReviewed'] == true,
        body: json['body'] != null && json['body'].toString().isNotEmpty
            ? Uint8List.fromList(base64Decode(json['body'].toString()))
            : null,
        feedback: json['feedback'],
      longitude: json['longitude'],
      latitude: json['latitude'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toMap() {
    return {

    'id': id,
    'date': date,
      'userId': userId,
    'shopName': shopName,
    'bookerName': bookerName,
    'brand': brand,
    'walkthrough': walkthrough,
    'planogram': planogram,
    'signage': signage,
    'productReviewed': productReviewed,
    'body':  body != null ? base64Encode(body!) : null, 'feedback': feedback,
      'latitude':latitude,
      'longitude': longitude,
      'address': address
     };
    }
}