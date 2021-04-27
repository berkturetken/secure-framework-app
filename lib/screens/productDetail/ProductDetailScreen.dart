import 'package:flutter/material.dart';
import 'package:secure_framework_app/screens/login/services/UserProvider.dart';
import 'package:provider/provider.dart';
import 'package:secure_framework_app/screens/login/services/UserData.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:secure_framework_app/components/constants.dart';
import 'package:secure_framework_app/crypto/cryptographicOperations.dart';
import 'dart:convert';
import 'package:secure_framework_app/repository/operationsRepo.dart';
import 'package:secure_framework_app/components/CustomDrawer.dart';

Future<void> sendCommand(String command, String email) async {
  final storage = Storage;
  String aesKey = await storage.read(key: "AES-Key");
  String iv = await storage.read(key: "IV");
  String hmacKey = await storage.read(key: "HMAC-Key");

  String encryptedCommand = encryptionAES(command, aesKey, iv);
  print("Encrypted Message: " + encryptedCommand);

  String arrangedCommand = arrangeCommand(encryptedCommand, command, hmacKey);

  // PRODUCT CODE is hard-coded for now!!!
  // Sending the light message and waiting for response
  Map jsonResponse = await sendMessage(arrangedCommand, email, "6AOLWR912");
  var response = jsonResponse["message"];

  print("Response: " + response);
}

class ProductDetailScreen extends StatefulWidget {
  static const routeName = "/productDetail";

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool status = false;
  Map<String, int> command = {};
  
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    User user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Product Detail"),
        backgroundColor: Colors.blue[900],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Text(
                      "Living Room - Light 1",
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ),
                  _switch(user),
                ],
              ),
            ],
          ),
        ),
      ),
      drawer: CustomDrawer(),
    );
  }

  Widget _switch(User user) {
    return FlutterSwitch(
      value: status,
      onToggle: (val) {
        setState(() {
          status = val;
          print(status);
          if (status) {
            command["light"] = 1;
          } else {
            command["light"] = 0;
          }

          String formattedCommand = json.encode(command);
          sendCommand(formattedCommand, user.email);
          print("Formatted Message is: " + formattedCommand);
        });
      },
    );
  }
}