import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:nanoid/async.dart';
import 'package:order_booking_shop/API/Globals.dart';
import 'package:order_booking_shop/View_Models/StockCheckItems.dart';
import 'package:order_booking_shop/Views/HomePage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../API/DatabaseOutputs.dart';
import '../Databases/DBHelper.dart';

import '../Models/ShopVisitModels.dart';
import '../Models/StockCheckItems.dart';
import '../View_Models/OrderViewModels/ProductsViewModel.dart';
import '../View_Models/ShopVisitViewModel.dart';
import 'FinalOrderBookingPage.dart';



void main() {
  runApp( MaterialApp(
      home: ShopVisit( onBrandItemsSelected: (String ) {  })

  ),
  );
}

class ShopVisit extends StatefulWidget {
  final Function(String) onBrandItemsSelected;
// Add this line

  const ShopVisit({
    Key? key,
    required this.onBrandItemsSelected,

  }) : super(key: key);

  @override
  _ShopVisitState createState() => _ShopVisitState();
}

class _ShopVisitState extends State<ShopVisit> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  //final productsViewModel = Get.put(ProductsViewModel());
  TextEditingController ShopNameController = TextEditingController();
  TextEditingController _brandDropDownController = TextEditingController();
  TextEditingController BookerNameController = TextEditingController();

  TextEditingController _searchController = TextEditingController();
  List<DataRow> filteredRows = [];
  void filterData(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredRows = [];
      });
    } else {
      List<DataRow> tempList = [];
      for (DataRow row in productsController.rows) {
        for (DataCell cell in row.cells) {
          if (cell.child is Text && (cell.child as Text).data!.contains(query)) {
            tempList.add(row);
            break;
          }
        }
      }
      setState(() {
        filteredRows = tempList;
      });
    }
  }
  final shopisitViewModel = Get.put(ShopVisitViewModel());
  final stockcheckitemsViewModel = Get.put(StockCheckItemsViewModel());
  int? shopVisitId;
  int? stockcheckitemsId;
  String selectedShopOwner = '';
  String selectedOwnerContact= '';
  String selectedShopOrderNo = '';
  List<Map<String, dynamic>> shopOwners = [];
  final Products productsController = Get.put(Products());


  DBHelper dbHelper = DBHelper();
  List<String> dropdownItems5 = [];
  List<String> dropdownItems = [];
  List<String> brandDropdownItems = [];
  String selectedItem ='';
  String? selectedDropdownValue;
  String selectedBrand = '';
  List<String> selectedProductNames = [];
  // Add an instance of ProductsViewModel
  ProductsViewModel productsViewModel = Get.put(ProductsViewModel());
  int serialCounter = 1;
  double currentBalance = 0.0;
  String currentUserId = '';
  String currentMonth = DateFormat('MMM').format(DateTime.now());

  get shopData => null;

  void navigateToNewOrderBookingPage(String selectedBrandName) async {
    // Set the selected shop name without navigation
    setState(() {
      selectedItem = selectedBrandName;
    });
  }
  // List<StockCheckItem> stockCheckItems = [StockCheckItem()];
  int serialNo = 1;
  final shopVisitViewModel = Get.put(ShopVisitViewModel());
  //final stockcheckitemsViewModel =Get.put(StockCheckItemsViewModel());
  ImagePicker _imagePicker = ImagePicker();
  File? _imageFile;
  bool checkboxValue1 = false;
  bool checkboxValue2 = false;
  bool checkboxValue3 = false;
  bool checkboxValue4 = false;
  String feedbackController = '';
  dynamic latitude = '';
  dynamic longitude ='';
  bool isButtonPressed = false;
  bool isButtonPressed2 = false;
  List<DataRow> rows = [];

  // Uint8List? _imageBytes;


  @override
  void initState() {

    super.initState();
    //selectedDropdownValue = dropdownItems[0]; // Default value
    _fetchBrandItemsFromDatabase();
    //fetchShopData();
    fetchShopNames();
    onCreatee();
    _loadCounter();
    //  _saveCounter();
    fetchProductsNamesByBrand();
    saveCurrentLocation();
    _checkUserIdAndFetchShopNames();
   // productsController.controllers.clear();
    // removeSavedValues(index);

  }
  Future<void> removeSavedValues(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Remove itemDesc and qty from SharedPreferences
    await prefs.remove('itemDesc$index');
    await prefs.remove('qty$index');

    print('Removed itemDesc$index and qty$index from SharedPreferences');
  }


  Future<void> _checkUserIdAndFetchShopNames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == 'B0001' || userId == 'B0006' || userId == 'B0004') {
      await fetchShopNames1();
    } else {
      await fetchShopNames();
    }
  }

  Future<void> fetchShopNames() async {
    String userCity = userCitys;
    List<dynamic> shopNames = await dbHelper.getShopNamesForCity(userCity);
    shopOwners = (await dbHelper.getOwnersDB())!;
    setState(() {
      // Explicitly cast each element to String

      dropdownItems = shopNames.map((dynamic item) => item.toString()).toSet().toList();
    });
  }


  Future<void> fetchShopNames1() async {

    List<dynamic> shopNames = await dbHelper.getShopNames();
    shopOwners = (await dbHelper.getOwnersDB())!;
    setState(() {
      // Explicitly cast each element to String

      dropdownItems = shopNames.map((dynamic item) => item.toString()).toSet().toList();
    });
  }

  Future<void> saveCurrentLocation() async {
    PermissionStatus permission = await Permission.location.request();

    if (permission.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        latitude  = position.latitude ;
        longitude = position.longitude ;


        print('Latitude: $latitude, Longitude: $longitude');

        // Using geocoding to convert latitude and longitude to an address
        List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
        Placemark currentPlace = placemarks[0];

        String address1 = "${currentPlace.thoroughfare} ${currentPlace.subLocality}, ${currentPlace.locality}${currentPlace.postalCode}, ${currentPlace.country}";
        address = address1;

        print('Address is: $address1');
      } catch (e) {
        print('Error getting location:$e');
      }
    } else {
      print('Location permission is not granted');
    }
  }

  _loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      serialCounter = prefs.getInt('serialCounter') ?? 1;
      currentMonth = prefs.getString('currentMonth') ?? currentMonth;
      currentUserId = prefs.getString('currentUserId') ?? ''; // Add this line
    });
  }

  _saveCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('serialCounter', serialCounter);
    await prefs.setString('currentMonth', currentMonth);
    await prefs.setString('currentUserId', currentUserId); // Add this line
  }

  String generateNewOrderId( String userId) {
    String currentMonth = DateFormat('MMM').format(DateTime.now());

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
//set state
    String orderId =
        "$userId-$currentMonth-${serialCounter.toString().padLeft(3, '0')}";
    serialCounter++;
    _saveCounter(); // Save the updated counter value, current month, and userId
    return orderId;
  }


  Future<void> onCreatee() async {
    DatabaseOutputs db = DatabaseOutputs();
    await db.showShopVisit();
    await db.showStockCheckItems();
    // DatabaseOutputs outputs = DatabaseOutputs();
    //  outputs.checkFirstRun();
  }


  // Method to fetch brand items from the database.
  void _fetchBrandItemsFromDatabase() async {
    DBHelper dbHelper = DBHelper();
    List<String> brandItems = await dbHelper.getBrandItems();

    // Remove duplicates from the shopNames list
    List<String> uniqueBrandNames = brandItems.toSet().toList();

    // Set the retrieved brand items in the state.
    setState(() {
      brandDropdownItems = uniqueBrandNames;
    });
  }
  Future<void> saveImage()  async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/captured_image.jpg';

      // Compress the image76
      Uint8List? compressedImageBytes = await FlutterImageCompress.compressWithFile(
        _imageFile!.path,
        minWidth: 400,
        minHeight: 600,
        quality:40,
      );

      // Save the compressed image
      await File(filePath).writeAsBytes(compressedImageBytes!);

      print('Compressed image saved successfully at $filePath');
    } catch (e) {
      print('Error compressing and saving image: $e');
    }
  }


  @override
  Widget build(BuildContext context) {

    ShopNameController.text= selectedItem;
    BookerNameController.text= userNames;

    return Scaffold(
      appBar: AppBar(
        title: Text('Shop Visit'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        ' Date: ${_getFormattedDate()}',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Shop Name',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    Container(
                      height: 30,
                      child: TypeAheadField<String>(
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: TextEditingController(text: selectedItem),
                          decoration: InputDecoration(
                            enabled: false,
                            hintText: '---Select Shop---',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 6.0,horizontal: 8.0),
                          ),
                        ),
                        suggestionsCallback: (pattern) {
                          return dropdownItems
                              .where((item) => item.toLowerCase().contains(pattern.toLowerCase()))
                              .toList();
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            title: Text(suggestion),
                          );
                        },
                        onSuggestionSelected: (suggestion)  {
                          // Validate that the selected item is from the list
                          if (dropdownItems.contains(suggestion)) {
                            setState(() {
                              selectedItem = suggestion;
                              shopName = selectedItem;
                            });

                            for (var owner in shopOwners) {
                              if (owner['shop_name'] == selectedItem) {
                                setState(() {
                                  selectedShopOwner = owner['owner_name'];
                                  selectedOwnerContact = owner['phone_no'];
                                });
                              }
                            }
                            productsController.rows;
                            productsController.fetchProducts();
                            for (int i = 0; i < productsController.rows.length; i++) {
                              removeSavedValues(i);
                            }



                          }
                        },
                      ),
                    ),


                    SizedBox(height: 20.0),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Booker Name',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    Container(
                      height: 30,
                      child: TextFormField(enabled: false,
                        controller: BookerNameController,

                        decoration: InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 6.0,horizontal: 8.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),

                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Brand',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 30,
                            child: TypeAheadFormField<String>(
                              textFieldConfiguration: TextFieldConfiguration(
                                decoration: InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 6.0,horizontal: 8.0),
                                  enabled: false,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                                controller: _brandDropDownController,
                              ),
                              suggestionsCallback: (pattern) {
                                return brandDropdownItems
                                    .where((item) => item.toLowerCase().contains(pattern.toLowerCase()))
                                    .toList();
                              },
                              itemBuilder: (context, itemData) {
                                return ListTile(
                                  title: Text(itemData),
                                );
                              },
                              onSuggestionSelected: (itemData) async {
                                // Validate that the selected item is from the list
                                if (brandDropdownItems.contains(itemData)) {
                                  setState(() {
                                    _brandDropDownController.text = itemData;
                                    globalselectedbrand = itemData;
                                  });
                                  // Call the callback to pass the selected brand to FinalOrderBookingPage
                                  widget.onBrandItemsSelected(itemData);
                                  print('Selected Brand: $itemData');
                                  print(globalselectedbrand);
                                  productsController.fetchProducts();
                                  for (int i = 0; i < productsController.rows.length; i++) {
                                    removeSavedValues(i);
                                  }
                                  productsController.controllers.clear();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Checklist',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '1-Stock Check (Current Balance)',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
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
                                                filterData(query);
                                              },
                                              decoration: InputDecoration(
                                                labelText: 'Search',
                                                hintText: 'Type to search...',
                                                prefixIcon: Icon(Icons.search),
                                              ),
                                            ),
                                          ),
                                          SingleChildScrollView(
                                            scrollDirection: Axis.vertical, // Add vertical scroll direction
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: DataTable(
                                                columns: [
                                                  DataColumn(label: Text('Product')),
                                                  DataColumn(label: Text('Quantity')),
                                                ],
                                                rows: filteredRows.isNotEmpty ? filteredRows : productsController.rows,
                                              ),
                                            ),
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

                    SizedBox(height: 20),
                    Column(
                      children: [
                        buildRow('1-Performed Store Walkthrough', checkboxValue1, (bool? value) {
                          if (value != null) {
                            setState(() {
                              checkboxValue1 = value;
                              // checkbox= checkboxValue1;
                            });
                          }
                        }),
                        buildRow('2-Update Store Planogram', checkboxValue2, (bool? value) {
                          if (value != null) {
                            setState(() {
                              checkboxValue2 = value;
                              // checkbox2= checkboxValue2;
                            });
                          }
                        }),
                        buildRow('3-Shelf tags and price signage check', checkboxValue3, (bool? value) {
                          if (value != null) {
                            setState(() {
                              checkboxValue3 = value;
                              //    checkbox3= checkboxValue3;
                            });
                          }
                        }),
                        buildRow('4-Expiry date on product reviewed', checkboxValue4, (bool? value) {
                          if (value != null) {
                            setState(() {
                              checkboxValue4 = value;
                              // checkbox4= checkboxValue4;
                            });
                          }
                        }),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              final image = await _imagePicker.getImage(
                                source: ImageSource.camera,
                                imageQuality: 40, // Adjust the quality (0 to 100)
                              );

                              if (image != null) {
                                setState(() {
                                  _imageFile = File(image.path);

                                  shopData?['imagePath'] = _imageFile!.path;

                                  // // Convert the image file to bytes and store it in _imageBytes
                                  // List<int> imageBytesList = _imageFile!.readAsBytesSync();
                                  // _imageBytes = Uint8List.fromList(imageBytesList);
                                });

                                // Save only the image
                                await saveImage();

                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text('No image selected.'),
                                ));
                              }
                            } catch (e) {
                              print('Error capturing image: $e');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Text('+ Add Photo'),
                        ),
                        SizedBox(height: 10),
                        // Add the Stack widget to overlay the warning icon on top of the image
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_imageFile != null)
                              Image.file(
                                _imageFile!,
                                height: 400,
                                width: 600,
                                fit: BoxFit.cover,
                              ),
                            if (_imageFile == null)
                              Icon(
                                Icons.warning,
                                color: Colors.red,
                                size: 48,
                              ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text('Feedback/ Special Note'),
                        SizedBox(height: 20.0),
                        // Feedback or Note Box
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10.0),

                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Feedback or Note',
                              border: InputBorder.none,
                            ),
                            maxLines: 3,
                            onChanged: (text) {
                              setState(() {
                                feedbackController = text;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: isButtonPressed
                              ? null
                              : () async {
                            setState(() {
                              isButtonPressed = true;
                            });

                            // bool allRowsFilled = stockCheckItems.every((item) =>
                            // item.itemDescriptionController.text.isNotEmpty &&
                            //     item.qtyController.text.isNotEmpty);

                            // if (!allRowsFilled) {
                            //   Fluttertoast.showToast(
                            //     msg: 'Please fill all stock check items before proceeding.',
                            //     toastLength: Toast.LENGTH_SHORT,
                            //     gravity: ToastGravity.BOTTOM,
                            //     backgroundColor: Colors.red,
                            //     textColor: Colors.white,
                            //   );
                            //   setState(() {
                            //     isButtonPressed = false;
                            //   });
                            //   return;
                            // }

                            if (!checkboxValue1 ||
                                !checkboxValue2 ||
                                !checkboxValue3 ||
                                !checkboxValue4) {
                              Fluttertoast.showToast(
                                msg: 'Please complete all tasks before proceeding.',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );

                              setState(() {
                                checkboxValue1 = false;
                                checkboxValue2 = false;
                                checkboxValue3 = false;
                                checkboxValue4 = false;
                              });

                              setState(() {
                                isButtonPressed = false;
                              });
                              return;
                            }

                            if (_imageFile == null ||
                                ShopNameController.text.isEmpty ||
                                BookerNameController.text.isEmpty ||
                                _brandDropDownController.text.isEmpty) {
                              Fluttertoast.showToast(
                                msg: 'Please fulfill all requirements before proceeding.',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );
                              setState(() {
                                isButtonPressed = false;
                              });
                              return;
                            }

                            String imagePath =  _imageFile!.path;
                            var id = await customAlphabet('1234567890', 10);
                            List<int> imageBytesList = await File(imagePath).readAsBytes();
                            Uint8List? imageBytes = Uint8List.fromList(imageBytesList);
                            String NewOrderId = generateNewOrderId(userId.toString());
                            OrderMasterid= NewOrderId;
                            print(OrderMasterid);


                            shopVisitViewModel.addShopVisit(ShopVisitModel(
                              id: int.parse(id),
                              shopName: ShopNameController.text,
                              userId: userId,
                              bookerName: BookerNameController.text,
                              brand:_brandDropDownController.text,
                              date:_getFormattedDate(),
                              walkthrough: checkboxValue1,
                              planogram: checkboxValue2,
                              signage: checkboxValue3,
                              productReviewed: checkboxValue4,
                              address: address,
                              body: imageBytes,
                              longitude: longitude,
                              latitude: latitude,
                            ));

                            String visitId =
                            await shopVisitViewModel.fetchLastShopVisitId();
                            shopVisitId = int.parse(visitId);
                            // Extract data from DataTable rows
                            // Extract data from DataTable rows with non-zero quantities
                            List<Map<String, dynamic>> rowDataDetails = [];

                            List<StockCheckItemsModel> stockCheckItemsList = [];
                            SharedPreferences prefs = await SharedPreferences.getInstance();

                            for (int i = 0; i < (filteredRows.isNotEmpty ? filteredRows : productsController.rows).length; i++) {
                              DataRow row = (filteredRows.isNotEmpty ? filteredRows : productsController.rows)[i];
                              String itemDesc = row.cells[0].child?.toString() ?? '';
                              String qty = productsController.controllers[i].text; // Get the value from the controller

                              // Only add the item if qty is not null or empty
                              if (int.parse(qty) != 0) {
                                stockCheckItemsList.add(
                                  StockCheckItemsModel(
                                    shopvisitId: shopVisitId,
                                    itemDesc: itemDesc,
                                    qty: qty,
                                  ),
                                );

                                // Store itemDesc and qty into SharedPreferences
                                await prefs.setString('itemDesc$i', itemDesc);
                                await prefs.setString('qty$i', qty);
                                // Print itemDesc and qty
                                print('itemDesc$i: $itemDesc');
                                print('qty$i: $qty');
                              }
                            }


                            // productsController.navigateToFinalOrderBookingPage();



                            // }

                            // Check if there are any non-zero quantity items
                            if (stockCheckItemsList.isEmpty) {
                              Fluttertoast.showToast(
                                msg: 'Please enter quantities greater than zero before proceeding.',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );
                              setState(() {
                                isButtonPressed = false;
                              });
                              return;
                            }

                            // Call the method to add stock check items to the database
                            for (var stockCheckItems in stockCheckItemsList) {
                              await stockcheckitemsViewModel.addStockCheckItems(stockCheckItems);
                            }



                            // Display success message
                            // Fluttertoast.showToast(
                            //   msg: 'Stock check items saved successfully!',
                            //   toastLength: Toast.LENGTH_SHORT,
                            //   gravity: ToastGravity.BOTTOM,
                            //   backgroundColor: Colors.green,
                            //   textColor: Colors.white,
                            // );

                            DBHelper dbShop = DBHelper();
                            dbShop.postShopVisitData();
                            dbShop.postStockCheckItems();

                            // Fluttertoast.showToast(
                            //   msg: 'Data saved successfully!',
                            //   toastLength: Toast.LENGTH_SHORT,
                            //   gravity: ToastGravity.BOTTOM,
                            //   backgroundColor: Colors.green,
                            //   textColor: Colors.white,
                            // );


                            // Navigate to the FinalOrderBookingPage only if all validations pass
                            Map<String, dynamic> dataToPass = {
                              'shopName': ShopNameController.text,
                              'ownerName': selectedShopOwner.toString(),
                              'selectedBrandName': _brandDropDownController.text,
                              'userName': BookerNameController.text,
                              'ownerContact': selectedOwnerContact.toString(),
                              //  'rowDataDetails': rowDataDetails,

                            };

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FinalOrderBookingPage(),
                                settings: RouteSettings(arguments: dataToPass),

                              ),
                            );

                            setState(() {
                              isButtonPressed = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Text('+ Order Booking Form'),
                        ),

                        SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: isButtonPressed2
                              ? null
                              : () async {
                            setState(() {
                              isButtonPressed2 = true;
                            });

                            // bool allRowsFilled = stockCheckItems.every((item) =>
                            // item.itemDescriptionController.text.isNotEmpty &&
                            //     item.qtyController.text.isNotEmpty);

                            // if (!allRowsFilled) {
                            //   Fluttertoast.showToast(
                            //     msg: 'Please fill all stock check items before proceeding.',
                            //     toastLength: Toast.LENGTH_SHORT,
                            //     gravity: ToastGravity.BOTTOM,
                            //     backgroundColor: Colors.red,
                            //     textColor: Colors.white,
                            //   );
                            //   setState(() {
                            //     isButtonPressed2 = false;
                            //   });
                            //   return;
                            // }

                            if (!checkboxValue1 ||
                                !checkboxValue2 ||
                                !checkboxValue3 ||
                                !checkboxValue4) {
                              Fluttertoast.showToast(
                                msg: 'Please complete all tasks before proceeding.',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );

                              setState(() {
                                checkboxValue1 = false;
                                checkboxValue2 = false;
                                checkboxValue3 = false;
                                checkboxValue4 = false;
                              });

                              setState(() {
                                isButtonPressed2 = false;
                              });
                              return;
                            }

                            if (_imageFile == null ||
                                ShopNameController.text.isEmpty ||
                                BookerNameController.text.isEmpty ||
                                _brandDropDownController.text.isEmpty) {
                              Fluttertoast.showToast(
                                msg: 'Please fulfill all requirements before proceeding.',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );
                              setState(() {
                                isButtonPressed2 = false;
                              });
                              return;
                            }

                            String imagePath = _imageFile!.path;
                            var id = await customAlphabet('1234567890', 12);
                            List<int> imageBytesList = await File(imagePath).readAsBytes();
                            Uint8List? imageBytes = Uint8List.fromList(imageBytesList);

                            shopVisitViewModel.addShopVisit(ShopVisitModel(
                              id: int.parse(id),
                              shopName: ShopNameController.text,
                              userId: userId,
                              bookerName: BookerNameController.text,
                              brand: _brandDropDownController.text,
                              date: _getFormattedDate(),
                              walkthrough: checkboxValue1,
                              planogram: checkboxValue2,
                              signage: checkboxValue3,
                              productReviewed: checkboxValue4,
                              address: address,
                              body: imageBytes,
                              latitude: latitude,
                              longitude: longitude,
                            ));

                            String visitId =
                            await shopisitViewModel.fetchLastShopVisitId();
                            shopVisitId = int.parse(visitId);

                            // List<Map<String, dynamic>> stockCheckItemsDetails = [];
                            // for (var stockCheckItem in stockCheckItems) {
                            //   String selectedItem =
                            //       stockCheckItem.itemDescriptionController.text;
                            //   int quantity =
                            //       int.tryParse(stockCheckItem.qtyController.text) ?? 0;
                            //
                            //   stockCheckItemsDetails.add({
                            //     'selectedItem': selectedItem,
                            //     'quantity': quantity,
                            //   });
                            // }
                            //
                            // saveStockCheckItems();

                            DBHelper dbshop = DBHelper();

                            dbshop.postShopVisitData();
                            dbshop.postStockCheckItems();



                            // Additional validation that everything must be filled
                            if (ShopNameController.text.isNotEmpty &&
                                BookerNameController.text.isNotEmpty &&
                                _brandDropDownController.text.isNotEmpty) {
                              Navigator.pop(context);
                              // Stop the timer on the home page
                              HomePage();
                            } else {
                              Fluttertoast.showToast(
                                msg: 'Please fill all fields before proceeding.',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );
                            }

                            setState(() {
                              isButtonPressed2 = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Text('No Order'),
                        ),

                        SizedBox(height: 50),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // void saveStockCheckItems() async {
  //   List<StockCheckItemsModel> stockCheckItemsList = [];
  //
  //   for (var stockCheckItem in stockCheckItems) {
  //     final stockCheckItems = StockCheckItemsModel(
  //       shopvisitId: shopVisitId ?? 0,
  //       itemDesc: stockCheckItem.itemDescriptionController.text, // Access the text value
  //       qty: int.tryParse(stockCheckItem.qtyController.text) ?? 0,
  //     );
  //     stockCheckItemsList.add(stockCheckItems);
  //   }
  //
  //   await DBHelper().addStockCheckItems(stockCheckItemsList);
  // }


  Widget buildRow(String text, bool value, void Function(bool?) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyle(fontSize: 14, color: Colors.black),
        ),
        Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              checkColor: Colors.white,
              activeColor: Colors.green,
            ),
            if (!value)
              Icon(
                Icons.warning,
                color: Colors.red,
                size: 24,
              ),
          ],
        ),
      ],
    );
  }

  // void addStockCheckItem() {
  //   setState(() {
  //     stockCheckItems.add(StockCheckItem());
  //   });
  // }
  //
  // void deleteStockCheckItem(int index) {
  //   setState(() {
  //     stockCheckItems.removeAt(index);
  //   });
  // }

  String _getFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('dd-MMM-yyyy');
    return formatter.format(now);
  }

  void onBrandSelected(String selectedBrand) {
    setState(() {
      _brandDropDownController.text = selectedBrand;
    });
  }

  Future<void> fetchProductsNamesByBrand() async {
    String selectedBrand = globalselectedbrand;
    DBHelper dbHelper = DBHelper();
    List<dynamic> productNames = await dbHelper.getProductsNamesByBrand(selectedBrand);

    setState(() {
      // Explicitly cast each element to String
      dropdownItems5 = productNames.map((dynamic item) => item.toString()).toSet().toList();
    });
  }


}

class StockCheckItem {
  TextEditingController itemDescriptionController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  String? selectedDropdownValue;
}

// class StockCheckItemRow extends StatelessWidget {
//   final StockCheckItem stockCheckItem;
//   final int serialNo;
//   final VoidCallback onDelete;
//   final List<String> dropdownItems;
//   final List<String> selectedProductNames;
//   final productsViewModel = Get.put(ProductsViewModel());
//   StockCheckItemRow({
//     required this.stockCheckItem,
//     required this.serialNo,
//     required this.onDelete,
//     required this.dropdownItems,
//     required this.selectedProductNames,
//
//   });

// @override
// Widget build(BuildContext context) {
//   return Column(
//     children: [
//       Row(
//         children: [
//           Text(
//             '$serialNo',
//             style: TextStyle(fontSize: 16, color: Colors.black),
//           ),
//           SizedBox(width: 20),
//       //     Container(
//       //       width: 179.5,
//       //       height: 50,
//       //       margin: const EdgeInsets.all(0.5),
//       //       child: Padding(
//       //         padding: const EdgeInsets.symmetric(vertical: 0.50, horizontal: 0.10),
//       //         child: TypeAheadFormField<ProductsModel>(
//       //           textFieldConfiguration: TextFieldConfiguration(
//       //             decoration: InputDecoration(
//       //
//       //               border: OutlineInputBorder(
//       //                 borderRadius: BorderRadius.circular(5.0),
//       //               ),
//       //               contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 3.0),
//       //             ),
//       //             controller: stockCheckItem.itemDescriptionController,
//       //             style: TextStyle(fontSize: 12),
//       //             maxLines: null,
//       //           ),
//       //           suggestionsCallback: (pattern) async {
//       //             await productsViewModel.fetchProductsByBrand(globalselectedbrand);
//       //
//       //             return productsViewModel.allProducts
//       //                 .where((product) =>
//       //             product.product_name?.toLowerCase().contains(pattern.toLowerCase()) ?? false)
//       //                 .toList();
//       //           },
//       //           itemBuilder: (context, itemData) {
//       //             return ListTile(
//       //               title: Text(itemData.product_name ?? ''),
//       //               tileColor: stockCheckItem.selectedDropdownValue == itemData.product_name
//       //                   ? Colors.grey
//       //                   : Colors.transparent,
//       //             );
//       //           },
//       //           onSuggestionSelected: (itemData) {
//       //             // Only set the state if the selected item is in the suggestions list
//       //             if (productsViewModel.allProducts.contains(itemData)) {
//       //               stockCheckItem.selectedDropdownValue = itemData.product_name;
//       //               stockCheckItem.itemDescriptionController.text = itemData.product_name ?? '';
//       //             }
//       //           },
//       //           suggestionsBoxDecoration: SuggestionsBoxDecoration(),
//       //         ),
//       //       ),
//       //     ),
//       //     SizedBox(width: 10),
//       //     Container(
//       //       width: 60,
//       //       height: 50,
//       //       child: TextFormField(
//       //         controller: stockCheckItem.qtyController,
//       //         decoration: InputDecoration(
//       //           border: OutlineInputBorder(
//       //             borderRadius: BorderRadius.circular(5.0),
//       //           ),
//       //         ),
//       //         style: TextStyle(fontSize: 11),
//       //         keyboardType: TextInputType.number,
//       //         inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'^0{1,}'))], // Allow backspacing over initial zeros
//       //         validator: (value) {
//       //           if (value == null || value.isEmpty) {
//       //             return 'Please enter a quantity.';
//       //           } else {
//       //             int? qty = int.tryParse(value);
//       //             if (qty == null) {
//       //               return 'Please enter a valid number.';
//       //             } else if (qty <= 0) {
//       //               return 'Quantity must be greater than zero.';
//       //             }
//       //           }
//       //           return null;
//       //         },
//       //       ),
//       //     ),
//       //     SizedBox(width: 0),
//       //     IconButton(
//       //       icon: Icon(Icons.delete_outline, size: 20, color: Colors.red),
//       //       onPressed: onDelete,
//       //     ),
//         ],
//       ),
//       // Optionally, you can add a SizedBox for spacing between columns
//       SizedBox(height: 10),
//     ],
//   );
// }
// }


class Products extends GetxController {
  final productsViewModel = ProductsViewModel();
  RxList<DataRow> rows = <DataRow>[].obs;
  List<TextEditingController> controllers = [];

  Future<void> fetchProducts() async {
    await productsViewModel.fetchProductsByBrand(globalselectedbrand);
    var products = productsViewModel.allProducts;

    // Clear existing rows and controllers before adding new ones
    rows.clear();
    controllers.clear();

    for (var product in products) {
      var controller = TextEditingController(text: '0'); // Set default value here
      FocusNode focusNode = FocusNode();
      controllers.add(controller);

      focusNode.addListener(() {
        if (!focusNode.hasFocus && controller.text.isEmpty) {
          controller.text = '0';
        }
      });

      rows.add(DataRow(cells: [
        DataCell(Text(product.product_name ?? '')),
        DataCell(TextField(
          controller: controller,
          focusNode: focusNode, // Assign the FocusNode
          keyboardType: TextInputType.number,
          onTap: () {
            controller.clear(); // Clear the text when the TextField is focused
          },
        ))
      ]));
    }
  }

}




