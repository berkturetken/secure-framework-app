import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:secure_framework_app/components/constants.dart';
import 'package:secure_framework_app/components/formError.dart';
import 'package:secure_framework_app/components/defaultButton.dart';
import 'package:secure_framework_app/crypto/cryptographicOperations.dart';
import 'package:secure_framework_app/repository/operationsRepo.dart';
import 'package:secure_framework_app/screens/login/services/UserProvider.dart';
import 'package:provider/provider.dart';
import 'package:secure_framework_app/screens/login/services/UserData.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

Future<int> clickAddNewResident(String currentUserEmail, String message) async {
  final storage = Storage;
  String aesKey = await storage.read(key: "AES-Key");
  String iv = await storage.read(key: "IV");
  String hmacKey = await storage.read(key: "HMAC-Key");

  String encryptedMessage = encryptionAES(message, aesKey, iv);
  print("Encrypted Message in resident form: " + encryptedMessage);

  String arrangedCommand = arrangeCommand(encryptedMessage, message, hmacKey);

  Map jsonResponse = await addNewResident(currentUserEmail, arrangedCommand);
  // If there is any response
  var response = jsonResponse["message"];
  var statusCode = jsonResponse["statusCode"];
  print("Response in clickAddNewResident: " + response);
  
  return statusCode;
}


class AddResidentForm extends StatefulWidget {
  @override
  _AddResidentFormState createState() => _AddResidentFormState();
}

class _AddResidentFormState extends State<AddResidentForm> {
  final _formKey = GlobalKey<FormState>();

  String email, productCode, role;
  final List<String> errors = [];
  bool isLoading = false;

  final emailTextField = TextEditingController();
  final productCodeTextField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    User currentUser = userProvider.user;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildEmailFormField(),
          SizedBox(height: 20),
          buildProductCodeFormField(),
          SizedBox(height: 20),
          //buildRoleFormField(),
          SizedBox(height: 10),
          FormError(errors: errors),
          SizedBox(height: 10),
          _addNewResidentButton(currentUser),
        ],
      ),
    );
  }

  // Add New Resident Button
  Widget _addNewResidentButton(User currentUser) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : DefaultButton(
            text: "Add a New Resident",
            buttonType: "Green",
            press: () async {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                setState(() {
                  isLoading = true;
                });
              }
              setState(() {
                isLoading = false;
              });

              // For debugging purposes:
              print("Button is pressed");

              print("Resident's email: " + email);
              print("Product Code: " + productCode);
              var data = {
                'email': email,
                'productCode': productCode
              };
              String formattedData = jsonEncode(data);

              int returnFromButton = await clickAddNewResident(currentUser.email, formattedData);
              print(returnFromButton);
              if (returnFromButton == 200) {
                _onAlertWithCustomImagePressed(context);
                // Clear the input fields
                emailTextField.clear();
                productCodeTextField.clear();
              }
            },
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
        } else if (emailValidationRegExp.hasMatch(value) &&
            errors.contains(InvalidEmailError)) {
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
        } else if (!emailValidationRegExp.hasMatch(value) &&
            !errors.contains(InvalidEmailError)) {
          setState(() {
            errors.add(InvalidEmailError);
          });
        }
        return null;
      },
      decoration: inputDecoration("Email", "Enter your email address"),
      controller: emailTextField,
    );
  }

  // Product Code Form Field
  TextFormField buildProductCodeFormField() {
    return TextFormField(
      keyboardType: TextInputType.name,
      onSaved: (newValue) => productCode = newValue,
      onChanged: (value) {
        if (value.isNotEmpty && errors.contains(ProductCodeNullError)) {
          setState(() {
            errors.remove(ProductCodeNullError);
          });
        } else if (value.length == 9 &&
            errors.contains(InvalidProductCodeError)) {
          setState(() {
            errors.remove(InvalidProductCodeError);
          });
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty && !errors.contains(ProductCodeNullError)) {
          setState(() {
            errors.add(ProductCodeNullError);
          });
        } else if (value.length != 9 &&
            !errors.contains(InvalidProductCodeError)) {
          setState(() {
            errors.add(InvalidProductCodeError);
          });
        }
        return null;
      },
      decoration: inputDecoration("Product Code", "Enter your product code"),
      controller: productCodeTextField,
    );
  }

  // Role Form Field
  TextFormField buildRoleFormField() {
    return TextFormField(
      keyboardType: TextInputType.name,
      onSaved: (newValue) => role = newValue,
      onChanged: (value) {
        if (value.isNotEmpty && errors.contains(ProductCodeNullError)) {
          setState(() {
            errors.remove(ProductCodeNullError);
          });
        } else if (value.length == 9 &&
            errors.contains(InvalidProductCodeError)) {
          setState(() {
            errors.remove(InvalidProductCodeError);
          });
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty && !errors.contains(ProductCodeNullError)) {
          setState(() {
            errors.add(ProductCodeNullError);
          });
        } else if (value.length != 9 &&
            !errors.contains(InvalidProductCodeError)) {
          setState(() {
            errors.add(InvalidProductCodeError);
          });
        }
        return null;
      },
      decoration: inputDecoration("Role", "Enter resident's role"),
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

  _onAlertWithCustomImagePressed(context) {
    Alert(
      context: context,
      title: "GREAT!",
      desc: "You added a new resident succesfully",
      image: Image.asset("assets/images/success-2.png"),
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Take Me Back",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        )
      ],
    ).show();
  }

}
