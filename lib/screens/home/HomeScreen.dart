import 'package:flutter/material.dart';
import 'package:secure_framework_app/components/formError.dart';
import 'package:secure_framework_app/screens/home/services/ProductProvider.dart';
import 'package:secure_framework_app/screens/login/services/UserProvider.dart';
import 'package:provider/provider.dart';
import 'package:secure_framework_app/screens/login/services/UserData.dart';
import 'package:secure_framework_app/screens/productDetail/ProductDetailScreen.dart';
import 'package:secure_framework_app/components/CustomDrawer.dart';
import 'package:secure_framework_app/screens/home/services/ProductData.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:secure_framework_app/components/constants.dart';
import 'package:secure_framework_app/repository/operationsRepo.dart';
import 'package:secure_framework_app/crypto/cryptographicOperations.dart';

Future<String> clickAddProduct(String email, String productCode) async {
  final storage = Storage;
  String returnedCiphertext, plainMessage;
  String aesKey = await storage.read(key: "AES-Key");
  String iv = await storage.read(key: "IV");
  String hmacKey = await storage.read(key: "HMAC-Key");

  String encryptedMessage = encryptionAES(productCode, aesKey, iv);
  print("Encrypted Message in Home Screen - clickAddProduct: " + encryptedMessage);

  String arrangedCommand = arrangeCommand(encryptedMessage, productCode, hmacKey);
  Map jsonResponseFromAddProduct = await addProduct(email, arrangedCommand);
  returnedCiphertext = jsonResponseFromAddProduct["message"];
  plainMessage = await verifyAndExtractIncommingMessages(returnedCiphertext);
  
  // String manipulation
  plainMessage = plainMessage.substring(1, plainMessage.length-1);

  return plainMessage;
}

class HomeScreen extends StatefulWidget {
  static const routeName = "/home";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variables
  final _formKey = GlobalKey<FormState>();
  final List<String> errors = [];
  bool _isButtonLoading = false;
  String productCode;
  final productCodeTextField = TextEditingController();
  final key = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    User user = userProvider.user;
    // Prints multiple times
    // print("User Email:" + user.email);
    // print("First Product Name of the current user: " + user.products[0].productName);

    return Scaffold(
      key: key,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Home Page"),
        backgroundColor: Colors.blue[900],
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _popupWindow(context, user);
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
                  child: Text(
                    "Most Used Products",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: user.products.length,
                  itemBuilder: (context, index) => _myProductsCard(
                      user.products[index], userProvider, context),
                ),
              ],
            ),
          ),
        ),
        onRefresh: () => _fetchProductsAgain(user),
      ),
      drawer: CustomDrawer(),
    );
  }

  // Pop-up window
  _popupWindow(BuildContext context, User user) {
    Alert(
      context: context,
      title: "Adding a Product",
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0, 30, 0, 10),
              child: buildProductCodeFormField(),
            ),
            FormError(errors: errors),
          ],
        ),
      ),
      buttons: [
        _addProductButton(user),
      ],
    ).show();
  }

  // Add Product Button
  DialogButton _addProductButton(User user) {
    return _isButtonLoading
        ? Container(
            child: Center(child: CircularProgressIndicator()),
            color: Colors.white,
          )
        : DialogButton(
            onPressed: () async {
              print("'Adding This Product' is clicked");
              if (_formKey.currentState.validate() && errors.isEmpty) {
                _formKey.currentState.save();
                // Loading starts
                setState(() {
                  _isButtonLoading = true;
                });

                dynamic returnedMessage = await clickAddProduct(user.email, productCode);

                // Loading ends
                setState(() {
                  _isButtonLoading = false;
                });

                Navigator.pop(context);
                productCodeTextField.clear();
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
              }
            },
            color: Colors.green[800],
            child: Text(
              "Add This Product",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          );
  }

  // Product Card
  // TODO: Refactor the below function
  Widget _myProductsCard(Product product, UserProvider userProvider, BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.33,
      child: Card(
        margin: const EdgeInsets.all(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 0.0),
                    child: Text(
                      product.productName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.keyboard_arrow_right,
                      size: 35,
                    ),
                    color: Colors.blue,
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                          ProductDetailScreen.routeName,
                          arguments: product);
                    },
                  ),
                ],
              ),
              Divider(
                color: Colors.teal[300],
                thickness: 2,
              ),
              Container(
                padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
                child: Text(
                  product.productCode,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              userProvider.isOwnerOnThisProduct(product.roleIDs)
                  ? _displayOwnerRole()
                  : SizedBox.shrink(),
              userProvider.isResidentOnThisProduct(product.roleIDs)
                  ? _displayResidentRole()
                  : SizedBox.shrink(),
            ],
          ),
        ),
        elevation: 15,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  // Display "Owner" text in the card
  Container _displayOwnerRole() {
    return Container(
      child: Text(
        "Owner",
        style: TextStyle(
          fontSize: 18,
          color: Colors.green[700]
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Display "Resident" text in the card
  Container _displayResidentRole() {
    return Container(
      child: Text(
        "Resident",
        style: TextStyle(
          fontSize: 18,
          color: Colors.red[700]
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Get the products when scrolled down
  Future<void> _fetchProductsAgain(User currentUser) async {
    await Provider.of<ProductProvider>(context, listen: false)
        .fetchAndGetProducts(currentUser.email, currentUser)
        .then((_) {});
  }

  // Product Code Form Field
  TextFormField buildProductCodeFormField() {
    return TextFormField(
      keyboardType: TextInputType.name,
      onSaved: (newValue) => productCode = newValue,
      onChanged: (value) {
        if (value.isNotEmpty && errors.contains(ProductCodeNullError)) {
          setState(() {
            errors.remove(ProductCodeNullError);
          });
        } else if (value.length == 9 &&
            errors.contains(InvalidProductCodeError)) {
          setState(() {
            errors.remove(InvalidProductCodeError);
          });
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty && !errors.contains(ProductCodeNullError)) {
          setState(() {
            errors.add(ProductCodeNullError);
          });
        } else if (value.isNotEmpty &&
            value.length != 9 &&
            !errors.contains(InvalidProductCodeError)) {
          setState(() {
            errors.add(InvalidProductCodeError);
          });
        }
        return null;
      },
      decoration: inputDecoration("Product Code", "Enter your product code"),
      controller: productCodeTextField,
    );
  }

  // Generic Input Field Decoration
  InputDecoration inputDecoration(String title, String text) {
    OutlineInputBorder outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Colors.grey),
      gapPadding: 10,
    );
    return InputDecoration(
      labelText: title,
      hintText: text,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 42,
        vertical: 16,
      ),
      enabledBorder: outlineInputBorder,
      focusedBorder: outlineInputBorder,
      border: outlineInputBorder,
    );
  }
}
