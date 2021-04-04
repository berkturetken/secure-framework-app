import 'package:flutter/material.dart';
import 'package:secure_framework_app/screens/home/HomeScreen.dart';
import 'package:secure_framework_app/screens/login/loginScreen.dart';
import 'screens/signUp/signUpScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => SignUpScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}