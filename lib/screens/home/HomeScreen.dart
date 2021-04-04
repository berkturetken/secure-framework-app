import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:secure_framework_app/components/constants.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:secure_framework_app/repository/encryptionRepo.dart';

Future<void> encryptMessage(String message) async {
  final storage = Storage;
  String masterKey = await storage.read(key: "masterKey");

  var message_in_bytes = utf8.encode(message);

  // Encode the key and IV
  var encodedKey = base64.encode(utf8.encode(masterKey.substring(0, 32)));
  var encodedIV = base64.encode(utf8.encode(masterKey.substring(32, 48)));
  var hmacKey = utf8.encode(masterKey.substring(48, 80));

  // Determine key and IV
  final key = encrypt.Key.fromBase64(encodedKey);
  final iv = encrypt.IV.fromBase64(encodedIV);

  // Create an encrypter with the key and set the mode as CBC (Cipher Block Chaining)
  final encrypter =
      encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

  final encrypted = encrypter.encrypt(message, iv: iv);
  print("Encrypted Message: " + encrypted.base64);
  // print(encrypted.base64);

  var hmacSha256 = Hmac(sha256, hmacKey); // HMAC-SHA256
  var digest = hmacSha256.convert(message_in_bytes);
  var hmac = base64.encode(digest.bytes);
  print("HMAC: " + hmac);
  print("Length: " + hmac.length.toString());

  var data = encrypted.base64 + hmac;
  print("Sent data: " + data);

  // Right now: MAIL and Product Code is coded MANUALLY 
  // Sending the light message and waiting for response
  Map jsonResponse = await sendMessage(data, "claire@gmail.com", "6AOLWR912");
  var response = jsonResponse["message"];
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
                          encryptMessage(formattedMessage);
                          print("Formatted Message is: " + formattedMessage);
                        }
                        else {
                          var message = {
                            "light": 0,
                          };
                          var formattedMessage = json.encode(message);
                          encryptMessage(formattedMessage);
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
