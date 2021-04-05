import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:secure_framework_app/components/constants.dart';
import 'package:secure_framework_app/components/formError.dart';
import 'package:secure_framework_app/components/defaultButton.dart';
import 'package:secure_framework_app/repository/loginRepo.dart';
import 'package:secure_framework_app/crypto/cryptographicOperations.dart';


Future<void> fetchNonceAndLogin(String email, String password) async {
  /***** FIRST PART *****/
  Map jsonResponse = await getNonce(email);

  nonce = jsonResponse["message"];
  print("Nonce: " + nonce);

  /***** SECOND PART *****/
  // Encode the key and IV
  var encodedKey = base64.encode(utf8.encode(password.substring(0, 32)));
  var encodedIV = base64.encode(utf8.encode(password.substring(32, 48)));
  
  // Encrypt the nonce
  String encryptedNonce = encryption(nonce, encodedKey, encodedIV);
  print("Encrypted Nonce (Key is the hashed password): " + encryptedNonce);

  Map jsonResponse2 = await validateLogin(email, encryptedNonce);
  var encryptedMasterKey = jsonResponse2["message"];
  String masterKey = decryption(encryptedMasterKey, encodedKey, encodedIV);

  print("Master Key: " + masterKey);

  arrangeMasterKey(masterKey);
}


class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  
  String email;
  String password;
  // bool rememberMe = false;
 
  final List<String> errors = [];  

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildEmailFormField(),
          SizedBox(height: 20),
          buildPasswordFormField(),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Forgot your password?",
                style: TextStyle(decoration: TextDecoration.underline)
              ),
            ],
          ),
          FormError(errors: errors),
          SizedBox(height: 20),
          
          DefaultButton(
            text: "LOGIN",
            buttonType: "Orange",
            press: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                
                print("Email: $email");

                var bytes_1 = utf8.encode(password);
                var hashedPassword = sha512.convert(bytes_1);
                print("Password: $password");
                print("Hashed Password: $hashedPassword");
                fetchNonceAndLogin(email, hashedPassword.toString());

                Navigator.pushNamed(context, '/home');
              }
            },
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Need an account? ",
                style: TextStyle(fontSize: 16),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/');
                },
                child: Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 16, color: Colors.lightBlue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Email Form Field
  TextFormField buildEmailFormField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      onSaved: (newValue) => email = newValue,
      onChanged: (value) {
        if (value.isNotEmpty && errors.contains(EmailNullError)) {
          setState(() {
            errors.remove(EmailNullError);
          });
        } else if (emailValidationRegExp.hasMatch(value) && errors.contains(InvalidEmailError)) {
          setState(() {
            errors.remove(InvalidEmailError);
          });
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty && !errors.contains(EmailNullError)) {
          setState(() {
            errors.add(EmailNullError);
          });
        } else if (!emailValidationRegExp.hasMatch(value) && !errors.contains(InvalidEmailError)) {
          setState(() {
            errors.add(InvalidEmailError);
          });
        }
        return null;
      },
      decoration: inputDecoration("Email", "Enter your email address"),
    );
  }

  // Password Form Field
  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: true,
      onSaved: (newValue) => password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty && errors.contains(PasswordNullError)) {
          setState(() {
            errors.remove(PasswordNullError);
          });
        } else if (value.length >= 8 && errors.contains(ShortPasswordError)) {
          setState(() {
            errors.remove(ShortPasswordError);
          });
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty && !errors.contains(PasswordNullError)) {
          setState(() {
            errors.add(PasswordNullError);
          });
        } else if (value.length < 8 && !errors.contains(ShortPasswordError)) {
          setState(() {
            errors.add(ShortPasswordError);
          });
        }
        return null;
      },
      decoration: inputDecoration("Password", "Enter your password"),
    );
  }

  // Generic Input Field Decoration
  InputDecoration inputDecoration(String title, String text) {
    OutlineInputBorder outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Colors.grey),
      gapPadding: 10,
    );
    return InputDecoration(
      labelText: title,
      hintText: text,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 42,
        vertical: 20,
      ),
      enabledBorder: outlineInputBorder,
      focusedBorder: outlineInputBorder,
      border: outlineInputBorder,
    );
  }
}