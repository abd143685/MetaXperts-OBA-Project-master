import 'package:get/get.dart';
import 'package:order_booking_shop/API/Globals.dart';
//import 'package:order_booking_shop/Models/OrderModels/OrderMasterModel.dart';
//import '../../Models/OrderModels/OrderMasterModel.dart';
import '../../Models/ProductsModel.dart';
import '../../Repositories/OrderRepository/OrderMasterRepository.dart';
import '../../Repositories/OrderRepository/ProductsRepository.dart';

class ProductsViewModel extends GetxController {
  var allProducts = <ProductsModel>[].obs;

  ProductsRepository productsRepository = ProductsRepository();

  @override
  void onInit() {
    super.onInit();
    fetchAllProductsModel();
  }

  fetchAllProductsModel() async {
    var products = await productsRepository.getProductsModel();
    allProducts.value = products;
  }
  addProductAll(ProductsModel productsModel) {
    productsRepository.add(productsModel);
    fetchAllProductsModel();
  }

  updateProductAll(ProductsModel productsModel) {
    productsRepository.update(productsModel);
    fetchAllProductsModel();
  }
  deleteProductsAll(int id) {
    productsRepository.delete(id);
    fetchAllProductsModel();
  }

  Future<void> fetchProductsByBrand(String brand) async {
    try {
      String brand = globalselectedbrand;
      // Fetch products by brand from the repository
      List<ProductsModel> products = await productsRepository.getProductsByBrand(brand);

      // Set the products in the allProducts list
      allProducts.value = products;
    } catch (e) {
      print("Error fetching products by brand: $e");
    }
  }



}
