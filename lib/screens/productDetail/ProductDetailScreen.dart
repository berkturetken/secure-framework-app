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
import 'package:secure_framework_app/screens/home/services/ProductProvider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

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

class ProductDetailScreen extends StatefulWidget {
  static const routeName = "/productDetail";

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool status = false;
  bool _isInit = true;
  bool _isLoading = false;
  Map<String, int> command = {};

  @override
  void didChangeDependencies() {
    if (_isInit) {
      print("Inside isInit.");
      setState(() {
        _isLoading = true;
      });
      final userProvider = Provider.of<UserProvider>(context);
      User user = userProvider.user;
      final arguments = ModalRoute.of(context).settings.arguments;
      Product currentProduct = arguments;
      Provider.of<ProductProvider>(context)
          .fetchAndGetProductStatus(currentProduct.productCode, user.email)
          .then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    User user = userProvider.user;
    final arguments = ModalRoute.of(context).settings.arguments;
    Product currentProduct = arguments;

    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
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
                        _switch(context, user, currentProduct),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            drawer: CustomDrawer(),
          );
  }

  Widget _switch(BuildContext context, User user, Product product) {
    return FlutterSwitch(
      value: status,
      onToggle: (val) async {
        Map x;
        print("Val: ${val}");
        if (val) {
          command["light"] = 1;
        } else {
          command["light"] = 0;
        }
        String formattedCommand = json.encode(command);
        await sendCommand(formattedCommand, user.email, product.productCode);
        
        // Try for different ms values for sleep! --> Now, sleep: 0.5 seconds
        // TODO: What can we do as an alternative?
        await Future.delayed(Duration(milliseconds: 500));
        await Provider.of<ProductProvider>(context, listen: false)
            .fetchAndGetProductStatus(product.productCode, user.email)
            .then((value) => {
              x = value
            });
        
        // Retrieved response
        x.forEach((key, value) {
          value = value.toInt(); 
          if ((value == 1 && val) || (value == 0 && !val)) {
            setState(() {
              status = val;
            });
          }
          else {
            _popupWindow(context);
          }
         });
      },
    );
  }

  // Pop up window
  _popupWindow(context) {
    Alert(
      context: context,
      title: "Sorry :(",
      desc: "We cannot connect to the IoT Devices",
      image: Image.asset("assets/images/cross-2.png"),
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Take Me Back",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        )
      ],
    ).show();
  }

}
