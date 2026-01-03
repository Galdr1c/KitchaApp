import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for encrypting sensitive data.
class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  final _storage = const FlutterSecureStorage();
  static const _keyName = 'encryption_key';

  /// Encrypt a string.
  Future<String> encrypt(String plainText) async {
    final key = await _getOrCreateKey();
    // Simple XOR encryption for demonstration
    // In production, use proper AES encryption
    final encoded = _xorEncode(plainText, key);
    return base64.encode(utf8.encode(encoded));
  }

  /// Decrypt a string.
  Future<String> decrypt(String encryptedText) async {
    final key = await _getOrCreateKey();
    final decoded = utf8.decode(base64.decode(encryptedText));
    return _xorEncode(decoded, key);
  }

  /// Store encrypted value.
  Future<void> storeSecure(String key, String value) async {
    final encrypted = await encrypt(value);
    await _storage.write(key: key, value: encrypted);
  }

  /// Read encrypted value.
  Future<String?> readSecure(String key) async {
    final encrypted = await _storage.read(key: key);
    if (encrypted == null) return null;
    return await decrypt(encrypted);
  }

  /// Delete secure value.
  Future<void> deleteSecure(String key) async {
    await _storage.delete(key: key);
  }

  /// Clear all secure storage.
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  Future<String> _getOrCreateKey() async {
    String? key = await _storage.read(key: _keyName);
    
    if (key == null) {
      // Generate a random key
      key = base64.encode(List.generate(32, (i) => DateTime.now().microsecond % 256));
      await _storage.write(key: _keyName, value: key);
    }
    
    return key;
  }

  String _xorEncode(String text, String key) {
    final result = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      result.writeCharCode(text.codeUnitAt(i) ^ key.codeUnitAt(i % key.length));
    }
    return result.toString();
  }
}
