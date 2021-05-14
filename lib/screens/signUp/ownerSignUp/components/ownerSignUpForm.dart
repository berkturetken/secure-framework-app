import 'package:flutter/material.dart';
import 'package:secure_framework_app/components/constants.dart';
import 'package:secure_framework_app/components/defaultButton.dart';
import 'package:secure_framework_app/components/formError.dart';
import 'dart:convert';
import 'package:secure_framework_app/repository/signUpRepo.dart';
import 'package:secure_framework_app/crypto/cryptographicOperations.dart';
import 'package:flutter/services.dart';
import 'package:secure_framework_app/screens/login/loginScreen.dart';
import 'package:secure_framework_app/screens/signUp/residentSignUp/ResidentSignUpScreen.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

Future<dynamic> beginOwnerSignUp(String data) async {
  var encryptedData = await encryptionRSA(data);
  Map jsonResponseFromOwnerSignUp = await ownerSignUp(encryptedData);
  return jsonResponseFromOwnerSignUp;
}

class OwnerSignUpForm extends StatefulWidget {
  @override
  _OwnerSignUpFormState createState() => _OwnerSignUpFormState();
}

class _OwnerSignUpFormState extends State<OwnerSignUpForm> {
  bool isLoading = false;
  // Form Variables
  final _formKey = GlobalKey<FormState>();
  final List<String> errors = [];
  
  // Text Fields
  String name, surname, email, productCode, password = "", confirmationPassword;
  
  // Text Field Controllers
  final nameTextField = TextEditingController();
  final surnameTextField = TextEditingController();
  final emailTextField = TextEditingController();
  final productCodeTextField = TextEditingController();
  final passwordTextField = TextEditingController();
  final confirmationPasswordTextField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildNameFormField(),
          SizedBox(height: 20),
          buildSurnameFormField(),
          SizedBox(height: 20),
          buildEmailFormField(),
          SizedBox(height: 20),
          buildProductCodeFormField(),
          SizedBox(height: 20),
          buildPasswordFormField(),
          SizedBox(height: 20),
          buildConfirmationPasswordFormField(),
          SizedBox(height: 10),
          FormError(errors: errors),
          SizedBox(height: 15),
          _createAnAccountButton(),
          SizedBox(height: 20),
          _customTextRouting("Already have an account? ", LoginScreen.routeName, "Login"),
          SizedBox(height: 10),
          _customTextRouting("Are you a resident? ", ResidentSignUpScreen.routeName, "Sign Up"),
        ],
      ),
    );
  }

  // 'Create an Account' Button
  Widget _createAnAccountButton() {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : DefaultButton(
            text: "Create an Account",
            press: () async {
              if (_formKey.currentState.validate() && errors.isEmpty) {
                _formKey.currentState.save();
                // Loading starts
                setState(() {
                  isLoading = true;
                });

                // Prepare the data - Hash the password before sending to the server
                String hashedPassword = passwordHashing(password);

                var data = {
                  'name': name,
                  'surname': surname,
                  'email': email,
                  'productCode': productCode,
                  'password': hashedPassword
                };

                String formattedData = jsonEncode(data);
                print(formattedData);
                dynamic response = await beginOwnerSignUp(formattedData);
                
                // Loading ends
                setState(() {
                  isLoading = false;
                });
                _popupWindow(context, response);

                // Clear the input fields
                if(response["statusCode"] == 200) {
                  clearInputFields();
                }
              }
            },
          );
  }

  // Clearing the input fields
  clearInputFields() {
    nameTextField.clear();
    surnameTextField.clear();
    emailTextField.clear();
    productCodeTextField.clear();
    passwordTextField.clear();
    confirmationPasswordTextField.clear();
  }

  // Pop-up window
  _popupWindow(context, response) {
    // Return Codes are as follows
    // 200: User is successfully created,
    // 400: User is already registered with another product,
    // 400: Product Code is invalid
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

  // Custom Text and Ink with Routing
  Widget _customTextRouting(String text, String route, String inkText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: TextStyle(fontSize: 16),
        ),
        InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(route);
          },
          child: Text(
            inkText,
            style: TextStyle(fontSize: 16, color: Colors.lightBlue),
          ),
        ),
      ],
    );
  }

  // Name Form Field
  TextFormField buildNameFormField() {
    return TextFormField(
      keyboardType: TextInputType.name,
      onSaved: (newValue) => name = newValue,
      onChanged: (value) {
        if (value.isNotEmpty && errors.contains(NameNullError)) {
          setState(() {
            errors.remove(NameNullError);
          });
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty && !errors.contains(NameNullError)) {
          setState(() {
            errors.add(NameNullError);
          });
        }
        return null;
      },
      decoration: inputDecoration("Name", "Enter your name"),
      controller: nameTextField,
    );
  }

  // Surname Form Field
  TextFormField buildSurnameFormField() {
    return TextFormField(
      keyboardType: TextInputType.name,
      onSaved: (newValue) => surname = newValue,
      onChanged: (value) {
        if (value.isNotEmpty && errors.contains(SurnameNullError)) {
          setState(() {
            errors.remove(SurnameNullError);
          });
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty && !errors.contains(SurnameNullError)) {
          setState(() {
            errors.add(SurnameNullError);
          });
        }
        return null;
      },
      decoration: inputDecoration("Surname", "Enter your surname"),
      controller: surnameTextField,
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
        } else if (value.isNotEmpty && !emailValidationRegExp.hasMatch(value) && !errors.contains(InvalidEmailError)) {
          setState(() {
            errors.add(InvalidEmailError);
          });
        }
        return null;
      },
      decoration: inputDecoration("Email", "Enter your email"),
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
        } else if (value.isNotEmpty && value.length != 9 && !errors.contains(InvalidProductCodeError)) {
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

  // Password Form Field
  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: true,
      onSaved: (newValue) => password = newValue,
      onChanged: (value) {
        password = value;
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
        } else if (value.isNotEmpty && value.length < 8 && !errors.contains(ShortPasswordError)) {
          setState(() {
            errors.add(ShortPasswordError);
          });
        }
        return null;
      },
      decoration: inputDecoration("Password", "Enter your password"),
      controller: passwordTextField,
    );
  }

  // Confirmation Password Form Field
  TextFormField buildConfirmationPasswordFormField() {
    return TextFormField(
      obscureText: true,
      onSaved: (newValue) => confirmationPassword = newValue,
      onChanged: (value) {
        if (value.isNotEmpty &&
            errors.contains(ConfirmationPasswordNullError)) {
          setState(() {
            errors.remove(ConfirmationPasswordNullError);
          });
        } else if (value == password && errors.contains(MatchPasswordError)) {
          setState(() {
            errors.remove(MatchPasswordError);
          });
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty && !errors.contains(ConfirmationPasswordNullError)) {
          setState(() {
            errors.add(ConfirmationPasswordNullError);
          });
        } else if (value.isNotEmpty && value != password && !errors.contains(MatchPasswordError)) {
          setState(() {
            errors.add(MatchPasswordError);
          });
        }
        return null;
      },
      decoration: inputDecoration("Confirmation Password", "Enter your password again"),
      controller: confirmationPasswordTextField,          
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
        vertical: 16,
      ),
      enabledBorder: outlineInputBorder,
      focusedBorder: outlineInputBorder,
      border: outlineInputBorder,
    );
  }
}
