import 'package:flutter/material.dart';
import 'package:secure_framework_app/components/CustomDrawer.dart';
import 'package:provider/provider.dart';
import 'package:secure_framework_app/screens/login/services/UserProvider.dart';
import 'package:secure_framework_app/screens/login/services/UserData.dart';
import 'package:secure_framework_app/screens/home/services/ProductData.dart';
import 'package:secure_framework_app/screens/home/services/ProductProvider.dart';

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
                      itemBuilder: (context, index) =>
                          _usersCard(context, tempList[index]),
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
  Widget _usersCard(BuildContext context, var users) {
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

  // RoleID to Role Names
  String getRoleNamesFromInt(int roleId) {
    List<String> userRoles = ["", "Resident", "Owner", "Technical Service"];
    return userRoles[roleId];
  }

  // Get corresponding color for the given RoleID
  Color getColor(int roleId) {
    List<Color> colors = [Colors.blue[700], Colors.green[700], Colors.red[700]];
    return colors[roleId-1];
  }

}
