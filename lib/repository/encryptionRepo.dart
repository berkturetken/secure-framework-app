import 'dart:typed_data';
import 'package:encrypt/encrypt_io.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as e;
import 'package:secure_framework_app/cryptoData/plainText.dart';
import 'dart:convert';
// import 'package:rsa_encrypt/rsa_encrypt.dart';
import 'package:pointycastle/export.dart';

// Built-in functions from the pointycastle package
Uint8List _processInBlocks(AsymmetricBlockCipher engine, Uint8List input) {
  final numBlocks = input.length ~/ engine.inputBlockSize +
      ((input.length % engine.inputBlockSize != 0) ? 1 : 0);

  final output = Uint8List(numBlocks * engine.outputBlockSize);

  var inputOffset = 0;
  var outputOffset = 0;
  while (inputOffset < input.length) {
    final chunkSize = (inputOffset + engine.inputBlockSize <= input.length)
        ? engine.inputBlockSize
        : input.length - inputOffset;

    outputOffset += engine.processBlock(
        input, inputOffset, chunkSize, output, outputOffset);

    inputOffset += chunkSize;
  }

  return (output.length == outputOffset)
      ? output
      : output.sublist(0, outputOffset);
}

// Built-in functions from the pointycastle package
Uint8List rsaEncrypt(RSAPublicKey myPublic, Uint8List dataToEncrypt) {
  final encryptor = OAEPEncoding(RSAEngine())
    ..init(true, PublicKeyParameter<RSAPublicKey>(myPublic)); // true=encrypt

  return _processInBlocks(encryptor, dataToEncrypt);
}


Future<void> encryptAndSend(String plainText) async {
  // parseKeyFromFile() is not working!!!
  // final publicKey = await parseKeyFromFile('assets/my_rsa_public.pem');
  final publicPem = await rootBundle.loadString('assets/my_rsa_public.pem');
  final publicKey = e.RSAKeyParser().parse(publicPem) as RSAPublicKey;

  // final plainText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';
  final encrypter = e.Encrypter(e.RSA(publicKey: publicKey));

  final encrypted = encrypter.encrypt(plainText);
  // final encrypted = encrypt(plainText, publicKey); -- rsa_encrypt
  var newEncrypted = rsaEncrypt(publicKey, utf8.encode(plainText));

  // print("Encrypted message: " + encrypted.base64);
  print("Encrypted message --> ");
  var encryptedFormatted = base64Encode(newEncrypted); 
  print(encryptedFormatted);

  var responseJson;
  final body = {
    "message": encrypted.base64,
  };
  final jsonString = json.encode(body);

  try {
    final response = await http.post(
      'https://h24q9fa19h.execute-api.eu-central-1.amazonaws.com/test/signup',
      body: jsonString,
    );
    responseJson = jsonDecode(response.body);
    print(responseJson.runtimeType);
    print(responseJson);
  } on Exception catch (_) {
    print("Exception occurs...");
  }
  // return responseJson;
}