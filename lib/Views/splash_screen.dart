import 'dart:async';

import 'package:flutter/material.dart';
import 'package:order_booking_shop/Views/HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';
//import 'package:google_map_live/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () async {
      bool isLoggedIn = await _checkLoginStatus();

      if (isLoggedIn) {
        // Redirect to the home page if the user is already logged in
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => HomePage(),
             // settings: RouteSettings(arguments: dataToPass)
          ),
        );
      } else {
        // Redirect to the login page if the user is not logged in
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LoginForm(),
            // settings: RouteSettings(arguments: dataToPass)
          ),
        );
      }
    });
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? userNames = prefs.getString('userNames');
    String? userCitys = prefs.getString('userCitys');
    return userId != null && userId.isNotEmpty && userCitys!=null && userCitys.isNotEmpty && userNames!=null && userNames.isNotEmpty;
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Image.asset('assets/images/courage.jpeg'))
      //  Center(
      //   child: Text(
      //     'COURAGE ERP',
      //     textAlign: TextAlign.center,
      //   ),
      // ),

      // body: GeneralExceptionWidget(
      //   onPress: () {},
      // ),

      //   body: const Image(image: AssetImage(ImageAssets.oms)),
      //   floatingActionButton: FloatingActionButton(onPressed: () {
      //     Utils.toastMessageCenter('Hello Ali');
      //   }),
    );
  }
}
