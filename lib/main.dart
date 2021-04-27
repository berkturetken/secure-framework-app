import 'package:flutter/material.dart';
import 'package:secure_framework_app/screens/addResident/AddResidentScreen.dart';
import 'package:secure_framework_app/screens/home/HomeScreen.dart';
import 'package:secure_framework_app/screens/home/services/ProductProvider.dart';
import 'package:secure_framework_app/screens/login/components/loginForm.dart';
import 'package:secure_framework_app/screens/login/loginScreen.dart';
import 'package:secure_framework_app/screens/productDetail/ProductDetailScreen.dart';
import 'screens/signUp/ownerSignUp/OwnerSignUpScreen.dart';
import 'package:provider/provider.dart';
import 'package:secure_framework_app/screens/login/services/UserProvider.dart';
import 'screens/signUp/residentSignUp/ResidentSignUpScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => ProductProvider()),
      ],
      child: MaterialApp(
        initialRoute: LoginForm.routeName ,
        routes: {
          OwnerSignUpScreen.routeName: (context) => OwnerSignUpScreen(),
          ResidentSignUpScreen.routeName: (context) => ResidentSignUpScreen(),
          LoginForm.routeName: (context) => LoginScreen(),
          HomeScreen.routeName: (context) => HomeScreen(),
          ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
          AddResidentScreen.routeName: (context) => AddResidentScreen(),
        },
      ),
    );
  }
}