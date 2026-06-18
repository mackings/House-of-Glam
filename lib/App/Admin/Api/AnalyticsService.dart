import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hog/App/Admin/Model/AnalyticsModel.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/constants/api_config.dart';
import 'package:http/http.dart' as http;

class AnalyticsService {
  static const String baseUrl = "${ApiConfig.apiBaseUrl}/admin";

  static Future<AdminAnalyticsResponse?> getAnalytics() async {
    return _fetchData(
      "$baseUrl/analytics",
      (json) => AdminAnalyticsResponse.fromJson(json),
    );
  }

  static Future<AnalyticsUsersPage?> getAnalyticsUsers({
    int page = 1,
    int limit = 20,
    String? search,
    String? role,
    String? subscriptionPlan,
    String? verification,
    String? accountStatus,
  }) {
    return _fetchData(
      _analyticsUri('users', {
        'page': '$page',
        'limit': '$limit',
        if ((search ?? '').isNotEmpty) 'search': search!,
        if ((role ?? '').isNotEmpty) 'role': role!,
        if ((subscriptionPlan ?? '').isNotEmpty)
          'subscriptionPlan': subscriptionPlan!,
        if ((verification ?? '').isNotEmpty) 'verification': verification!,
        if ((accountStatus ?? '').isNotEmpty) 'accountStatus': accountStatus!,
      }).toString(),
      AnalyticsUsersPage.fromJson,
    );
  }

  static Future<AnalyticsListingsPage?> getAnalyticsListings({
    int page = 1,
    int limit = 20,
    String? search,
    String? pricing,
    String? approvalStatus,
    String? availability,
    bool? featured,
  }) {
    return _fetchData(
      _analyticsUri('listings', {
        'page': '$page',
        'limit': '$limit',
        if ((search ?? '').isNotEmpty) 'search': search!,
        if ((pricing ?? '').isNotEmpty) 'pricing': pricing!,
        if ((approvalStatus ?? '').isNotEmpty)
          'approvalStatus': approvalStatus!,
        if ((availability ?? '').isNotEmpty) 'availability': availability!,
        if (featured != null) 'featured': '$featured',
      }).toString(),
      AnalyticsListingsPage.fromJson,
    );
  }

  static Future<AnalyticsTransactionsPage?> getAnalyticsTransactions({
    int page = 1,
    int limit = 20,
    bool successfulOnly = false,
    String? search,
    String? paymentMethod,
    String? currency,
    String? category,
  }) {
    final endpoint =
        successfulOnly ? 'successful-transactions' : 'transactions';
    return _fetchData(
      _analyticsUri(endpoint, {
        'page': '$page',
        'limit': '$limit',
        if ((search ?? '').isNotEmpty) 'search': search!,
        if ((paymentMethod ?? '').isNotEmpty) 'paymentMethod': paymentMethod!,
        if ((currency ?? '').isNotEmpty) 'currency': currency!,
        if ((category ?? '').isNotEmpty) 'category': category!,
      }).toString(),
      AnalyticsTransactionsPage.fromJson,
    );
  }

  static Future<AnalyticsEarningsPage?> getAnalyticsEarnings({
    int page = 1,
    int limit = 20,
  }) {
    return _fetchData(
      _analyticsUri('earnings', {
        'page': '$page',
        'limit': '$limit',
      }).toString(),
      AnalyticsEarningsPage.fromJson,
    );
  }

  static Uri _analyticsUri(
    String endpoint,
    Map<String, String> queryParameters,
  ) {
    return Uri.parse(
      '$baseUrl/analytics/$endpoint',
    ).replace(queryParameters: queryParameters);
  }

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
      if (kDebugMode) debugPrint("GET $url");
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (kDebugMode) {
        debugPrint("Response [${response.statusCode}]: ${response.body}");
      }

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return fromJson(jsonData);
      } else {
        throw Exception("Failed to fetch data");
      }
    } catch (e) {
      if (kDebugMode) debugPrint("Error fetching analytics: $e");
      return null;
    }
  }
}
