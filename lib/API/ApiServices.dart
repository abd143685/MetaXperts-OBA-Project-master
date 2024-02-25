import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'AppExceptions.dart';
import 'BaseApiServices.dart';
import 'package:http/http.dart' as http;

class ApiServices extends BaseApiServices {


// Your provided OAuth and token URLs
 // final authorizationEndpoint = Uri.parse('https://apex.oracle.com/pls/apex/metaxperts/oauth');
//   final tokenEndpoint = Uri.parse('https://apex.oracle.com/pls/apex/metaxperts/oauth/token');
// // Your provided client ID and secret
//   final identifier = 'PEdOhv7Iqu4sCtQsRzbibQ..';
//   final secret = '122w1TFTxsqTwY1-nhV9fA..';

  final tokenEndpoint = Uri.parse('https://g77e7c85ff59092-db17lrv.adb.ap-singapore-1.oraclecloudapps.com/ords/metaxperts/oauth/token');

// Your provided client ID and secret
  final identifier = 'LdvnAhHGx6Li4XXJTfIW0w..';
  final secret = 'IMjAqywrUane3NA_qGVTWQ..';

// This is a URL on your application's server. The authorization server will redirect the resource owner here after they authorize.
//   final redirectUrl = Uri.parse('http://localhost:8000/callback');

  Future<oauth2.Client> getClient() async {
    return await oauth2.clientCredentialsGrant(
      tokenEndpoint,
      identifier,
      secret,
    );
  }
@override
  Future<dynamic> getApi(dynamic url) async {
    final client = await getClient();

    final response = await client.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
    dynamic responseJson = jsonDecode(response.body);
    responseJson = responseJson['items'];

    return responseJson;
  }



  @override
  Future<dynamic> postApi(var data , dynamic url)async{
    final client = await getClient();
    if (kDebugMode) {
      print(url);
      print(data);
    }

    dynamic responseJson ;
    try {

      final response = await client.post(Uri.parse(url),
          body: data
      ).timeout( const Duration(seconds: 10));
      responseJson  = returnResponse(response) ;
    }on SocketException {
      print(InternetException(''));
    }on RequestTimeOut {
      print(RequestTimeOut(''));

    }
    if (kDebugMode) {
      print(responseJson);
    }
    return responseJson ;
  }

  Future<bool> masterPost(Map<String, dynamic> data, dynamic url, ) async {
    final client = await getClient();

    if (kDebugMode) {
      print(url);
      print(data);
    }

    try {
      final response = await client.post(
        Uri.parse(url),
        body: data,  // Use the provided body if not null, otherwise fallback to data
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      } else {
        print("ERROR ${response.statusCode.toString()}");
        return false;
      }
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  dynamic returnResponse(http.Response response){
    switch(response.statusCode){
      case 200:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson ;
      case 400:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson ;

      default :
        throw FetchDataException('Error accoured while communicating with server '+response.statusCode.toString()) ;
    }
  }


  Future<bool> masterPostWithImage(Map<dynamic, dynamic> data, dynamic url, Uint8List? body) async {
    if (kDebugMode) {
      print(url);
      print(data);
    }

    try {
      // Get the OAuth2 client
      var client = await getClient();

      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add fields from the data map
      data.forEach((key, value) {
        request.fields[key.toString()] = value.toString();
      });

      // Add image if provided
      if (body != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'body',
            body,
            filename: 'shop_image.jpg', // Adjust the filename as needed
          ),
        );
      }

      // Use the client to send the request
      final streamedResponse = await client.send(request);

      // Get the response
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Successful response, you might want to handle the response further
        var result = response.body;
        print('Image uploaded successfully. Response: $result');

        if (kDebugMode) {
          print(result);
        }
        return true;
      } else {
        // Unsuccessful response
        print("ERROR ${response.statusCode.toString()}");
        return false;
      }

    } catch (e) {
      // Exception during the API request
      print(e.toString());
      return false;
    }
  }


}
