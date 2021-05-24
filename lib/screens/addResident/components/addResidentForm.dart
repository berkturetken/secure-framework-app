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
import 'package:secure_framework_app/screens/home/services/ProductData.dart';

Future<dynamic> clickAddNewResident(String currentUserEmail, String message) async {
  final storage = Storage;
  String aesKey = await storage.read(key: "AES-Key");
  String iv = await storage.read(key: "IV");
  String hmacKey = await storage.read(key: "HMAC-Key");

  String encryptedMessage = encryptionAES(message, aesKey, iv);
  print("Encrypted Message in resident form: " + encryptedMessage);

  String arrangedCommand = arrangeCommand(encryptedMessage, message, hmacKey);

  Map jsonResponseFromAddNewResident = await addNewResident(currentUserEmail, arrangedCommand);
  return jsonResponseFromAddNewResident;
}

class AddResidentForm extends StatefulWidget {
  @override
  _AddResidentFormState createState() => _AddResidentFormState();
}

class _AddResidentFormState extends State<AddResidentForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> errors = [];
  final emailTextField = TextEditingController();

  String email, productCode;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    User currentUser = userProvider.user;
    List<Product> products = currentUser.products;
    List<Product> ownerProducts = getOwnerProducts(products);
    Product defaultProduct = ownerProducts[0];

    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildEmailFormField(),
          SizedBox(height: 20),
          buildProductCodeFormField(ownerProducts, defaultProduct),
          SizedBox(height: 10),
          FormError(errors: errors),
          SizedBox(height: 10),
          _addNewResidentButton(currentUser, defaultProduct),
        ],
      ),
    );
  }

  // Get the products that the current user has an Owner Role
  List<Product> getOwnerProducts(List<Product> p) {
    List<Product> ownerP = [];
    p.forEach((product) { 
      if (product.roleIDs.contains(2)) {
        ownerP.add(product);
      }
    });
    return ownerP;
  }

  // 'Add New Resident' Button
  Widget _addNewResidentButton(User currentUser, Product defaultProduct) {
    return isLoading
        ? Container(
          child: Center(child: CircularProgressIndicator()),
          color: Colors.white,
        )
        : DefaultButton(
            text: "Add a New Resident",
            buttonType: "Green",
            press: () async {
              if (_formKey.currentState.validate() && errors.isEmpty) {
                _formKey.currentState.save();
                setState(() {
                  isLoading = true;
                });

                // If dropdown menu is never used, then productCode is null.
                // Therefore, get the productCode of the first product of the current user's products
                if (productCode == null) {
                  productCode = defaultProduct.productCode;
                }
                var data = {'email': email, 'productCode': productCode};
                String formattedData = jsonEncode(data);

                dynamic response = await clickAddNewResident(currentUser.email, formattedData);

                setState(() {
                  isLoading = false;
                });
                _popupWindow(context, response);

                // Clear the input fields if user is added successfully
                if (response["statusCode"] == 200) {
                  emailTextField.clear();
                }
              }
            },
          );
  }

  // Pop-up window
  _popupWindow(context, response) {
    // Return Codes are as follows
    // 200: User added to the database
    // 400: User is already in the system
    int returnCode = response["statusCode"];
    String returnMessage = response["message"];
    Alert(
      context: context,
      title: returnCode == 200 ? "Great :)" : "Sorry :(",
      desc: returnMessage,
      image: returnCode == 200
          ? Image.asset("assets/images/success-2.png")
          : Image.asset("assets/images/cross-2.png"),
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
        } else if (value.isNotEmpty &&
            !emailValidationRegExp.hasMatch(value) &&
            !errors.contains(InvalidEmailError)) {
          setState(() {
            errors.add(InvalidEmailError);
          });
        }
        return null;
      },
      decoration: inputDecoration("Email", text: "Enter your email address"),
      controller: emailTextField,
    );
  }

  // Product Code Form Field
  DropdownButtonFormField<Product> buildProductCodeFormField(List<Product> products, Product defaultProduct) {
    return DropdownButtonFormField<Product>(
      value: defaultProduct,
      onChanged: (selectedValue) {
        setState(() {
          defaultProduct = selectedValue;
          productCode = defaultProduct.productCode;
        });
      },
      decoration: inputDecoration("Product Name - Product Code"),
      items: products.map<DropdownMenuItem<Product>>((Product value) {
        return DropdownMenuItem<Product>(
          value: value,
          child: Text(value.productName + " - " + value.productCode),
        );
      }).toList(),
    );
  }

  // Generic Input Field Decoration
  InputDecoration inputDecoration(String title, {String text}) {
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
