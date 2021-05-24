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

Future<dynamic> clickDeleteResident(
    String email, String deletedEmail, String productCode) async {
  final storage = Storage;
  String aesKey = await storage.read(key: "AES-Key");
  String iv = await storage.read(key: "IV");
  String hmacKey = await storage.read(key: "HMAC-Key");

  String encryptedMessage = encryptionAES(productCode, aesKey, iv);
  print("Encrypted Message in manage product screen: " + encryptedMessage);

  String arrangedCommand =
      arrangeCommand(encryptedMessage, productCode, hmacKey);
  Map jsonResponseFromDeleteResident =
      await deleteResident(email, deletedEmail, arrangedCommand);
  return jsonResponseFromDeleteResident;
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
    User currentUser = userProvider.user;
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
  Widget _usersCard(BuildContext context, var users, UserProvider userProvider,
      Product currentProduct) {
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
          userProvider.isOwnerOnThisProduct(currentProduct.roleIDs)
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
  Padding _deleteResidentButton(
      User currentUser, String deletedEmail, Product currentProduct) {
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
          print("Clicked 'Remove Resident'");
          _popupWindow(context, currentUser, deletedEmail, currentProduct);
        },
      ),
    );
  }

  // Pop-up window
  _popupWindow(BuildContext context, User currentUser, String deletedEmail,
      Product currentProduct) {
    Alert(
      context: context,
      title: "Removing a resident...",
      desc: "Are you really want to remove this user?",
      buttons: [
        DialogButton(
          onPressed: () async {
            String formattedData = jsonEncode(currentProduct.productCode);
            print("Pressed product code: " + currentProduct.productCode);
            dynamic response = await clickDeleteResident(
                currentUser.email, deletedEmail, formattedData);

            print("Delete operation is handled...");
            // Navigator.pop(context)
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
