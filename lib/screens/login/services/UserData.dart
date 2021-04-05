import 'package:flutter/material.dart';

class User with ChangeNotifier {
  //final String name;
  //final String surname;
  final String email;
  final List<String> productCodes;
  final String masterKey;

  User({
    //@required this.name,
    //@required this.surname,
    @required this.email,
    @required this.productCodes,
    @required this.masterKey
  });
}