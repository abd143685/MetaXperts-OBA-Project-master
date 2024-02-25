import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../API/Globals.dart';
import 'package:http/http.dart' as http;

var gpx;
var track;
var segment;
var trkpt;
var longi;
var lat;

String gpxString="";

Future<void> startTimer() async {
  startTimerFromSavedTime();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Timer.periodic(Duration(seconds: 1), (timer) async {
    secondsPassed++;
    await prefs.setInt('secondsPassed', secondsPassed);
  });
}

void startTimerFromSavedTime() {
  SharedPreferences.getInstance().then((prefs) async {
    String savedTime = prefs.getString('savedTime') ?? '00:00:00';
    List<String> timeComponents = savedTime.split(':');
    int hours = int.parse(timeComponents[0]);
    int minutes = int.parse(timeComponents[1]);
    int seconds = int.parse(timeComponents[2]);
    int totalSavedSeconds = hours * 3600 + minutes * 60 + seconds;
    final now = DateTime.now();
    int totalCurrentSeconds = now.hour * 3600 + now.minute * 60 + now.second;
    secondsPassed = totalCurrentSeconds - totalSavedSeconds;
    if (secondsPassed < 0) {
      secondsPassed = 0;
    }
    await prefs.setInt('secondsPassed', secondsPassed);
    print("Loaded Saved Time");
  });
}


Future<void> postFile() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  double totalDistance = pref.getDouble("TotalDistance") ?? 0.0;
  final date = DateFormat('dd-MM-yyyy').format(DateTime.now());
  final downloadDirectory = await getDownloadsDirectory();
  final filePath = File('${downloadDirectory?.path}/track$date.gpx');

  if (!filePath.existsSync()) {
    print('File does not exist');
    return;
  }
  var request = http.MultipartRequest("POST",
      Uri.parse("https://webhook.site/400fcb1d-e07a-4aab-8228-158fada8d775"));
  var gpxFile = await http.MultipartFile.fromPath(
      'body', filePath.path);
  request.files.add(gpxFile);

  // Add other fields if needed
  request.fields['userId'] = userId;
  request.fields['userName'] = userNames;
  request.fields['fileName'] = "${_getFormattedDate1()}.gpx";
  request.fields['date'] = _getFormattedDate1();
  request.fields['totalDistance'] = "${totalDistance.toString()} KM"; // Add totalDistance as a field

  try {
    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.toBytes();
      var result = String.fromCharCodes(responseData);
      print("Results: Post Successfully");
      //deleteGPXFile();
      pref.setDouble("TotalDistance", 0.0);
    } else {
      print("Failed to upload file. Status code: ${response.statusCode}");
    }
  } catch (e) {
    print("Error: $e");
  }
}

String _getFormattedDate1() {
  final now = DateTime.now();
  final formatter = DateFormat('dd-MMM-yyyy  [hh:mm a] ');
  return formatter.format(now);
}
// Total distance is stored in the shared Prefernces "TotalDistance" when the user clock out.