import 'package:flutter/material.dart';
import 'components/signUpForm.dart';

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("Secure Home"),
        ),
        backgroundColor: Colors.blue[900],
      ),
      body: SafeArea(
        child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
                    child: Text(
                      "Sign Up",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  SignUpForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}