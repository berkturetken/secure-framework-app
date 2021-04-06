import 'package:flutter/material.dart';
import '../services/UserData.dart';
import 'package:secure_framework_app/repository/loginRepo.dart';
import 'package:secure_framework_app/crypto/cryptographicOperations.dart';

class UserProvider with ChangeNotifier {
  User _user;

  User get user => _user;

  Future<void> fetchAndSetUser(String email, String password) async {
    String nonce, encryptedNonce, encryptedMasterKey, masterKey;
    Map jsonResponsefromGetNonce = await getNonce(email);

    if (jsonResponsefromGetNonce != null) {
      nonce = jsonResponsefromGetNonce["message"];
    }
    print("Nonce: " + nonce);

    var key = password.substring(0, 32);
    var iv = password.substring(32, 48);

    encryptedNonce = encryption(nonce, key, iv);
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
