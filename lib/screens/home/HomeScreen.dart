import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:secure_framework_app/components/constants.dart';
import 'package:secure_framework_app/crypto/cryptographicOperations.dart';
import 'dart:convert';
import 'package:secure_framework_app/repository/encryptionRepo.dart';

Future<void> sendCommand(String command) async {
  final storage = Storage;
  var encodedKey = await storage.read(key: "AES-Key");
  var encodedIV = await storage.read(key: "IV");
  var encodedPreHMAC = await storage.read(key: "Pre-HMAC");

  String encryptedCommand = encryption(command, encodedKey, encodedIV);
  print("Encrypted Message: " + encryptedCommand);

  String arrangedCommand = arrangeCommand(encryptedCommand, command, encodedPreHMAC);

  // Right now: MAIL and Product Code is coded MANUALLY 
  // Sending the light message and waiting for response
  Map jsonResponse = await sendMessage(arrangedCommand, "claire@gmail.com", "6AOLWR912");
  var response = jsonResponse["message"];

  // Currently, there is a PROBLEM with the response: 
  // "message: Error while decrypting the command!"
  print("Response: " + response);
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool status = false;

  @override
  Widget build(BuildContext context) {
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
                          sendCommand(formattedMessage);
                          print("Formatted Message is: " + formattedMessage);
                        }
                        else {
                          var message = {
                            "light": 0,
                          };
                          var formattedMessage = json.encode(message);
                          sendCommand(formattedMessage);
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
