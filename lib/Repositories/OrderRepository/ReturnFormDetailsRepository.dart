
import '../../Databases/DBHelper.dart';
import '../../Models/ReturnFormDetails.dart';

class ReturnFormDetailsRepository {

  DBHelper dbHelperReturnFormDetails = DBHelper();

  Future<List<ReturnFormDetailsModel>> getReturnFormDetails() async {
    var dbClient = await dbHelperReturnFormDetails.db;
    List<Map> maps = await dbClient!.query('return_form_details', columns: ['id','returnformId', 'productName', 'quantity','bookerId', 'reason']);
    List<ReturnFormDetailsModel> returnformdetails = [];
    for (int i = 0; i < maps.length; i++) {

      returnformdetails.add(ReturnFormDetailsModel.fromMap(maps[i]));
    }
    return returnformdetails;
  }

  Future<int> add(ReturnFormDetailsModel returnformdetailsModel) async {
    var dbClient = await dbHelperReturnFormDetails.db;
    return await dbClient!.insert('return_form_details', returnformdetailsModel.toMap());
  }

  Future<int> update(ReturnFormDetailsModel returnformdetailsModel) async {
    var dbClient = await dbHelperReturnFormDetails.db;
    return await dbClient!.update('return_form_details',returnformdetailsModel.toMap(),
        where: 'id = ?', whereArgs: [returnformdetailsModel.id]);
  }

  Future<int> delete(int id) async {
    var dbClient = await dbHelperReturnFormDetails.db;
    return await dbClient!.delete('return_form_details',
        where: 'id = ?', whereArgs: [id]);
  }
}