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

Future<bool> sendCommand(String command, String email, String productCode) async {
  final storage = Storage;
  String aesKey = await storage.read(key: "AES-Key");
  String iv = await storage.read(key: "IV");
  String hmacKey = await storage.read(key: "HMAC-Key");

  String encryptedCommand = encryptionAES(command, aesKey, iv);
  print("Encrypted Message: " + encryptedCommand);
  String arrangedCommand = arrangeCommand(encryptedCommand, command, hmacKey);

  Map jsonResponseFromSendMessage =
      await sendMessage(arrangedCommand, email, productCode);

  // Null Check
  if (jsonResponseFromSendMessage == null) {
    return false;
  }

  // Error Check
  if (jsonResponseFromSendMessage["statusCode"] == 400) {
    return false;
  }
  return true;
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
  bool _isSwitchLoading = false;
  Map<String, int> command = {};

  @override
  void didChangeDependencies() {
    // Providers, Objects and Variables
    final userProvider = Provider.of<UserProvider>(context);
    User user = userProvider.user;
    final arguments = ModalRoute.of(context).settings.arguments;
    Product currentProduct = arguments;

    if (_isInit) {
      // Loading starts
      setState(() {
        _isLoading = true;
      });

      Provider.of<ProductProvider>(context)
          .fetchAndGetProductStatus(currentProduct.productCode, user.email)
          .then((value) {
        // Update the initial condition of the light
        status = fromIntToBool(value["light"].toInt());

        // Loading ends
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
                        userProvider.isOwnerOnThisProduct(currentProduct.roleIDs)
                            ? _switch(context, user, currentProduct)
                            : SizedBox.shrink(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            drawer: CustomDrawer(),
          );
  }

  // Light Switch
  Widget _switch(BuildContext context, User user, Product product) {
    return _isSwitchLoading
        ? Center(child: CircularProgressIndicator())
        : FlutterSwitch(
            value: status,
            onToggle: (val) async {
              // Loading starts
              setState(() {
                _isSwitchLoading = true;
              });
              print("Val: $val");
              command["light"] = fromBoolToInt(val);

              String formattedCommand = json.encode(command);
              bool response = await sendCommand(formattedCommand, user.email, product.productCode);

              // Loading ends
              setState(() {
                _isSwitchLoading = false;
              });

              if (response) {
                status = val;
              }
              else {
                _popupWindow(context);
              }
            },
          );
  }

  // Pop up window
  _popupWindow(context) {
    Alert(
      context: context,
      title: "Sorry :(",
      desc: "IoT is not connected.",
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

  // Int to Bool
  bool fromIntToBool(int number) {
    // Only, returns "False" if the number is 0. Otherwise, returns "True"
    if (number == 0) return false;
    return true;
  }

  // Bool to Int
  int fromBoolToInt(bool boolean) {
    // Only, returns 0 if the boolean is "False". Otherwise, returns 1
    if (!boolean) return 0;
    return 1;
  }
}
