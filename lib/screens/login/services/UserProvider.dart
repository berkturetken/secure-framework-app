import 'package:flutter/material.dart';
import '../services/UserData.dart';
import 'package:secure_framework_app/repository/loginRepo.dart';

class UserProvider with ChangeNotifier {
  User _user;
  
  User get user => _user;

  Future<void> fetchAndSetUser(String email, String nonce) async {
    Map jsonResponse = await validateLogin(email, nonce);

    User user = new User(
      email: email,
      productCodes: null,
      masterKey: jsonResponse["message"],
    );

    _user = user;
    notifyListeners();
  }
}