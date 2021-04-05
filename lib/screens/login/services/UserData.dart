import 'package:flutter/material.dart';
import 'package:secure_framework_app/screens/home/services/ProductData.dart';

/*
  Name and Surname can be added later
*/

class User with ChangeNotifier {
  final String email;
  final List<Product> products;
  final String masterKey;

  User({
    @required this.email,
    this.products,
    @required this.masterKey
  });
}