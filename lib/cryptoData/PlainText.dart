import 'package:flutter/material.dart';

class PlainText {
  final int statusCode;
  final String pText;

  PlainText({
    this.statusCode,
    this.pText
  });

  factory PlainText.fromJson(Map<String, dynamic> json) {
    return PlainText(
      statusCode: json['statusCode'],
      pText: json['body'],
    );
  }
}