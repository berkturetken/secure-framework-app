import 'package:flutter/material.dart';
import 'package:secure_framework_app/components/CustomDrawer.dart';
import 'package:secure_framework_app/screens/addResident/components/addResidentForm.dart';

class AddResidentScreen extends StatelessWidget {
  static const routeName = "/addResident";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Add Resident'),
        backgroundColor: Colors.blue[900],
      ),
      body: SafeArea(
        child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 20, 0, 30),
                    child: Text(
                      "As an owner, add a new resident",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  AddResidentForm(),
                ],
              ),
            ),
          ),
        ),
      ),
      drawer: CustomDrawer(),
    );
  }
}