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
      'https://h24q9fa19h.execute-api.eu-central-1.amazonaws.com/test/command',
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

Future<Map> addNewResident(String email, String message) async {
  var responseJson;
  final body = {
    "email": email,
    "message": message
  };
  final jsonString = json.encode(body);
  
  try {
    final response = await http.post(
      'https://h24q9fa19h.execute-api.eu-central-1.amazonaws.com/test/addresident',
      body: jsonString
    );
    responseJson = jsonDecode(response.body);
    print(responseJson);
  } on Exception catch(_) {
    print("Exception occurs in addNewResident() - operationsRepo...");
  }
  return responseJson;
}

Future<Map> getStatus(String productCode, String email) async {
  var responseJson;
  final body = {
    "email": email,
    "productCode": productCode
  };
  final jsonString = json.encode(body);
  
  try {
    final response = await http.post(
      'https://h24q9fa19h.execute-api.eu-central-1.amazonaws.com/test/status',
      body: jsonString
    );
    responseJson = jsonDecode(response.body);
    print(responseJson);
  } on Exception catch(_) {
    print("Exception occurs in getStatus() - operationsRepo...");
  }
  return responseJson;
}

Future<Map> getUsers(String productCode, String email) async {
  var responseJson;
  final body = {
    "email": email,
    "productCode": productCode
  };
  final jsonString = json.encode(body);
  
  try {
    final response = await http.post(
      'https://h24q9fa19h.execute-api.eu-central-1.amazonaws.com/test/get-users',
      body: jsonString
    );
    responseJson = jsonDecode(response.body);
    print(responseJson);
  } on Exception catch(_) {
    print("Exception occurs in getUsers() - operationsRepo...");
  }
  return responseJson;
}

Future<Map> deleteResident(String email, String deletedEmail, String message) async {
  var responseJson;
  final body = {
    "email": email,
    "deletedEmail": deletedEmail,
    "message": message
  };
  final jsonString = json.encode(body);
  
  try {
    final response = await http.post(
      'https://h24q9fa19h.execute-api.eu-central-1.amazonaws.com/test/delete-resident',
      body: jsonString
    );
    responseJson = jsonDecode(response.body);
    print(responseJson);
  } on Exception catch(_) {
    print("Exception occurs in deleteResident() - operationsRepo...");
  }
  return responseJson;
}

Future<Map> addProduct(String email, String message) async {
  var responseJson;
  final body = {
    "email": email,
    "message": message
  };
  final jsonString = json.encode(body);
  
  try {
    final response = await http.post(
      'https://h24q9fa19h.execute-api.eu-central-1.amazonaws.com/test/add-product',
      body: jsonString
    );
    responseJson = jsonDecode(response.body);
    print(responseJson);
  } on Exception catch(_) {
    print("Exception occurs in addProduct() - operationsRepo...");
  }
  return responseJson;
}
