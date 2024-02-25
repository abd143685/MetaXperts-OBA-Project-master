import 'dart:io';
import 'dart:io';
import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;

import '../Databases/DBHelper.dart';
import '../Models/ShopVisitModels.dart';

class ShopVisitRepository {

  DBHelper dbHelpershopvisit = DBHelper();

  Future<List<ShopVisitModel>> getShopVisit() async {
    var dbClient = await dbHelpershopvisit.db;
    List<Map> maps = await dbClient!.query('shopVisit', columns: ['id','date', 'shopName','userId' , 'bookerName' , 'brand' ,'walkthrough', 'planogram' , 'signage', 'productReviewed','feedback','longitude','latitude','address', 'body']);
    List<ShopVisitModel> shopvisit = [];

    for (int i = 0; i < maps.length; i++) {
      shopvisit.add(ShopVisitModel.fromMap(maps[i]));
    }
    return shopvisit;
  }

  Future<String> getLastid() async {
    var dbClient = await dbHelpershopvisit.db;
    List<Map> maps = await dbClient!.query(
      'shopVisit',
      columns: ['id'],
      orderBy: 'Id DESC',
      limit: 1,
    );
    if (maps.isEmpty) {
      // Handle the case when no records are found
      return "";
    }

    // Convert the orderId to a string and return
    return maps[0]['id'].toString();
  }

    Future<int> add(ShopVisitModel shopvisitModel) async {
      var dbClient = await dbHelpershopvisit.db;
      return await dbClient!.insert('shopVisit', shopvisitModel.toMap());
    }

  // Future<void> addShopVisit(ShopVisitModel shopVisit) async {
  //   final db = await dbHelpershopvisit.db;
  //   try {
  //     // Convert image file to bytes
  //     List<int> imageBytesList = await getImageBytesFromPath(shopVisit.body);
  //     Uint8List imagePathBytes = Uint8List.fromList(imageBytesList);
  //
  //     await db?.insert(
  //       'shopVisit',
  //       {
  //         'id': shopVisit.id,
  //         'date': shopVisit.date,
  //         'shopName': shopVisit.shopName,
  //         'bookerName': shopVisit.bookerName,
  //         'brand': shopVisit.brand,
  //         'walkthrough': shopVisit.walkthrough,
  //         'planogram': shopVisit.planogram,
  //         'signage': shopVisit.signage,
  //         'productReviewed': shopVisit.productReviewed,
  //         'body': imagePathBytes, // Store image data in the 'body' column as BLOB
  //         'feedback': shopVisit.feedback,
  //       },
  //       conflictAlgorithm: ConflictAlgorithm.replace,
  //     );
  //   } catch (e) {
  //     print('Error adding shop visit: $e');
  //   }
  // }

  // Future<List<int>> getImageBytesFromPath(String? imagePath) async {
  //   if (imagePath != null && imagePath.isNotEmpty) {
  //     io.File imageFile = io.File(imagePath);
  //     return await imageFile.readAsBytes();
  //   }
  //   return [];
  // }

    Future<int> update(ShopVisitModel shopvisitModel) async {
      var dbClient = await dbHelpershopvisit.db;
      return await dbClient!.update('shopVisit', shopvisitModel.toMap(),
          where: 'id=?', whereArgs: [shopvisitModel.id]);
    }

    Future<int> delete(int id) async {
      var dbClient = await dbHelpershopvisit.db;
      return await dbClient!.delete('shopVisit',
          where: 'id=?', whereArgs: [id]);
    }
  }