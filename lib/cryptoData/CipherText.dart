import 'package:flutter/material.dart';

class CipherText {
  final int statusCode;
  final String cText;

  CipherText({
    this.statusCode,
    this.cText
  });

  factory CipherText.fromJson(Map<String, dynamic> json) {
    return CipherText(
      statusCode: json['statusCode'],
      cText: json['body'],
    );
  }
}