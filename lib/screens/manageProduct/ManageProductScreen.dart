import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:secure_framework_app/components/CustomDrawer.dart';
import 'package:provider/provider.dart';
import 'package:secure_framework_app/crypto/cryptographicOperations.dart';
import 'package:secure_framework_app/repository/operationsRepo.dart';
import 'package:secure_framework_app/screens/login/services/UserProvider.dart';
import 'package:secure_framework_app/screens/login/services/UserData.dart';
import 'package:secure_framework_app/screens/home/services/ProductData.dart';
import 'package:secure_framework_app/screens/home/services/ProductProvider.dart';
import 'package:secure_framework_app/components/constants.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

Future<List> clickDeleteResident(String email, String deletedEmail, String productCode) async {
  final storage = Storage;
  String returnedCiphertext, plainMessage;
  int statusCode;
  List<dynamic> response = [];
  String aesKey = await storage.read(key: "AES-Key");
  String iv = await storage.read(key: "IV");
  String hmacKey = await storage.read(key: "HMAC-Key");

  String encryptedMessage = encryptionAES(productCode, aesKey, iv);
  print("Encrypted Message in manage product screen: " + encryptedMessage);

  String arrangedCommand = arrangeCommand(encryptedMessage, productCode, hmacKey);
  Map jsonResponseFromDeleteResident = await deleteResident(email, deletedEmail, arrangedCommand);

  statusCode = jsonResponseFromDeleteResident["statusCode"];
  returnedCiphertext = jsonResponseFromDeleteResident["message"];
  plainMessage = await verifyAndExtractIncommingMessages(returnedCiphertext);
  response.add(statusCode);
  response.add(plainMessage);
  return response;
}

class ManageProductScreen extends StatefulWidget {
  static const routeName = "/manageProduct";

  @override
  _ManageProductScreenState createState() => _ManageProductScreenState();
}

class _ManageProductScreenState extends State<ManageProductScreen> {
  bool _isInit = true;
  bool _isLoading = false;
  List<dynamic> tempList;
  final key = new GlobalKey<ScaffoldState>();

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
          .fetchAndGetUsers(currentProduct.productCode, user.email)
          .then((value) {
        tempList = value;
        print("List --> ");
        print(tempList);

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
    final arguments = ModalRoute.of(context).settings.arguments;
    Product currentProduct = arguments;

    return _isLoading
        ? Container(
            child: Center(child: CircularProgressIndicator()),
            color: Colors.white,
          )
        : Scaffold(
            key: key,
            appBar: AppBar(
              centerTitle: true,
              title: Text("Manage Your Product"),
              backgroundColor: Colors.blue[900],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _heading(),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: tempList.length,
                      itemBuilder: (context, index) => _usersCard(context,
                          tempList[index], userProvider, currentProduct),
                    ),
                  ],
                ),
              ),
            ),
            drawer: CustomDrawer(),
          );
  }

  // Heading of the page
  Container _heading() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
      child: Text(
        "Users of the Product",
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  // Users Card
  Widget _usersCard(BuildContext context, var users, UserProvider userProvider, Product currentProduct) {
    return Card(
      elevation: 6.0,
      margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text(
              users["email"],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              getRoleNamesFromInt(users["roleId"]),
              style: TextStyle(color: getColor(users["roleId"])),
            ),
          ),
          userProvider.isOwnerOnThisProduct(currentProduct.roleIDs) && users["roleId"] != 2
              ? Row(
                  children: <Widget>[
                    _deleteResidentButton(
                        userProvider.user, users["email"], currentProduct),
                  ],
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  // 'Delete Resident' Button
  Padding _deleteResidentButton(User currentUser, String deletedEmail, Product currentProduct) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 0, 10),
      child: OutlinedButton.icon(
        icon: Icon(
          Icons.delete,
          size: 18,
          color: Colors.red,
        ),
        label: Text(
          "Remove Resident",
          style: TextStyle(
            color: Colors.red,
          ),
        ),
        onPressed: () {
          _popupWindow(context, currentUser, deletedEmail, currentProduct);
        },
      ),
    );
  }

  // Pop-up window
  _popupWindow(BuildContext context, User currentUser, String deletedEmail, Product currentProduct) {
    Alert(
      context: context,
      title: "Removing a resident...",
      desc: "Are you really want to remove this user?",
      buttons: [
        DialogButton(
          onPressed: () async {
            String formattedData = jsonEncode(currentProduct.productCode);
            List<dynamic> response = await clickDeleteResident(currentUser.email, deletedEmail, formattedData);
            String returnedMessage = response[1];
            // String manipulation
            returnedMessage = returnedMessage.substring(1, returnedMessage.length-1);

            // TODO: Add circular progress indicator!
            
            Navigator.pop(context);
            final snackBar = SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(returnedMessage),
              action: SnackBarAction(
                label: "OK",
                onPressed: () {
                  print("'OK' is clicked");
                },
              ),
            );
            key.currentState.showSnackBar(snackBar);
            //TODO: Change below 3 lines if you find a better approach! This one is not a good one...
            await Future.delayed(Duration(seconds: 2));
            Navigator.pop(context);
            Navigator.of(context).pushNamed(ManageProductScreen.routeName, arguments: currentProduct);
          },
          color: Colors.red[800],
          child: Text(
            "Yes",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
        DialogButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.green[700],
          child: Text(
            "No",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
      ],
    ).show();
  }

  // RoleID to Role Names
  String getRoleNamesFromInt(int roleId) {
    List<String> userRoles = ["", "Resident", "Owner", "Technical Service"];
    return userRoles[roleId];
  }

  // Get corresponding color for the given RoleID
  Color getColor(int roleId) {
    List<Color> colors = [Colors.blue[700], Colors.green[700], Colors.red[700]];
    return colors[roleId - 1];
  }
}
