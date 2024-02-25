import 'package:get/get.dart';

import '../../Models/ReturnFormModel.dart';
import '../../Repositories/OrderRepository/ReturnFormRepository.dart';


class ReturnFormViewModel extends GetxController{

  var allReturnForm = <ReturnFormModel>[].obs;
  ReturnFormRepository returnformRepository =ReturnFormRepository ();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchAllReturnForm();
  }

  fetchAllReturnForm() async{
    var returnform = await returnformRepository.getReturnForm();
    allReturnForm.value = returnform;
  }

  Future<String> fetchLastReturnFormId() async{
    String returnform = await returnformRepository.getLastId();
    return returnform;
  }

  addReturnForm(ReturnFormModel returnformModel){
    returnformRepository.add( returnformModel);
    fetchAllReturnForm();
  }

  updateReturnForm(ReturnFormModel returnformModel){
    returnformRepository.update(returnformModel);
    fetchAllReturnForm();
  }

  deleteReturnForm(int id){
    returnformRepository.delete(id);
    fetchAllReturnForm();
  }

}