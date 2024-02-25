import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:order_booking_shop/API/Globals.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io' as io;
import 'dart:async';
import '../API/ApiServices.dart';
import '../Models/AttendanceModel.dart';
import '../Models/OrderModels/OrderDetailsModel.dart';
import '../Models/OrderModels/OrderMasterModel.dart';
import '../Models/RecoveryFormModel.dart';
import '../Models/ReturnFormDetails.dart';
import '../Models/ReturnFormModel.dart';
import '../Models/ShopModel.dart';
import '../Models/ShopVisitModels.dart';
import '../Models/StockCheckItems.dart';
import '../Models/loginModel.dart';

class DBHelper {
  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDatabase();
    return _db!;
  }


  Future<Database> initDatabase() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'shop.db');
    var db = await openDatabase(path, version: 1, onCreate: _onCreate ,);
    return db;
  }
_onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE shop(id INTEGER PRIMARY KEY AUTOINCREMENT, shopName TEXT, city TEXT,date TEXT, shopAddress TEXT, ownerName TEXT, ownerCNIC TEXT, phoneNo TEXT, alternativePhoneNo INTEGER, latitude TEXT, longitude TEXT, userId TEXT,posted INTEGER DEFAULT 0)");
    await db.execute("CREATE TABLE orderMaster (orderId TEXT PRIMARY KEY, date TEXT, shopName TEXT, ownerName TEXT, phoneNo TEXT, brand TEXT, userName TEXT, userId TEXT, total INTEGER, creditLimit TEXT, requiredDelivery TEXT,posted INTEGER DEFAULT 0)");
    await db.execute("CREATE TABLE order_details(id INTEGER PRIMARY KEY AUTOINCREMENT,order_master_id TEXT,productName TEXT,quantity INTEGER,price INTEGER,amount INTEGER,posted INTEGER DEFAULT 0,FOREIGN KEY (order_master_id) REFERENCES orderMaster(orderId))");
    await db.execute("CREATE TABLE ownerData(id NUMBER,shop_name TEXT, owner_name TEXT, phone_no TEXT, city TEXT)");
    await db.execute("CREATE TABLE products(id NUMBER, product_code TEXT, product_name TEXT, uom TEXT ,price TEXT, brand TEXT, quantity TEXT)");
    await db.execute("CREATE TABLE orderMasterData(order_no TEXT, shop_name TEXT, user_id TEXT)");
    await db.execute("CREATE TABLE orderDetailsData(order_no TEXT, product_name TEXT, quantity_booked INTEGER, price INTEGER)");
    await db.execute("CREATE TABLE orderBookingStatusData(order_no TEXT, status TEXT, order_date TEXT, shop_name TEXT, amount TEXT, user_id TEXT)");
    await db.execute("CREATE TABLE netBalance(shop_name TEXT, debit TEXT,credit TEXT)");
    await db.execute("CREATE TABLE accounts(account_id INTEGER, shop_name TEXT, order_date TEXT, credit TEXT, booker_name TEXT)");
    await db.execute("CREATE TABLE productCategory(brand TEXT)");
    await db.execute("CREATE TABLE attendance(id INTEGER PRIMARY KEY , date TEXT, timeIn TEXT, userId TEXT, latIn TEXT, lngIn TEXT, bookerName TEXT)");
    await db.execute("CREATE TABLE attendanceOut(id INTEGER PRIMARY KEY , date TEXT, timeOut TEXT, totalTime TEXT, userId TEXT,latOut TEXT, lngOut TEXT,totalDistance TEXT, posted INTEGER DEFAULT 0)");
    await db.execute("CREATE TABLE recoveryForm (recoveryId TEXT, date TEXT, shopName TEXT, cashRecovery REAL, netBalance REAL, userId TEXT ,bookerName TEXT)");
    await db.execute("CREATE TABLE returnForm (returnId INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, shopName TEXT, returnAmount INTEGER, bookerId TEXT, bookerName TEXT)");
    await db.execute("CREATE TABLE return_form_details(id INTEGER PRIMARY KEY AUTOINCREMENT,returnFormId TEXT,productName TEXT,quantity TEXT,reason TEXT,bookerId TEXT,FOREIGN KEY (returnFormId) REFERENCES returnForm(returnId))");
    await db.execute("CREATE TABLE shopVisit (id TEXT PRIMARY KEY,date TEXT,shopName TEXT,userId TEXT,bookerName TEXT,brand TEXT,walkthrough TEXT,planogram TEXT,signage TEXT,productReviewed TEXT,feedback TEXT,latitude TEXT,longitude TEXT,address TEXT,body BLOB)");
    await db.execute("CREATE TABLE Stock_Check_Items(id INTEGER PRIMARY KEY AUTOINCREMENT,shopvisitId TEXT,itemDesc TEXT,qty TEXT,FOREIGN KEY (shopvisitId) REFERENCES shopVisit(id))");
    await db.execute("CREATE TABLE login(user_id TEXT, password TEXT ,user_name TEXT, city TEXT)");
}
  Future<void> insertShop(ShopModel shop) async {
    final Database db = await initDatabase();

    // Insert the shop into the 'shop' table
    await db.insert(
      'shop',
      shop.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Insert the relevant data into the 'ownerData' table
    await db.rawInsert(
      'INSERT INTO ownerData(id, shop_name, owner_name, phone_no, city) VALUES(?, ?, ?, ?, ?)',
      [shop.id, shop.shopName, shop.ownerName, shop.phoneNo, shop.city],
    );
  }

  Future<List<Map<String, dynamic>>?> getOrderMasterdataDB() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> ordermaster = await db.query('orderBookingStatusData');
      return ordermaster;
    } catch (e) {
      print("Error retrieving products: $e");
      return null;
    }
  }

  Future<bool> insertOrderDetailsData(List<dynamic> dataList) async {
    final Database db = await initDatabase();
    try {
      for (var data in dataList) {
        await db.insert('orderDetailsData', data);
      }
      return true;
    } catch (e) {
      print("Error inserting orderDetailsGet data: ${e.toString()}");
      return false;
    }
  }

  Future<ShopModel?> getShopData(int id) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient!.query(
      'shop',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ShopModel.fromMap(maps.first);
    } else {
      return null;
    }
  }
  Future<List<String>> getOrderDetailsProductNames() async {
    final Database db = await initDatabase();
    try {
      // Retrieve product names where order_no matches the global variable
      final List<Map<String, dynamic>> productNames = await db.query(
        'orderDetailsData',
        where: 'order_no = ?',
        whereArgs: [selectedorderno],
      );
      return productNames.map((map) => map['product_name'] as String).toList();
    } catch (e) {
      print("Error retrieving Products names: $e");
      return [];
    }
  }

  Future<String?> fetchQuantityForProduct(String productName) async {
    try {
      final Database db = await initDatabase();
      final List<Map<String, dynamic>> result = await db.query(
        'orderDetailsData',
        columns: ['quantity_booked'],
        where: 'product_name = ?',
        whereArgs: [productName],
      );

      if (result.isNotEmpty) {
        return result[0]['quantity_booked'].toString();
      } else {
        return null; // Handle the case where quantity is not found
      }
    } catch (e) {
      print("Error fetching quantity for product: $e");
      return null;
    }
  }


  Future<String?> fetchPriceForProduct(String productName) async {
    try {
      final Database db = await initDatabase();
      final List<Map<String, dynamic>> result = await db.query(
        'orderDetailsData',
        columns: ['price'],
        where: 'product_name = ?',
        whereArgs: [productName],
      );

      if (result.isNotEmpty) {
        return result[0]['price'].toString();
      } else {
        return null; // Handle the case where quantity is not found
      }
    } catch (e) {
      print("Error fetching price for product: $e");
      return null;
    }
  }


  Future<List<String>> getOrderMasterOrderNo() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> orderNo = await db.query('orderBookingStatusData', where: 'user_id = ?', whereArgs: [userId]);
      return orderNo.map((map) => map['order_no'] as String).toList();
    } catch (e) {
      print("Error retrieving order no: $e");
      return [];
    }
  }
  Future<List<String>> getOrderMasterShopNames() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> shopNames = await db.query('orderBookingStatusData', where: 'user_id = ? AND status = ?',
        whereArgs: [userId, "DISPATCHED"],
      );
      return shopNames.map((map) => map['shop_name'] as String).toList();
    } catch (e) {
      print("Error retrieving shop names: $e");
      return [];
    }
  }
  Future<List<String>> getOrderMasterShopNames2() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> shopNames = await db.query('orderBookingStatusData', where: 'user_id = ?',
        whereArgs: [userId],
      );
      return shopNames.map((map) => map['shop_name'] as String).toList();
    } catch (e) {
      print("Error retrieving shop names: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>?> getShopDB() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> products = await db.query('shop');
      return products;
    } catch (e) {
      print("Error retrieving products: $e");
      return null;
    }
  }
  Future<void> postShopTable() async {
    final Database db = await initDatabase();
    final ApiServices api = ApiServices();

    try {
      final List<Map<String, dynamic>> records = await db.query('shop');

      // Print each record
      for (var record in records) {
        print(record.toString());
      }
      // Select only the records that have not been posted yet
      final products = await db.rawQuery('SELECT * FROM shop WHERE posted = 0');
      if (products.isNotEmpty) {  // Check if the table is not empty
        for (var i in products) {
          print("FIRST ${i.toString()}");


        ShopModel v = ShopModel(
            id: "${i['id']}",
            shopName: i['shopName'].toString(),
            city: i['city'].toString(),
            date: i['date'].toString(),
            shopAddress: i['shopAddress'].toString(),
            ownerName: i['ownerName'].toString(),
            ownerCNIC: i['ownerCNIC'].toString(),
            phoneNo: i['phoneNo'].toString(),
            alternativePhoneNo: i['alternativePhoneNo'].toString(),
            latitude: i['latitude'].toString(),
             longitude: i['longitude'].toString(),
             userId: i['userId'].toString()

        );

        var result = await api.masterPost(
          v.toMap(),
          'https://g77e7c85ff59092-db17lrv.adb.ap-singapore-1.oraclecloudapps.com/ords/metaxperts/addshop/post/',
        );

        if (result == true) {
         // await db.rawQuery("UPDATE attendanceOut SET posted = 1 WHERE id = '${i['id']}'");

          await db.rawUpdate("UPDATE shop SET posted = 1 WHERE id = ?", [i['id']]);
        }
      }
    }
    }catch (e) {
      print("ErrorRRRRRRRRR: $e");
      return null;
    }
  }
  Future<bool> entershopdata(String shopName) async {
    final Database db = await initDatabase();
    try {
      await db.rawInsert("INSERT INTO shops (shopName) VALUES ('$shopName')");
      return true;
    } catch (e) {
      print("Error inserting product: $e");
      return false;
    }
  }
  Future<Object> getrow() async {
    final Database db = await initDatabase();
    try {
      var results = await db.rawQuery("SELECT * FROM shops");
      if (results.isNotEmpty) {
        return results;
      } else {
        print("No rows found in the 'shops' table.");
        return false;
      }
    } catch (e) {
      print("Error retrieving product: $e");
      return false;
    }
  }
  Future<bool> enterownerdata(ShopModel shopModel) async {
    final Database db = await initDatabase();
    try {
      await db.rawQuery("INSERT INTO  owner(owner_name,phone_no  VALUES ('${shopModel.ownerName.toString()}','${shopModel.phoneNo.toString()}'}') ");
      return true;
    } catch (e) {
      print("Error inserting product: $e");
      return false;
    }
    }

// Define a function to perform a migration if necessary.

  // Create a shop
  Future<int> createShop(ShopModel shop) async {
    final dbClient = await db;
    return dbClient!.insert('shop', shop.toMap());
  }

  // Read all shops
  Future<List<ShopModel>> getShop() async {
    final dbClient = await db;
    final List<Map<dynamic, dynamic>> maps = await dbClient!.query('shop');
    return List.generate(maps.length, (index) {
      return ShopModel.fromMap(maps[index]);
    });
  }

  //
  // // Update a shop
  // Future<int> updateShop(ShopModel shop) async {
  //   final dbClient = await db;
  //   return dbClient!.update('shop', shop.toMap(),
  //       where: 'id = ?', whereArgs: [shop.id]);
  // }

  // Delete a shop
  Future<int> deleteShop(int id) async {
    final dbClient = await db;
    return dbClient!.delete('shop', where: 'id = ?', whereArgs: [id]);
  }
  Future<void> addOrderDetails(List<OrderDetailsModel> orderDetailsList) async {
    final db = await _db;
    for (var orderDetails in orderDetailsList) {
      await db?.insert('order_details', orderDetails.toMap());
    }
  }

  Future<List<Map<String, dynamic>>> getOrderDetails() async {
    final db = await _db;
    try {
      if (db != null) {
        final List<Map<String, dynamic>> products = await db.rawQuery('SELECT * FROM order_details');
        return products;
      } else {
        // Handle the case where the database is null
        return [];
      }
    } catch (e) {
      // Let the calling code handle the error
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>?> getOrderMasterDB() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> products = await db.query('orderMaster');
      return products;
    } catch (e) {
      print("Error retrieving products: $e");
      return null;
    }
  }

  Future<void> postMasterTable() async {
    final Database db = await initDatabase();
    final ApiServices api = ApiServices();

    try {
      final List<Map<String, dynamic>> records = await db.query('orderMaster');

      // Print each record
      for (var record in records) {
        print(record.toString());
      }
      // Select only the records that have not been posted yet
      final products = await db.rawQuery('SELECT * FROM orderMaster WHERE posted = 0');
      if (products.isNotEmpty) {  // Check if the table is not empty
        for (var i in products) {
          print("FIRST ${i.toString()}");

        OrderMasterModel v = OrderMasterModel(
            orderId: i['orderId'].toString(),
            shopName: i['shopName'].toString(),
            ownerName: i['ownerName'].toString(),
            phoneNo: i['phoneNo'].toString(),
            brand: i['brand'].toString(),
            date: i['date'].toString(),
            userId: i['userId'].toString(),
            userName: i['userName'].toString(),

            total: i['total'].toString(),
            // subTotal: i['subTotal'].toString(),
            //
            // discount: i['discount'].toString(),
            creditLimit: i['creditLimit'].toString(),
            requiredDelivery: i['requiredDelivery'].toString()
        );

        var result = await api.masterPost(
          v.toMap(),
          'https://g77e7c85ff59092-db17lrv.adb.ap-singapore-1.oraclecloudapps.com/ords/metaxperts/ordermaster/post/',
        );

        if (result == true) {
          await db.rawQuery("UPDATE orderMaster SET posted = 1 WHERE orderId = '${i['orderId']}'");

        }
      }
    } }catch (e) {
      print("ErrorRRRRRRRRR: $e");
      return null;
    }
  }

  Future<void> postOrderDetails() async {
    final Database db = await initDatabase();
    final ApiServices api = ApiServices();
    try {

      final List<Map<String, dynamic>> records = await db.query('order_details');

      // Print each record
      for (var record in records) {
        print(record.toString());
      }
      // Select only the records that have not been posted yet
      final products = await db.rawQuery('SELECT * FROM order_details WHERE posted = 0');
      if (products.isNotEmpty) {  // Check if the table is not empty
        for (var i in products) {
          print("FIRST ${i.toString()}");

        OrderDetailsModel v = OrderDetailsModel(
            id: i['id'].toString(),
            orderMasterId: i['order_master_id'].toString(),
            productName: i['productName'].toString(),
            price: i['price'].toString(),
            quantity: i['quantity'].toString(),
            amount: i['amount'].toString()
        );
        var result = await api.masterPost(v.toMap(), 'https://g77e7c85ff59092-db17lrv.adb.ap-singapore-1.oraclecloudapps.com/ords/metaxperts/orderdetail/post/');
        if(result == true){
          await db.rawQuery("UPDATE order_details SET posted = 1 WHERE id = '${i['id']}'");
        }
      }}

    } catch (e) {
      print("ErrorRRRRRRRRR: $e");
      return null;
    }
  }

  Future<List<String>> getShopNames() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> shopNames = await db.query('ownerData');
      return shopNames.map((map) => map['shop_name'] as String).toList();
    } catch (e) {
      print("Error retrieving shop names: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>?> getOwnersDB() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> owner = await db.query('ownerData');
      return owner;
    } catch (e) {
      print("Error retrieving products: $e");
      return null;
    }
  }

  Future<List<String>> getShopNamesForCity(String userCity) async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> shopNames = await db.query(
        'ownerData',
        where: 'city = ?',
        whereArgs: [userCitys],
      );
      return shopNames.map((map) => map['shop_name'] as String).toList();
    } catch (e) {
      print("Error retrieving shop names for city: $e");
      return [];
    }
  }



  Future<bool> insertOwnerData(List<dynamic> dataList) async {
    final Database db = await initDatabase();
    try {
      for (var data in dataList) {
        await db.insert('ownerData', data);
      }
      return true;
    } catch (e) {
      print("Error inserting owner  data: ${e.toString()}");
      return false;
    }
  }

  Future<void> deleteAllRecords() async{
    final db = await initDatabase();
    await db.delete('ownerData');
    await db.delete('products');
    await db.delete('orderMasterData');
    await db.delete('orderDetailsData');
    await db.delete('orderBookingStatusData');
    await db.delete('netBalance');
    await db.delete('accounts');
    await db.delete('productCategory');
    await db.delete('login');
  }

  Future<bool> insertProductsData(List<dynamic> dataList) async {
    final Database db = await initDatabase();
    try {
      for (var data in dataList) {
        await db.insert('products', data);
      }
      return true;
    } catch (e) {
      print("Error inserting product data: ${e.toString()}");
      return false;
    }
  }
  Future<List<String>> getBrandItems() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> result = await db.query('products');
      return result.map((data) => data['brand'] as String).toList();
    } catch (e) {
      print("Error fetching brand items: $e");
      return [];
    }
  }

  Future<Iterable> getProductsNames() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>>? productNames= await db.query('products');
      return productNames!.map((map) => map['product_name'].toList());
    } catch (e) {
      print("Error retrieving products: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>?> getProductsDB() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> products = await db.query('products');
      return products;
    } catch (e) {
      print("Error retrieving products: $e");
      return null;
    }
  }

  Future<List<String>> getProductsNamesByBrand(String selectedBrand) async {
    final Database db = await initDatabase();

    try {
      final List<Map<String, dynamic>> productNames = await db.query(
        'products',
        where: 'brand = ?',
        whereArgs: [globalselectedbrand],
      );

      return productNames.map((map) => map['product_name'] as String).toList();
    } catch (e) {
      print("Error fetching product names for brand: $e");
      return [];
    }
  }




  Future<bool> insertAccoutsData(List<dynamic> dataList) async {
    final Database db = await initDatabase();
    try {
      for (var data in dataList) {
        await db.insert('accounts', data);
      }
      return true;
    } catch (e) {
      print("Error inserting Accounts: ${e.toString()}");
      return false;
    }
  }


  Future<bool> insertNetBalanceData(List<dynamic> dataList) async {
    final Database db = await initDatabase();
    try {
      for (var data in dataList) {
        await db.insert('netBalance', data);
      }
      return true;
    } catch (e) {
      print("Error inserting netBalanceData: ${e.toString()}");
      return false;
    }
  }



  Future<bool> insertOrderBookingStatusData(List<dynamic> dataList) async {
    final Database db = await initDatabase();
    try {
      for (var data in dataList) {
        await db.insert('orderBookingStatusData', data);
      }
      return true;
    } catch (e) {
      print("Error inserting orderBookingStatusData: ${e.toString()}");
      return false;
    }
  }


  Future<List<String>?> getShopNamesFromNetBalance() async {
    try {
      final List<Map<String, dynamic>>? netBalanceData = await getNetBalanceDB();
      return netBalanceData?.map((map) => map['shop_name'] as String).toList();
    } catch (e) {
      print("Error retrieving shop names from netBalance: $e");
      return [];
    }
  }
  Future<Map<String, dynamic>> getDebitsAndCreditsTotal() async {
    try {
      final List<Map<String, dynamic>>? netBalanceData = await getNetBalanceDB();
      Map<String, double> shopDebits = {};
      Map<String, double> shopCredits = {};

      for (var row in netBalanceData!) {
        String shopName = row['shop_name'];
        double debit = double.parse(row['debit'] ?? '0');
        double credit = double.parse(row['credit'] ?? '0');

        shopDebits[shopName] = (shopDebits[shopName] ?? 0) + debit;
        shopCredits[shopName] = (shopCredits[shopName] ?? 0) + credit;
      }

      return {'debits': shopDebits, 'credits': shopCredits};
    } catch (e) {
      print("Error calculating debits and credits total: $e");
      return {'debits': {}, 'credits': {}};
    }
  }

  Future<Map<String, double>> getDebitsMinusCreditsPerShop() async {
    try {
      final List<Map<String, dynamic>>? netBalanceData = await getNetBalanceDB();
      Map<String, double> shopDebitsMinusCredits = {};

      for (var row in netBalanceData!) {
        String shopName = row['shop_name'];
        double debit = double.parse(row['debit'] ?? '0');
        double credit = double.parse(row['credit'] ?? '0');

        double debitsMinusCredits = debit - credit;

        shopDebitsMinusCredits[shopName] = (shopDebitsMinusCredits[shopName] ?? 0) + debitsMinusCredits;
      }

      return shopDebitsMinusCredits;
    } catch (e) {
      print("Error calculating debits minus credits per shop: $e");
      return {};
    }
  }

  Future<bool> insertOrderMasterData(List<dynamic> dataList) async {
    final Database db = await initDatabase();
    try {
      for (var data in dataList) {
        await db.insert('orderMasterData', data);
      }
      return true;
    } catch (e) {
      print("Error inserting orderMaster data: ${e.toString()}");
      return false;
    }
  }


  Future<List<Map<String, dynamic>>?> getNetBalanceDB() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> netbalance = await db.query('netBalance');
      return  netbalance;
    } catch (e) {
      print("Error retrieving products: $e");
      return null;
    }
  }


  Future<List<Map<String, dynamic>>?> getAccoutsDB() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> account = await db.query('accounts');
      return  account;
    } catch (e) {
      print("Error retrieving accounts: $e");
      return null;
    }
  }


  Future<List<Map<String, dynamic>>?> getOrderBookingStatusDB() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> orderbookingstatus = await db.query('orderBookingStatusData', where: 'user_id = ?', whereArgs: [userId]);
      return  orderbookingstatus;
    } catch (e) {
      print("Error retrieving products: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getOrderMasterDataDB() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> ordermaster = await db.query('orderMasterData');
      return ordermaster;

    } catch (e) {
      print("Error retrieving products: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getOrderDetailsDB() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> orderdetails = await db.query('orderDetailsData');
      return orderdetails;
    } catch (e) {
      print("Error retrieving orderDetailsGet: $e");
      return null;
    }
  }


  Future<void> postAttendanceTable() async {
    final Database db = await initDatabase();
    final ApiServices api = ApiServices();

    try {
      final products = await db.rawQuery('select * from attendance');

      if (products.isNotEmpty || products != null) {  // Check if the table is not empty
        for (var i in products) {
          print("FIRST ${i.toString()}");

          AttendanceModel v = AttendanceModel(
            id: i['id'].toString(),
            date: i['date'].toString(),
            userId: i['userId'].toString(),
            timeIn: i['timeIn'].toString(),
            latIn: i['latIn'].toString(),
            lngIn: i['lngIn'].toString(),
            bookerName: i['bookerName'].toString(),
          );

          var result = await api.masterPost(
            v.toMap(),
            'https://g77e7c85ff59092-db17lrv.adb.ap-singapore-1.oraclecloudapps.com/ords/metaxperts/attendance/post/',
          );
          print("API Call");

          if (result == true) {
            await db.rawDelete("DELETE FROM attendance WHERE id = ?", [i['id']]);
          }
        }
      }

    else
      {
        print("null data");
      }
    }
    catch (e) {
      print("ErrorRRRRRRRRR: $e");
      // Handle the error if needed
    }
  }

  Future<void> postAttendanceOutTable() async {
    final Database db = await initDatabase();
    final ApiServices api = ApiServices();
    try {
      final products = await db.rawQuery('select * from attendanceOut');

      if (products.isNotEmpty || products != null) {  // Check if the table is not empty
        for (var i in products) {
          print("FIRST ${i.toString()}");

          AttendanceOutModel v = AttendanceOutModel(
            id: i['id'].toString(),
            date: i['date'].toString(),
            userId: i['userId'].toString(),
            timeOut: i['timeOut'].toString(),
            totalTime: i['totalTime'].toString(),
            latOut: i['latOut'].toString(),
            lngOut: i['lngOut'].toString(),
            totalDistance: i['totalDistance'].toString()
          );
          var result = await api.masterPost(
            v.toMap(),
            'https://g77e7c85ff59092-db17lrv.adb.ap-singapore-1.oraclecloudapps.com/ords/metaxperts/attendanceout/post/',
          );

          if (result == true) {
            print('successfully post');
            await db.rawDelete("DELETE FROM attendanceOut WHERE id = ?", [i['id']]);
          }
        }
      }
    } catch (e) {
      print("ErrorRRRRRRRRR: $e");
      return null;
    }
  }


  Future<bool> insertProductCategory(List<dynamic> dataList) async {
    final Database db = await initDatabase();
    try {
      for (var data in dataList) {
        await db.insert('productCategory', data);
      }
      return true;
    } catch (e) {
      print("Error inserting product category data: ${e.toString()}");
      return false;
    }
  }


  // Future<List<String>> getBrandItems() async {
  //   final Database db = await initDatabase();
  //   try {
  //     final List<Map<String, dynamic>> result = await db.query('productCategory');
  //     return result.map((data) => data['product_brand'] as String).toList();
  //   } catch (e) {
  //     print("Error fetching brand items: $e");
  //     return [];
  //   }
  // }



  Future<List<Map<String, dynamic>>?> getAllPCs() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> PCs = await db.query('productCategory');
      return PCs;
    } catch (e) {
      print("Error retrieving products: $e");
      return null;
    }
  }
  Future<List<Map<String, dynamic>>?> getAllAttendance() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> PCs = await db.query('attendance');
      return PCs;
    } catch (e) {
      print("Error retrieving products: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getAllAttendanceOut() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> PCs = await db.query('attendanceOut');
      return PCs;
    } catch (e) {
      print("Error retrieving products: $e");
      return null;
    }
  }
  Future<List<Map<String, dynamic>>?> getRecoveryFormDB() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> products = await db.query('recoveryForm');
      return products;
    } catch (e) {
      print("Error retrieving products: $e");
      return null;
    }
  }

  Future<void> postRecoveryFormTable() async {
    final Database db = await initDatabase();
    final ApiServices api = ApiServices();

    try {
      final products = await db.rawQuery('select * from recoveryForm');
      var count = 0;
      if (products.isNotEmpty || products != null)  { // Check if the table is not empty

        for (var i in products) {
          print("FIRST ${i.toString()}");

          RecoveryFormModel v = RecoveryFormModel(
              recoveryId: i['recoveryId'].toString(),
              shopName: i['shopName'].toString(),
              date: i['date'].toString(),
              cashRecovery: i['cashRecovery'].toString(),
              netBalance: i['netBalance'].toString(),
              userId: i['userId'].toString(),
              bookerName: i['bookerName'].toString()


          );

          var result = await api.masterPost(
            v.toMap(),
            'https://g77e7c85ff59092-db17lrv.adb.ap-singapore-1.oraclecloudapps.com/ords/metaxperts/recoveryform/post/',
          );

          if (result == true) {
            db.rawQuery(
                "DELETE FROM recoveryForm WHERE recoveryId = '${i['recoveryId']}'");
          }
        }
      }
    }catch (e) {
      print("ErrorRRRRRRRRR: $e");
      return null;
    }
  }
  Future<List<Map<String, dynamic>>> getReturnFormDetailsDB() async {
    final db = await _db;
    try {
      if (db != null) {
        final List<Map<String, dynamic>> products = await db.rawQuery('SELECT * FROM return_form_details');
        return products;
      } else {
        // Handle the case where the database is null
        return [];
      }
    } catch (e) {
      // Let the calling code handle the error
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>?> getReturnFormDB() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> products = await db.query('returnForm');
      return products;
    } catch (e) {
      print("Error retrieving products: $e");
      return null;
    }
  }

  Future<void> postReturnFormTable() async {
    final Database db = await initDatabase();
    final ApiServices api = ApiServices();

    try {
      final products = await db.rawQuery('select * from returnForm');
      var count = 0;
      if (products.isNotEmpty || products != null)  {  // Check if the table is not empty

      for (var i in products) {
        print("FIRST ${i.toString()}");

        ReturnFormModel v =  ReturnFormModel(
          returnId: i['returnId'].toString(),
          shopName: i['shopName'].toString(),
          date: i['date'].toString(),
          returnAmount: i['returnAmount'].toString(),
          bookerId: i['bookerId'].toString(),
          bookerName: i['bookerName'].toString()
        );

        var result = await api.masterPost(
          v.toMap(),
          'https://g77e7c85ff59092-db17lrv.adb.ap-singapore-1.oraclecloudapps.com/ords/metaxperts/returnform/post/',
        );

        if (result == true) {
          db.rawQuery("DELETE FROM returnForm WHERE returnId = '${i['returnId']}'");

        }
      }
    }} catch (e) {
      print("ErrorRRRRRRRRR: $e");
      return null;
    }
  }

  Future<void> postReturnFormDetails() async {
    final Database db = await initDatabase();
    final ApiServices api = ApiServices();
    try {
      final products = await db.rawQuery('select * from return_form_details');
      var count = 0;
      if (products.isNotEmpty || products != null)  {  // Check if the table is not empty

        for(var i in products){
        print(i.toString());
        count++;
        ReturnFormDetailsModel v =ReturnFormDetailsModel(
          id: "${i['id']}".toString(),
          returnformId: i['returnFormId'].toString(),
          productName: i['productName'].toString(),
          reason: i['reason'].toString(),
          quantity: i['quantity'].toString(),
          bookerId: i['bookerId'].toString()
        );
        var result = await api.masterPost(v.toMap(), 'https://g77e7c85ff59092-db17lrv.adb.ap-singapore-1.oraclecloudapps.com/ords/metaxperts/returnformdetail/post');
        if(result == true){
          db.rawQuery('DELETE FROM return_form_details WHERE id = ${i['id']}');
        }
      }
    }} catch (e) {
      print("ErrorRRRRRRRRR: $e");
      return null;
    }
  }

  Future<void> addStockCheckItems(List<StockCheckItemsModel> stockCheckItemsList) async {
    final db = await _db;
    for (var stockCheckItems in stockCheckItemsList) {
      await db?.insert('Stock_Check_Items',stockCheckItems.toMap());
    }
  }

  Future<List<Map<String, dynamic>>?> getShopVisitDB() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> shopVisit = await db.query('shopVisit');
      return shopVisit;
    } catch (e) {
      print("Error retrieving shopVisit: $e");
      return null;
    }
  }
  Future<List<Map<String, dynamic>>> getShopVisit({int limit = 0, int offset = 0}) async {
    final db = await _db;
    try {
      if (db != null) {
        String query = 'SELECT id, date, shopName, userId, bookerName, brand, walkthrough, planogram, signage, productReviewed, feedback, latitude, longitude, address, body FROM shopVisit';

        // Add LIMIT and OFFSET only if specified
        if (limit > 0) {
          query += ' LIMIT $limit';
        }
        if (offset > 0) {
          query += ' OFFSET $offset';
        }

        final List<Map<String, dynamic>> products = await db.rawQuery(query);

        // Fetch the body data separately
        // for (Map<String, dynamic> product in products) {
        //   final Uint8List body = await fetchBodyData(product['id']);
        //   product['body'] = body;
        // }

        return products;
      } else {
        // Handle the case where the database is null
        return [];
      }
    } catch (e) {
      // Let the calling code handle the error
      rethrow;
    }
  }

  // Future<Uint8List> fetchBodyData(String id) async {
  //   final db = await _db;
  //   try {
  //     if (db != null) {
  //       final List<Map<String, dynamic>> result = await db.query(
  //         'shopVisit',
  //         columns: ['body'],
  //         where: 'id = ?',
  //         whereArgs: [id],
  //       );
  //
  //       if (result.isNotEmpty) {
  //         return Uint8List.fromList(base64Decode(result[0]['body'].toString()));
  //       }
  //     }
  //
  //     // Handle the case where data is not found
  //     return Uint8List(0);
  //   } catch (e) {
  //     // Handle the error or rethrow it
  //     print('Error fetching body data: $e');
  //     rethrow;
  //   }
  // }

  Future<List<Map<String, dynamic>>> getStockCheckItems() async {
    final db = await _db;
    try {
      if (db != null) {
        final List<Map<String, dynamic>> products = await db.rawQuery('SELECT * FROM Stock_Check_Items');
        return products;
      } else {
        // Handle the case where the database is null
        return [];
      }
    } catch (e) {
      // Let the calling code handle the error
      rethrow;
    }
  }
  //
  // Future<void> addShopVisit(ShopVisitModel shopVisit) async {
  //   final db = await _db;
  //   try {
  //     await db?.insert(
  //       'shopVisit',
  //       shopVisit.toMap(),
  //       conflictAlgorithm: ConflictAlgorithm.replace,
  //     );
  //
  //     // Check if 'imagePath' is not null or empty
  //     if (shopVisit.imagePath != null && shopVisit.imagePath!.isNotEmpty) {
  //       // Read the image file and convert it to bytes
  //       File imageFile = File(shopVisit.imagePath! as String);
  //       List<int> imageBytesList = await imageFile.readAsBytes();
  //       Uint8List imagePathBytes = Uint8List.fromList(imageBytesList);
  //
  //       // Update the 'imagePath' field in the database with image bytes
  //       await db?.update(
  //         'shopVisit',
  //         {'imagePath': imagePathBytes},
  //         where: 'id = ?',
  //         whereArgs: [shopVisit.id],
  //       );
  //     }
  //   } catch (e) {
  //     print('Error adding shop visit: $e');
  //   }
  // }
  Future<void> postShopVisitData() async {
    final Database db = await initDatabase();
    final ApiServices api = ApiServices();

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/captured_image.jpg';


    try {
      final products = await db.rawQuery('''SELECT *, 
      CASE WHEN walkthrough = 1 THEN 'True' ELSE 'False' END AS walkthrough,
      CASE WHEN planogram = 1 THEN 'True' ELSE 'False' END AS planogram,
      CASE WHEN signage = 1 THEN 'True' ELSE 'False' END AS signage,
      CASE WHEN productReviewed = 1 THEN 'True' ELSE 'False' END AS productReviewed
      FROM shopVisit
      ''');

      await db.rawQuery('VACUUM');
      if (products.isNotEmpty || products != null)  {  // Check if the table is not empty


      for (Map<dynamic, dynamic> i in products) {
        print("FIRST ${i}");

        ShopVisitModel v = ShopVisitModel(
          id: i['id'].toString(),
          date: i['date'].toString(),
          userId: i['userId'].toString(),
          shopName: i['shopName'].toString(),
          bookerName: i['bookerName'].toString(),
          brand: i['brand'].toString(),
          walkthrough: i['walkthrough'].toString(),
          planogram: i['planogram'].toString(),
          signage: i['signage'].toString(),
          productReviewed: i['productReviewed'].toString(),
          feedback: i['feedback'].toString(),
          latitude: i['latitude'].toString(),
          longitude: i['longitude'].toString(),
          address: i['address'].toString(),
          body: i['body'] != null && i['body'].toString().isNotEmpty
              ? Uint8List.fromList(base64Decode(i['body'].toString()))
              : Uint8List(0),

        );

        // Print image path before trying to create the file
        print("Image Path from Database: ${i['body']}");
        print("lat:${i['latitude']}");

        // Declare imageBytes outside the if block
        Uint8List imageBytes;
        final directory = await getApplicationDocumentsDirectory();
        final filePath = File('${directory.path}/captured_image.jpg');

        if (filePath.existsSync()) {
          // File exists, proceed with reading the file
          List<int> imageBytesList = await filePath.readAsBytes();
          imageBytes = Uint8List.fromList(imageBytesList);
        } else {
          print("File does not exist at the specified path: ${filePath.path}");
          continue; // Skip to the next iteration if the file doesn't exist
        }


        // Print information before making the API request
        print("Making API request for shop visit ID: ${v.id}");


        var result = await api.masterPostWithImage(
          v.toMap(),
          'https://g77e7c85ff59092-db17lrv.adb.ap-singapore-1.oraclecloudapps.com/ords/metaxperts/report/post/',
          imageBytes,
        );
        if (result == true) {
          await db.rawQuery('DELETE FROM shopVisit WHERE id = ${i['id']}');
          print("Successfully posted data for shop visit ID: ${v.id}");

         }
        else {
          print("Failed to post data for shop visit ID: ${v.id}");

      }
      }

    }
      } catch (e) {
      print("Error processing shop visit data: $e");
      return null;
    }
  }

  Future<void> postStockCheckItems() async {
    final Database db = await initDatabase();
    final ApiServices api = ApiServices();
    try {
      final products = await db.rawQuery('select * from Stock_Check_Items');
      var count = 0;
      if (products.isNotEmpty || products != null)  {  // Check if the table is not empty

        for(var i in products){
        print(i.toString());
        count++;
        StockCheckItemsModel v =StockCheckItemsModel(
          id: "${i['id']}${i['shopvisitId']}".toString(),
          shopvisitId: i['shopvisitId'].toString(),
          itemDesc: i['itemDesc'].toString(),
          qty: i['qty'].toString(),
        );
        var result = await api.masterPost(v.toMap(), 'https://g77e7c85ff59092-db17lrv.adb.ap-singapore-1.oraclecloudapps.com/ords/metaxperts/shopvisit/post/');
        if(result == true){
          db.rawQuery('DELETE FROM Stock_Check_Items WHERE id = ${i['id']}');
        }
      }
    } }catch (e) {
      print("ErrorRRRRRRRRR: $e");
      return null;
    }
  }

  Future<bool> insertLogin(List<dynamic> dataList) async {
    final Database db = await initDatabase();
    try {
      for (var data in dataList) {
        await db.insert('login', data);
      }
      return true;
    } catch (e) {
      print("Error inserting login data: ${e.toString()}");
      return false;
    }
  }
  Future<bool>login(Users user) async{
    final Database db = await initDatabase();
    var results=await db.rawQuery("select * from login where user_id = '${user.user_id}' AND password = '${user.password}'");
    if(results.isNotEmpty){
      return true;
    }
    else{
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> getAllLogins() async {
    final Database db = await initDatabase();
    try {
      final List<Map<String, dynamic>> logins = await db.query('login');
      return logins;
    } catch (e) {
      print("Error retrieving products: $e");
      return null;
    }
  }
  Future<String?> getUserName(String userId) async {
    final Database db = await initDatabase();
    try {
      var results = await db.rawQuery("select user_name from login where user_id = '$userId'");
      if (results.isNotEmpty) {
        // Explicitly cast to String
        return results.first['user_name'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching user name: $e");
      return null;
    }
  }
  Future<String?> getUserCity(String userId) async {
    final Database db = await initDatabase();
    try {
      var results = await db.rawQuery("select city from login where user_id = '$userId'");
      if (results.isNotEmpty) {
        // Explicitly cast to String
        return results.first['city'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching user city: $e");
      return null;
    }
  }


}
