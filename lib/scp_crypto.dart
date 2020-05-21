import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:cryptography/cryptography.dart';
import 'package:cryptography/utils.dart';
import 'package:test/test.dart';

class ScpCrypto {

  static final Random _random = Random.secure();

  Future<String> decodeThenDecrypt(
      String key, String nonce, String base64Text) async {
    List<int> decodedKey = base64.decode(key);
    List<int> decodedNonce = base64.decode(nonce);
    List<int> decodedText = base64.decode(base64Text);
    return await decryptMessage(decodedKey, decodedNonce, decodedText);
  }

  Future<String> decryptMessage(
      List<int> key, List<int> nonce, List<int> encryptedText) async {
    // Encode Key
    SecretKey secretKey = SecretKey(key);
    //Encode nonce
    Nonce encodedNonce = Nonce(nonce);
    //Encode encrypted text
    List<int> cipherText = encryptedText;
    // Decrypt
    final clearText = await chacha20Poly1305Aead
        .decrypt(
      cipherText,
      secretKey: secretKey,
      nonce: encodedNonce,
    )
        .catchError((err) {
      print(err);
    });
    // Return text
    return utf8.decode(clearText);
  }

  Future<ScpJson> encryptThenEncode(
      String key, String message) async {
    EncryptedPayload encryptedPayload =
        await encryptMessage(key, message);
    return ScpJson(
      key: base64Encode(utf8.encode(key)),
      encryptedPayload: encryptedPayload,
    );
  }

  Future<EncryptedPayload> encryptMessage(
      String key, String plainText) async {
    // Encode Key
    SecretKey secretKey = SecretKey(utf8.encode(key));
    //Encode encrypted text
    List<int> clearText = utf8.encode(plainText);
    // Encrypt
    Nonce nonce = Nonce.randomBytes(12);
    final encryptedText = await chacha20Poly1305Aead.encrypt(
      clearText,
      secretKey: secretKey,
      nonce: nonce,
    );

    String base64Data =
        base64Encode(chacha20Poly1305Aead.getDataInCipherText(encryptedText));
    String base64Mac = base64Encode(
        chacha20Poly1305Aead.getMacInCipherText(encryptedText).bytes);

    return EncryptedPayload(
      base64Data: base64Data,
      dataLength:
          chacha20Poly1305Aead.getDataInCipherText(encryptedText).length,
      base64Mac: base64Mac,
      base64DataWithMac: base64Encode(encryptedText),
      base64Nonce: base64Encode(nonce.bytes),
    );
  }

  bool verifyHMAC(String content, String hmac) {
    //for now only with default password later the password stored for the device has to be extracted.
    SecretKey secretKey =
        SecretKey(utf8.encode('01234567890123456789012345678901'));
    var input = utf8.encode(content);
    final sink = Hmac(sha512).newSink(secretKey: secretKey);
    sink.add(input);
    sink.close();
    var mac = sink.mac;
    return ListEquality().equals(hexToBytes(hmac), mac.bytes);
  }
   
  String generatePassword() {
      var values = List<int>.generate(32, (i) => _random.nextInt(256));
      return base64Url.encode(values).substring(0,32);
  }
}

class EncryptedPayload {
  String base64DataWithMac;
  String base64Data;
  int dataLength;
  String base64Mac;
  String base64Nonce;

  EncryptedPayload(
      {this.base64Data, this.dataLength, this.base64Mac, this.base64DataWithMac, this.base64Nonce});
}

class ScpJson {
  String key;
  EncryptedPayload encryptedPayload;

  ScpJson({this.key, this.encryptedPayload});

  Map<String, dynamic> toJson() => {
        'key': key,
        'payload': encryptedPayload.base64Data,
        'payloadLength': encryptedPayload.dataLength,
        'mac': encryptedPayload.base64Mac,
      };
}