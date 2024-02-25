// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:fluttertoast/fluttertoast.dart';
//
//
// class CurrentLocationScreen extends StatefulWidget {
//   const CurrentLocationScreen({Key? key}) : super(key: key);
//
//   @override
//   _CurrentLocationScreenState createState() => _CurrentLocationScreenState();
//
//   // Static method to get current latitude and longitude
//   static Map<String, double?> getCurrentLocation() {
//     return {
//       'latitude': _CurrentLocationScreenState.globalLatitude,
//       'longitude': _CurrentLocationScreenState.globalLongitude
//     };
//   }
// }
//
// class _CurrentLocationScreenState extends State<CurrentLocationScreen> {
//   late GoogleMapController googleMapController;
//
//   // Variables to store latitude and longitude
//
//   static const CameraPosition initialCameraPosition = CameraPosition(
//     target: LatLng(37.42796133580664, -122.085749655962),
//     zoom: 14,
//   );
//
//   Set<Marker> markers = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("User current location"),
//         automaticallyImplyLeading: false,
//         centerTitle: true,
//       ),
//       body: GoogleMap(
//         initialCameraPosition: initialCameraPosition,
//         markers: markers,
//         zoomControlsEnabled: false,
//         mapType: MapType.normal,
//         onMapCreated: (GoogleMapController controller) {
//           googleMapController = controller;
//         },
//       ),
//       // Remove the FloatingActionButton
//     );
//   }
//
//   Future<void> _getCurrentLocation() async {
//     Position position = await _determinePosition();
//
//     // Save latitude and longitude into variables
//     globalLatitude = position.latitude;
//     globalLongitude = position.longitude;
//
//     googleMapController.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(target: LatLng(globalLatitude!, globalLongitude!), zoom: 14),
//       ),
//     );
//
//     markers.clear();
//
//     markers.add(Marker(
//       markerId: const MarkerId('currentLocation'),
//       position: LatLng(globalLatitude!, globalLongitude!),
//       infoWindow: const InfoWindow(
//         title: 'Current Location',
//         snippet: 'Your current location',
//       ),
//     ));
//
//     Fluttertoast.showToast(
//       msg: 'Location Saved',
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.BOTTOM,
//       timeInSecForIosWeb: 1,
//       backgroundColor: Colors.blue,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );
//
//     setState(() {});
//
//     // Close the page after 4 seconds
//     Future.delayed(const Duration(seconds: 3), () {
//       Navigator.pop(context);
//     });
//   }
//
//
//   Future<Position> _determinePosition() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//
//     if (!serviceEnabled) {
//       return Future.error('Location services are disabled');
//     }
//
//     permission = await Geolocator.checkPermission();
//
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//
//       if (permission == LocationPermission.denied) {
//         return Future.error("Location permission denied");
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       return Future.error('Location permissions are permanently denied');
//     }
//
//     Position position = await Geolocator.getCurrentPosition();
//
//     return position;
//     }
// }