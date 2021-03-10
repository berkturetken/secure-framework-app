import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {
  const DefaultButton({
    Key key,
    this.text,
    this.press,
    this.buttonType,
  }) : super(key: key);

  final String text;
  final VoidCallback press;
  final String buttonType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FlatButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        color: colorPicker(buttonType),
        onPressed: press,
        child: Text(
          text,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Color colorPicker(String buttonType) {
    if (buttonType == "Red")
      return Colors.red;
    else if (buttonType == "Blue")
      return Colors.blue;
    else if (buttonType == "Green")
      return Colors.green;
    else if (buttonType == "Primary")
      return Color(0XFFffb300);
    else if(buttonType == "Orange")
      return Colors.deepOrange;
    else if(buttonType == "Default")
      return Color(0XFF9CCC65);
    else
      return Color(0XFF9CCC65);
  }
}
