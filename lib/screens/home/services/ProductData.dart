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
  final List<dynamic> roleIDs;
  final String timeStamp;

  Product({
    @required this.productCode,
    @required this.productName,
    @required this.roleIDs,
    this.timeStamp
  });
}