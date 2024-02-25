import 'package:get/get.dart';
import '../Models/StockCheckItems.dart';
import '../Repositories/OrderRepository/SrockCheckItemsRepository.dart';


class StockCheckItemsViewModel extends GetxController{

  var allStockCheckItems = <StockCheckItemsModel>[].obs;
  StockCheckItemsRepository stockcheckitemsRepository = StockCheckItemsRepository();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchAllOStockCheckItems();
  }


  fetchAllOStockCheckItems() async{
    var stockcheckitems = await stockcheckitemsRepository.getStockCheckItems();
    allStockCheckItems.value = stockcheckitems;
  }


  addStockCheckItems(StockCheckItemsModel stockcheckitemsModel){
    stockcheckitemsRepository.add(stockcheckitemsModel);
    fetchAllOStockCheckItems();
  }

  updateStockCheckItems(StockCheckItemsModel stockcheckitemsModel){
    stockcheckitemsRepository.update(stockcheckitemsModel);
    fetchAllOStockCheckItems();
  }

  deleteStockCheckItems(int id){
    stockcheckitemsRepository.delete(id);
    fetchAllOStockCheckItems();
  }

}