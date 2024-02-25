import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nanoid/nanoid.dart';
import 'package:connectivity/connectivity.dart';
import 'package:order_booking_shop/API/Globals.dart';
import 'package:order_booking_shop/Models/AttendanceModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../API/DatabaseOutputs.dart';
import '../Tracker/trac.dart';
import '../View_Models/AttendanceViewModel.dart';
import 'login.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'OrderBookingStatus.dart';
import 'RecoveryFormPage.dart';
import 'ReturnFormPage.dart';
import 'ShopPage.dart';
import 'ShopVisit.dart';
import 'package:order_booking_shop/Databases/DBHelper.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;


//tarcker
final FirebaseAuth auth = FirebaseAuth.instance;
final User? user = auth.currentUser;
final myUid = userId;
final name = userNames;


bool showButton = false;


class MyIcons {
  static const IconData addShop = IconData(0xf52a, fontFamily: 'MaterialIcons');
  static const IconData store = Icons.store;
  static const IconData returnForm = IconData(0xee93, fontFamily: 'MaterialIcons');
  static const IconData person = Icons.person;
  static const IconData orderBookingStatus = IconData(0xf52a, fontFamily: 'MaterialIcons');
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>with WidgetsBindingObserver {
  final attendanceViewModel = Get.put(AttendanceViewModel());
  late TimeOfDay _currentTime; // Add this line
  late DateTime _currentDate;
  List<String> shopList = [];
  String? selectedShop2;
  int? attendanceId;
  late Isolate _isolate;
  int? attendanceId1;
  double? globalLatitude1;
  double? globalLongitude1;
  DBHelper dbHelper = DBHelper();

  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;
  StreamSubscription<Position>? _positionStreamSubscription;

  Future<void> _logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Clear the user ID or any other relevant data from SharedPreferences
    prefs.remove('userId');
    prefs.remove('userCitys');
    prefs.remove('userNames');
    // Add any additional logout logic here
  }

  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      // Handle the case when permission is denied
      Fluttertoast.showToast(
        msg: "Location permissions are required to clock in.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  _retrieveSavedValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
      userNames = prefs.getString('userNames') ?? '';
      userCitys = prefs.getString('userCitys') ?? '';
    });
  }
  Future<void> _toggleClockInOut() async {
    final service = FlutterBackgroundService();
    Completer<void> completer = Completer<void>();

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent users from dismissing the dialog
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );


    bool isLocationEnabled = await _isLocationEnabled();

    if (!isLocationEnabled) {
      Fluttertoast.showToast(
        msg: "Please enable GPS or location services before clocking in.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      completer.complete();
      return completer.future;
    }

    bool isLocationPermissionGranted = await _checkLocationPermission();
    if (!isLocationPermissionGranted) {
      await _requestLocationPermission();
      completer.complete();
      return completer.future;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await _getCurrentLocation();

    setState(() async {
      isClockedIn = !isClockedIn;

      if (isClockedIn) {
        locationbool = true;
        service.startService();
        var id = await customAlphabet('1234567890', 10);
        await prefs.setString('clockInId', id);
        attendanceViewModel.addAttendance(AttendanceModel(
            id: prefs.getString('clockInId'),
            timeIn: _getFormattedtime(),
            date: _getFormattedDate(),
            userId: userId.toString(),
            latIn: globalLatitude1,
            lngIn: globalLongitude1,
            bookerName: userNames
        ));
        //startTimer();
        _saveCurrentTime();
        _saveClockStatus(true);
        //_getLocation();
        //getLocation();
        _clockRefresh();
        isClockedIn = true;
        DBHelper dbmaster = DBHelper();
        dbmaster.postAttendanceTable();

      } else {
        service.invoke("stopService");
        attendanceViewModel.addAttendanceOut(AttendanceOutModel(
          id: prefs.getString('clockInId'),
          timeOut: _getFormattedtime(),
          totalTime: _formatDuration(newsecondpassed.toString()),
          date: _getFormattedDate(),
          userId: userId.toString(),
          latOut: globalLatitude1,
          lngOut: globalLongitude1,
          totalDistance: prefs.getDouble('TotalDistance')
          // posted: postedController
        ));
        isClockedIn = false;
        _saveClockStatus(false);
        DBHelper dbmaster = DBHelper();
        dbmaster.postAttendanceOutTable();
        _stopTimer();
        setState(() async {
          _clockRefresh();
          //_stopListening();
          //stopListeningnew();
          //await saveGPXFile();
          //await postFile();
          await prefs.remove('clockInId');
        });
      }
    });
    await Future.delayed(Duration(seconds: 3));
    Navigator.pop(context); // Close the loading indicator dialog
    completer.complete();
    return completer.future;
  }

  Future<bool> _isLocationEnabled() async {
    // Add your logic to check if location services are enabled
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    return isLocationEnabled;
  }
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initializeNotifications() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'clock_channel', // id
      'Clock Notifications', // title
      description: 'Notifications for clock events', // description
      importance: Importance.high, // importance must be at high or max level
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'clock_channel', // channel_id
      'Clock Notifications', // channel_name
      //: 'Notifications for clock events',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // notification id
      title,
      body,
      platformChannelSpecifics,
    );
  }

  String _getFormattedtime() {
    final now = DateTime.now();
    final formatter = DateFormat('HH:mm:ss a');
    return formatter.format(now);
  }

  _loadClockStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isClockedIn = prefs.getBool('isClockedIn') ?? false;
    print(isClockedIn.toString() + "RES B100");
    if (isClockedIn == true) {
      print("B100 CLOCKIN RUNN");
      //startTimerFromSavedTime();
      final service = FlutterBackgroundService();
      service.startService();
      //_clockRefresh();
    }else{
      prefs.setInt('secondsPassed', 0);
    }
  }

  _saveClockStatus(bool clockedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isClockedIn', clockedIn);
    isClockedIn = clockedIn;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _loadClockStatus();
    fetchShopList();
    _retrieveSavedValues();
    _clockRefresh();
    print("B1000 ${name.toString()}");
    _currentDate = DateTime.now();
    _currentTime = TimeOfDay.fromDateTime(_currentDate);
    _requestPermission();
    location.changeSettings(interval: 300, accuracy: loc.LocationAccuracy.high);
    location.enableBackgroundMode(enable: true);
    _getFormattedDate();
  }

  void _saveCurrentTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime currentTime = DateTime.now();
    String formattedTime = _formatDateTime(currentTime);
    prefs.setString('savedTime', formattedTime);
    print("Save Current Time");
  }

  String _formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('HH:mm:ss');
    return formatter.format(dateTime);
  }
  int newsecondpassed = 0;
  void _clockRefresh() async {
    newsecondpassed = 0;
    timer = Timer.periodic(Duration(seconds: 0), (timer) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        prefs.reload();
        newsecondpassed = prefs.getInt('secondsPassed')!;
      });
    });
  }

  Future<String> _stopTimer() async {
    String totalTime = _formatDuration(newsecondpassed.toString());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('secondsPassed', 0);
    setState(() {
      secondsPassed = 0;
    });
    return totalTime;
  }

  String _formatDuration(String secondsString) {
    int seconds = int.parse(secondsString);
    Duration duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String secondsFormatted = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$secondsFormatted';
  }

  @override
  void dispose() {
    timer.cancel();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await _determinePosition();
      // Save the location into the database (you need to implement this part)
      globalLatitude1 = position.latitude;
      globalLongitude1 = position.longitude;
      // Show a toast
      Fluttertoast.showToast(
        msg: 'Location captured!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      throw Exception('Location services are disabled.');
    }

    // Check the location permission status.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Location permissions are denied
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Location permissions are permanently denied
      throw Exception('Location permissions are permanently denied.');
    }

    // Get the current position
    return await Geolocator.getCurrentPosition();
  }

  Future<void> fetchShopList() async {
    List<String> fetchShopList = await fetchData();
    if (fetchShopList.isNotEmpty) {
      setState(() {
        shopList = fetchShopList;
        selectedShop2 = shopList.first;
      });
    }
  }

  Future<List<String>> fetchData() async {
    return [];
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('dd-MMM-yyyy');
    return formatter.format(now);
  }

  void handleShopChange(String? newShop) {
    setState(() {
      selectedShop2 = newShop;
    });
  }

  @override
  Widget build(BuildContext context) {


    return WillPopScope(
      onWillPop: () async {
        // Return false to prevent going back
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.green,
          toolbarHeight: 80.0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Timer: ${_formatDuration(newsecondpassed.toString())}',

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
              PopupMenuButton<int>(
                icon: Icon(Icons.more_vert),
                color: Colors.white,
                onSelected: (value) async {
                  switch (value) {
                    case 1:
                    // Check internet connection before refresh
                      final bool isConnected = await InternetConnectionChecker().hasConnection;
                      if (!isConnected) {
                        // No internet connection
                        Fluttertoast.showToast(
                          msg: "No internet connection.",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } else {
                        // Internet connection is available
                        DatabaseOutputs outputs = DatabaseOutputs();
                        // Run both functions in parallel
                        showLoadingIndicator(context);
                        await Future.wait([
                          backgroundTask(),
                          postFile(),
                          outputs.checkFirstRun(),
                          Future.delayed(Duration(seconds: 5)),
                        ]);

                        // After 10 seconds, hide the loading indicator and perform the refresh logic
                        Navigator.of(context, rootNavigator: true).pop();
                      }
                      break;

                    case 2:
                    // Handle the action for the second menu item (Log Out)
                      if (isClockedIn) {
                        // Check if the user is clocked in
                        Fluttertoast.showToast(
                          msg: "Please clock out before logging out.",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } else {
                        await _logOut();
                        // If the user is not clocked in, proceed with logging out
                        Navigator.pushReplacement(
                          // Replace the current page with the login page
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginForm(),
                          ),
                        );
                      }
                      break;
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<int>(
                      value: 1,
                      child: Text('Refresh'),
                    ),
                    PopupMenuItem<int>(
                      value: 2,
                      child: Text('Log Out'),
                    ),
                  ];
                },
              )
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 150,
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () {
                             // if (isClockedIn) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ShopPage(),
                                  ),
                                );
                            //   } else {
                            //     showDialog(
                            //       context: context,
                            //       builder: (context) => AlertDialog(
                            //         title: Text('Clock In Required'),
                            //         content: Text('Turn on location.'),
                            //         actions: [
                            //           TextButton(
                            //             onPressed: () => Navigator.pop(context),
                            //             child: Text('OK'),
                            //           ),
                            //         ],
                            //       ),
                            //     );
                            //   }
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  MyIcons.addShop,
                                  color: Colors.white,
                                  size: 50,
                                ),
                                SizedBox(height: 10),
                                Text('Add Shop'),
                              ],
                            ),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          ],
                        ),
                        SizedBox(width: 10),
                        Container(
                          height: 150,
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () {
                              // if (isClockedIn) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ShopVisit(onBrandItemsSelected: (String) {}),
                                  ),
                                );
                            //   } else {
                            //     showDialog(
                            //       context: context,
                            //       builder: (context) => AlertDialog(
                            //         title: Text('Clock In Required'),
                            //         content: Text('Please clock in before visiting a shop.'),
                            //         actions: [
                            //           TextButton(
                            //             onPressed: () => Navigator.pop(context),
                            //             child: Text('OK'),
                            //           ),
                            //         ],
                            //       ),
                            //     );
                            //   }
                             },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.store,
                                  color: Colors.white,
                                  size: 50,
                                ),
                                SizedBox(height: 10),
                                Text('Shop Visit'),
                              ],
                            ),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 150,
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () {
                             // if (isClockedIn) {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ReturnFormPage()));
                              // } else {
                              //   showDialog(
                              //     context: context,
                              //     builder: (context) => AlertDialog(
                              //       title: Text('Clock In Required'),
                              //       content: Text('Please clock in before accessing the Return Form.'),
                              //       actions: [
                              //         TextButton(
                              //           onPressed: () => Navigator.pop(context),
                              //           child: Text('OK'),
                              //         ),
                              //       ],
                              //     ),
                              //   );
                              // }
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  MyIcons.returnForm,
                                  color: Colors.white,
                                  size: 50,
                                ),
                                SizedBox(height: 10),
                                Text('Return Form'),
                              ],
                            ),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          height: 150,
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () {
                            //  if (isClockedIn) {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => RecoveryFromPage()));
                              // } else {
                              //   showDialog(
                              //     context: context,
                              //     builder: (context) => AlertDialog(
                              //       title: Text('Clock In Required'),
                              //       content: Text('Please clock in before accessing the Recovery.'),
                              //       actions: [
                              //         TextButton(
                              //           onPressed: () => Navigator.pop(context),
                              //           child: Text('OK'),
                              //         ),
                              //       ],
                              //     ),
                              //   );
                              // }
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 50,
                                ),
                                SizedBox(height: 10),
                                Text('Recovery'),
                              ],
                            ),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 150,
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () {
                             // if (isClockedIn) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderBookingStatus(),
                                  ),
                                );
                              // } else {
                              //   showDialog(
                              //     context: context,
                              //     builder: (context) => AlertDialog(
                              //       title: Text('Clock In Required'),
                              //       content: Text('Please clock in before checking Order Booking Status.'),
                              //       actions: [
                              //         TextButton(
                              //           onPressed: () => Navigator.pop(context),
                              //           child: Text('OK'),
                              //         ),
                              //       ],
                              //     ),
                              //   );
                              // }
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  MyIcons.orderBookingStatus,
                                  color: Colors.white,
                                  size: 50,
                                ),
                                SizedBox(height: 10),
                                Text('Order Booking Status'),
                              ],
                            ),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                  ]
              ),
            ),
          ),
        ),
        //
        floatingActionButton: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),

            child:ElevatedButton.icon(
              onPressed:() async {
                // await MoveToBackground.moveTaskToBack();
                final service = FlutterBackgroundService();
                await _toggleClockInOut();
              },
              icon: Icon(
                isClockedIn ? Icons.timer_off : Icons.timer,
                color: isClockedIn ? Colors.red : Colors.green,
              ),
              label: Text(
                isClockedIn ? 'Clock Out' : 'Clock In',
                style: TextStyle(fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: isClockedIn ? Colors.red : Colors.green, backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

          ),
        ),
      ),
    );
  }
  // Future<void> postFile() async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   double totalDistance = pref.getDouble("TotalDistance") ?? 0.0;
  //   final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
  //   final downloadDirectory = await getDownloadsDirectory();
  //   final filePath = File('${downloadDirectory?.path}/track$date.gpx');
  //
  //   if (!filePath.existsSync()) {
  //     print('File does not exist');
  //     return;
  //   }
  //   var request = http.MultipartRequest("POST",
  //       Uri.parse("https://webhook.site/400fcb1d-e07a-4aab-8228-158fada8d775"));
  //   var gpxFile = await http.MultipartFile.fromPath(
  //       'body', filePath.path);
  //   request.files.add(gpxFile);
  //
  //   // Add other fields if needed
  //   request.fields['userId'] = userId;
  //   request.fields['userName'] = userNames;
  //   request.fields['fileName'] = "${_getFormattedDate1()}.gpx";
  //   request.fields['date'] = _getFormattedDate1();
  //   request.fields['totalDistance'] = totalDistance.toString(); // Add totalDistance as a field
  //
  //   try {
  //     var response = await request.send();
  //     if (response.statusCode == 200) {
  //       var responseData = await response.stream.toBytes();
  //       var result = String.fromCharCodes(responseData);
  //       print("Results: Post Successfully");
  //      //deleteGPXFile();
  //       pref.setDouble("TotalDistance", 0.0);
  //     } else {
  //       print("Failed to upload file. Status code: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print("Error: $e");
  //   }
  // }

  // Future<void> deleteGPXFile() async {
  //     try {
  //       final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
  //      // final gpxString = await GpxWriter().asString(gpx, pretty: true);
  //       final downloadDirectory = await getDownloadsDirectory();
  //       final filePath = "${downloadDirectory!.path}/track$date.gpx";
  //       final file = File(filePath);
  //
  //       if (file.existsSync()) {
  //         await file.delete();
  //         print('GPX file deleted successfully');
  //       } else {
  //         print('GPX file does not exist');
  //       }
  //     } catch (e) {
  //       print('Error deleting GPX file: $e');
  //   }
  //   }

  Future<bool> requestPermissions(BuildContext context) async {
    final notificationStatus = await Permission.notification.status;
    final locationStatus = await Permission.location.status;

    if (!notificationStatus.isGranted) {
      PermissionStatus newNotificationStatus = await Permission.notification.request();

      if (newNotificationStatus.isDenied || newNotificationStatus.isPermanentlyDenied) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Permission Denied'),
              content: Text('Notification permission is required for this app to function properly. Please grant it in the app settings.'),
              actions: <Widget>[
                TextButton(
                  child: Text('Open Settings'),
                  onPressed: () {
                    openAppSettings();
                  },
                ),
              ],
            );
          },
        );
        return false;
      }
    }

    if (!locationStatus.isGranted) {
      PermissionStatus newLocationStatus = await Permission.location.request();

      if (newLocationStatus.isDenied || newLocationStatus.isPermanentlyDenied) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Permission Denied'),
              content: Text('Location permission is required for this app to function properly. Please grant it in the app settings.'),
              actions: <Widget>[
                TextButton(
                  child: Text('Open Settings'),
                  onPressed: () {
                    openAppSettings();
                  },
                ),
              ],
            );
          },
        );
        return false;
      }
    }

    return true;
  }



  void showLoadingIndicator(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Refreshing..."),
            ],
          ),
        );
      },
    );
  }

  Future<bool> isInternetConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    bool isConnected = connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi;

    print('Internet Connected: $isConnected');

    return isConnected;
  }

  Future<void> backgroundTask() async {
    try {
      bool isConnected = await isInternetConnected();

      if (isConnected) {
        print('Internet connection is available. Initiating background data synchronization.');
        await synchronizeData();
        print('Background data synchronization completed.');
      } else {
        print('No internet connection available. Skipping background data synchronization.');
      }
    } catch (e) {
      print('Error in backgroundTask: $e');
    }
  }

  Future<void> synchronizeData() async {
    print('Synchronizing data in the background.');
    await postAttendanceTable();
    await postAttendanceOutTable();
    await postShopTable();
    await postShopVisitData();
    await postStockCheckItems();
    await postMasterTable();
    await postOrderDetails();
    await postReturnFormTable();
    await postReturnFormDetails();
    await postRecoveryFormTable();
  }

  Future<void> postShopVisitData() async {
    DBHelper dbHelper = DBHelper();
    await dbHelper.postShopVisitData();
  }

  Future<void> postStockCheckItems() async {
    DBHelper dbHelper = DBHelper();
    await dbHelper.postStockCheckItems();
  }

  Future<void> postAttendanceOutTable() async {
    DBHelper dbHelper = DBHelper();
    await dbHelper.postAttendanceOutTable();
  }

  Future<void> postAttendanceTable() async {
    DBHelper dbHelper = DBHelper();
    await dbHelper.postAttendanceTable();
  }

  Future<void> postMasterTable() async {
    DBHelper dbHelper = DBHelper();
    await dbHelper.postMasterTable();
  }

  Future<void> postOrderDetails() async {
    DBHelper dbHelper = DBHelper();
    await dbHelper.postOrderDetails();
  }

  Future<void> postShopTable() async {
    DBHelper dbHelper = DBHelper();
    await dbHelper.postShopTable();
  }

  Future<void> postReturnFormTable() async {
    print('Attempting to post Return data');
    DBHelper dbHelper = DBHelper();
    await dbHelper.postReturnFormTable();
    print('Return data posted successfully');
  }

  Future<void> postReturnFormDetails() async {
    DBHelper dbHelper = DBHelper();
    await dbHelper.postReturnFormDetails();
  }

  Future<void> postRecoveryFormTable() async {
    DBHelper dbHelper = DBHelper();
    await dbHelper.postRecoveryFormTable();
  }
  _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('done');
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
  String _getFormattedDate1() {
    final now = DateTime.now();
    final formatter = DateFormat('dd-MMM-yyyy  [hh:mm a] ');
    return formatter.format(now);
  }

}