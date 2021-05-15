import 'package:flutter/material.dart';

// It is going to be used later!
enum Roles {
  resident,
  houseOwner,
  technicalService
}

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