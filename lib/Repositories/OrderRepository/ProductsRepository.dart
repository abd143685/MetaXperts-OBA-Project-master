
import 'package:order_booking_shop/API/Globals.dart';

import '../../Databases/DBHelper.dart';
import '../../Models/ProductsModel.dart';

class ProductsRepository {

  DBHelper dbHelperProducts = DBHelper();

  Future<List<ProductsModel>> getProductsModel() async {
    var dbClient = await dbHelperProducts.db;
    List<Map> maps = await dbClient!.query('products', columns: [
      'product_code',
      'product_name',
      'uom',
      'price',
      'brand',
      'quantity'
    ]);
    List<ProductsModel> products = [];
    for (int i = 0; i < maps.length; i++) {
      products.add(ProductsModel.fromMap(maps[i]));
    }
    return products;
  }
  Future<int> add(ProductsModel productsModel) async {
    var dbClient = await dbHelperProducts.db;
    return await dbClient!.insert('products', productsModel.toMap());
  }

  Future<List<ProductsModel>> getProductsByBrand(String brand) async {
    var dbClient = await dbHelperProducts.db;
    List<Map> maps = await dbClient!.query(
      'products',
      columns: [
        'product_code',
        'product_name',
        'uom',
        'price',
        'brand',
        'quantity'
      ],
      where: 'brand = ?',
      whereArgs: [globalselectedbrand],
    );
    List<ProductsModel> products = [];
    for (int i = 0; i < maps.length; i++) {
      products.add(ProductsModel.fromMap(maps[i]));
    }
    return products;
  }



  Future<int> update(ProductsModel productsModel) async {
    var dbClient = await dbHelperProducts.db;
    return await dbClient!.update('products', productsModel.toMap(),
       where: 'product_code = ?', whereArgs: [productsModel.product_code]);
  }

  Future<int> delete(int product_code) async {
    var dbClient = await dbHelperProducts.db;
    return await dbClient!.delete('products',
        where: 'product_code = ?', whereArgs: [product_code]);
  }


}

