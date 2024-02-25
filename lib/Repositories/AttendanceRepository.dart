

import '../Databases/DBHelper.dart';
import '../Models/AttendanceModel.dart';

class AttendanceRepository {

  DBHelper dbHelper = DBHelper();

  Future<List<AttendanceModel>> getAttendance() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient!.query('attendance', columns: ['id', 'date' , 'timeIn' , 'userId' , 'latIn' , 'lngIn','bookerName' ]);
    List<AttendanceModel> attendance = [];

    for (int i = 0; i < maps.length; i++) {
      attendance.add(AttendanceModel.fromMap(maps[i]));
    }
    return attendance;
  }

  // Future<List<AttendanceModel>> getShopName() async {
  //   var dbClient = await dbHelper.db;
  //   List<Map> maps = await dbClient!.query('shop', columns: ['id', 'shopName']);
  //   List<AttendanceModel> shop = [];
  //
  //   for (int i = 0; i < maps.length; i++) {
  //     shop.add(AttendanceModel.fromMap(maps[i]));
  //   }
  //   return shop;
  // }

  //
  // Future<String> getLastid() async {
  //   var dbClient = await dbHelper.db;
  //   List<Map> maps = await dbClient!.query(
  //     'shop',
  //     columns: ['id'],
  //     orderBy: 'Id DESC',
  //     limit: 1,
  //   );
  //   if (maps.isEmpty) {
  //     // Handle the case when no records are found
  //     return "";
  //   }
  //
  //   // Convert the orderId to a string and return
  //   return maps[0]['id'].toString();
  // }


  Future<List<AttendanceOutModel>> getAttendanceOut() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient!.query('attendanceOut', columns: ['id', 'date' , 'timeOut' ,'totalTime', 'userId' , 'latOut', 'lngOut','totalDistance', 'posted']);
    List<AttendanceOutModel> attendanceout = [];

    for (int i = 0; i < maps.length; i++) {
      attendanceout.add(AttendanceOutModel.fromMap(maps[i]));
    }
    return attendanceout;
  }

  Future<int> addOut(AttendanceOutModel attendanceoutModel) async{
    var dbClient = await dbHelper.db;
    return await dbClient!.insert('attendanceOut' , attendanceoutModel.toMap());
  }

  Future<int> add(AttendanceModel attendanceModel) async{
    var dbClient = await dbHelper.db;
    return await dbClient!.insert('attendance' , attendanceModel.toMap());
  }

  Future<int> update(AttendanceModel attendanceModel) async{
    var dbClient = await dbHelper.db;
    return await dbClient!.update('attendance', attendanceModel.toMap(),
        where: 'id= ?', whereArgs: [attendanceModel.id] );
  }

  Future<int> delete(int id) async{
    var dbClient = await dbHelper.db;
    return await dbClient!.delete('attendance',
        where: 'id=?', whereArgs: [id] );
  }



}



