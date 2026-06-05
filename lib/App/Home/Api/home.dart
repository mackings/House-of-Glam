import 'dart:convert';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Home/Model/category.dart';
import 'package:hog/App/Home/Model/tailor.dart';
import 'package:hog/App/Home/Model/vendor.dart';
import 'package:hog/constants/api_config.dart';
import 'package:hog/utils/session_expiry_handler.dart';
import 'package:http/http.dart' as http;

class HomeApiService {
  static const String baseUrl = ApiConfig.apiBaseUrl;
  static final Map<String, VendorDetailsResponse> _vendorCache = {};
  static final Map<String, Future<VendorDetailsResponse?>> _vendorInFlight = {};

  static Future<List<Tailor>> getAllTailors() async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/user/getAllTailor");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("➡️ GET Request: $url");
      print("⬅️ Response: ${response.body}");

      if (await SessionExpiryHandler.handleIfExpired(
        statusCode: response.statusCode,
        responseBody: response.body,
      )) {
        return [];
      }

      if (response.statusCode == 200) {
        final List<dynamic> tailorsJson =
            jsonDecode(response.body)["data"] ?? [];
        return tailorsJson.map((t) => Tailor.fromJson(t)).toList();
      }
    } catch (e) {
      print("❌ Error fetching tailors: $e");
    }

    return [];
  }

  static Future<List<Category>> getAllCategories() async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/category/getAllCategories");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("➡️ GET Request: $url");
      print("⬅️ Response: ${response.body}");

      if (await SessionExpiryHandler.handleIfExpired(
        statusCode: response.statusCode,
        responseBody: response.body,
      )) {
        return [];
      }

      if (response.statusCode == 200) {
        final List<dynamic> categoriesJson =
            jsonDecode(response.body)["data"] ?? [];
        final categories =
            categoriesJson.map((c) => Category.fromJson(c)).toList();

        await SecurePrefs.saveCategories(categories);
        return categories;
      }
    } catch (e) {
      print("❌ Error fetching categories: $e");
    }

    return [];
  }

  static Future<VendorDetailsResponse?> getVendorDetails(
    String vendorId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _vendorCache.containsKey(vendorId)) {
      return _vendorCache[vendorId];
    }

    if (!forceRefresh && _vendorInFlight.containsKey(vendorId)) {
      return _vendorInFlight[vendorId];
    }

    final future = _fetchVendorDetails(vendorId, forceRefresh: forceRefresh);
    _vendorInFlight[vendorId] = future;
    final result = await future;
    _vendorInFlight.remove(vendorId);
    if (result != null) {
      _vendorCache[vendorId] = result;
    }
    return result;
  }

  static VendorDetailsResponse? getCachedVendorDetails(String vendorId) {
    return _vendorCache[vendorId];
  }

  static String? getCachedVendorImage(String vendorId) {
    final image = _vendorCache[vendorId]?.userProfile.image;
    if (image == null || image.trim().isEmpty) {
      return null;
    }
    return image;
  }

  static Future<void> prefetchVendorDetails(List<String> vendorIds) async {
    await Future.wait(
      vendorIds.map((vendorId) => getVendorDetails(vendorId)),
      eagerError: false,
    );
  }

  static Future<VendorDetailsResponse?> _fetchVendorDetails(
    String vendorId, {
    bool forceRefresh = false,
  }) async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse(
        "$baseUrl/material/getVendorDetails?vendorId=$vendorId",
      );

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("➡️ GET Request: $url");
      print("⬅️ Response: ${response.body}");

      if (await SessionExpiryHandler.handleIfExpired(
        statusCode: response.statusCode,
        responseBody: response.body,
      )) {
        return null;
      }

      if (response.statusCode == 200) {
        return VendorDetailsResponse.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("❌ Error fetching vendor details: $e");
    }

    if (!forceRefresh) {
      return _vendorCache[vendorId];
    }

    return null;
  }

  // ✅ ADD RATING API
  static Future<VendorRatingResult?> rateVendor(
    String vendorId,
    int rating,
  ) async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/rate/rate/$vendorId");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"rating": rating}),
      );

      print("➡️ POST Request: $url");
      print("📦 Request Body: {\"rating\": $rating}");
      print("⬅️ Response: ${response.body}");

      if (await SessionExpiryHandler.handleIfExpired(
        statusCode: response.statusCode,
        responseBody: response.body,
      )) {
        return null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final vendorJson = Map<String, dynamic>.from(
          decoded['vendor'] as Map? ?? const {},
        );
        vendorJson['averageRating'] = decoded['averageRating'];
        final vendor = Vendor.fromJson(vendorJson);
        final cached = _vendorCache[vendorId];
        if (cached != null) {
          _vendorCache[vendorId] = VendorDetailsResponse(
            success: true,
            message: decoded['message']?.toString() ?? '',
            vendor: vendor,
            userProfile: cached.userProfile,
          );
        }
        return VendorRatingResult(
          message:
              decoded['message']?.toString() ?? 'Vendor rated successfully',
          averageRating:
              (decoded['averageRating'] as num?)?.toDouble() ?? vendor.rate,
          vendor: vendor,
        );
      } else {
        print("❌ Rating failed with status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Error rating vendor: $e");
      return null;
    }
  }

  // ✅ DELETE RATING API
  static Future<bool> deleteRating(String vendorId) async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/rate/rate?vendorId=$vendorId");

      final response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("➡️ DELETE Request: $url");
      print("⬅️ Response: ${response.body}");

      if (await SessionExpiryHandler.handleIfExpired(
        statusCode: response.statusCode,
        responseBody: response.body,
      )) {
        return false;
      }

      if (response.statusCode == 200) {
        return true;
      } else {
        print("❌ Delete rating failed with status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Error deleting rating: $e");
      return false;
    }
  }
}

class VendorRatingResult {
  final String message;
  final double averageRating;
  final Vendor vendor;

  const VendorRatingResult({
    required this.message,
    required this.averageRating,
    required this.vendor,
  });
}
