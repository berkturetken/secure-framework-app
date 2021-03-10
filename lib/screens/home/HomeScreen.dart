import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<PlainText> encryptAndSend() async {
  // Prepare a plaintext & encode key and IV
  final plainText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';
  var encodedKey = base64.encode(utf8.encode("this is a key666"));
  var encodedIV = base64.encode(utf8.encode("this is an IV666"));

  // Determine key and IV
  final key = encrypt.Key.fromBase64(encodedKey);
  final iv = encrypt.IV.fromBase64(encodedIV);

  // Create an encrypter with key
  final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

  // Encrypt the plaintext with iv
  final encrypted = encrypter.encrypt(plainText, iv: iv);
  print("Encrypted Message --> " + encrypted.base64);

  var responseJson;
  // var returnedPlainText = "";
  final body = {
    "message": encrypted.base64,
  };
  final jsonString = json.encode(body);

  try {
    final response = await http.post(
      'https://h24q9fa19h.execute-api.eu-central-1.amazonaws.com/test/denemedecrypt',
      body: jsonString,
    );
    responseJson = jsonDecode(response.body);
    print(responseJson);
    /*
    // Get the plaintext again (small problem --> Dictionary inside a dictionary?)
    var responseString = responseJson["body"].toString();
    int len = responseString.length;
    returnedPlainText = responseString.substring(14, len - 1);
    print(returnedPlainText);
    */
  } on Exception catch (_) {
    print("Exception occurs...");
  }
  return PlainText.fromJson(responseJson);
}


Future<CipherText> decryptAndGet() async {
  final plainText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';
  var encodedKey = base64.encode(utf8.encode("this is a key666"));
  var encodedIV = base64.encode(utf8.encode("this is an IV666"));

  // Determine key and IV
  final key = encrypt.Key.fromBase64(encodedKey);
  final iv = encrypt.IV.fromBase64(encodedIV);

  // Create an encrypter with key
  final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

  // Encrypt the plaintext with iv
  final encrypted = encrypter.encrypt(plainText, iv: iv);

  var responseJson, returnedPlainText;
  bool isCorrect = false;
  final body = {
    "message": plainText,
  };
  final jsonString = json.encode(body);

  try {
    final response = await http.post(
      'https://h24q9fa19h.execute-api.eu-central-1.amazonaws.com/test/denemeencrypt',
      body: jsonString,
    );
    responseJson = jsonDecode(response.body);
    
    // Get the plaintext again (small problem --> Dictionary inside a dictionary?)
    var responseString = responseJson["body"].toString();
    int len = responseString.length;
    returnedPlainText = responseString.substring(16, len - 2);
    print("Returned Plain Text --> " + returnedPlainText.toString());
    print("Encrypted -->" + encrypted.base64);
    if(returnedPlainText.toString() == encrypted.base64) {
      isCorrect = true;
    }
    //
    
    print(responseJson);
  } on Exception catch (_) {
    print("Exception occurs...");
  }
  print(isCorrect);
  if(isCorrect) {
    return CipherText.fromJson(responseJson);
  }
  else {
    return null;
  }
  
}


class PlainText {
  final int statusCode;
  final String pText;

  PlainText({this.statusCode, this.pText});

  factory PlainText.fromJson(Map<String, dynamic> json) {
    return PlainText(
      statusCode: json['statusCode'],
      pText: json['body'],
    );
  }
}

class CipherText {
  final int statusCode;
  final String cText;

  CipherText({this.statusCode, this.cText});

  factory CipherText.fromJson(Map<String, dynamic> json) {
    return CipherText(
      statusCode: json['statusCode'],
      cText: json['body'],
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<PlainText> futurePlainText;
  Future<CipherText> futureCipherText;

  
  /*
  @override
  void initState() {
    super.initState();
    futurePlainText = encryptAndSend();
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("Home Page"),
        ),
        backgroundColor: Colors.blue[900],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 150,
                  height: 50,
                  child: FlatButton(
                    onPressed: () {
                      setState(() {
                        futurePlainText = encryptAndSend();  
                      });
                    },
                    child: Text(
                      "Encrypt",
                      style: TextStyle(fontSize: 20),
                    ),
                    color: Colors.deepOrange,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                SizedBox(
                  width: 150,
                  height: 50,
                  child: FlatButton(
                    onPressed: () {
                      setState(() {
                        futureCipherText = decryptAndGet();  
                      });
                    },
                    child: Text(
                      "Decrypt",
                      style: TextStyle(fontSize: 20),
                    ),
                    color: Colors.deepOrange,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.fromLTRB(20, 40, 20, 0),
              child: FutureBuilder<PlainText>(
                future: futurePlainText,
                builder: (context, snapshot) {
                  if(snapshot.hasData) {
                    return Text("Encrypt Button: " + snapshot.data.pText);
                  }
                  else if(snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return Text("Encrypt Button: ");
                }
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(20, 40, 20, 0),
              child: FutureBuilder<CipherText>(
                future: futureCipherText,
                builder: (context, snapshot) {
                  if(snapshot.hasData) {
                    return Text("Decrypt Button: " + snapshot.data.cText);
                  }
                  else if(snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return Text("Decrypt Button: ");
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}
