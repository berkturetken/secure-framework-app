import 'package:flutter/material.dart';
import 'package:secure_framework_app/screens/home/HomeScreen.dart';
import 'package:secure_framework_app/screens/productDetail.dart/ProductDetailScreen.dart';

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
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
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home Page'),
            trailing: Icon(Icons.arrow_right),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
            },
          ),
          ExpansionTile(
            leading: Icon(Icons.perm_device_information),
            title: Text('My Products'),
            trailing: Icon(Icons.arrow_drop_down),
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home Sweet Home'),
                trailing: Icon(Icons.arrow_right),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed(ProductDetailScreen.routeName);
                  // Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Summer House'),
                trailing: Icon(Icons.arrow_right),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed(ProductDetailScreen.routeName);
                },
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Rented House-1'),
                trailing: Icon(Icons.arrow_right),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          ListTile(
            leading: Icon(Icons.contact_mail),
            title: Text('Add Resident'),
            trailing: Icon(Icons.arrow_right),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
