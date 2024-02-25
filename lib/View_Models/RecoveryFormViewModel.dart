import 'package:get/get.dart';
import 'package:order_booking_shop/Models/RecoveryFormModel.dart';

import '../Repositories/RecoveryFormRepository.dart';


class RecoveryFormViewModel extends GetxController{

  var allRecoveryForm = <RecoveryFormModel>[].obs;
  RecoveryFormRepository recoveryformRepository = RecoveryFormRepository ();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchAllRecoveryForm();
  }

  fetchAllRecoveryForm() async{
    var returnform = await recoveryformRepository.getRecoveryForm();
    allRecoveryForm.value = returnform;
  }

  // Future<String> fetchLastReturnFormId() async{
  //   String returnform = await recoveryformRepository.getLastId();
  //   return returnform;
  // }

  addRecoveryForm(RecoveryFormModel returnformModel){
    recoveryformRepository.add( returnformModel);
    fetchAllRecoveryForm();
  }

  updateRecoveryForm(RecoveryFormModel returnformModel){
    recoveryformRepository.update(returnformModel);
    fetchAllRecoveryForm();
  }

  deleteRecoveryForm(int id){
    recoveryformRepository.delete(id);
    fetchAllRecoveryForm();
  }

}