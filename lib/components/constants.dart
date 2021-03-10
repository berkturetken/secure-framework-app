import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Storage
final Storage = new FlutterSecureStorage();

// Constants
String nonce = "";
const String IVKey = "this is an IV666"; 

// ----- ERRORS -----

// Name Checks
const String NameNullError = "Please enter your name";

// Surname Checks
const String SurnameNullError = "Please enter your surname";

// Email Checks
final RegExp emailValidationRegExp = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
const String EmailNullError = "Please enter your email";
const String InvalidEmailError = "Please enter a valid email";

// Password Checks
const String PasswordNullError = "Please enter your password";
const String ShortPasswordError = "Password is too short";

// Confirmation Password Checks
const String ConfirmationPasswordNullError = "Confirmation password cannot be blank";
const String MatchPasswordError = "Passwords do not match";

// Product Code Checks
const String ProductCodeNullError = "Please enter your product code";
const String InvalidProductCodeError = "Please enter a valid product code";