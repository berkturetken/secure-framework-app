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

  // Decides whether a user has an Owner Role or not
  bool isOwner() {
    // True if a user is an Owner of at least one product
    // False if a user is NOT an Owner of any product
    // RoleID: 2 --> HouseOwner
    for (var i=0; i < _user.products.length; i++) {
      if (_user.products[i].roleID == 2) {
        return true;
      }
    }
    return false;   
  }

  // Is the current user has an Owner Role on that product?
  bool isOwnerOnThisProduct(int currentProductRoleID) {
    return currentProductRoleID == 1;
  }

  // Delete user
  void deleteCurrentUser() {
    _user = null;
  }

  Future<void> fetchAndSetUser(String email, String password) async {
    String nonce, encryptedNonce, encryptedMasterKey, masterKey;
    
    Map jsonResponsefromGetNonce = await getNonce(email);
    
    // Null Check
    if (jsonResponsefromGetNonce == null) {
      print("jsonResponseFromGetNonce is null...");
      return;
    }

    // Error Check
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
    
    // Null Check
    if (jsonResponseFromValidateLogin == null) {
      print("jsonResponseFromValidateLogin is null...");
      return;
    }

    // Error Check
    if (jsonResponseFromValidateLogin["statusCode"] == 400) {
      print("jsonResponseFromValidateLogin returned 400...");
      return;
    }

    encryptedMasterKey = jsonResponseFromValidateLogin["message"];
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
