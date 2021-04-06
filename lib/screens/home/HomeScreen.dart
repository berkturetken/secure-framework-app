import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:secure_framework_app/components/constants.dart';
import 'package:secure_framework_app/crypto/cryptographicOperations.dart';
import 'dart:convert';
import 'package:secure_framework_app/repository/operationsRepo.dart';
import 'package:secure_framework_app/screens/login/services/UserProvider.dart';
import 'package:provider/provider.dart';
import 'package:secure_framework_app/screens/login/services/UserData.dart';

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

class HomeScreen extends StatefulWidget {
  static const routeName = "/home";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool status = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    User user = userProvider.user; 

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text("Home Page"),
        ),
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
                  FlutterSwitch(
                    value: status,
                    onToggle: (val) {
                      setState(() {
                        status = val;
                        print(status);
                        if (status) {
                          var message = {
                            "light": 1,
                          };
                          var formattedMessage = json.encode(message);
                          sendCommand(formattedMessage, user.email);
                          print("Formatted Message is: " + formattedMessage);
                        }
                        else {
                          var message = {
                            "light": 0,
                          };
                          var formattedMessage = json.encode(message);
                          sendCommand(formattedMessage, user.email);
                          print("Formatted Message is: " + formattedMessage);
                        }
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
