import 'package:flutter/material.dart';
import 'package:secure_framework_app/components/defaultButton.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text("Home Page"),
        ),
        backgroundColor: Colors.blue[900],
      ),
      body: SafeArea(
        child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DefaultButton(
                    text: "Encrypt",
                    buttonType: "Orange",
                    press: () {
                      print("Deneme");
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
