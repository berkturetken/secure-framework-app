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
import 'package:secure_framework_app/screens/home/services/ProductData.dart';

Future<void> sendCommand(String command, String email, String productCode) async {
  final storage = Storage;
  String aesKey = await storage.read(key: "AES-Key");
  String iv = await storage.read(key: "IV");
  String hmacKey = await storage.read(key: "HMAC-Key");

  String encryptedCommand = encryptionAES(command, aesKey, iv);
  print("Encrypted Message: " + encryptedCommand);
  String arrangedCommand = arrangeCommand(encryptedCommand, command, hmacKey);
  
  Map jsonResponseFromSendMessage = await sendMessage(arrangedCommand, email, productCode);
}

Future<void> getProductStatus(String productCode, String email) async {
  // TODO: Decryption of the message can be grouped as a seperate function!!!
  final storage = Storage;
  String aesKey = await storage.read(key: "AES-Key");
  String iv = await storage.read(key: "IV");
  String hmacKey = await storage.read(key: "HMAC-Key");

  // String encryptedCommand = encryptionAES(productCode, aesKey, iv);
  // print("Encrypted Message: " + encryptedCommand);

  // String arrangedCommand = arrangeCommand(encryptedCommand, productCode, hmacKey);

  /* VARIABLES */
  String encryptedCurrentStatus, cipherText, plainText, hmac, hmacCreatedByClient;
  int length, threshold;
  Map decodedPlainText;
  Map jsonResponseFromGetStatus = await getStatus(productCode, email);
  if (jsonResponseFromGetStatus != null) {
    encryptedCurrentStatus = jsonResponseFromGetStatus["message"];
    print("Response from getStatus: " + encryptedCurrentStatus);
  }

  // Decrypt the response
  length = encryptedCurrentStatus.length;
  threshold = length - HmacLength;
  cipherText = encryptedCurrentStatus.substring(0, threshold);
  hmac = encryptedCurrentStatus.substring(threshold);
  plainText = decryption(cipherText, aesKey, iv);
  hmacCreatedByClient = hmacing(plainText, hmacKey);
  if (hmacCreatedByClient != hmac) {
    print("HMACs are not matched!");
  } else {
    print("HMACs are matched.");
    print(plainText);

    decodedPlainText = jsonDecode(plainText);
    print("Decoded version: ${decodedPlainText}");
    decodedPlainText.forEach((key, value) {
      print("Key: " + key);
      print("Value: " + value.toString());
    });
  }
}

class ProductDetailScreen extends StatefulWidget {
  static const routeName = "/productDetail";

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

// TODO: Code refactoring for this screen --> Use provider for the IoT devices
// of corresponding product
class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool status = false;
  Map<String, int> command = {};

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    User user = userProvider.user;
    final arguments = ModalRoute.of(context).settings.arguments;
    Product currentProduct = arguments;

    getProductStatus(currentProduct.productCode, user.email);

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
                  _switch(user, currentProduct),
                ],
              ),
            ],
          ),
        ),
      ),
      drawer: CustomDrawer(),
    );
  }

  Widget _switch(User user, Product product) {
    return FlutterSwitch(
      value: status,
      onToggle: (val) async {
        print("Val: ${val}");
        if (val) {
          command["light"] = 1;
        } else {
          command["light"] = 0;
        }
        String formattedCommand = json.encode(command);
        await sendCommand(formattedCommand, user.email, product.productCode);
        
        // Try for different ms values for sleep!
        await Future.delayed(Duration(milliseconds: 250));    
        await getProductStatus("6AOLWR912", user.email);

        // Since setState() is used, getProductStatus is called TWICE! --> Handle this
        setState(() {
          status = val;
        });
      },
    );
  }
}
