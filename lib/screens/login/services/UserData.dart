import 'package:flutter/material.dart';
import 'package:secure_framework_app/screens/home/services/ProductData.dart';

/*
  Name and Surname can be added later
*/

class User with ChangeNotifier {
  String email;
  List<Product> products;
  String masterKey;

  User({
    @required this.email,
    this.products,
    @required this.masterKey
  });
}