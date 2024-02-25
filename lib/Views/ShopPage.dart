import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nanoid/async.dart';
import 'package:order_booking_shop/API/Globals.dart';
import 'package:order_booking_shop/View_Models/ShopViewModel.dart';
import 'package:order_booking_shop/Views/HomePage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Databases/DBHelper.dart';
import '../Models/ShopModel.dart';
import 'CurrentLocationScreen.dart';
import 'ShopList.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({Key? key}) : super(key: key);

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class AlphabeticInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Allow only alphabets
    final newText = newValue.text.replaceAll(RegExp(r'[^a-zA-Z]'), '');

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class CNICFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    // Allow only up to 13 digits
    if (text.length > 13) {
      return oldValue;
    }

    final newText = StringBuffer();

    // Add slashes after the first five digits and twelfth digit
    if (text.length > 5) {
      newText.write(text.substring(0, 5) + '-');
      if (text.length > 12) {
        newText.write(text.substring(5, 12) + '-');
        newText.write(text.substring(12));
      } else {
        newText.write(text.substring(5));
      }
    } else {
      newText.write(text);
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class _ShopPageState extends State<ShopPage> {

  final shopViewModel = Get.put(ShopViewModel());

  final shopNameController = TextEditingController();
  final cityController = TextEditingController();
  final distributorNameController = TextEditingController();
  final shopAddressController = TextEditingController();
  final ownerNameController = TextEditingController();
  final ownerCNICController = TextEditingController();
  final phoneNoController = TextEditingController();
  final alternativePhoneNoController = TextEditingController();
  static double? globalLatitude;
  static double? globalLongitude;
  int? shopId;
  String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  bool isLocationAdded = false;
  // Future<void> _openLocationScreen() async {
  //   final result = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => CurrentLocationScreen(),
  //     ),
  //   );
  //   if (result != null && result is Map<String, double>) {
  //     // Handle latitude and longitude data from CurrentLocationScreen
  //     setState(() {
  //       // Set isLocationAdded to true when location is added
  //       isLocationAdded = true;
  //       // shopViewModel.latitude = result['latitude'];
  //       // shopViewModel.longitude = result['longitude'];
  //     });
  //   }
  // }
  List<String> validCities = ['Adezai', 'Ahmed Nager Chatha', 'Ahmedpur East', 'Ali Bandar', 'Ali Pur', 'Amir Chah', 'Arifwala', 'Astor', 'Attock', 'Ayubia', 'Baden', 'Bagh', 'Bahawalnagar', 'Bahawalpur', 'Bajaur', 'Banda Daud Shah',
    'Bannu', 'Baramula', 'Basti Malook', 'Batagram', 'Bazdar', 'Bela', 'Bellpat', 'Bhagalchur', 'Bhaipheru', 'Bhakkar', 'Bhalwal', 'Bhimber', 'Birote', 'Buner', 'Burewala', 'Burj', 'Chachro', 'Chagai',
    'Chah Sandan', 'Chailianwala', 'Chakdara', 'Chakku', 'Chakwal', 'Chaman', 'Charsadda', 'Chhatr', 'Chichawatni', 'Chiniot', 'Chitral', 'Chowk Azam', 'Chowk Sarwar Shaheed', 'Dadu', 'Dalbandin', 'Dargai', 'Darya Khan',
    'Daska', 'Dera Bugti', 'Dera Ghazi Khan', 'Dera Ismail Khan', 'Derawar Fort', 'Dhana Sar', 'Dhaular', 'Digri', 'Dina City', 'Dinga', 'Dipalpur', 'Diplo', 'Diwana', 'Dokri', 'Drasan', 'Drosh', 'Duki', 'Dushi', 'Duzab',
    'Faisalabad', 'Fateh Jang', 'Gadar', 'Gadra', 'Gajar', 'Gandava', 'Garhi Khairo', 'Garruck', 'Ghakhar Mandi', 'Ghanian', 'Ghauspur', 'Ghazluna', 'Ghotki', 'Gilgit', 'Girdan', 'Gujar Khan', 'Gujranwala', 'Gujrat', 'Gulistan',
    'Gwadar', 'Gwash', 'Hab Chauki', 'Hafizabad', 'Hala', 'Hameedabad', 'Hangu', 'Haripur', 'Harnai', 'Haroonabad', 'Hasilpur', 'Haveli Lakha', 'Hinglaj', 'Hoshab', 'Hunza', 'Hyderabad', 'Islamkot', 'Ispikan', 'Jacobabad', 'Jahania',
    'Jalla Araain', 'Jamesabad', 'Jampur', 'Jamshoro', 'Janghar', 'Jati (Mughalbhin)', 'Jauharabad', 'Jhal', 'Jhal Jhao', 'Jhang', 'Jhatpat', 'Jhelum', 'Jhudo', 'Jiwani', 'Jungshahi', 'Kalabagh', 'Kalam', 'Kalandi', 'Kalat', 'Kamalia',
    'Kamararod', 'Kamokey', 'Kanak', 'Kandi', 'Kandiaro', 'Kanpur', 'Kapip', 'Kappar', 'Karachi', 'Karak', 'Karodi', 'Karor Lal Esan', 'Kashmor', 'Kasur', 'Katuri', 'Keti Bandar', 'Khairpur', 'Khanaspur', 'Khanewal', 'Khanpur', 'Kharan',
    'Kharian', 'Khokhropur', 'Khora', 'khuiratta', 'Khushab', 'Khuzdar', 'Khyber Agency', 'Kikki', 'Klupro', 'Kohan', 'Kohat', 'Kohistan', 'Kohlu', 'Korak', 'Korangi', 'Kot Addu', 'Kot Sarae', 'Kotli', 'Kotri', 'Kurram Agency', 'Laar',
    'Lahore', 'Lahri', 'Lakki Marwat', 'Lalamusa', 'Larkana', 'Lasbela', 'Latamber', 'Layyah', 'Liari', 'Lodhran', 'Loralai', 'Lower Dir', 'Lund', 'Mach', 'Madyan', 'Mailsi', 'Makhdoom Aali', 'Malakand', 'Malakand Agency', 'Mamoori', 'Mand',
    'Mandi Bahauddin', 'Mandi Warburton', 'Mangla', 'Manguchar', 'Mansehra', 'Mardan', 'Mashki Chah', 'Maslti', 'Mastuj', 'Mastung', 'Mathi', 'Matiari', 'Mehar', 'Mekhtar', 'Merui', 'Mian Channu', 'Mianez', 'Mianwali', 'Minawala', 'Miram Shah',
    'Mirpur', 'Mirpur Batoro', 'Mirpur Khas', 'Mirpur Sakro', 'Mithani', 'Mithi', 'Mohmand Agency', 'Mongora', 'Moro', 'Multan', 'Murgha Kibzai', 'Muridke', 'Murree', 'Musa Khel Bazar', 'Muzaffarabad', 'Muzaffargarh', 'Nagar', 'Nagar Parkar', 'Nagha Kalat',
    'Nal', 'Naokot', 'Narowal', 'Naseerabad', 'Naudero', 'Nauroz Kalat', 'Naushara', 'Nawabshah', 'Nazimabad', 'North Waziristan', 'Noushero Feroz', 'Nowshera', 'Nur Gamma', 'Nushki', 'Nuttal', 'Okara', 'Ormara', 'Paharpur', 'Pak Pattan', 'Palantuk', 'Panjgur',
    'Pasni', 'Pattoki', 'Pendoo', 'Peshawar', 'Piharak', 'pirMahal', 'Pirmahal', 'Pishin', 'Plandri', 'Pokran', 'Qambar', 'Qamruddin Karez', 'Qazi Ahmad', 'Qila Abdullah', 'Qila Didar Singh', 'Qila Ladgasht', 'Qila Safed', 'Qila Saifullah', 'Quetta', 'Rabwah',
    'Rahim Yar Khan', 'Raiwind', 'Rajan Pur', 'Rakhni', 'Ranipur', 'Ratodero', 'Rawalakot', 'Rawalpindi', 'Renala Khurd', 'Robat Thana', 'Rodkhan', 'Rohri', 'Sadiqabad', 'Safdar Abad – (Dhaban Singh)', 'Sahiwal', 'Saidu Sharif', 'Saindak', 'Sakesar', 'Sakrand',
    'Samberial', 'Sanghar', 'Sangla Hill', 'Sanjawi', 'Sarai Alamgir', 'Sargodha', 'Saruna', 'Shabaz Kalat', 'Shadadkhot', 'Shafqat Shaheed Chowk', 'Shahbandar', 'Shahdadpur', 'Shahpur', 'Shahpur Chakar', 'Shakargarh', 'Shangla', 'Shangrila', 'Sharam Jogizai',
    'Sheikhupura', 'Shikarpur', 'Shingar', 'Shorap', 'Sialkot', 'Sibi', 'Skardu', 'Sohawa', 'Sonmiani', 'Sooianwala', 'South Waziristan', 'Spezand', 'Spintangi', 'Sui', 'Sujawal', 'Sukkur', 'Sundar ', 'Suntsar', 'Surab', 'Swabi', 'Swat', 'Taank', 'Takhtbai',
    'Talagang', 'Tando Adam', 'Tando Allahyar', 'Tando Bago', 'Tangi', 'Tar Ahamd Rind', 'Tarbela', 'Taxila', 'Thall', 'Thalo', 'Thatta', 'Toba Tek Singh', 'Tordher', 'Tujal', 'Tump', 'Turbat', 'Umarao', 'Umarkot', 'Uthal', 'Vehari', 'Veirwaro', 'Vitakri', 'Wadh',
    'Wah Cantonment', 'Washap', 'Wasjuk', 'Yakmach' , 'Pasrur', 'Zafarwal', 'Waziranbad', 'Siraye Alamgir' ,'Kingra'];



  @override
  void initState() {

    super.initState();
    saveCurrentLocation();
    _checkUserIdAndFetchShopNames();
  }

  Future<void> saveCurrentLocation() async {
    PermissionStatus permission = await Permission.location.request();

    if (permission.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        globalLatitude  = position.latitude ;
        globalLongitude = position.longitude ;

        print('Latitude: $globalLatitude, Longitude: $globalLongitude');

        // // Using geocoding to convert latitude and longitude to an address
        // List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
        // Placemark currentPlace = placemarks[0];
        //
        // String address1 = "${currentPlace.thoroughfare} ${currentPlace.subLocality}, ${currentPlace.locality}${currentPlace.postalCode}, ${currentPlace.country}";
        // address = address1;

        //print('Address is: $address1');
      } catch (e) {
        print('Error getting location:$e');
      }
    } else {
      print('Location permission is not granted');
    }
  }
  Future<void> _checkUserIdAndFetchShopNames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != 'B0001' && userId != 'B0006' && userId != 'B0004') {
      setState(() {
        cityController.text = 'Sialkot';
      });
    } else {
      // Proceed with your logic for the specified user IDs
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                  children: <Widget>[Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Display the live date
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            ' Date: $currentDate',
                            style: TextStyle(
                              fontSize: 13,

                            ),
                          ),
                        ),
                      ), const SizedBox(height: 10),
                      Form(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            // Text Field 1 - Shop Name
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Shop Name',
                                    style:
                                    TextStyle(fontSize: 18, color: Colors.black,  fontWeight: FontWeight.bold,),
                                  ),
                                ),
                                TextFormField(
                                  controller: shopNameController,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15), // Adjust the padding as needed
                                    labelText: 'Enter Shop Name',
                                    floatingLabelBehavior: FloatingLabelBehavior.never,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'City',
                                    style:
                                    TextStyle(fontSize: 18, color: Colors.black,  fontWeight: FontWeight.bold,),
                                  ),
                                ),
                                TypeAheadFormField(
                                  enabled: userId == 'B0001' || userId == 'B0006' || userId == 'B0004',
                                  textFieldConfiguration: TextFieldConfiguration(
                                    controller: cityController,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                      labelText: 'Enter City',
                                      floatingLabelBehavior: FloatingLabelBehavior.never,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                    ),),
                                  suggestionsCallback: (pattern) {
                                    return [
                                      'Adezai', 'Ahmed Nager Chatha', 'Ahmedpur East', 'Ali Bandar', 'Ali Pur', 'Amir Chah', 'Arifwala', 'Astor', 'Attock', 'Ayubia', 'Baden', 'Bagh', 'Bahawalnagar', 'Bahawalpur', 'Bajaur', 'Banda Daud Shah',
                                      'Bannu', 'Baramula', 'Basti Malook', 'Batagram', 'Bazdar', 'Bela', 'Bellpat', 'Bhagalchur', 'Bhaipheru', 'Bhakkar', 'Bhalwal', 'Bhimber', 'Birote', 'Buner', 'Burewala', 'Burj', 'Chachro', 'Chagai',
                                      'Chah Sandan', 'Chailianwala', 'Chakdara', 'Chakku', 'Chakwal', 'Chaman', 'Charsadda', 'Chhatr', 'Chichawatni', 'Chiniot', 'Chitral', 'Chowk Azam', 'Chowk Sarwar Shaheed', 'Dadu', 'Dalbandin', 'Dargai', 'Darya Khan',
                                      'Daska', 'Dera Bugti', 'Dera Ghazi Khan', 'Dera Ismail Khan', 'Derawar Fort', 'Dhana Sar', 'Dhaular', 'Digri', 'Dina City', 'Dinga', 'Dipalpur', 'Diplo', 'Diwana', 'Dokri', 'Drasan', 'Drosh', 'Duki', 'Dushi', 'Duzab',
                                      'Faisalabad', 'Fateh Jang', 'Gadar', 'Gadra', 'Gajar', 'Gandava', 'Garhi Khairo', 'Garruck', 'Ghakhar Mandi', 'Ghanian', 'Ghauspur', 'Ghazluna', 'Ghotki', 'Gilgit', 'Girdan', 'Gujar Khan', 'Gujranwala', 'Gujrat', 'Gulistan',
                                      'Gwadar', 'Gwash', 'Hab Chauki', 'Hafizabad', 'Hala', 'Hameedabad', 'Hangu', 'Haripur', 'Harnai', 'Haroonabad', 'Hasilpur', 'Haveli Lakha', 'Hinglaj', 'Hoshab', 'Hunza', 'Hyderabad', 'Islamkot', 'Ispikan', 'Jacobabad', 'Jahania',
                                      'Jalla Araain', 'Jamesabad', 'Jampur', 'Jamshoro', 'Janghar', 'Jati (Mughalbhin)', 'Jauharabad', 'Jhal', 'Jhal Jhao', 'Jhang', 'Jhatpat', 'Jhelum', 'Jhudo', 'Jiwani', 'Jungshahi', 'Kalabagh', 'Kalam', 'Kalandi', 'Kalat', 'Kamalia',
                                      'Kamararod', 'Kamokey', 'Kanak', 'Kandi', 'Kandiaro', 'Kanpur', 'Kapip', 'Kappar', 'Karachi', 'Karak', 'Karodi', 'Karor Lal Esan', 'Kashmor', 'Kasur', 'Katuri', 'Keti Bandar', 'Khairpur', 'Khanaspur', 'Khanewal', 'Khanpur', 'Kharan',
                                      'Kharian', 'Khokhropur', 'Khora', 'khuiratta', 'Khushab', 'Khuzdar', 'Khyber Agency', 'Kikki', 'Klupro', 'Kohan', 'Kohat', 'Kohistan', 'Kohlu', 'Korak', 'Korangi', 'Kot Addu', 'Kot Sarae', 'Kotli', 'Kotri', 'Kurram Agency', 'Laar',
                                      'Lahore', 'Lahri', 'Lakki Marwat', 'Lalamusa', 'Larkana', 'Lasbela', 'Latamber', 'Layyah', 'Liari', 'Lodhran', 'Loralai', 'Lower Dir', 'Lund', 'Mach', 'Madyan', 'Mailsi', 'Makhdoom Aali', 'Malakand', 'Malakand Agency', 'Mamoori', 'Mand',
                                      'Mandi Bahauddin', 'Mandi Warburton', 'Mangla', 'Manguchar', 'Mansehra', 'Mardan', 'Mashki Chah', 'Maslti', 'Mastuj', 'Mastung', 'Mathi', 'Matiari', 'Mehar', 'Mekhtar', 'Merui', 'Mian Channu', 'Mianez', 'Mianwali', 'Minawala', 'Miram Shah',
                                      'Mirpur', 'Mirpur Batoro', 'Mirpur Khas', 'Mirpur Sakro', 'Mithani', 'Mithi', 'Mohmand Agency', 'Mongora', 'Moro', 'Multan', 'Murgha Kibzai', 'Muridke', 'Murree', 'Musa Khel Bazar', 'Muzaffarabad', 'Muzaffargarh', 'Nagar', 'Nagar Parkar', 'Nagha Kalat',
                                      'Nal', 'Naokot', 'Narowal', 'Naseerabad', 'Naudero', 'Nauroz Kalat', 'Naushara', 'Nawabshah', 'Nazimabad', 'North Waziristan', 'Noushero Feroz', 'Nowshera', 'Nur Gamma', 'Nushki', 'Nuttal', 'Okara', 'Ormara', 'Paharpur', 'Pak Pattan', 'Palantuk', 'Panjgur',
                                      'Pasni', 'Pattoki', 'Pendoo', 'Peshawar', 'Piharak', 'pirMahal', 'Pirmahal', 'Pishin', 'Plandri', 'Pokran', 'Qambar', 'Qamruddin Karez', 'Qazi Ahmad', 'Qila Abdullah', 'Qila Didar Singh', 'Qila Ladgasht', 'Qila Safed', 'Qila Saifullah', 'Quetta', 'Rabwah',
                                      'Rahim Yar Khan', 'Raiwind', 'Rajan Pur', 'Rakhni', 'Ranipur', 'Ratodero', 'Rawalakot', 'Rawalpindi', 'Renala Khurd', 'Robat Thana', 'Rodkhan', 'Rohri', 'Sadiqabad', 'Safdar Abad – (Dhaban Singh)', 'Sahiwal', 'Saidu Sharif', 'Saindak', 'Sakesar', 'Sakrand',
                                      'Samberial', 'Sanghar', 'Sangla Hill', 'Sanjawi', 'Sarai Alamgir', 'Sargodha', 'Saruna', 'Shabaz Kalat', 'Shadadkhot', 'Shafqat Shaheed Chowk', 'Shahbandar', 'Shahdadpur', 'Shahpur', 'Shahpur Chakar', 'Shakargarh', 'Shangla', 'Shangrila', 'Sharam Jogizai',
                                      'Sheikhupura', 'Shikarpur', 'Shingar', 'Shorap', 'Sialkot', 'Sibi', 'Skardu', 'Sohawa', 'Sonmiani', 'Sooianwala', 'South Waziristan', 'Spezand', 'Spintangi', 'Sui', 'Sujawal', 'Sukkur', 'Sundar ', 'Suntsar', 'Surab', 'Swabi', 'Swat', 'Taank', 'Takhtbai',
                                      'Talagang', 'Tando Adam', 'Tando Allahyar', 'Tando Bago', 'Tangi', 'Tar Ahamd Rind', 'Tarbela', 'Taxila', 'Thall', 'Thalo', 'Thatta', 'Toba Tek Singh', 'Tordher', 'Tujal', 'Tump', 'Turbat', 'Umarao', 'Umarkot', 'Uthal', 'Vehari', 'Veirwaro', 'Vitakri', 'Wadh',
                                      'Wah Cantonment', 'Washap', 'Wasjuk', 'Yakmach' , 'Pasrur', 'Zafarwal', 'Waziranbad', 'Siraye Alamgir' ,'Kingra'
                                    ].where((city) => city.toLowerCase().contains(pattern.toLowerCase())).toList();
                                  },
                                  itemBuilder: (context, suggestion) {
                                    return ListTile(
                                      title: Text(suggestion),
                                    );
                                  },
                                  onSuggestionSelected: (suggestion) {
                                    // Validate that the selected city is from the list
                                    if (['Adezai', 'Ahmed Nager Chatha', 'Ahmedpur East', 'Ali Bandar', 'Ali Pur', 'Amir Chah', 'Arifwala', 'Astor', 'Attock', 'Ayubia',
                                      'Baden', 'Bagh', 'Bahawalnagar', 'Bahawalpur', 'Bajaur', 'Banda Daud Shah', 'Bannu', 'Baramula', 'Basti Malook', 'Batagram', 'Bazdar',
                                      'Bela', 'Bellpat', 'Bhagalchur', 'Bhaipheru', 'Bhakkar', 'Bhalwal', 'Bhimber', 'Birote', 'Buner', 'Burewala', 'Burj', 'Chachro', 'Chagai',
                                      'Chah Sandan', 'Chailianwala', 'Chakdara', 'Chakku', 'Chakwal', 'Chaman', 'Charsadda', 'Chhatr', 'Chichawatni', 'Chiniot', 'Chitral', 'Chowk Azam',
                                      'Chowk Sarwar Shaheed', 'Dadu', 'Dalbandin', 'Dargai', 'Darya Khan', 'Daska', 'Dera Bugti', 'Dera Ghazi Khan', 'Dera Ismail Khan', 'Derawar Fort', 'Dhana Sar',
                                      'Dhaular', 'Digri', 'Dina', 'Dinga', 'Dipalpur', 'Diplo', 'Diwana', 'Dokri', 'Drasan', 'Drosh', 'Duki', 'Dushi', 'Duzab', 'Faisalabad', 'Fateh Jang', 'Gadar', 'Gadra',
                                      'Gajar', 'Gandava', 'Garhi Khairo', 'Garruck', 'Ghakhar Mandi', 'Ghanian', 'Ghauspur', 'Ghazluna', 'Ghotki', 'Gilgit', 'Girdan', 'Gujar Khan', 'Gujranwala', 'Gujrat', 'Gulistan',
                                      'Gwadar', 'Gwash', 'Hab Chauki', 'Hafizabad', 'Hala', 'Hameedabad', 'Hangu', 'Haripur', 'Harnai', 'Haroonabad', 'Hasilpur', 'Haveli Lakha', 'Hinglaj', 'Hoshab', 'Hunza', 'Hyderabad',
                                      'Islamkot', 'Ispikan', 'Jacobabad', 'Jahania', 'Jalla Araain', 'Jamesabad', 'Jampur', 'Jamshoro', 'Janghar', 'Jati (Mughalbhin)', 'Jauharabad', 'Jhal', 'Jhal Jhao', 'Jhang', 'Jhatpat',
                                      'Jhelum', 'Jhudo', 'Jiwani', 'Jungshahi', 'Kalabagh', 'Kalam', 'Kalandi', 'Kalat', 'Kamalia', 'Kamararod', 'Kamokey', 'Kanak', 'Kandi', 'Kandiaro', 'Kanpur', 'Kapip', 'Kappar', 'Karachi',
                                      'Karak', 'Karodi', 'Karor Lal Esan', 'Kashmor', 'Kasur', 'Katuri', 'Keti Bandar', 'Khairpur', 'Khanaspur', 'Khanewal', 'Khanpur', 'Kharan', 'Kharian', 'Khokhropur', 'Khora', 'khuiratta',
                                      'Khushab', 'Khuzdar', 'Khyber Agency', 'Kikki', 'Klupro', 'Kohan', 'Kohat', 'Kohistan', 'Kohlu', 'Korak', 'Korangi', 'Kot Addu', 'Kot Sarae', 'Kotli', 'Kotri', 'Kurram Agency', 'Laar', 'Lahore',
                                      'Lahri', 'Lakki Marwat', 'Lalamusa', 'Larkana', 'Lasbela', 'Latamber', 'Layyah', 'Liari', 'Lodhran', 'Loralai', 'Lower Dir', 'Lund', 'Mach', 'Madyan', 'Mailsi', 'Makhdoom Aali', 'Malakand', 'Malakand Agency',
                                      'Mamoori', 'Mand', 'Mandi Bahauddin', 'Mandi Warburton', 'Mangla', 'Manguchar', 'Mansehra', 'Mardan', 'Mashki Chah', 'Maslti', 'Mastuj', 'Mastung', 'Mathi', 'Matiari', 'Mehar', 'Mekhtar', 'Merui', 'Mian Channu',
                                      'Mianez', 'Mianwali', 'Minawala', 'Miram Shah', 'Mirpur', 'Mirpur Batoro', 'Mirpur Khas', 'Mirpur Sakro', 'Mithani', 'Mithi', 'Mohmand Agency', 'Mongora', 'Moro', 'Multan', 'Murgha Kibzai', 'Muridke', 'Murree',
                                      'Musa Khel Bazar', 'Muzaffarabad', 'Muzaffargarh', 'Nagar', 'Nagar Parkar', 'Nagha Kalat', 'Nal', 'Naokot', 'Narowal', 'Naseerabad', 'Naudero', 'Nauroz Kalat', 'Naushara', 'Nawabshah', 'Nazimabad', 'North Waziristan',
                                      'Noushero Feroz', 'Nowshera', 'Nur Gamma', 'Nushki', 'Nuttal', 'Okara', 'Ormara', 'Paharpur', 'Pak Pattan', 'Palantuk', 'Panjgur', 'Pasni', 'Pattoki', 'Pendoo', 'Peshawar', 'Piharak', 'pirMahal', 'Pirmahal', 'Pishin',
                                      'Plandri', 'Pokran', 'Qambar', 'Qamruddin Karez', 'Qazi Ahmad', 'Qila Abdullah', 'Qila Didar Singh', 'Qila Ladgasht', 'Qila Safed', 'Qila Saifullah', 'Quetta', 'Rabwah', 'Rahim Yar Khan', 'Raiwind', 'Rajan Pur', 'Rakhni',
                                      'Ranipur', 'Ratodero', 'Rawalakot', 'Rawalpindi', 'Renala Khurd', 'Robat Thana', 'Rodkhan', 'Rohri', 'Sadiqabad', 'Safdar Abad – (Dhaban Singh)', 'Sahiwal', 'Saidu Sharif', 'Saindak', 'Sakesar', 'Sakrand', 'Samberial',
                                      'Sanghar', 'Sangla Hill', 'Sanjawi', 'Sarai Alamgir', 'Sargodha', 'Saruna', 'Shabaz Kalat', 'Shadadkhot', 'Shafqat Shaheed Chowk', 'Shahbandar', 'Shahdadpur', 'Shahpur', 'Shahpur Chakar', 'Shakargarh', 'Shangla', 'Shangrila',
                                      'Sharam Jogizai', 'Sheikhupura', 'Shikarpur', 'Shingar', 'Shorap', 'Sialkot', 'Sibi', 'Skardu', 'Sohawa', 'Sonmiani', 'Sooianwala', 'South Waziristan', 'Spezand', 'Spintangi', 'Sui', 'Sujawal', 'Sukkur', 'Sundar', 'Suntsar',
                                      'Surab', 'Swabi', 'Swat', 'Taank', 'Takhtbai', 'Talagang', 'Tando Adam', 'Tando Allahyar', 'Tando Bago', 'Tangi', 'Tar Ahamd Rind', 'Tarbela', 'Taxila', 'Thall', 'Thalo', 'Thatta', 'Toba Tek Singh', 'Tordher', 'Tujal', 'Tump',
                                      'Turbat', 'Umarao', 'Umarkot', 'Uthal', 'Vehari', 'Veirwaro', 'Vitakri', 'Wadh', 'Wah Cantonment', 'Washap', 'Wasjuk', 'Yakmach', 'Pasrur', 'Zafarwal', 'Waziranbad', 'Siraye Alamgir' ,'Kingra'
                                    ].contains(suggestion)) {
                                      setState(() {
                                        cityController.text = suggestion;
                                      });
                                    } else {
                                      // Handle validation, for example, show an error message
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Invalid City'),
                                            content: Text('Please select a city from the provided list.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
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

                              ],
                            ),
                            const SizedBox(height: 10),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Distributor Name',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                TypeAheadFormField(
                                  textFieldConfiguration: TextFieldConfiguration(
                                    controller: distributorNameController,
                                    decoration: InputDecoration(
                                      contentPadding:
                                      EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                      labelText: 'Enter Distributor Name',
                                      floatingLabelBehavior: FloatingLabelBehavior.never,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                    ),
                                  ),
                                  suggestionsCallback: (pattern) {
                                    // Your suggestions callback for distributor names
                                    // Replace this with your actual distributor names suggestions logic
                                    return [
                                      'Distributor 1',
                                      'Distributor 2',
                                      'Distributor 3',
                                      // Add more distributor names as needed
                                    ].where((distributor) =>
                                        distributor.toLowerCase().contains(pattern.toLowerCase())).toList();
                                  },
                                  itemBuilder: (context, suggestion) {
                                    // Your itemBuilder for distributor names
                                    // Replace this with your actual distributor names itemBuilder logic
                                    return ListTile(
                                      title: Text(suggestion),
                                    );
                                  },
                                  onSuggestionSelected: (suggestion) {
                                    // Your onSuggestionSelected for distributor names
                                    // Replace this with your actual onSuggestionSelected logic
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Text Field 2 - Shop Address
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Shop Address',
                                    style:
                                    TextStyle(fontSize: 18, color: Colors.black,  fontWeight: FontWeight.bold,),
                                  ),
                                ),
                                TextFormField(
                                  controller: shopAddressController,
                                  decoration: InputDecoration( contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),                              labelText: 'Enter Shop Address',
                                    floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter some text';
                                    } else if (!RegExp(r'^[a-zA-Z]+$')
                                        .hasMatch(value)) {
                                      return 'Please enter alphabets only';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Text Field 3 - Owner Name
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Owner Name',
                                    style:
                                    TextStyle(fontSize: 18, color: Colors.black,  fontWeight: FontWeight.bold,),
                                  ),
                                ),
                                TextFormField(
                                  controller: ownerNameController,
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                    labelText: 'Enter Owner Name',
                                    floatingLabelBehavior: FloatingLabelBehavior.never,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter some text';
                                    } else if (!RegExp(r'^[a-zA-Z]+$')
                                        .hasMatch(value)) {
                                      return 'Please enter alphabets only';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height:10),

                            // Text Field 4 - Owner CNIC
                            // Text Field 4 - Owner CNIC
                            // Text Field 4 - Owner CNIC
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Owner CNIC',
                                    style:       TextStyle(fontSize: 18, color: Colors.black,  fontWeight: FontWeight.bold,),
                                  ),
                                ),
                                TextFormField(
                                  controller: ownerCNICController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(13),
                                    CNICFormatter(),
                                  ],
                                  keyboardType: TextInputType.phone, // Set the keyboard type to phone
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                    labelText: 'Enter Owner CNIC',
                                    floatingLabelBehavior: FloatingLabelBehavior.never,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    if (value.length < 13) {
                                      return 'CNIC must be at least 13 digits';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

// Text Field 5 - Phone Number
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Phone Number',
                                    style:       TextStyle(fontSize: 18, color: Colors.black,  fontWeight: FontWeight.bold,),
                                  ),
                                ),
                                TextFormField(
                                  controller: phoneNoController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(11), // Limit the length to 11 characters
                                  ],
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                    labelText: '03#########',
                                    floatingLabelBehavior: FloatingLabelBehavior.never,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter some text';
                                    } else if (value.length != 11) {
                                      return 'Phone number must be 11 digits';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),


                            const SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Alternative Phone Number',
                                    style:  TextStyle(fontSize: 18, color: Colors.black,  fontWeight: FontWeight.bold,),
                                  ),
                                ),
                                TextFormField(
                                  controller: alternativePhoneNoController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(11), // Limit the length to 11 characters
                                  ],
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                    labelText: '03#########',
                                    floatingLabelBehavior: FloatingLabelBehavior.never,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isNotEmpty && value.length != 11) {
                                      return 'Alternative phone number must be 11 digits or empty';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                            //
                            // // ElevatedButton for adding location
                            // // "Save" button with width and height
                            // Container(
                            //   constraints: BoxConstraints(
                            //     maxWidth: 200, // Set the maximum width here
                            //     maxHeight: 40, // Set the maximum height here
                            //   ),
                            //   child: ElevatedButton(
                            //     onPressed: () {
                            //       _openLocationScreen(); // Your button click logic here
                            //     },
                            //
                            //
                            //
                            //     style: ElevatedButton.styleFrom(
                            //       primary: Colors.red,
                            //       onPrimary: Colors.white,
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(10),
                            //       ),
                            //     ),
                            //     child: const Row(
                            //       mainAxisAlignment: MainAxisAlignment.center,
                            //       children: [
                            //         Icon(
                            //           Icons.location_on,
                            //           color: Colors.white,
                            //         ),
                            //         SizedBox(width: 8),
                            //         Text(
                            //           'Add Location',
                            //           style: TextStyle(
                            //             fontSize: 18,
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            // const SizedBox(height: 20),

                            // Align the "save" button to the bottom right
                            Align(
                              alignment: Alignment.bottomRight,
                              child: SizedBox(
                                width: 100,
                                height: 30,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // Validate the selected city
                                    String selectedCity = cityController.text;

                                    if (validCities.contains(selectedCity)) {
                                      // City is valid, proceed with the rest of the code

                                      // Check if the location is available
                                      //  Map<String, double?> currentLocation = CurrentLocationScreen.getCurrentLocation();
                                      //   if (currentLocation['latitude'] == null || currentLocation['longitude'] == null) {
                                      //     // Show toast message for missing location
                                      //     Fluttertoast.showToast(
                                      //       msg: 'Location not available. Please try again.',
                                      //       toastLength: Toast.LENGTH_SHORT,
                                      //       gravity: ToastGravity.BOTTOM,
                                      //       timeInSecForIosWeb: 1,
                                      //       backgroundColor: Colors.red,
                                      //       textColor: Colors.white,
                                      //       fontSize: 16.0,
                                      //     );
                                      //     return;
                                      //   }

                                      // Continue with the rest of the validation and data saving logic
                                      if (shopNameController.text.isNotEmpty &&
                                          cityController.text.isNotEmpty &&
                                          shopAddressController.text.isNotEmpty &&
                                          ownerNameController.text.isNotEmpty &&
                                          ownerCNICController.text.length >= 13 &&
                                          ownerCNICController.text.isNotEmpty &&
                                          phoneNoController.text.isNotEmpty &&
                                          alternativePhoneNoController.text.isNotEmpty) {
                                        var id = await customAlphabet('1234567890', 12);

                                        // double? latitude = currentLocation['latitude'];
                                        // double? longitude = currentLocation['longitude'];

                                        shopViewModel.addShop(ShopModel(
                                          id: int.parse(id),
                                          shopName: shopNameController.text,
                                          city: cityController.text,
                                          date: currentDate,
                                          shopAddress: shopAddressController.text,
                                          ownerName: ownerNameController.text,
                                          ownerCNIC: ownerCNICController.text,
                                          phoneNo: phoneNoController.text,
                                          alternativePhoneNo: alternativePhoneNoController.text,
                                          latitude: globalLatitude,
                                          longitude: globalLongitude,
                                          userId: userId,
                                          // ... existing parameters ...
                                          // latitude: shopViewModel.latitude,
                                          // longitude: shopViewModel.longitude,
                                        ));


                                        String shopid = await shopViewModel.fetchLastShopId();
                                        shopId = int.parse(shopid);

                                        shopNameController.text = "";
                                        cityController.text = "";
                                        shopAddressController.text = "";
                                        ownerNameController.text = "";
                                        ownerCNICController.text = "";
                                        phoneNoController.text = "";
                                        alternativePhoneNoController.text = "";

                                        DBHelper dbmaster = DBHelper();

                                        dbmaster.postShopTable();

                                        // Navigate to the home page after saving
                                        // Inside the ShopPage where you navigate back to HomePage
                                        Navigator.pop(context);
                                        HomePage(); // Stop the timer when navigating back

                                        // Show toast message
                                        Fluttertoast.showToast(
                                          msg: 'Data saved successfully!',
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.green,
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                      } else {
                                        // Show toast message for invalid input
                                        Fluttertoast.showToast(
                                          msg: 'Please fill all fields properly.',
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                      }
                                    } else {
                                      // Show toast message for invalid city
                                      Fluttertoast.showToast(
                                        msg: 'Please select a valid city.',
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
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    minimumSize: const Size(200, 50),
                                  ),
                                  child: const Text(
                                    'Save',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                  ]),
            ),
          ),
        )
        );
    }
}