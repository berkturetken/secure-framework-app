import 'package:flutter/material.dart';

class Product with ChangeNotifier {
  final String productCode;
  final String productName;
  final int roleID;

  Product({
    @required this.productCode,
    @required this.productName,
    @required this.roleID
  });
}