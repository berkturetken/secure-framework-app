import 'package:flutter/material.dart';
import 'package:secure_framework_app/screens/home/services/ProductProvider.dart';
import 'package:secure_framework_app/screens/login/services/UserProvider.dart';
import 'package:provider/provider.dart';
import 'package:secure_framework_app/screens/login/services/UserData.dart';
import 'package:secure_framework_app/screens/productDetail/ProductDetailScreen.dart';
import 'package:secure_framework_app/components/CustomDrawer.dart';
import 'package:secure_framework_app/screens/home/services/ProductData.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = "/home";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    User user = userProvider.user;

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Home Page"),
          backgroundColor: Colors.blue[900],
        ),
        body: SingleChildScrollView(
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
                  itemBuilder: (context, index) => _myProductsCard(user.products[index], productProvider, context),
                ),
              ],
            ),
          ),
        ),
        drawer: CustomDrawer());
  }

  // Product Card
  // TODO: Refactor the below function
  Widget _myProductsCard(Product product, ProductProvider productProvider, BuildContext context) {
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
              Container(
                child: Text(
                  productProvider.getUserRole(product.roleID),
                  style: TextStyle(
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
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

}