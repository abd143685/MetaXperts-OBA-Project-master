import 'package:get/get.dart';

import '../../Models/ReturnFormDetails.dart';
import '../../Repositories/OrderRepository/ReturnFormDetailsRepository.dart';

class ReturnFormDetailsViewModel extends GetxController{

  var allOrderDetails = <ReturnFormDetailsModel>[].obs;
  ReturnFormDetailsRepository returnformdetailsRepository = ReturnFormDetailsRepository();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchAllReturnFormDetails();
  }




  fetchAllReturnFormDetails() async{
    var returnformdetails = await returnformdetailsRepository.getReturnFormDetails();
    allOrderDetails.value = returnformdetails;
  }


  addReturnFormDetail(ReturnFormDetailsModel returnformdetailsModel){
    returnformdetailsRepository.add(returnformdetailsModel);
    fetchAllReturnFormDetails();
  }

  updateReturnFormDetails(ReturnFormDetailsModel returnformdetailsModel){
    returnformdetailsRepository.update(returnformdetailsModel);
    fetchAllReturnFormDetails();
  }

  deleteReturnFormDetails(int id){
    returnformdetailsRepository.delete(id);
    fetchAllReturnFormDetails();
  }

}