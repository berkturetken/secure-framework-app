import 'package:flutter/material.dart';
import 'package:secure_framework_app/components/constants.dart';
import 'package:secure_framework_app/components/defaultButton.dart';
import 'package:secure_framework_app/components/formError.dart';
import 'dart:convert';
import 'package:secure_framework_app/repository/signUpRepo.dart';
import 'package:secure_framework_app/crypto/cryptographicOperations.dart';
import 'package:flutter/services.dart';
import 'package:secure_framework_app/screens/login/components/loginForm.dart';
import 'package:secure_framework_app/screens/login/loginScreen.dart';

Future<void> beginSignUp(String data) async {
  var encryptedData = await encryptionRSA(data);

  Map jsonResponseFromSignUp = await signUp(encryptedData);

}

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  
  String name, surname, email, productCode, password = "", confirmationPassword;

  final List<String> errors = [];

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
          
          DefaultButton(
            text: "Create an Account",
            press: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                
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
                
                beginSignUp(formattedData);
              }
            },
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account? ",
                style: TextStyle(fontSize: 16),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(LoginForm.routeName);
                },
                child: Text(
                  "Login",
                  style: TextStyle(fontSize: 16, color: Colors.lightBlue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Name Form Field
  TextFormField buildNameFormField() {
    return TextFormField(
      keyboardType: TextInputType.name,
      onSaved: (newValue) => name = newValue,
      onChanged: (value) {
        if (value.isEmpty && errors.contains(NameNullError)) {
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
      decoration: inputDecoration("Email", "Enter your email"),
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
        }
        else if (value.length == 9 && errors.contains(InvalidProductCodeError)) {
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
        }
        else if(value.length != 9 && !errors.contains(InvalidProductCodeError)) {
          setState(() {
            errors.add(InvalidProductCodeError);
          });
        }
        return null;
      },
      decoration: inputDecoration("Product Code", "Enter your product code"),
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

  // Confirmation Password Form Field
  TextFormField buildConfirmationPasswordFormField() {
    return TextFormField(
      obscureText: true,
      onSaved: (newValue) => confirmationPassword = newValue,
      onChanged: (value) {
        if (value.isNotEmpty && errors.contains(ConfirmationPasswordNullError)) {
          setState(() {
            errors.remove(ConfirmationPasswordNullError);
          });
        }
        else if (value == password && errors.contains(MatchPasswordError)) {
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
        }
        else if (value != password && !errors.contains(MatchPasswordError)) {
          setState(() {
            errors.add(MatchPasswordError);
          });
        }
        return null;
      },
      decoration:
          inputDecoration("Confirmation Password", "Enter your password again"),
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