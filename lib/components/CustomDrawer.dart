import 'package:flutter/material.dart';
import 'package:secure_framework_app/screens/addResident/AddResidentScreen.dart';
import 'package:secure_framework_app/screens/home/HomeScreen.dart';
import 'package:secure_framework_app/screens/login/loginScreen.dart';
import 'package:secure_framework_app/components/constants.dart';
import 'package:secure_framework_app/screens/login/services/UserProvider.dart';
import 'package:provider/provider.dart';
import 'package:secure_framework_app/screens/login/services/UserData.dart';
import 'package:secure_framework_app/screens/home/services/ProductData.dart';
import 'package:secure_framework_app/screens/productDetail/ProductDetailScreen.dart';

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    User currentUser = userProvider.user;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _drawerHeader(),
          _drawerItemHomePage(context),
          _drawerItemMyProducts(currentUser, context),
          _drawerItemAddResident(context),
          Divider(),
          _drawerItemLogout(userProvider),
          _drawerItemAppVersion(),
        ],
      ),
    );
  }

  // Drawer Header
  DrawerHeader _drawerHeader() {
    return DrawerHeader(
      child: Align(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.code,
              color: Colors.white,
              size: 100.0,
            ),
            Text(
              "Secure Home",
              style: TextStyle(color: Colors.white, fontSize: 25.0),
            ),
          ],
        ),
      ),
      decoration: BoxDecoration(color: Colors.blue),
    );
  }

  // Drawer Item - Home Page
  ListTile _drawerItemHomePage(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.home),
      title: Text('Home Page'),
      trailing: Icon(Icons.arrow_right),
      onTap: () {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      },
    );
  }

  // Drawer Item - My Products
  ExpansionTile _drawerItemMyProducts(User user, BuildContext context) {
    return ExpansionTile(
      leading: Icon(Icons.perm_device_information),
      title: Text('My Products'),
      trailing: Icon(Icons.arrow_drop_down),
      children: <Widget>[
        ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: user.products.length,
            itemBuilder: (context, index) =>
                _listTile(user.products[index], context)),
      ],
    );
  }

  // List tile - i.e. products
  ListTile _listTile(Product product, BuildContext context) {
    return ListTile(
      leading: Icon(Icons.home),
      title: Text(product.productName),
      trailing: Icon(Icons.arrow_right),
      onTap: () {
        Navigator.of(context).pushReplacementNamed(
            ProductDetailScreen.routeName,
            arguments: product);
      },
    );
  }

  // Drawer Item - Add Resident
  ListTile _drawerItemAddResident(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.contact_mail),
      title: Text('Add Resident'),
      trailing: Icon(Icons.arrow_right),
      onTap: () {
        Navigator.of(context).pushReplacementNamed(AddResidentScreen.routeName);
      },
    );
  }

  // Drawer Item - Logout
  ListTile _drawerItemLogout(UserProvider userProvider) {
    return ListTile(
      leading: Icon(Icons.logout),
      title: Text('Logout'),
      //trailing: Icon(Icons.arrow_right),
      onTap: () {
        _logout(userProvider);
      },
    );
  }

  // Drawer Item - App Version
  ListTile _drawerItemAppVersion() {
    return ListTile(
      title: Text('0.0.1'),
      onTap: () {},
    );
  }

  // Logout Process
  _logout(UserProvider userProvider) async {
    final storage = Storage;
    await storage.deleteAll();
    userProvider.deleteCurrentUser();
    print("Logging out from the app...");
    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
  }
}
