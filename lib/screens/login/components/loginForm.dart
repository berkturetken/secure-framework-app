import 'package:flutter/material.dart';
import 'package:secure_framework_app/components/constants.dart';
import 'package:secure_framework_app/components/formError.dart';
import 'package:secure_framework_app/components/defaultButton.dart';
import 'package:secure_framework_app/crypto/cryptographicOperations.dart';
import 'package:secure_framework_app/screens/login/services/UserProvider.dart';
import 'package:provider/provider.dart';
import 'package:secure_framework_app/screens/login/services/UserData.dart';
import 'package:secure_framework_app/screens/home/HomeScreen.dart';
import 'package:secure_framework_app/screens/signUp/ownerSignUp/OwnerSignUpScreen.dart';
import 'package:secure_framework_app/screens/home/services/ProductProvider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  String email, password;
  final List<String> errors = [];
  bool isLoading = false;

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
              Text("Forgot your password?",
                  style: TextStyle(decoration: TextDecoration.underline)),
            ],
          ),
          FormError(errors: errors),
          SizedBox(height: 20),
          _loginButton(),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Need an account? ",
                style: TextStyle(fontSize: 16),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(OwnerSignUpScreen.routeName);
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

  // Login Button
  Widget _loginButton() {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : DefaultButton(
            text: "LOGIN",
            buttonType: "Orange",
            press: () async {
              if (_formKey.currentState.validate() && errors.isEmpty) {
                _formKey.currentState.save();
                // Loading starts
                setState(() {
                  isLoading = true;
                });

                try {
                  print("Email: $email");
                  String hashedPassword = passwordHashing(password);

                  await Provider.of<UserProvider>(context, listen: false)
                      .fetchAndSetUser(email, hashedPassword)
                      .then((_) {});

                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  User currentUser = userProvider.user;
                  
                  if (currentUser == null) {
                    _popupWindow(context);
                    // Loading ends
                    setState(() {
                      isLoading = false;
                    });
                  }
                  else {
                    await Provider.of<ProductProvider>(context, listen: false)
                        .fetchAndGetProducts(email, currentUser)
                        .then((_) {});

                    // Loading ends
                    setState(() {
                      isLoading = false;
                    });

                    print("Navigating to the home screen");
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ),
                        ModalRoute.withName(HomeScreen.routeName));
                  }
                } catch (e) {
                  // Loading ends
                  setState(() {
                    isLoading = false;
                  });
                  print("An error occured: " + e.toString());
                }
              }
            },
          );
  }

  // Pop-up window
  _popupWindow(context) {
    Alert(
      context: context,
      title: "Sorry :(",
      desc: "Your email address or password is incorrect!",
      image: Image.asset("assets/images/cross-2.png"),
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
        } else if ((emailValidationRegExp.hasMatch(value) || value.isEmpty) &&
            errors.contains(InvalidEmailError)) {
          setState(() {
            errors.remove(InvalidEmailError);
          });
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty &&  !errors.contains(EmailNullError)) {
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
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty && !errors.contains(PasswordNullError)) {
          setState(() {
            errors.add(PasswordNullError);
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
