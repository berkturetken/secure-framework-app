import 'package:flutter/material.dart';
import '../services/UserData.dart';
import 'package:secure_framework_app/repository/loginRepo.dart';
import 'package:secure_framework_app/crypto/cryptographicOperations.dart';

class UserProvider with ChangeNotifier {
  User _user;

  // Getter
  User get user => _user;

  // Setter
  // set user (User u) {
  //   _user.email = u.email;
  //   _user.masterKey = u.masterKey;
  //   _user.products = u.products;
  // }

  // Delete user
  void deleteCurrentUser() {
    _user = null;
  }

  Future<void> fetchAndSetUser(String email, String password) async {
    String nonce, encryptedNonce, encryptedMasterKey, masterKey;
    
    Map jsonResponsefromGetNonce = await getNonce(email);
    
    // Null check
    if (jsonResponsefromGetNonce == null) {
      print("jsonResponseFromGetNonce is null...");
      return;
    }

    // Error check
    if (jsonResponsefromGetNonce["statusCode"] == 400) {
      print("jsonResponseFromGetNonce returned 400...");
      return;
    }

    nonce = jsonResponsefromGetNonce["message"];
    print("Nonce: " + nonce);

    // Kev and iv arrangement
    var key = password.substring(0, 32);
    var iv = password.substring(32, 48);

    encryptedNonce = encryptionAES(nonce, key, iv);
    print("Encrypted Nonce (Key is the hashed password): " + encryptedNonce);
    
    Map jsonResponseFromValidateLogin = await validateLogin(email, encryptedNonce);
    if (jsonResponseFromValidateLogin != null) {
      encryptedMasterKey = jsonResponseFromValidateLogin["message"];
    }

    masterKey = decryption(encryptedMasterKey, key, iv);
    print("Master Key: " + masterKey);

    arrangeMasterKey(masterKey);

    User user = new User(
      email: email,
      masterKey: masterKey,
    );

    _user = user;
    notifyListeners();
  }

}
