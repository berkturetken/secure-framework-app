import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map> ownerSignUp(String credentials) async {
  var responseJson;
  final body = {
    "message": credentials,
  };
  final jsonString = json.encode(body);

  try {
    final response = await http.post(
      'https://h24q9fa19h.execute-api.eu-central-1.amazonaws.com/test/signup',
      body: jsonString,
    );
    responseJson = jsonDecode(response.body);
    print(responseJson);
  } on Exception catch (_) {
    print("Exception occurs in ownerSignUp() --- signUpRepo ...");
  }
  return responseJson;
}

Future<Map> residentSignUp(String credentials) async {
  var responseJson;
  final body = {
    "message": credentials,
  };
  final jsonString = json.encode(body);

  try {
    final response = await http.post(
      'https://h24q9fa19h.execute-api.eu-central-1.amazonaws.com/test/signupresident',
      body: jsonString,
    );
    responseJson = jsonDecode(response.body);
    print(responseJson);
  } on Exception catch (_) {
    print("Exception occurs in residentSignUp() --- signUpRepo ...");
  }
  return responseJson;
}