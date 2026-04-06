import 'dart:convert';

import 'package:hog/App/Admin/Model/PendingListing.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/constants/api_config.dart';
import 'package:http/http.dart' as http;

class AdminService {
  static const String baseUrl = "${ApiConfig.apiBaseUrl}/admin";

  static Future<SellerModerationListResponse> getAllPendingListings({
    int page = 1,
    int limit = 20,
    String? categoryId,
  }) async {
    final json = await _get(
      'getAllPendingSellerListings',
      queryParameters: {
        'page': '$page',
        'limit': '$limit',
        if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
      },
    );

    return SellerModerationListResponse.fromJson(json);
  }

  static Future<SellerModerationListResponse> getApprovedListings({
    int page = 1,
    int limit = 20,
    bool mine = false,
    String? approvedBy,
    String? categoryId,
  }) async {
    final json = await _get(
      'getApprovedSellerListings',
      queryParameters: {
        'page': '$page',
        'limit': '$limit',
        if (mine) 'mine': 'true',
        if (approvedBy != null && approvedBy.isNotEmpty) 'approvedBy': approvedBy,
        if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
      },
    );

    return SellerModerationListResponse.fromJson(json);
  }

  static Future<SellerModerationListResponse> getRejectedListings({
    int page = 1,
    int limit = 20,
    bool mine = false,
    String? rejectedBy,
    String? categoryId,
  }) async {
    final json = await _get(
      'getRejectedSellerListings',
      queryParameters: {
        'page': '$page',
        'limit': '$limit',
        if (mine) 'mine': 'true',
        if (rejectedBy != null && rejectedBy.isNotEmpty) 'rejectedBy': rejectedBy,
        if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
      },
    );

    return SellerModerationListResponse.fromJson(json);
  }

  static Future<SellerModerationListResponse> getSellerListings({
    required String status,
    int page = 1,
    int limit = 20,
    bool mine = false,
    String? approvedBy,
    String? rejectedBy,
    String? categoryId,
  }) async {
    final json = await _get(
      'getSellerListings',
      queryParameters: {
        'status': status,
        'page': '$page',
        'limit': '$limit',
        if (mine) 'mine': 'true',
        if (approvedBy != null && approvedBy.isNotEmpty) 'approvedBy': approvedBy,
        if (rejectedBy != null && rejectedBy.isNotEmpty) 'rejectedBy': rejectedBy,
        if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
      },
    );

    return SellerModerationListResponse.fromJson(json);
  }

  static Future<SellerModerationListing> getListingById(String listingId) async {
    final json = await _get('getSellerListingById/$listingId');
    final data = _asMap(json['data']);
    if (data == null) {
      throw Exception('Seller listing details were not returned by the server.');
    }
    return SellerModerationListing.fromJson(data);
  }

  static Future<ListingModerationHistoryResponse> getModerationHistory({
    int page = 1,
    int limit = 20,
    String? action,
    String? moderatorId,
  }) async {
    final json = await _get(
      'getListingModerationHistory',
      queryParameters: {
        'page': '$page',
        'limit': '$limit',
        if (action != null && action.isNotEmpty) 'action': action,
        if (moderatorId != null && moderatorId.isNotEmpty) 'moderatorId': moderatorId,
      },
    );

    return ListingModerationHistoryResponse.fromJson(json);
  }

  static Future<void> approveListing(String listingId) async {
    await _put('approveSellerListing/$listingId');
  }

  static Future<void> rejectListing(String listingId, List<String> reasons) async {
    final cleanedReasons =
        reasons.map((reason) => reason.trim()).where((reason) => reason.isNotEmpty).toList();
    if (cleanedReasons.isEmpty) {
      throw Exception('At least one rejection reason is required.');
    }

    await _put(
      'rejectSellerListing/$listingId',
      body: jsonEncode({
        'reasons': cleanedReasons.length == 1 ? cleanedReasons.first : cleanedReasons,
      }),
    );
  }

  static Future<Map<String, dynamic>> _get(
    String endpoint, {
    Map<String, String>? queryParameters,
  }) async {
    final headers = await _headers();
    final uri = _buildUri(endpoint, queryParameters: queryParameters);
    final response = await http.get(uri, headers: headers);
    return _parseResponse(response);
  }

  static Future<Map<String, dynamic>> _put(
    String endpoint, {
    String? body,
  }) async {
    final headers = await _headers();
    final uri = _buildUri(endpoint);
    final response = await http.put(uri, headers: headers, body: body);
    return _parseResponse(response);
  }

  static Uri _buildUri(
    String endpoint, {
    Map<String, String>? queryParameters,
  }) {
    return Uri.parse('$baseUrl/$endpoint').replace(
      queryParameters:
          queryParameters == null || queryParameters.isEmpty
              ? null
              : queryParameters,
    );
  }

  static Future<Map<String, String>> _headers() async {
    final token = await SecurePrefs.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found for admin request.');
    }
    return ApiConfig.getAuthHeaders(token);
  }

  static Map<String, dynamic> _parseResponse(http.Response response) {
    final json =
        response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json;
    }

    throw Exception(
      (json['message'] ?? 'Request failed with status ${response.statusCode}.')
          .toString(),
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }
}
