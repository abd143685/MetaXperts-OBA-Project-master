

import '../Databases/DBHelper.dart';
import '../Models/RecoveryFormModel.dart';

class RecoveryFormRepository{

  DBHelper dbHelperRecoveryForm = DBHelper();

  Future<List<RecoveryFormModel>> getRecoveryForm() async{
    var dbClient = await dbHelperRecoveryForm.db;
    List<Map> maps = await dbClient!.query('recoveryForm',columns: ['recoveryId','date','shopName','netBalance',' userId', 'bookerName']);
    List<RecoveryFormModel> recoveryform = [];
    for(int i = 0; i<maps.length; i++)
    {
      recoveryform.add(RecoveryFormModel.fromMap(maps[i]));
    }
    return recoveryform;
  }
  //
  // Future<String> getLastId() async {
  //   var dbClient = await dbHelperReturnForm.db;
  //   List<Map> maps = await dbClient.query(
  //     'returnForm',
  //     columns: ['returnId'],
  //     orderBy: 'returnId DESC',
  //     limit: 1,
  //   );
  //
  //   if (maps.isEmpty) {
  //     // Handle the case when no records are found
  //     return "";
  //   }
  //
  //   // Convert the orderId to a string and return
  //   return maps[0]['returnId'].toString();
  // }


  Future<int> add(RecoveryFormModel  recoveryform) async{
    var dbClient = await dbHelperRecoveryForm.db;
    return await dbClient!.insert('recoveryForm',  recoveryform.toMap());
  }

  Future<int> update(RecoveryFormModel  recoveryform) async{
    var dbClient = await dbHelperRecoveryForm.db;
    return await dbClient!.update('recoveryForm', recoveryform.toMap(),
        where: 'recoveryForm = ?', whereArgs: [ recoveryform.recoveryId]);
  }


  Future<int> delete(int recoveryId) async{
    var dbClient = await dbHelperRecoveryForm.db;
    return await dbClient!.delete('recoveryForm',
        where: 'recoveryId = ?', whereArgs: [recoveryId]);
  }




}

