import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:secure_framework_app/crypto/cryptographicOperations.dart';
import 'package:secure_framework_app/repository/operationsRepo.dart';
import '../services/ProductData.dart';
import 'package:secure_framework_app/screens/login/services/UserData.dart';

class ProductProvider with ChangeNotifier {
  /*
  Product _product;

  // Getter
  Product get product => _product;
  */

  List<String> userRoles = ["", "Resident", "Owner", "Technical Service"];

  // Get User Role for a given role Id
  String getUserRole(int roleID) {
    return userRoles[roleID];
  }
  
  Future<void> fetchAndGetProducts(String email, User user) async {
    List<Product> products = new List();
    String encryptedProducts, plainText;
    List<dynamic> decodedPlainText;

    Map jsonResponseFromGetProducts = await getProducts(email);

    // Null check
    if (jsonResponseFromGetProducts == null) {
      return;
    }

    encryptedProducts = jsonResponseFromGetProducts["message"];
    plainText = await verifyAndExtractIncommingMessages(encryptedProducts);
    decodedPlainText = jsonDecode(plainText);

    for (var i = 0; i < decodedPlainText.length; i++) {
      Product tempProduct = new Product(
        productCode: decodedPlainText[i]['productCode'],
        productName: decodedPlainText[i]['productName'],
        roleID: decodedPlainText[i]['roleId']
      );
      products.add(tempProduct);
    }
    user.products = products;
    notifyListeners();
  }

  Future<Map> fetchAndGetProductStatus(String productCode, String email) async {
    String encryptedCurrentStatus, plainText;
    Map decodedPlainText = {};
    Map jsonResponseFromGetStatus = await getStatus(productCode, email);

    // Null check
    if (jsonResponseFromGetStatus == null) {
      print("JsonResponseFromGetStatus is null...");
      return decodedPlainText;
    }

    // Unsuccessful return check
    if(jsonResponseFromGetStatus["statusCode"] != 200) {
      print("Status code is NOT 200...");
      return decodedPlainText;
    }

    encryptedCurrentStatus = jsonResponseFromGetStatus["message"];
    plainText = await verifyAndExtractIncommingMessages(encryptedCurrentStatus);
    decodedPlainText = jsonDecode(plainText);
    print("Decoded version: $decodedPlainText");

    decodedPlainText.forEach((key, value) {
      print("Key: " + key);
      print("Value: " + value.toString());
    });
    notifyListeners();
    return decodedPlainText;
  }
  
}
