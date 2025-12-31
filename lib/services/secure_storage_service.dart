import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Save a secure value
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Read a secure value
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  /// Delete a specific key
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Clear all secure storage (use with caution)
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  /// Get encryption key for database (generates one if missing)
  Future<String> getDatabaseKey() async {
    String? key = await read('db_encryption_key');
    if (key == null) {
      // Simple generated key for demo, in real production use a stronger random generator
      key = DateTime.now().millisecondsSinceEpoch.toString() + '_kitcha_prod';
      await write('db_encryption_key', key);
    }
    return key;
  }
}
