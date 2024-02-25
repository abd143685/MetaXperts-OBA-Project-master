import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:order_booking_shop/API/DatabaseOutputs.dart';
import 'package:order_booking_shop/Views/HomePage.dart';
import 'package:order_booking_shop/Views/ShopListPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../API/Globals.dart';
import '../Databases/DBHelper.dart';
import '../Models/loginModel.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void initState() {
    super.initState();
    DatabaseOutputs outputs = DatabaseOutputs();
    outputs.initializeData();
  }

  final dblogin = DBHelper();

  _login() async {
    bool isLoggedIn = await _checkLoginStatus();

    if (isLoggedIn) {
      Map<String, dynamic> dataToPass = {

        'userName': userNames

      };
      // User is already logged in, navigate to the home page directly
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => HomePage(),
            settings: RouteSettings(arguments: dataToPass)
        ),
      );
      return;
    }
    var response = await dblogin.login(
      Users(user_id: _emailController.text, password: _passwordController.text, user_name: ''),
    );


    if (response == true) {
      var userName = await dblogin.getUserName(_emailController.text);
      var userCity = await dblogin.getUserCity(_emailController.text);

      if (userName != null && userCity != null) {
        print('User Name: $userName, City: $userCity');

        // Store user inputs in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('userId', _emailController.text);
        prefs.setString('userNames', userName);
        prefs.setString('userCitys', userCity);

        // Print saved values
        print('Saved userId: ${prefs.getString('userId')}');
        print('Saved userNames: ${prefs.getString('userNames')}');
        print('Saved userCitys: ${prefs.getString('userCitys')}');

        Map<String, dynamic> dataToPass = {
          'userName': userName,
        };



        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HomePage(),
            settings: RouteSettings(arguments: dataToPass),
          ),
        );
      } else {
        print('Failed to fetch user name or city');
      }
      Fluttertoast.showToast(msg: "Successfully logged in", toastLength: Toast.LENGTH_LONG);
    } else {
      Fluttertoast.showToast(msg: "Failed login", toastLength: Toast.LENGTH_LONG);
    }
  }
  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? userNames = prefs.getString('userNames');
    String? userCitys = prefs.getString('userCitys');
    return userId != null && userId.isNotEmpty && userCitys!=null && userCitys.isNotEmpty && userNames!=null && userNames.isNotEmpty;
  }



  // void _setFirstLoginStatus(bool value) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setBool('isFirstLogin', value);
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Image.asset(
                    'assets/images/p1.png',
                    width: 250.0,
                    height: 250.0,
                  ),
                ),
                SizedBox(height: 0.0),
                Center(
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.brown,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: Colors.white, width: 1),
                  ),
                  child: Container(
                    width: 300,
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'User ID',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Container(
                          margin: EdgeInsets.all(1.0),
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Icon(
                            Icons.person,
                            color: Colors.black,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(12.0),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green, width: 0),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 0),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: Colors.white, width: 1),
                  ),
                  child: Container(
                    width: 300,
                    child: TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Container(
                          margin: EdgeInsets.all(1.0),
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Icon(
                            Icons.lock,
                            color: Colors.black,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(12.0),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                  height: 40,
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      _login();
                      // DatabaseOutputs outputs = DatabaseOutputs();
                      // outputs.checkFirstRun();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Login',
                          style: TextStyle(fontSize: 18),
                        ),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Add some space between the new text and image
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 16.0, right: 16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Image.asset(
                              'assets/images/b1.png',
                              width: 23.0,
                              height: 23.0,
                            ),
                            Text(
                              'MetaXperts',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '03456699233',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 6,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
