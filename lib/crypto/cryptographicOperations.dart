import 'package:encrypt/encrypt.dart' as e;
import 'dart:convert';
import 'package:secure_framework_app/components/constants.dart';
import 'package:crypto/crypto.dart';

String decryption(String cipherText, String encodedKey, String encodedIV) {
  // Preparing the key and the IV
  final key = e.Key.fromBase64(encodedKey);
  final iv = e.IV.fromBase64(encodedIV);
  
  // Create an encrypter with the key and set the mode as CBC (Cipher Block Chaining)
  final obj = e.Encrypter(e.AES(key, mode: e.AESMode.cbc));
  
  e.Encrypted ct = e.Encrypted.fromBase64(cipherText);
  String plainText = obj.decrypt(ct, iv: iv);
  
  return plainText;
}

String encryption(String plainText, String encodedKey, encodedIV) {
  // Preparing the key and the IV
  final key = e.Key.fromBase64(encodedKey);
  final iv = e.IV.fromBase64(encodedIV);

  // Create an encrypter with the key and set the mode as CBC (Cipher Block Chaining)
  final obj = e.Encrypter(e.AES(key, mode: e.AESMode.cbc));

  // Encrypt and convert to the string
  e.Encrypted pt = obj.encrypt(plainText, iv: iv);
  String cipherText = pt.base64;

  return cipherText;
}

void arrangeMasterKey(String masterKey) async {
  /***** 
  Divide the masterKey as follows:
  --> AES Key:  0-32  bytes
  --> IV:       32-48 bytes
  --> HMAC:     48-80 bytes
  *****/

  // Encode the key, IV, and HMAC
  String encodedKey = base64.encode(utf8.encode(masterKey.substring(0, 32)));
  String encodedIV = base64.encode(utf8.encode(masterKey.substring(32, 48)));
  String encodedHmacKey = masterKey.substring(48, 80);

  // Save the above items to the flutter secure storage
  final storage = Storage;
  await storage.write(key: "AES-Key", value: encodedKey);
  await storage.write(key: "IV", value: encodedIV);
  await storage.write(key: "Pre-HMAC", value: encodedHmacKey);
}

String arrangeCommand(String cipherText, String plainText, String encodedPreHMAC) {
  // Encrypt the messages which are going to send to the IoT device through AWS
  var decodedHmac = utf8.encode(encodedPreHMAC);
  List<int> encodedMessage = utf8.encode(plainText);

  Hmac hmacSha256 = Hmac(sha256, decodedHmac);        // HMAC-SHA256
  Digest digest = hmacSha256.convert(encodedMessage);
  String hmac = base64.encode(digest.bytes);

  String encryptedCommand = cipherText + hmac;

  // For debugging
  print("HMAC: " + hmac);
  print("HMAC Length: " + hmac.length.toString());
  print("To be sent Command: " + encryptedCommand);
  print("Command Length: " + encryptedCommand.length.toString());

  return encryptedCommand;
}

