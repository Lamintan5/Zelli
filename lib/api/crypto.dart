import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionHelper {
  late final encrypt.Key _key;

  EncryptionHelper(String uuid) {

    String keyString = uuid.replaceAll('-', '');
    if (keyString.length > 32) {
      keyString = keyString.substring(0, 32);
    } else {
      keyString = keyString.padRight(32, '0');
    }
    _key = encrypt.Key.fromUtf8(keyString);
  }

  String encryptField(String field) {
    if (field.isEmpty) {
      return '';
    }

    final encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));
    final iv = encrypt.IV.fromLength(16);
    final encrypted = encrypter.encrypt(field, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  String decryptField(String encryptedField) {
    if (encryptedField.isEmpty) {
      return '';
    }
    final parts = encryptedField.split(':');
    if (parts.length != 2) {
      throw ArgumentError('Invalid encrypted data format');
    }

    final iv = encrypt.IV.fromBase64(parts[0]);
    final encryptedText = parts[1];

    final encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));
    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
    return decrypted;
  }
}
