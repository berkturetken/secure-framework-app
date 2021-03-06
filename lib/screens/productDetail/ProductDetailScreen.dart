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
import 'package:secure_framework_app/screens/manageProduct/ManageProductScreen.dart';

Future<bool> sendCommand(String command, String email, String productCode) async {
  final storage = Storage;
  String encryptedMessage, plainMessage;
  String aesKey = await storage.read(key: "AES-Key");
  String iv = await storage.read(key: "IV");
  String hmacKey = await storage.read(key: "HMAC-Key");

  String encryptedCommand = encryptionAES(command, aesKey, iv);
  print("Encrypted Message: " + encryptedCommand);
  String arrangedCommand = arrangeCommand(encryptedCommand, command, hmacKey);

  Map jsonResponseFromSendMessage = await sendMessage(arrangedCommand, email, productCode);
  encryptedMessage = jsonResponseFromSendMessage["message"];
  plainMessage = await verifyAndExtractIncommingMessages(encryptedMessage);

  // Null Check
  if (jsonResponseFromSendMessage == null) {
    print("Returned message: " + plainMessage);
    return false;
  }

  // Error Check
  if (jsonResponseFromSendMessage["statusCode"] == 400) {
    print("Returned message: " + plainMessage);
    return false;
  }
  
  //TODO: Use plaintext in the pop-up window
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
  double temperature;
  String timeStamp = "t";

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
        // Update the initial conditions of the light, temperature and timestamp
        status = fromIntToBool(value["info"]["light"].toInt());
        temperature = value["info"]["temp"];
        timeStamp = value["timeStamp"];

        // Loading ends
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  // TODO: Refactor the below code!
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    User user = userProvider.user;
    final arguments = ModalRoute.of(context).settings.arguments;
    Product currentProduct = arguments;

    return _isLoading
        ? Container(
            child: Center(child: CircularProgressIndicator()),
            color: Colors.white,
          )
        : Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text("Product Detail"),
              backgroundColor: Colors.blue[900],
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.people,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                        ManageProductScreen.routeName,
                        arguments: currentProduct);
                  },
                ),
              ],
            ),
            body: RefreshIndicator(
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _lastFetchedDate(timeStamp),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _lightLabel(),
                          userProvider.isResidentOnThisProduct(
                                  currentProduct.roleIDs)
                              ? _switch(context, user, currentProduct)
                              : SizedBox.shrink(),
                        ],
                      ),
                      Divider(
                        color: Colors.black,
                        height: 50.0,
                        thickness: 1.5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _temperatureLabel(),
                          userProvider.isResidentOnThisProduct(
                                  currentProduct.roleIDs)
                              ? Text(temperature.toString(),
                                  style: TextStyle(fontSize: 20))
                              : SizedBox.shrink(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              onRefresh: () => _fetchDataAgain(currentProduct, user),
            ),
            drawer: CustomDrawer(),
          );
  }

  // Display the last date that the data is fetched
  Container _lastFetchedDate(String timestamp) {
    timestamp = dateBeautifier(timestamp);
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
      child: Text(
        timestamp,
        style: TextStyle(fontSize: 14, color: Colors.grey[800]),
      ),
    );
  }

  // Get the data from IoT device when scrolled down
  Future<void> _fetchDataAgain(Product currentProduct, User user) async {
    await Provider.of<ProductProvider>(context, listen: false)
        .fetchAndGetProductStatus(currentProduct.productCode, user.email)
        .then((value) {
      status = fromIntToBool(value["info"]["light"].toInt());
      temperature = value["info"]["temp"];
      timeStamp = value["timeStamp"];
    });
  }

  // Light
  Container _lightLabel() {
    return Container(
      child: Text(
        "Living Room - Light 1",
        style: TextStyle(
          fontSize: 17,
        ),
      ),
    );
  }

  // Temperature
  Container _temperatureLabel() {
    return Container(
      child: Text(
        "Temperature",
        style: TextStyle(
          fontSize: 17,
        ),
      ),
    );
  }

  // Light Switch
  Widget _switch(BuildContext context, User user, Product product) {
    return _isSwitchLoading
        ? Container(
            child: Center(child: CircularProgressIndicator()),
            color: Colors.white,
          )
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
              bool response = await sendCommand(
                  formattedCommand, user.email, product.productCode);

              // Loading ends
              setState(() {
                _isSwitchLoading = false;
              });

              if (response) {
                status = val;
              } else {
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
      desc: "IoT is not connected",
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

  /* Helper Functions */
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

  // Date beautifier
  String dateBeautifier(String timestamp) {
    String day = "";
    String month = "";
    String year = "";
    String time = "";
    String beuatifiedDate = "";
    int len = timestamp.length;
    List<String> months = [
      "",
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];

    // Adjusting the day
    int dayIndex = timestamp.indexOf('/');
    String retrievedDay = timestamp.substring(0, dayIndex);
    if (retrievedDay.substring(0, 1) == "0") {
      retrievedDay = retrievedDay.substring(1);
    }
    day = retrievedDay;

    // Adjusting the month
    int monthIndex = timestamp.indexOf('/', 3);
    String retrievedMonth = timestamp.substring(3, monthIndex);
    if (retrievedMonth.substring(0, 1) == "0") {
      retrievedMonth = retrievedMonth.substring(1);
    }
    month = months[int.parse(retrievedMonth)];

    // Adjusting the year
    int yearIndex = timestamp.indexOf(' ');
    String retrievedYear = timestamp.substring(monthIndex + 1, yearIndex);
    year = retrievedYear;

    // Adjusting the time
    
    String retrievedTime = timestamp.substring(yearIndex + 1, len-3);
    time = retrievedTime;

    beuatifiedDate = day + " " + month + " " + year + " " + time;
    return beuatifiedDate;
  }

}
