import 'package:flutter/material.dart';
import 'components/ownerSignUpForm.dart';

class OwnerSignUpScreen extends StatelessWidget {
  static const routeName = "/ownerSignUp";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text("Sign Up"),
        ),
        backgroundColor: Colors.blue[900],
      ),
      body: SafeArea(
        child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child: Text(
                      "Owner",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  OwnerSignUpForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}