import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:secure_framework_app/components/constants.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

Future<Map> getNonce(String email) async {
  var responseJson;
  final body = {
    "userEmail": email
  };
  final jsonString = json.encode(body);

  try {
    final response = await http.post(
      'https://h24q9fa19h.execute-api.eu-central-1.amazonaws.com/test/nonce',
      body: jsonString 
    );
    responseJson = jsonDecode(response.body);
    print(responseJson);
  } on Exception catch(_) {
      print("Exception occurs in getNonce() - loginRepo ...");
  }
  return responseJson;
}


Future<Map> validateLogin(String email, String nonce) async {
  var responseJson;
  final body = {
    "userEmail": email,
    "nonce": nonce
  };
  final jsonString = json.encode(body);

  try {
    final response = await http.post(
      'https://h24q9fa19h.execute-api.eu-central-1.amazonaws.com/test/login',
      body: jsonString 
    );
    responseJson = jsonDecode(response.body);
    print(responseJson);
  } on Exception catch(_) {
      print("Exception occurs in validateLogin() - loginRepo...");
  }
  return responseJson;
}