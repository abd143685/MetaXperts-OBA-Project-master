import 'package:get/get.dart';
import 'package:order_booking_shop/API/Globals.dart';
import 'package:order_booking_shop/Views/ReturnFormPage.dart';
//import 'package:order_booking_shop/Models/OrderModels/OrderMasterModel.dart';
//import '../../Models/OrderModels/OrderDetailsModel.dart';
import '../../Models/OrderModels/OrderDetailsModel.dart';
import '../../Repositories/OrderRepository/OrderDetailsRepository.dart';
//import '../../Repositories/OrderRepository/OrderMasterRepository.dart';

class OrderDetailsViewModel extends GetxController{

  var allOrderDetails = <OrderDetailsModel>[].obs;
  var allGetOrderDetails = <GetOrderDetailsModel>[].obs;
  OrderDetailsRepository orderdetailsRepository = OrderDetailsRepository();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchAllOrderDetails();
  }

  fetchAllOrderDetails() async{
    var orderdetails = await orderdetailsRepository.getOrderDetails();
    allOrderDetails.value = orderdetails;
  }

  addOrderDetail(OrderDetailsModel orderdetailsModel){
    orderdetailsRepository.add(orderdetailsModel);
    fetchAllOrderDetails();
  }

  Future<void> fetchProductsNames(String order_no) async {
    try {
      String order_no = selectedorderno;
      // Fetch products by brand from the repository
      List<GetOrderDetailsModel> getorderdetails = await orderdetailsRepository.getOrderDetailsProductNamesByOrder(order_no);

      // Set the products in the allProducts list
      allGetOrderDetails.value = getorderdetails;
    } catch (e) {
      print("Error fetching products by Order No: $e");
    }
  }
  updateOrderDetails(OrderDetailsModel orderdetailsModel){
    orderdetailsRepository.update(orderdetailsModel);
    fetchAllOrderDetails();
  }

  deleteOrderDetails(int id){
    orderdetailsRepository.delete(id);
    fetchAllOrderDetails();
  }

}