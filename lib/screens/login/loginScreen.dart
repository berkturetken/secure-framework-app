import 'package:flutter/material.dart';
import 'package:secure_framework_app/screens/login/components/loginForm.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = "/login";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Login"),
        backgroundColor: Colors.blue[900],
      ),
      body: SafeArea(
        child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 100, 0, 20),
                    child: Text(
                      "Whoever you are, come!",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  LoginForm()
                ],
              ),
            )
          ),
        ),
      )
    );
  }
}