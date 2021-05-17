import 'package:flutter/material.dart';
import 'package:secure_framework_app/components/CustomDrawer.dart';
import 'package:secure_framework_app/components/defaultButton.dart';

class ManageProductScreen extends StatefulWidget {
  static const routeName = "/manageProduct";

  @override
  _ManageProductScreenState createState() => _ManageProductScreenState();
}

class _ManageProductScreenState extends State<ManageProductScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                itemCount: 5,
                itemBuilder: (context, index) => _usersCard(context),
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
  Widget _usersCard(BuildContext context) {
    return Card(
      elevation: 6.0,
      margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text(
              'claire@gmail.com',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              'Owner',
              style: TextStyle(color: Colors.green[700]),
            ),
          ),
          Row(
            children: <Widget>[
              Padding(
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
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
