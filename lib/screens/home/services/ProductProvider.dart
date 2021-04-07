import 'package:flutter/material.dart';
import 'package:secure_framework_app/crypto/cryptographicOperations.dart';
import 'package:secure_framework_app/repository/operationsRepo.dart';
import '../services/ProductData.dart';
import 'package:secure_framework_app/screens/login/services/UserData.dart';
import 'package:secure_framework_app/components/constants.dart';

class ProductProvider with ChangeNotifier {
  List _products;

  List<Product> get products => _products;

  Future<void> fetchAndGetProducts(String email, User user) async {
    final storage = Storage; 
    List<Product> products = new List();
    String encryptedProducts, cipherText, plainText, key, iv, hmac, hmacKey, hmacCreatedByClient;
    int length, threshold;

    Map jsonResponseFromGetProducts = await getProducts(email);
    if (jsonResponseFromGetProducts != null) {
      encryptedProducts = jsonResponseFromGetProducts["message"];
      print(encryptedProducts);
    }

    length = encryptedProducts.length;
    threshold = length - HmacLength;
    cipherText = encryptedProducts.substring(0, threshold);
    hmac = encryptedProducts.substring(threshold);

    key = await storage.read(key: "AES-Key");
    iv = await storage.read(key: "IV");
    hmacKey = await storage.read(key: "HMAC-Key");

    plainText = decryption(cipherText, key, iv);
    hmacCreatedByClient = hmacing(plainText, hmacKey);

    print("Coming HMAC: " + hmac);
    print("Created HMAC: " + hmacCreatedByClient);

    if (hmacCreatedByClient != hmac) {
      print("HMACs are not matched!");
    }
    else {
      print("HMACs are matched.");
      print(plainText);
    }


    // TODO List:
    // After successful decryption
    // Create a loop which creates tempProduct object in every iteration
    // Then, add this product to products list!
    
    /*
    Product tempProduct = new Product(
      productCode: null,
      productName: null,
      roleID: null
    );

    products.add(tempProduct);
    user.products = products;
    */
    notifyListeners();
  }
}
