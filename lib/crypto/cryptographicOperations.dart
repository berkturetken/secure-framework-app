import 'package:encrypt/encrypt.dart' as e;
import 'dart:convert';
import 'package:secure_framework_app/components/constants.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';


String decryption(String cipherText, String preKey, String preIV) {
  // Encode the key and IV
  var encodedKey = utf8.encode(preKey);
  var encodedIV = utf8.encode(preIV);

  // Preparing the key and IV
  final key = e.Key(encodedKey);
  final iv = e.IV(encodedIV);

  // Create an encrypter with the key and set the mode as CBC (Cipher Block Chaining)
  final obj = e.Encrypter(e.AES(key, mode: e.AESMode.cbc));

  e.Encrypted ct = e.Encrypted.fromBase64(cipherText); // ct stands for CipherText
  String plainText = obj.decrypt(ct, iv: iv);

  return plainText;
}


String encryptionAES(String plainText, String preKey, String preIV) {
  // Encode the key and IV
  var encodedKey = utf8.encode(preKey);
  var encodedIV = utf8.encode(preIV);

  // Preparing the key and IV
  final key = e.Key(encodedKey);
  final iv = e.IV(encodedIV);

  // Create an encrypter with the key and set the mode as CBC (Cipher Block Chaining)
  final obj = e.Encrypter(e.AES(key, mode: e.AESMode.cbc));

  // Encrypt and convert to the string
  e.Encrypted ct = obj.encrypt(plainText, iv: iv); // pt stands for PlainText
  String cipherText = ct.base64;

  return cipherText;
}


Future<String> encryptionRSA (String data) async {
  // parseKeyFromFile() is not working! --> await parseKeyFromFile('assets/my_rsa_public.pem')
  final publicPem = await rootBundle.loadString('assets/my_rsa_public.pem');
  final publicKey = e.RSAKeyParser().parse(publicPem);

  final obj = e.Encrypter(e.RSA(publicKey: publicKey));
  e.Encrypted ct = obj.encrypt(data);
  String cipherText = ct.base64;

  // For debugging
  print("Encrypted Message: " + cipherText);
  return cipherText;
}


void arrangeMasterKey(String masterKey) async {
  /***** 
  Divide the masterKey as follows:
  --> AES Key:  0-32  bytes
  --> IV:       32-48 bytes
  --> HMAC:     48-80 bytes
  *****/

  // Arrange the key, IV, and HMAC
  String aesKey = masterKey.substring(0, 32);
  String iv = masterKey.substring(32, 48);
  String hmacKey = masterKey.substring(48, 80);
  // For debugging purposes:
  print("AES Key: " + aesKey);
  print("AES IV: " + iv);
  print("HMAC Key: " + hmacKey);

  // Save the above items to the flutter secure storage
  final storage = Storage;
  await storage.write(key: "AES-Key", value: aesKey);
  await storage.write(key: "IV", value: iv);
  await storage.write(key: "HMAC-Key", value: hmacKey);
}


String arrangeCommand(String cipherText, String plainText, String hmacKey) {
  // Encrypt the messages which are going to send to the IoT device through AWS
  String hmac = hmacing(plainText, hmacKey);  
  String securedCommand = cipherText + hmac;

  // For debugging purposes:
  print("HMAC: " + hmac);
  print("HMAC Length: " + hmac.length.toString());
  print("To be sent Command: " + securedCommand);
  print("Command Length: " + securedCommand.length.toString());

  return securedCommand;
}


String passwordHashing(String password) {
  // Hashing with SHA-512
  List<int> passwordBytes = utf8.encode(password);
  Digest passwordHashedDigest = sha512.convert(passwordBytes);
  
  // For debugging
  print("Password: $password");
  print("Hashed Password: $passwordHashedDigest");

  String passwordHashed = passwordHashedDigest.toString();
  return passwordHashed;
}


String hmacing(String plainText, String hmacKey) {
  List<int> encodedHmac = utf8.encode(hmacKey);
  List<int> encodedPlainText = utf8.encode(plainText);

  Hmac hmacSha256 = Hmac(sha256, encodedHmac);
  Digest digest = hmacSha256.convert(encodedPlainText);
  String hmac = base64.encode(digest.bytes);
  return hmac;
}