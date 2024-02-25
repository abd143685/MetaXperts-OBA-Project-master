// import 'package:flutter/material.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:order_booking_shop/API/Globals.dart';
// import 'package:order_booking_shop/Views/HomePage.dart';
// import '../API/DatabaseOutputs.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:fluttertoast/fluttertoast.dart';
// import '../Databases/DBHelper.dart';
// import 'CurrentLocationScreen.dart';
//
// void main() {
//   runApp(MaterialApp(
//     home: ShopListPage(
//       onShopItemSelected: (selectedShopName) {},
//     ),
//     // debugShowCheckedModeBanner: false,
//   ));
// }
//
// class ShopListPage extends StatefulWidget {
//   @override
//   _ShopListPageState createState() => _ShopListPageState();
//
//   void Function(Map<String, String>) onShopItemSelected;
//
//   ShopListPage({Key? key, required this.onShopItemSelected, this.user_name})
//       : super(key: key);
//   final String? user_name;
// }
//
// class _ShopListPageState extends State<ShopListPage> {
//   ImagePicker _imagePicker = ImagePicker();
//   bool clockedIn = false; // Define the variable here
//
//   List<String> dropdownItems = [];
//   String selectedItem = '';
//   String feedbackText = '';
//   String selectedShopOwner = '';
//   String selectedOwnerContact= '';
//   List<Map<String, dynamic>> shopOwners = [];
//
//   DBHelper dbHelper = DBHelper();
//
//   void initState() {
//     super.initState();
//     fetchShopData();
//   }
//
//   void fetchShopData() async {
//     List<String> shopNames = await dbHelper.getShopNames();
//     shopOwners = (await dbHelper.getOwnersDB())!;
//
//     setState(() {
//       dropdownItems = shopNames.toSet().toList();
//     });
//   }
//
//   void _captureImage() async {
//     final image = await _imagePicker.getImage(source: ImageSource.camera);
//     if (image != null) {
//       File capturedImage = File(image.path);
//
//       Fluttertoast.showToast(
//         msg: 'Image captured and saved.',
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: Colors.green,
//         textColor: Colors.white,
//       );
//     } else {
//       Fluttertoast.showToast(
//         msg: 'Image capture failed.',
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//       );
//     }
//   }
//
//   void navigateToHomePage() {
//     final shopData = {
//       'shopName': selectedItem,
//       'ownerName': selectedShopOwner,
//       'user_name': widget.user_name,
//       'ownerContact': selectedOwnerContact,
//     };
//     // Add the logic to navigate to the home page
//     // For example, you can use Navigator to push a new route
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => HomePage(),
//
//         settings: RouteSettings(arguments: shopData),),
//
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         toolbarHeight: 56.0,
//         backgroundColor: Colors.white,
//         actions: <Widget>[
//           SizedBox(
//             height: 16,
//           ),
//           Align(
//             alignment: Alignment.topLeft,
//             child: ElevatedButton.icon(
//               onPressed: () {
//                 DatabaseOutputs outputs = DatabaseOutputs();
//                 outputs.checkFirstRun();
//               },
//               icon: Icon(Icons.update),
//               label: Text(''),
//               style: ElevatedButton.styleFrom(
//                 primary: Colors.white,
//                 onPrimary: Colors.blue,
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//                 minimumSize: Size(
//                   80,
//                   20,
//                 ),
//               ),
//             ),
//           ),
//           PopupMenuButton(
//             icon: Icon(Icons.more_vert),
//             itemBuilder: (BuildContext context) {
//               return <PopupMenuEntry>[
//                 PopupMenuItem(
//                   child: Text('Settings'),
//                   value: 'Option 1',
//                 ),
//                 PopupMenuItem(
//                   child: Text('Log out'),
//                   value: 'Option 2',
//                 ),
//               ];
//             },
//             onSelected: (value) {
//               print('Selected: $value');
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Text(
//                   'Shop List',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 20.0),
//                 Container(
//                   padding: EdgeInsets.all(8.0),
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: Colors.grey,
//                       width: 2.0,
//                     ),
//                     borderRadius: BorderRadius.circular(12.0),
//                     color: Colors.grey[200],
//                   ),
//                   child: TypeAheadField<String>(
//                     textFieldConfiguration: TextFieldConfiguration(
//                       controller: TextEditingController(text: selectedItem),
//                       decoration: InputDecoration(
//                         hintText: '---Select Shop---',
//                       ),
//                     ),
//                     suggestionsCallback: (pattern) {
//                       return dropdownItems
//                           .where((item) =>
//                           item.toLowerCase().contains(pattern.toLowerCase()))
//                           .toList();
//                     },
//                     itemBuilder: (context, suggestion) {
//                       return ListTile(
//                         title: Text(suggestion),
//                       );
//                     },
//                     onSuggestionSelected: (suggestion) {
//                       setState(() {
//                         selectedItem = suggestion;
//                       });
//
//                       for (var owner in shopOwners) {
//                         if (owner['shop_name'] == selectedItem) {
//                           setState(() {
//                             selectedShopOwner = owner['owner_name'];
//                             selectedOwnerContact= owner['owner_contact'];
//                           });
//                         }
//                       }
//                     },
//                   ),
//                 ),
//                 SizedBox(height: 20.0),
//                 Text('Selected Item: $selectedItem'),
//                 Text('Selected Shop Owner: $selectedShopOwner'),
//                 Text('Selected Owner Contact: $selectedOwnerContact'),
//                 SizedBox(height: 20.0),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.grey[200],
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: TextField(
//                     decoration: InputDecoration(
//                       hintText: 'Feedback or Note',
//                       border: OutlineInputBorder(),
//                     ),
//                     maxLines: 3,
//                     onChanged: (text) {
//                       setState(() {
//                         feedbackText = text;
//                       });
//                     },
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: _captureImage,
//                       icon: Icon(Icons.add_a_photo),
//                       label: Text('Image'),
//                       style: ElevatedButton.styleFrom(
//                         primary: Colors.green,
//                         onPrimary: Colors.white,
//                         elevation: 10,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                         minimumSize: Size(150, 40),
//                       ),
//                     ),
//                     Spacer(),
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => CurrentLocationScreen(),
//                           ),
//                         );
//                       },
//                       icon: Icon(Icons.add_location),
//                       label: Text('live location'),
//                       style: ElevatedButton.styleFrom(
//                         primary: Colors.green,
//                         onPrimary: Colors.white,
//                         elevation: 10,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                         minimumSize: Size(150, 40),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 25),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     ElevatedButton(
//                       onPressed: () {
//
//
//
//                         navigateToHomePage();
//                         setState(() {
//                           clockedIn = !clockedIn;
//                         });
//                       },
//                       style: ElevatedButton.styleFrom(
//                         primary: Colors.green,
//                         onPrimary: Colors.white,
//                         elevation: 10,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                         minimumSize: Size(150, 40),
//                       ),
//                       child: Text(
//                         clockedIn ? 'Clock Out' : 'Clock In',
//                         style: TextStyle(
//                           fontSize: 20,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
