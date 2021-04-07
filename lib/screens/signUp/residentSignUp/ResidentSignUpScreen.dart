import 'package:flutter/material.dart';
import 'components/residentSignUpForm.dart';

class ResidentSignUpScreen extends StatelessWidget {
  static const routeName = "/residentSignUp";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Sign Up"),
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
                      "Resident",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  ResidentSignUpForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}