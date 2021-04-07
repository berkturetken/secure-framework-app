import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map> sendMessage(String message, String email, String productCode) async {
  var responseJson;
  final body = {
    "email": email,
    "productCode": productCode,
    "message": message,
  };
  final jsonString = json.encode(body);
  
  try {
    final response = await http.post(
      'https://h24q9fa19h.execute-api.eu-central-1.amazonaws.com/test/light-toggle',
      body: jsonString
    );
    responseJson = jsonDecode(response.body);
    print(responseJson);
  } on Exception catch(_) {
    print("Exception occurs in sendMessage() - operationsRepo...");
  }
  return responseJson;
}

Future<Map> getProducts(String email) async {
  var responseJson;
  final body = {
    "email": email,
  };
  final jsonString = json.encode(body);
  
  try {
    final response = await http.post(
      'https://h24q9fa19h.execute-api.eu-central-1.amazonaws.com/test/gateway-info',
      body: jsonString
    );
    responseJson = jsonDecode(response.body);
    print(responseJson);
  } on Exception catch(_) {
    print("Exception occurs in getProducts() - operationsRepo...");
  }
  return responseJson;
}