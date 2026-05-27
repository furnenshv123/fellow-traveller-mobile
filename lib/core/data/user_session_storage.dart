import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSessionStorage {
  static const _roleKey = 'current_role';
  static const _emailKey = 'user_email';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<void> saveRole(String role) => _storage.write(key: _roleKey, value: role);

  Future<String?> getRole() => _storage.read(key: _roleKey);

  Future<void> saveEmail(String email) => _storage.write(key: _emailKey, value: email);

  Future<String?> getEmail() => _storage.read(key: _emailKey);

  Future<void> clear() async {
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _emailKey);
  }
}
