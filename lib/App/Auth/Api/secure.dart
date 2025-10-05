import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hog/App/Home/Model/category.dart';

class SecurePrefs {
  static final _storage = const FlutterSecureStorage();

  // Keys
  static const String _authTokenKey = "auth_token";
  static const String _refreshTokenKey = "refresh_token";
  static const String _categoriesKey = "cached_categories";
  static const String _attireIdKey = "attire_id";
  static const String _userDataKey = "user_data";
  static const String _adminSettingsKey = "admin_settings";

  // ✅ NEW: Currency Key
  static const String _userCurrencyKey = "user_currency";

  // -------------------------
  // AUTH TOKEN
  // -------------------------
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _authTokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _authTokenKey);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _authTokenKey);
  }

  // -------------------------
  // REFRESH TOKEN
  // -------------------------
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  static Future<void> clearRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  // -------------------------
  // CATEGORIES
  // -------------------------
  static Future<void> saveCategories(List<Category> categories) async {
    final categoriesJson = jsonEncode(
      categories.map((c) => c.toJson()).toList(),
    );
    await _storage.write(key: _categoriesKey, value: categoriesJson);
  }

  static Future<List<Category>> getCategories() async {
    final categoriesJson = await _storage.read(key: _categoriesKey);
    if (categoriesJson != null) {
      final List<dynamic> decoded = jsonDecode(categoriesJson);
      return decoded.map((c) => Category.fromJson(c)).toList();
    }
    return [];
  }

  static Future<void> clearCategories() async {
    await _storage.delete(key: _categoriesKey);
  }

  // -------------------------
  // ATTIRE ID
  // -------------------------
  static Future<void> saveAttireId(String attireId) async {
    await _storage.write(key: _attireIdKey, value: attireId);
  }

  static Future<String?> getAttireId() async {
    return await _storage.read(key: _attireIdKey);
  }

  static Future<void> clearAttireId() async {
    await _storage.delete(key: _attireIdKey);
  }

  // -------------------------
  // USER DATA
  // -------------------------
  static Future<void> saveUserData(Map<String, dynamic> user) async {
    final userJson = jsonEncode(user);
    await _storage.write(key: _userDataKey, value: userJson);
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final userJson = await _storage.read(key: _userDataKey);
    if (userJson != null) {
      try {
        final decoded = jsonDecode(userJson) as Map<String, dynamic>;
        return decoded;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<void> clearUserData() async {
    await _storage.delete(key: _userDataKey);
  }

  /// ✅ Convenience: return only the user's role
  static Future<String?> getUserRole() async {
    final userJson = await _storage.read(key: _userDataKey);
    if (userJson != null) {
      try {
        final Map<String, dynamic> userMap = jsonDecode(userJson);
        final role = userMap['role'];
        return role != null ? role.toString() : null;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // -------------------------
  // ✅ USER CURRENCY
  // -------------------------
  static Future<void> saveUserCurrency(String currency) async {
    await _storage.write(key: _userCurrencyKey, value: currency);
  }

  static Future<String?> getUserCurrency() async {
    return await _storage.read(key: _userCurrencyKey);
  }

  static Future<void> clearUserCurrency() async {
    await _storage.delete(key: _userCurrencyKey);
  }

  // -------------------------
  // ADMIN SETTINGS
  // -------------------------
  static Future<void> saveAdminSettings(Map<String, dynamic> settings) async {
    final settingsJson = jsonEncode(settings);
    await _storage.write(key: _adminSettingsKey, value: settingsJson);
  }

  static Future<Map<String, dynamic>?> getAdminSettings() async {
    final settingsJson = await _storage.read(key: _adminSettingsKey);
    if (settingsJson != null) {
      try {
        final decoded = jsonDecode(settingsJson) as Map<String, dynamic>;
        return decoded;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<void> clearAdminSettings() async {
    await _storage.delete(key: _adminSettingsKey);
  }

  // -------------------------
  // CLEAR ALL (LOGOUT)
  // -------------------------
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
