
import 'package:order_booking_shop/API/Globals.dart';
import 'package:order_booking_shop/Models/OrderModels/OrderMasterModel.dart';

import '../../Databases/DBHelper.dart';
import '../../Models/OrderModels/OrderDetailsModel.dart';
import '../../Views/ReturnFormPage.dart';

class OrderDetailsRepository {

  DBHelper dbHelperOrderDetails = DBHelper();

  Future<List<OrderDetailsModel>> getOrderDetails() async {
    var dbClient = await dbHelperOrderDetails.db;
    List<Map> maps = await dbClient!.query('order_details', columns: ['id','order_master_id', 'productName', 'quantity', 'price', 'amount','posted']);
    List<OrderDetailsModel> orderdetails = [];
    for (int i = 0; i < maps.length; i++) {

      orderdetails.add(OrderDetailsModel.fromMap(maps[i]));
    }
    return orderdetails;
  }

  Future<int> add(OrderDetailsModel orderdetailsModel) async {
    var dbClient = await dbHelperOrderDetails.db;
    return await dbClient!.insert('order_details', orderdetailsModel.toMap());
  }

  Future<int> update(OrderDetailsModel orderdetailsModel) async {
    var dbClient = await dbHelperOrderDetails.db;
    return await dbClient!.update('order_details', orderdetailsModel.toMap(),
        where: 'id = ?', whereArgs: [orderdetailsModel.id]);
  }

  Future<int> delete(int id) async {
    var dbClient = await dbHelperOrderDetails.db;
    return await dbClient!.delete('order_details',
        where: 'id = ?', whereArgs: [id]);
  }

  Future<List<GetOrderDetailsModel>> getOrderDetailsProductNamesByOrder(String order_no) async {
    var dbClient = await dbHelperOrderDetails.db;
    List<Map> maps = await dbClient!.query(
      'orderDetailsData',
      columns: ['order_no', 'product_name'],
      where: 'order_no = ?',
      whereArgs: [selectedorderno],
    );
    List<GetOrderDetailsModel> products = [];
    for (int i = 0; i < maps.length; i++) {
      products.add(GetOrderDetailsModel.fromMap(maps[i]));
    }
    return products;
  }
}