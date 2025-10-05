import 'dart:convert';

import 'package:hog/App/Admin/Model/AnalyticsModel.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:http/http.dart' as http;

class AnalyticsService {
  static const String baseUrl = "https://hog-ymud.onrender.com/api/v1/admin";

  static Future<TotalUsersResponse?> getTotalUsers() async {
    return _fetchData(
      "$baseUrl/totalUsers",
      (json) => TotalUsersResponse.fromJson(json),
    );
  }

  static Future<FreePaidListingsResponse?> getFreeAndPaidListings() async {
    return _fetchData(
      "$baseUrl/totalNumberOfFreeAndPaidListings",
      (json) => FreePaidListingsResponse.fromJson(json),
    );
  }

  static Future<TotalEarningsResponse?> getTotalEarnings() async {
    return _fetchData(
      "$baseUrl/adminTotalEarnings",
      (json) => TotalEarningsResponse.fromJson(json),
    );
  }

  static Future<TotalTransactionsResponse?> getTotalTransactions() async {
    return _fetchData(
      "$baseUrl/totalTransactions",
      (json) => TotalTransactionsResponse.fromJson(json),
    );
  }

  static Future<TotalListingsResponse?> getTotalListings() async {
    return _fetchData(
      "$baseUrl/totalListings",
      (json) => TotalListingsResponse.fromJson(json),
    );
  }

  static Future<T?> _fetchData<T>(
    String url,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final token = await SecurePrefs.getToken();

    try {
      print("➡️ GET $url");
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("⬅️ Response [${response.statusCode}]: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return fromJson(jsonData);
      } else {
        throw Exception("Failed to fetch data");
      }
    } catch (e) {
      print("❌ Error fetching analytics: $e");
      return null;
    }
  }
}
