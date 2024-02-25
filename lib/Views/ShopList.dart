import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nanoid/nanoid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:order_booking_shop/API/DatabaseOutputs.dart';
import 'package:order_booking_shop/API/Globals.dart';
import 'package:order_booking_shop/Models/ProductsModel.dart';
import 'package:order_booking_shop/View_Models/OrderViewModels/OrderDetailsViewModel.dart';
import 'package:order_booking_shop/View_Models/OrderViewModels/OrderMasterViewModel.dart';
import 'package:order_booking_shop/View_Models/OrderViewModels/ProductsViewModel.dart';
import 'package:timezone/timezone.dart';
import '../Databases/DBHelper.dart';
import '../Models/OrderModels/OrderDetailsModel.dart';
import 'HomePage.dart';
import 'OrderBooking_2ndPage.dart';
import 'package:get/get.dart';



class FinalOrderBookingPage extends StatefulWidget {
  @override
  _FinalOrderBookingPageState createState() => _FinalOrderBookingPageState();
}

class _FinalOrderBookingPageState extends State<FinalOrderBookingPage> {
  final ordermasterViewModel = Get.put(OrderMasterViewModel());
  final orderdetailsViewModel = Get.put(OrderDetailsViewModel());
  int? ordermasterId;
  int? orderdetailsId;

  TextEditingController _ShopNameController = TextEditingController();
  TextEditingController _ownerNameController = TextEditingController();
  TextEditingController _phoneNoController = TextEditingController();
  TextEditingController _brandNameController = TextEditingController();
  TextEditingController _totalController = TextEditingController();
  TextEditingController _creditLimitController = TextEditingController();
  TextEditingController _discountController = TextEditingController();
  TextEditingController _subTotalController = TextEditingController();
  TextEditingController _paymentController = TextEditingController();
  TextEditingController _balanceController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  final quantityControllers = <ProductsModel, TextEditingController>{};
  final amounts = <ProductsModel, double>{};
  final String inStockValue = "In Stock";
  TextEditingController _requiredDeliveryController = TextEditingController();
  final productsViewModel = Get.put(ProductsViewModel());
  String selectedBrand = '';
  List<RowData> rowDataList = [];
  List<String> selectedProductNames = [];
  int serialNumber = 1;
  int serialCounter = 1;
  String currentMonth = DateFormat('MMM').format(DateTime.now());
  String currentUserId = '';
  String newOrderId='';
  // Define your credit limit options
  List<String> creditLimitOptions = [];
  String selectedCreditLimit = ''; // Set a default value
  List<DataRow> rows = [];
  List<DataRow> filteredRows = [];

  // void filterData(String query) {
  //   if (query.isEmpty) {
  //     setState(() {
  //       filteredRows = [];
  //     });
  //   } else {
  //     List<DataRow> tempList = [];
  //     for (DataRow row in productsController.rows) {
  //       for (DataCell cell in row.cells) {
  //         if (cell.child is Text && (cell.child as Text).data!.contains(query)) {
  //           tempList.add(row);
  //           break;
  //         }
  //       }
  //     }
  //     setState(() {
  //       filteredRows = tempList;
  //     });
  //   }
  // }

  @override

  @override
  void initState() {
    super.initState();
    fetchAllProducts();
    for (var product in productsViewModel.allProducts) {
      quantityControllers[product] = TextEditingController();
      quantityControllers[product]?.addListener(() {
        setState(() {
          amounts[product] = double.parse(product.price ?? '0') * double.parse(quantityControllers[product]?.text ?? '0');
        });
      });
    }

    _searchController = TextEditingController();

    List<String> dropdownItems = ['15 Days', '30 Days', 'On Cash'];

    // Initially add two rows
    addNewRow();
    addNewRow();
    onCreatee();
    _loadCounter();

    addListenerToController(_totalController, _calculateSubTotal);
    addListenerToController(_discountController, _calculateSubTotal);
    addListenerToController(_paymentController, _calculateBalance);
    addListenerToController(_subTotalController, _calculateBalance);
  }

  void fetchAllProducts() async {
    await productsViewModel.fetchProductsByBrand(globalselectedbrand);
  }


  @override
  void dispose() {
    // Dispose of controllers to avoid memory leaks
    _ShopNameController.dispose();
    _ownerNameController.dispose();
    _phoneNoController.dispose();
    _brandNameController.dispose();
    _totalController.dispose();
    _creditLimitController.dispose();
    _discountController.dispose();
    _subTotalController.dispose();
    _paymentController.dispose();
    _balanceController.dispose();
    _requiredDeliveryController.dispose();

    // Dispose of controllers in rowDataList
    for (var rowData in rowDataList) {
      rowData.qtyController.dispose();
      rowData.rateController.dispose();
      rowData.amountController.dispose();
    }
    super.dispose();
  }


  void addListenerToController(TextEditingController controller, Function() listener) {
    controller.addListener(() {
      listener();
    });
  }
  Future<void> onCreatee() async {
    DatabaseOutputs db = DatabaseOutputs();
    await db.showOrderMaster();
    await db.showOrderDetails();
    await db.showShopVisit();
    await db.showStockCheckItems();
  }

  @override
  Widget build(BuildContext context) {
    // Get the passed data
    final Map<String, String> args = Get.arguments ?? {};
    final shopData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final shopName = shopData['shopName'];
    final ownerName = shopData['ownerName'];
    final selectedBrandName = shopData['selectedBrandName'];
    final ownerContact = shopData['ownerContact'];
    final userName = shopData['userName'];
    print(OrderMasterid);
    print(shopName);
    print(ownerName);
    print(ownerContact);
    print(selectedBrandName);

    _ShopNameController.text = shopName!;
    _ownerNameController.text = ownerName!;
    _brandNameController.text = selectedBrandName;
    _phoneNoController.text = ownerContact!;
    return WillPopScope(
        onWillPop: () async {
          // Navigate to the home page
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          ); // Always return false to prevent going back
          return false;
        },
        // You can use any widget here as a placeholder
        child: Scaffold(
          appBar: AppBar(
            title: Text('Order Booking'),
            centerTitle: true,
            backgroundColor: Colors.white,
          ),
          body: Stack(
            children: <Widget>[
              SingleChildScrollView(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    buildTextFormField('Shop Name', _ShopNameController,readOnly: true),
                    SizedBox(height: 10),
                    buildTextFormField('Owner Name', _ownerNameController,readOnly: true),
                    SizedBox(height: 10),
                    buildTextFormField('Phone#', _phoneNoController,readOnly: true),
                    SizedBox(height: 10),
                    buildTextFormField('Brand', _brandNameController,readOnly: true),
                    SizedBox(height: 10),
                    for (var i = 0; i < rowDataList.length; i++) buildRow(rowDataList[i], i + 1),
                    SizedBox(height: 20),
                    SizedBox(height: 25),
                    Column(
                      children: [

                        SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Container(
                                  height: 500, // Set the desired height
                                  width: 300, // Set the desired width
                                  child:Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                                      side: BorderSide(
                                        color: Colors.black, // Change the color as needed
                                        width: 1.0, // Change the width as needed
                                      ),
                                    ),
                                    child: SingleChildScrollView( // Add a vertical ScrollView
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextField(
                                              controller: _searchController,
                                              onChanged: (query) {
                                                // _filterProducts(value);
                                              },
                                              decoration: InputDecoration(
                                                labelText: 'Search',
                                                hintText: 'Type to search...',
                                                prefixIcon: Icon(Icons.search),
                                              ),
                                            ),
                                          ),
                                          SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child:DataTable(

                                                columns: [
                                                  // DataColumn(label: Text('Sr')),
                                                  DataColumn(label: Text('Products')),
                                                  DataColumn(label: Text('In Stock', style: TextStyle(color: Colors.black))),
                                                  DataColumn(label: Text('Rate')),
                                                  DataColumn(label: Text('Quantity')),
                                                  DataColumn(label: Text('Amount')),
                                                ],

                                                rows: List<DataRow>.from(productsViewModel.allProducts.map((product) {
                                                  return DataRow(cells: [
                                                    //DataCell(Text(('index + 1').toString())), // Sr
                                                    DataCell(Text(product.product_name ?? '')), // Product
                                                    DataCell( Text('Passed data: ${args['data']}')),// In Stock
                                                    DataCell(Text(product.price ?? '')), // Rate
                                                    DataCell(
                                                      TextField(
                                                        controller: quantityControllers[product], // Assign the controller
                                                        keyboardType: TextInputType.number, // Set the keyboard type to number
                                                        inputFormatters: <TextInputFormatter>[
                                                          FilteringTextInputFormatter.digitsOnly // Only numbers can be entered
                                                        ],
                                                        onChanged: (value) {
                                                          setState(() {
                                                            amounts[product] = double.parse(product.price ?? '0') * double.parse(value);
                                                          });
                                                        },
                                                      ),
                                                    ), // Quantity
                                                    /// Quantity
                                                    DataCell(Text((amounts[product] ?? 0).toString())), // Amount
                                                    // Add more cells as needed
                                                  ]);
                                                }).toList()),
                                              )
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],),
                        ),

                      ],
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          addNewRow();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text('Add Products'),
                      ),
                    ),
                    buildTextFormField('Total', _totalController, readOnly: true),


                    SizedBox(height: 10),
                    // Replace the Credit Limit text field with a Dropdown
                    buildDropdown('Credit Limit', _creditLimitController, creditLimitOptions, selectedCreditLimit),
                    SizedBox(height: 10),
                    // buildTextFormField('Discount', _discountController),
                    // SizedBox(height: 10),
                    // buildTextFormField('Net Amount', _subTotalController,readOnly: true),
                    // SizedBox(height: 10),

                    buildDateField('Required Delivery', _requiredDeliveryController),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Check if credit limit is in the list
                          if (_ShopNameController.text.isNotEmpty &&
                              _ownerNameController.text.isNotEmpty &&
                              _phoneNoController.text.isNotEmpty &&
                              _brandNameController.text.isNotEmpty &&
                              _totalController.text.isNotEmpty &&
                              _creditLimitController.text.isNotEmpty &&
                              ['15 Days', '30 Days', 'On Cash'].contains(_creditLimitController.text) &&
                              // _discountController.text.isNotEmpty &&
                              // _subTotalController.text.isNotEmpty &&
                              _requiredDeliveryController.text.isNotEmpty &&
                              // Add additional checks for other required fields
                              rowDataList.every((rowData) =>
                              rowData.selectedProduct != null &&
                                  rowData.qtyController.text.isNotEmpty &&
                                  rowData.rateController.text.isNotEmpty &&
                                  rowData.amountController.text.isNotEmpty)) {

                            // All required fields are filled, proceed with confirmation logic

                            // String newOrderId = generateNewOrderId(userId.toString(), currentMonth);

                            List<Map<String, dynamic>> rowDataDetails = [];
                            for (var rowData in rowDataList) {
                              String selectedItem = rowData.selectedProduct?.product_name ?? '';
                              int quantity = int.tryParse(rowData.qtyController.text) ?? 0;
                              int rate = int.tryParse(rowData.rateController.text) ?? 0;
                              int totalAmount = int.tryParse(rowData.amountController.text) ?? 0;

                              rowDataDetails.add({
                                'selectedItem': selectedItem,
                                'quantity': quantity,
                                'rate': rate,
                                'totalAmount': totalAmount,
                              });
                            }

                            for (var product in productsViewModel.allProducts) {
                              String quantity = quantityControllers[product]?.text ?? '0';
                              int quantityValue = int.tryParse(quantity) ?? 0;
                              // Check if the quantity value is greater than or equal to 1
                              if (quantityValue >= 1) {
                                var id = await customAlphabet('1234567890', 5);
                                orderdetailsViewModel.addOrderDetail(
                                    OrderDetailsModel(
                                      id: int.parse(id),
                                      orderMasterId: orderMasterid,
                                      productName: product.product_name,
                                      amount: amounts[product],
                                      price: double.parse(product.price ?? '0'),
                                      quantity: quantityValue,
                                    ));
                              }
                            }

                            List<OrderDetailsModel> orderDetailsList = [];


                            DBHelper().addOrderDetails(orderDetailsList);

                            DBHelper dbmaster = DBHelper();


                            await dbmaster.postOrderDetails();

                            Map<String, dynamic> dataToPass = {
                              'shopName': _ShopNameController.text,
                              'ownerName': _ownerNameController.text,
                              'orderId': OrderMasterid,
                              'orderDate': _getFormattedDate(),
                              'phoneNo': _phoneNoController.text,
                              'rowDataDetails': rowDataDetails,
                              'brand': _brandNameController.text,
                              'userName': userNames,
                              'date': _getFormattedDate(),
                              'total': _totalController.text,
                              'creditLimit': _creditLimitController.text,
                              // 'discount': _discountController.text,
                              // 'subTotal': _subTotalController.text,
                              'requiredDelivery': _requiredDeliveryController.text
                            };

                            // Navigate to another page after confirmation
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => OrderBooking_2ndPage(),
                                settings: RouteSettings(arguments: dataToPass),
                              ),
                            );

                          } else {
                            // Show a message or handle the case where some fields are empty or invalid
                            Fluttertoast.showToast(
                              msg: 'Please fill in all required fields correctly and select a valid credit limit before confirming.',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.green,

                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          minimumSize: Size(200, 50),
                        ),
                        child: Text('Confirm'),
                      ),
                    ),

                  ],

                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Text(
                    _getFormattedDate(),
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }


  // String currentMonth = DateFormat('MMM').format(DateTime.now());
  // You can maintain this as a global variable or retrieve it from somewhere
  _loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int loadedCounter = prefs.getInt('serialCounter') ?? 1;
    String loadedMonth = prefs.getString('currentMonth') ?? currentMonth;
    String loadedUserId = prefs.getString('currentUserId') ?? '';

    print('Loaded Counter: $loadedCounter');
    print('Loaded Month: $loadedMonth');
    print('Loaded User ID: $loadedUserId');

    if (loadedMonth != currentMonth && loadedUserId != currentUserId) {
      // Reset the counter when the month changes
      loadedCounter = 1;
    }

    // String newOrderId = "$loadedUserId-$loadedMonth-${loadedCounter.toString().padLeft(3, '0')}";
    // orderMasterid = newOrderId;
    // print(orderMasterid);

    // Save the updated values to SharedPreferences
    prefs.setInt('serialCounter', loadedCounter);
    prefs.setString('currentMonth', loadedMonth);
    prefs.setString('currentUserId', loadedUserId);

    setState(() {
      serialCounter = loadedCounter;
      currentMonth = loadedMonth;
      currentUserId = loadedUserId;
    });
  }


  _saveCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('serialCounter', serialCounter);
    await prefs.setString('currentMonth', currentMonth);
    await prefs.setString('currentUserId', currentUserId); // Add this line
  }

  String generateNewOrderId( String userId, String currentMonth) {
    if (this.currentUserId != userId) {
      // Reset serial counter when the userId changes
      serialCounter = 1;
      this.currentUserId = userId;
    }

    if (this.currentMonth != currentMonth) {
      // Reset serial counter when the month changes
      serialCounter = 1;
      this.currentMonth = currentMonth;
    }

    String orderId =
        "$userId-$currentMonth-${serialCounter.toString().padLeft(3, '0')}";
    serialCounter++;
    _saveCounter(); // Save the updated counter value, current month, and userId
    return orderId;
  }


// Define dropdownItems as a list of valid items
  List<String> dropdownItems = ['7 Days','15 Days', '30 Days', 'On Cash'];

// Define shopOwners as a list of maps
  List<Map<String, dynamic>> shopOwners = [
    {'shop_name': 'Shop1', 'owner_name': 'Owner1', 'owner_contact': '1234567890'},
    {'shop_name': 'Shop2', 'owner_name': 'Owner2', 'owner_contact': '9876543210'},
    // Add more entries as needed
  ];

  String selectedShopOwner = ''; // Add this line to define selectedShopOwner

// Helper method to build a DropdownButton
  Widget buildDropdown(String labelText, TextEditingController controller, List<String> options, String selectedValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
        SizedBox(height: 5),
        Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black, // Set border color
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: TypeAheadFormField(
            textFieldConfiguration: TextFieldConfiguration(
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(8.0), // Adjust padding as needed
              ),
            ),
            suggestionsCallback: (pattern) {
              return dropdownItems
                  .where((status) => status.toLowerCase().contains(pattern.toLowerCase()))
                  .toList();
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                title: Text(suggestion),
              );
            },
            onSuggestionSelected: (suggestion) {
              // Validate that the selected item is from the list
              if (dropdownItems.contains(suggestion)) {
                setState(() {
                  controller.text = suggestion;
                });

                // Additional logic based on the selected suggestion
                // For example, setting other state variables based on the selected suggestion
                for (var owner in shopOwners) {
                  if (owner['shop_name'] == suggestion) {
                    setState(() {
                      selectedShopOwner = owner['owner_name'];
                      // Additional state variable, if needed
                      // selectedOwnerContact = owner['owner_contact'];
                    });
                  }
                }
              } else {
                // If the selected item is not from the list, show an error message or handle it accordingly
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Invalid Selection'),
                      content: Text('Please select a valid item from the list.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget buildTextFormField(String labelText, TextEditingController controller, {bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(fontSize: 13, color: Colors.black),
        ),
        SizedBox(height: 5),
        Container(
          height: 50,
          child: TextFormField(
            controller: controller,
            readOnly: readOnly, // Set readOnly based on the provided parameter
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            style: TextStyle(fontSize: 11),
          ),
        ),
      ],
    );
  }
  Widget buildDateField(String labelText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(fontSize: 13, color: Colors.black),
        ),
        SizedBox(height: 5),
        Container(
          height: 50,
          child: InkWell(
            onTap: () {
              _selectDate(context, controller);
            },
            child: AbsorbPointer(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                style: TextStyle(fontSize: 10),
              ),
            ),
          ),
        ),
      ],
    );
  }
  void addNewRow() {
    // Check if the product in the first row is selected
    if (rowDataList.isNotEmpty && rowDataList[0].selectedProduct == null) {
      // Display a message or handle the validation error
      print('Please select a product in the first row before adding more rows.');
      return;
    }

    setState(() {
      final newRow = RowData(
        serialNumber: serialNumber,
        qtyController: TextEditingController(),
        rateController: TextEditingController(),
        amountController: TextEditingController(),
        itemsDropdownValue: '',
        selectedProduct: null,
      );
      rowDataList.add(newRow);
      serialNumber++;
    });
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != DateTime.now()) {
      final formattedDate = DateFormat('dd-MMM-yyyy').format(picked);
      controller.text = formattedDate;
    }
  }

  Widget buildRow(RowData rowData, int rowNumber) {
    rowData.qtyController.addListener(() {
      calculateAmount(rowData.qtyController, rowData.rateController,
          rowData.amountController, rowData);
    });

    rowData.rateController.addListener(() {
      calculateAmount(rowData.qtyController, rowData.rateController,
          rowData.amountController, rowData);
    });




    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          SizedBox(
            height: 5,
          ),
          Text(
            '$rowNumber.',
            style: TextStyle(fontSize: 13, color: Colors.black),
          ),
          SizedBox(
            height: 5,
          ),
          Expanded(

            child: buildItemsTypeahead(rowData),
          ),
          SizedBox(height: 5),
          Container(
            width: 46,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Qty',
                  style: TextStyle(fontSize: 13, color: Colors.black),
                ),
                SizedBox(height: 5),
                Container(
                  height: 50,
                  child: TextFormField(
                    controller: rowData.qtyController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10), // Set the width here
                    ),
                    style: TextStyle(fontSize: 11),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^0{1,}'))], // Allow backspacing over initial zeros
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a quantity.';
                      } else {
                        int? qty = int.tryParse(value);
                        if (qty == null) {
                          return 'Please enter a valid number.';
                        } else if (qty <= 0) {
                          return 'Quantity must be greater than zero.';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),


          SizedBox(height: 5),
          Container(
            width: 60,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0), // Add content padding
              child: buildNonEditableText('Rate', rowData.rateController),
            ),
          ),



          Container(
            width: 55,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0), // Add content padding
              child: buildNonEditableText('Amount', rowData.amountController),
            ),
          ),

          SizedBox(height: 10),
          Container(


            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.delete_outline, size: 20,color: Colors.red),
                onPressed: () {
                  deleteRow(rowData);
                },
              ),
            ),
          )],
      ),
    );
  }

  Widget buildItemsTypeahead(RowData rowData) {
    // final products = productsViewModel.allProducts;
    final rateController = rowData.rateController;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Item',
          style: TextStyle(fontSize: 13, color: Colors.black),
        ),
        SizedBox(height: 5),
        Container(
          height: 50, // Adjust the height as needed
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child:TypeAheadFormField<ProductsModel>(
            textFieldConfiguration: TextFieldConfiguration(
              controller: TextEditingController(
                text: rowData.selectedProduct?.product_name ?? '',
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0), // Add content padding
              ),
              style: TextStyle(fontSize: 12),
              maxLines: null,
            ),
            suggestionsCallback: (pattern) async {
              return productsViewModel.allProducts
                  .where((product) =>
                  product.product_name!
                      .toLowerCase()
                      .contains(pattern.toLowerCase()))
                  .toList();
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                title: Text(
                  suggestion.product_name ?? '',
                  style: TextStyle(fontSize: 9), // Set the desired font size
                ),
              );
            },
            onSuggestionSelected: (suggestion) {
              if (suggestion != null) {
                print('Selected product: ${suggestion.product_name}');
                setState(() {
                  rowData.selectedProduct = suggestion;
                  rowData.selectedProduct?.price ??= '';
                  rateController.text = suggestion.price ?? '';
                  calculateAmount(
                    rowData.qtyController,
                    rowData.rateController,
                    rowData.amountController,
                    rowData,
                  );
                });
              }
            },
            // Customize the appearance of the suggestion box
            suggestionsBoxDecoration: SuggestionsBoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Colors.white, // Set the background color of the suggestion box
            ),
            // Show suggestions immediately on focus
            getImmediateSuggestions: true,
            // Automatically flip the suggestion box direction based on available space
            autoFlipDirection: true,
          ),


        ),



      ],
    );
  }

  Widget buildNonEditableText(String labelText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(fontSize: 12, color: Colors.black),
        ),
        SizedBox(height: 5),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0), // Add content padding
          child: Container(
            height: 50,
            child: TextFormField(
              controller: controller,
              enabled: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              style: TextStyle(fontSize: 9),
            ),
          ),
        ),
      ],
    );
  }

  void deleteRow(RowData rowData) {
    setState(() {
      rowDataList.remove(rowData);
    });
  }

  void _calculateTotal() {
    int totalAmount = 0;

    for (var rowData in rowDataList) {
      String? qty = rowData.qtyController.text;
      String? rate = rowData.rateController.text;

      if (qty != null && rate != null) {
        try {
          int qtyValue = int.tryParse(qty) ?? 0;
          int rateValue = int.tryParse(rate) ?? 0;
          totalAmount += qtyValue * rateValue;
        } catch (e) {
          // Handle parsing errors if needed
        }
      }
    }

    setState(() {
      _totalController.text = totalAmount.toString();
    });
  }
  void _calculateSubTotal() {
    String? totalValue = _totalController.text;
    String? discountValue = _discountController.text;

    if (totalValue != null && discountValue != null) {
      try {
        int totalAmount = int.tryParse(totalValue) ?? 0;
        int discount = int.tryParse(discountValue) ?? 0;
        int subTotal = totalAmount - discount;

        setState(() {
          _subTotalController.text = subTotal.toString();
        });
      } catch (e) {
        // Handle parsing errors if needed
      }
    }
  }

  void _calculateBalance() {
    String? subTotalValue = _subTotalController.text;
    String? paymentValue = _paymentController.text;

    if (subTotalValue != null && paymentValue != null) {
      try {
        int subTotal = int.tryParse(subTotalValue) ?? 0;
        int payment = int.tryParse(paymentValue) ?? 0;
        int balance = subTotal - payment;

        setState(() {
          _balanceController.text = balance.toString();
        });
      } catch (e) {
        // Handle parsing errors if needed
      }
    }
  }

  void calculateAmount(TextEditingController qtyController,
      TextEditingController rateController,
      TextEditingController amountController,
      RowData rowData) {
    String? qty = qtyController.text;
    String? rate = rateController.text;

    if (qty != null && rate != null) {
      try {
        int qtyValue = int.tryParse(qty) ?? 0;
        int rateValue = int.tryParse(rate) ?? 0;
        int amount = qtyValue * rateValue;
        amountController.text = amount.toString();
        // After calculating individual amounts, recalculate the total
        _calculateTotal();
        _calculateSubTotal();
        _calculateBalance();
      } catch (e) {
        amountController.text = '';
      }
    } else {
      amountController.text = '';
    }
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('dd-MMM-yyyy');
    return formatter.format(now);
  }


//   String getCurrentTimeInPakistan() {
//     // Initialize the time zone data
//     tz.initializeTimeZones();
//
//     // Get the location for Asia/Karachi
//     final Location pakistanTimeZone = getLocation('Asia/Karachi');
//
//     // Create a DateTime object representing the current date and time in UTC
//     DateTime nowUtc = DateTime.now().toUtc();
//
//     // Convert the UTC time to the Pakistan time zone
//     TZDateTime nowPakistan = TZDateTime.from(nowUtc, pakistanTimeZone);
//
//     // Format the date and time using the desired format
//     String formattedDateTime = DateFormat('dd-MMM-yyyy [HH:mm a]').format(nowPakistan);
//
//     return formattedDateTime;
//   }
}
class RowData {
  final int serialNumber;
  final TextEditingController qtyController;
  final TextEditingController rateController;
  final TextEditingController amountController;
  String itemsDropdownValue;
  ProductsModel? selectedProduct;
  RowData({
    required this.serialNumber,
    required this.qtyController,
    required this.rateController,
    required this.amountController,
    required this.itemsDropdownValue,
    required this.selectedProduct,
  });
}
