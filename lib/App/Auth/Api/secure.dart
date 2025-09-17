import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hog/App/Home/Model/category.dart';

class SecurePrefs {
  static final _storage = const FlutterSecureStorage();
  static const String _authTokenKey = "auth_token";
  static const String _categoriesKey = "cached_categories";
  static const String _attireIdKey = "attire_id"; // ✅ new key

  /// Save token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _authTokenKey, value: token);
  }

  /// Get token
  static Future<String?> getToken() async {
    return await _storage.read(key: _authTokenKey);
  }

  /// Delete token (logout)
  static Future<void> clearToken() async {
    await _storage.delete(key: _authTokenKey);
  }

  /// Save categories (as JSON string)
  static Future<void> saveCategories(List<Category> categories) async {
    final categoriesJson = jsonEncode(
      categories.map((c) => c.toJson()).toList(),
    );
    await _storage.write(key: _categoriesKey, value: categoriesJson);
  }

  /// Get categories (decode JSON back into list)
  static Future<List<Category>> getCategories() async {
    final categoriesJson = await _storage.read(key: _categoriesKey);
    if (categoriesJson != null) {
      final List<dynamic> decoded = jsonDecode(categoriesJson);
      return decoded.map((c) => Category.fromJson(c)).toList();
    }
    return [];
  }

  /// Clear cached categories
  static Future<void> clearCategories() async {
    await _storage.delete(key: _categoriesKey);
  }

  /// ✅ Save attireId
  static Future<void> saveAttireId(String attireId) async {
    await _storage.write(key: _attireIdKey, value: attireId);
  }

  /// ✅ Get attireId
  static Future<String?> getAttireId() async {
    return await _storage.read(key: _attireIdKey);
  }

  /// ✅ Clear attireId
  static Future<void> clearAttireId() async {
    await _storage.delete(key: _attireIdKey);
  }
}
