//import 'package:order_booking_shop/Databases/DBHelper.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../Databases/DBHelper.dart';
import 'ApiServices.dart';

class DatabaseOutputs{
  Future<void> checkFirstRun() async {
    SharedPreferences SP = await SharedPreferences.getInstance();
    bool firstrun = await SP.getBool('firstrun') ?? true;
    if(firstrun == true){

      await SP.setBool('firstrun', false);
      await initializeData();
    }else{
      print("UPDATING.......................................");
      await update();
     await initializeData();
    }
  }
  Future<void> check_OB() async{
    SharedPreferences SP = await SharedPreferences.getInstance();
    bool firstrun = await SP.getBool('firstrun') ?? true;
    if(firstrun == true){
      await initializeData();
      await SP.setBool('firstrun', false);
    }else{
      print("UPDATING.......................................");
      await update_orderbooking_status();
      initialize_orderbooking_status();
    }
  }
  Future<void> update_orderbooking_status() async{
    final dborderbookingstatus= DBHelper();
    print("DELETING.......................................");
    await dborderbookingstatus.deleteAllRecords();
  }
  void initialize_orderbooking_status() async{
    final api = ApiServices();
    final dborderbookingstatus= DBHelper();
    var OrderBookingStatusdata= await dborderbookingstatus.getOrderBookingStatusDB();

    //
    // if (OrderBookingStatusdata == null || OrderBookingStatusdata.isEmpty ) {
    //   var response2 = await api.getApi("https://g77e7c85ff59092-db17lrv.adb.ap-singapore-1.oraclecloudapps.com/ords/metaxperts/statusget/get/");
    //   var results2 = await dborderbookingstatus.insertOrderBookingStatusData(response2);   //return True or False
    //   if (results2) {
    //     print("Data inserted successfully.");
    //   } else {
    //     print("Error inserting data.");
    //   }
    // } else {
    //   print("Data is available.");
    // }
  }
 Future<void>  initializeData() async {
    final api = ApiServices();
    final db = DBHelper();
    final dbowner = DBHelper();
    final dbordermaster= DBHelper();
    final dborderdetails= DBHelper();
    final dbnetbalance= DBHelper();
    final dbaccounts= DBHelper();
    final dborderbookingstatus= DBHelper();
    final dblogin=DBHelper();
    final dbProductCategory=DBHelper();
    var Productdata = await db.getProductsDB();
    var OrderMasterdata = await dbordermaster.getOrderMasterDB();
    var OrderDetailsdata = await dborderdetails.getOrderDetailsDB();
    var NetBalancedata = await dbnetbalance.getNetBalanceDB();
    var Accountsdata = await dbaccounts.getAccoutsDB();
    var OrderBookingStatusdata= await dborderbookingstatus.getOrderBookingStatusDB();
    var Owerdata = await dbowner.getOwnersDB();
    var Logindata = await dblogin.getAllLogins();
    var PCdata = await dbProductCategory.getAllPCs();

    //https://g77e7c85ff59092-db17lrv.adb.ap-singapore-1.oraclecloudapps.com/ords/muhammad_usman/login/get/
    // https://g77e7c85ff59092-db17lrv.adb.ap-singapore-1.oraclecloudapps.com/ords/metaxperts/login/get/
    // var username = 'yxeRFdCC0wjh1BYjXu1HFw..';
    // var password = 'KG-oKSMmf4DhqtFNmVtpMw..';

    if (Logindata == null || Logindata.isEmpty ) {
       // replace with your actual access token
      var response3 = await api.getApi("https://g77e7c85ff59092-db17lrv.adb.ap-singapore-1.oraclecloudapps.com/ords/metaxperts/login/get/");
      var results3= await dblogin.insertLogin(response3);//return True or False
      if (results3) {
        print("Data inserted successfully.");
      } else {
        print("Error inserting data.");
      }
    } else {
      print("Data is available.");
    }


    if (Accountsdata == null || Accountsdata.isEmpty ) {
      var response2 = await api.getApi("https://g77e7c85ff59092-db17lrv.adb.ap-singapore-1.oraclecloudapps.com/ords/metaxperts/account/get/");
      var results2 = await dbaccounts.insertAccoutsData(response2);   //return True or False
      if (results2) {
        print("Data inserted successfully.");
      } else {
        print("Error inserting data.");
      }
    } else {
      print("Data is available.");
    }


    if (NetBalancedata == null || NetBalancedata.isEmpty ) {
      var response2 = await api.getApi("https://g77e7c85ff59092-db17lrv.adb.ap-singapore-1.oraclecloudapps.com/ords/metaxperts/balance/get/");
      var results2 = await dbnetbalance.insertNetBalanceData(response2);   //return True or False
      if (results2) {
        print("Data inserted successfully.");
      } else {
        print("Error inserting data.");
      }
    } else {
      print("Data is available.");
    }


    if (OrderBookingStatusdata == null || OrderBookingStatusdata.isEmpty ) {
      var response2 = await api.getApi("https://g77e7c85ff59092-db17lrv.adb.ap-singapore-1.oraclecloudapps.com/ords/metaxperts/statusget/get/");
      var results2 = await dborderbookingstatus.insertOrderBookingStatusData(response2);   //return True or False
      if (results2) {
        print("Data inserted successfully.");
      } else {
        print("Error inserting data.");
      }
    } else {
      print("Data is available.");
    }

    if (OrderMasterdata == null || OrderMasterdata.isEmpty ) {
      var response2 = await api.getApi("https://g77e7c85ff59092-db17lrv.adb.ap-singapore-1.oraclecloudapps.com/ords/metaxperts/masterget/get/");
      var results2 = await dbordermaster.insertOrderMasterData(response2);   //return True or False
      if (results2) {
        print("Data inserted successfully.");
      } else {
        print("Error inserting data.");
      }
    } else {
      print("Data is available.");
    }

    if (OrderDetailsdata == null || OrderDetailsdata.isEmpty ) {
      var response2 = await api.getApi("https://g77e7c85ff59092-db17lrv.adb.ap-singapore-1.oraclecloudapps.com/ords/metaxperts/detailget/get/");
      var results2 = await dborderdetails.insertOrderDetailsData(response2);   //return True or False
      if (results2) {
        print("Data inserted successfully.");
      } else {
        print("Error inserting data.");
      }
    } else {
      print("Data is available.");
    }


    if (Productdata == null || Productdata.isEmpty ) {
      var response = await api.getApi("https://g77e7c85ff59092-db17lrv.adb.ap-singapore-1.oraclecloudapps.com/ords/metaxperts/product/get/");
      var results= await db.insertProductsData(response);  //return True or False
      if (results) {
        print("Data inserted successfully.");
      }
      else {
        print("Error inserting data.");
      }

    } else {
      print("Data is available.");
    }

    if (Owerdata == null || Owerdata.isEmpty ) {
      var response2 = await api.getApi("https://g77e7c85ff59092-db17lrv.adb.ap-singapore-1.oraclecloudapps.com/ords/metaxperts/owner/get/");
      var results2 = await dbowner.insertOwnerData(response2);   //return True or False
      if (results2) {
        print("Data inserted successfully.");
      } else {
        print("Error inserting data.");
      }
    } else {
      print("Data is available.");
    }


    if (PCdata == null || PCdata.isEmpty ) {
      var response4 = await api.getApi("https://g77e7c85ff59092-db17lrv.adb.ap-singapore-1.oraclecloudapps.com/ords/metaxperts/brand/get/");
      var results4= await dbProductCategory.insertProductCategory(response4);//return True or False
      if (results4) {
        print("Data inserted successfully.");
      } else {
        print("Error inserting data.");
      }
    } else {
      print("Data is available.");
    }
    showAllTables();
  }


  // void initializeData() async{
  //    final api = ApiServices();
  //    final db = DBHelperProducts();
  //    final dbowner = DBHelperOwner();
  //    final dblogin=DBHelperLogin();
  //    final dbProductCategory=DBHelperProductCategory();
  //    var response = await api.getApi("https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/product/record");
  //    var results= await db.insertProductsData(response);  //return True or False
  //    //print(results.toString());
  //    var response2 = await api.getApi("https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/AddAhop/record/");
  //    var results2 = await dbowner.insertOwnerData(response2);   //return True or False
  //    //print(results2.toString());
  //    var response4 = await api.getApi("https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/login/get/");
  //    var results4= await dblogin.insertLogin(response4);//return True or False
  //    //print(results4.toString());
  //    var response5 = await api.getApi("https://g04d40198f41624-i0czh1rzrnvg0r4l.adb.me-dubai-1.oraclecloudapps.com/ords/courage/product_brand/get/");
  //    var results5= await dbProductCategory.insertProductCategory(response5);//return True or False
  //    print(results5.toString());
  //    showAllTables();
  // }

  Future<void> update() async {
    final db = DBHelper();
    final dbowner = DBHelper();
    final dblogin=DBHelper();
    final dbordermaster= DBHelper();
    final dborderdetails= DBHelper();
    final dborderbookingstatus= DBHelper();
    final dbProductCategory=DBHelper();
    final dbnetbalance=DBHelper();
    print("DELETING.......................................");
    await db.deleteAllRecords();
    await dbowner.deleteAllRecords();
    await dblogin.deleteAllRecords();
    await dbProductCategory.deleteAllRecords();
    await dbordermaster.deleteAllRecords();
    await dborderdetails.deleteAllRecords();
    await dbnetbalance.deleteAllRecords();
    await dborderbookingstatus.deleteAllRecords();
  }
  Future<void> showOrderMaster() async {
    print("************Tables SHOWING**************");
    print("************Order Master**************");
    final db = DBHelper();

    var data = await db.getOrderMasterDB();
    int co = 0;
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Order Master is $co");

  }
  Future<void> showOrderMasterData() async {
    print("************Tables SHOWING**************");
    print("************Order Master get data**************");
    final db = DBHelper();

    var data = await db.getOrderMasterDataDB();
    int co = 0;
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Order Master get data is $co");

  }

  Future<void> showOrderDetailsData() async {
    print("************Tables SHOWING**************");
    print("************Order Master get data**************");
    final db = DBHelper();

    var data = await db.getOrderDetailsDB();
    int co = 0;
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Order Details get data is $co");

  }

  Future<void> showReturnForm() async {
    print("************Tables SHOWING**************");
    print("************Return Form**************");
    final db = DBHelper();

    var data = await db.getReturnFormDB();
    int co = 0;
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Return Form is $co");

  }

  Future<void> showRecoveryForm() async {
    print("************Tables SHOWING**************");
    print("************Recovery Form**************");
    final db = DBHelper();

    var data = await db.getRecoveryFormDB();
    int co = 0;
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Recovery Form is $co");

  }

  Future<void> showShop() async {
    print("************Tables SHOWING**************");
    print("************Shops**************");
    final db = DBHelper();

    var data = await db.getShopDB();
    int co = 0;
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Add Shops is $co");
  }

  Future<void> showShopVisit() async {
    print("************Tables SHOWING**************");
    print("************SHOP VISIT**************");
    final db = DBHelper();

    var data = await db.getShopVisit();
    int co = 0;
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of SHOP VISIT is $co");

  }

  Future<void> showStockCheckItems() async {
    print("************Tables SHOWING**************");
    print("************Stock Check Items**************");
    final db = DBHelper();

    var data = await db.getStockCheckItems();
    int co = 0;
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Order Details is $co");

  }

  // Future<void> showShopVisit_2nd() async {
  //   print("************Tables SHOWING**************");
  //   print("************SHOP VISIT 2nd**************");
  //   final db = DBHelperShopVisit_2nd();
  //
  //   var data = await db.getShopVisit_2nd();
  //   int co = 0;
  //   for(var i in data!){
  //     co++;
  //     print("$co | ${i.toString()} \n");
  //   }
  //   print("TOTAL of SHOP VISIT 2nd is $co");
  //
  // }


  Future<void> showOrderDetails() async {
    print("************Tables SHOWING**************");
    print("************Order Details**************");
    final db = DBHelper();

    var data = await db.getOrderDetails();
    int co = 0;
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Order Details is $co");

  }

  Future<void> showAttendance() async {
    print("************Tables SHOWING**************");
    print("************Attendance In**************");
    final db = DBHelper();

    var data = await db.getAllAttendance();
    int co = 0;
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Attendance In is $co");

  }
  Future<void> showAttendanceOut() async {
    print("************Tables SHOWING**************");
    print("************Attendance Out**************");
    final db = DBHelper();

    var data = await db.getAllAttendanceOut();
    int co = 0;
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Attendance Out is $co");

  }

  Future<void> showReturnFormDetails() async {
    print("************Tables SHOWING**************");
    print("************Return Form Details**************");
    final db = DBHelper();

    var data = await db.getReturnFormDetailsDB();
    int co = 0;
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Return Form Details is $co");

  }



  Future<void> showAllTables() async {
    print("************Tables SHOWING**************");
    print("************Tables Products**************");
    final db = DBHelper();
    final dbowner = DBHelper();
    final dblogin = DBHelper();
    final dbPC = DBHelper();
    final dbordermaster = DBHelper();
    final dborderdetails = DBHelper();
    final dborderbookingstatus = DBHelper();
    final dbnetbalance = DBHelper();
    final dbaccounts = DBHelper();

    var data = await db.getProductsDB();
    int co = 0;
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Products is $co");

    print("************Tables Owners**************");
    co=0;
    data = await dbowner.getOwnersDB();
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Owners is $co");

    print("************Logins Owners**************");
    co=0;
    data = await dblogin.getAllLogins();
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Logins is $co");

    print("************ProductsCategories Owners**************");
    co=0;
    data = await dbPC.getAllPCs();
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Products Categories is $co");

    print("************Tables OrderMaster**************");
    co=0;
    data = await dbordermaster.getOrderMasterDB();
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of OrderMaster is $co");

    print("************Tables Order Details**************");
    co=0;
    data = await dborderdetails.getOrderDetailsDB();
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of OrderDetails data is $co");

    print("************Tables Order Booking Status**************");
    co=0;
    data = await dborderbookingstatus.getOrderBookingStatusDB();
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of OrderBooking Status is $co");

    print("TOTAL of netBalance is $co");

    print("************Tables Net Balance**************");
    co=0;
    data = await dbnetbalance.getNetBalanceDB();
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Net Balance is $co");

    print("************Tables Accounts**************");
    co=0;
    data = await dbaccounts.getAccoutsDB();
    for(var i in data!){
      co++;
      print("$co | ${i.toString()} \n");
    }
    print("TOTAL of Accounts is $co");

  }

}