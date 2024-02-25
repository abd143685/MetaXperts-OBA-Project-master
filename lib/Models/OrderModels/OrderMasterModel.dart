
import 'package:order_booking_shop/Models/ProductsModel.dart';

class OrderMasterModel {

  dynamic? orderId;
  String? date;
  String? shopName;
  String? ownerName;
  String? phoneNo;
  String? brand;
  dynamic? userId;
  dynamic? userName;
  dynamic? total;
  dynamic? creditLimit;
  // dynamic? discount;
  // dynamic? subTotal;
  dynamic? payment;
  dynamic? balance;
  dynamic? requiredDelivery;

  OrderMasterModel({

    this.orderId,
    this.date,
    this.shopName,
    this.ownerName,
    this.phoneNo,
    this.brand,
    this.userId,
    this.userName,

    this.creditLimit,
    // this.discount,

    this.requiredDelivery,
    // this.subTotal,
    this.total
  });

  factory OrderMasterModel.fromMap(Map<dynamic, dynamic> json) {
    return OrderMasterModel(

      orderId: json['orderId'],
      date: json['date'],
      shopName: json['shopName'],
      ownerName: json['ownerName'],
      phoneNo: json['phoneNo'],
      brand: json['brand'],
      userId: json['userId'],
        userName: json['userName'],

      total: json['total'],
      // subTotal: json['subTotal'],
      //
      // discount: json['discount'],
      creditLimit: json['creditLimit'],
      requiredDelivery: json['requiredDelivery']
    );
  }

  Map<String, dynamic> toMap() {
    return {

      'orderId': orderId,
      'date': date,
      'shopName': shopName,
      'ownerName': ownerName,
      'phoneNo': phoneNo,
      'brand': brand,
      'userId': userId,
      'userName': userName,
      'total': total,
      'creditLimit': creditLimit,
      // 'discount': discount,
      //
      // 'subTotal': subTotal,

      'requiredDelivery': requiredDelivery
    };
  }
}
//
//   Map<String, dynamic> toNewMap() {
//     return {
//       'shopName': shopName,
//       'ownerName': ownerName,
//       'phoneNo': phoneNo,
//       'brand': brand,
//     };
//   }
// }
//import 'package:order_booking_shop/Models/ProductsModel.dart';

class GetOrderMasterModel {

  dynamic? orderId;

  String? shop_name;
  dynamic? userId;


  GetOrderMasterModel({

    this.orderId,

    this.shop_name,

    this.userId,

  });

  factory GetOrderMasterModel.fromMap(Map<dynamic, dynamic> json) {
    return GetOrderMasterModel(

      orderId: json['orderId'],
      shop_name: json['shop_name'],
      userId: json['userId'],

    );
  }

  Map<String, dynamic> toMap() {
    return {

      'orderId': orderId,
      'shop_name': shop_name,
      'userId': userId,
    };
  }
}
//
//   Map<String, dynamic> toNewMap() {
//     return {
//       'shopName': shopName,
//       'ownerName': ownerName,
//       'phoneNo': phoneNo,
//       'brand': brand,
//     };
//   }
// }