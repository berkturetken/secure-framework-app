import 'package:flutter/material.dart';
import 'package:secure_framework_app/components/constants.dart';
import 'package:secure_framework_app/components/formError.dart';
import 'package:secure_framework_app/components/defaultButton.dart';

class AddResidentForm extends StatefulWidget {
  @override
  _AddResidentFormState createState() => _AddResidentFormState();
}

class _AddResidentFormState extends State<AddResidentForm> {
  final _formKey = GlobalKey<FormState>();

  String email, productCode, role;
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
          buildProductCodeFormField(),
          SizedBox(height: 20),
          //buildRoleFormField(),
          SizedBox(height: 10),
          FormError(errors: errors),
          SizedBox(height: 10),
          _addNewResidentButton(),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [],
          ),
        ],
      ),
    );
  }

  // Add New Resident Button
  Widget _addNewResidentButton() {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : DefaultButton(
            text: "Add a New Resident",
            buttonType: "Green",
            press: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                setState(() {
                  isLoading = true;
                });
              }
              setState(() {
                isLoading = false;
              });
              print("Button is pressed");
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
}
