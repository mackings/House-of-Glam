import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurePrefs {
  static final _storage = const FlutterSecureStorage();

  /// Save token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: "auth_token", value: token);
  }

  /// Get token
  static Future<String?> getToken() async {
    return await _storage.read(key: "auth_token");
  }

  /// Delete token (logout)
  static Future<void> clearToken() async {
    await _storage.delete(key: "auth_token");
  }
}
