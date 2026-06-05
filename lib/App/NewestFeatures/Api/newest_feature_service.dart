import 'dart:convert';
import 'dart:io';

import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/constants/api_config.dart';
import 'package:hog/utils/session_expiry_handler.dart';
import 'package:http/http.dart' as http;

class ApiResult {
  final bool success;
  final String message;
  final dynamic data;
  final int statusCode;

  const ApiResult({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
  });

  factory ApiResult.fromResponse(http.Response response) {
    dynamic decoded;
    try {
      decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (_) {
      decoded = null;
    }

    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
    final message =
        decoded is Map<String, dynamic>
            ? decoded['message']?.toString() ?? ''
            : response.reasonPhrase ?? '';

    return ApiResult(
      success:
          decoded is Map<String, dynamic>
              ? decoded['success'] == true || isSuccess
              : isSuccess,
      message:
          message.isEmpty
              ? (isSuccess ? 'Success' : 'Request failed')
              : message,
      data:
          decoded is Map<String, dynamic>
              ? decoded['data'] ?? decoded
              : decoded,
      statusCode: response.statusCode,
    );
  }

  factory ApiResult.failure(String message, {int statusCode = 0}) {
    return ApiResult(success: false, message: message, statusCode: statusCode);
  }
}

class NewestFeatureService {
  static const String _baseUrl = ApiConfig.apiBaseUrl;

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await SecurePrefs.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Future<ApiResult> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$path');
      final headers = await _headers(auth: auth);
      final payload = body == null ? null : jsonEncode(body);

      late final http.Response response;
      switch (method) {
        case 'POST':
          response = await http.post(uri, headers: headers, body: payload);
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: payload);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers, body: payload);
          break;
        default:
          response = await http.get(uri, headers: headers);
      }

      if (await SessionExpiryHandler.handleIfExpired(
        statusCode: response.statusCode,
        responseBody: response.body,
      )) {
        return ApiResult.failure(
          'Session expired',
          statusCode: response.statusCode,
        );
      }

      return ApiResult.fromResponse(response);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  static Future<ApiResult> _sendMultipart(
    String method,
    String path, {
    Map<String, String>? fields,
    List<File> files = const [],
    String fileField = 'images',
    bool auth = true,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$path');
      final request = http.MultipartRequest(method, uri);
      if (auth) {
        final token = await SecurePrefs.getToken();
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }
      request.fields.addAll(fields ?? const {});
      for (final file in files) {
        request.files.add(
          await http.MultipartFile.fromPath(fileField, file.path),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (await SessionExpiryHandler.handleIfExpired(
        statusCode: response.statusCode,
        responseBody: response.body,
      )) {
        return ApiResult.failure(
          'Session expired',
          statusCode: response.statusCode,
        );
      }

      return ApiResult.fromResponse(response);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  static Future<ApiResult> getPublicListings({String query = ''}) {
    return _send('GET', '/discovery/public/listings$query', auth: false);
  }

  static Future<ApiResult> getPublicListing(String listingId) {
    return _send('GET', '/discovery/public/listings/$listingId', auth: false);
  }

  static Future<ApiResult> getPublicDesigners({String query = ''}) {
    return _send('GET', '/discovery/public/designers$query', auth: false);
  }

  static Future<ApiResult> getPublicDesigner(String designerId) {
    return _send('GET', '/discovery/public/designers/$designerId', auth: false);
  }

  static Future<ApiResult> getListings({String query = ''}) {
    return _send('GET', '/discovery/listings$query');
  }

  static Future<ApiResult> getDesigners({String query = ''}) {
    return _send('GET', '/discovery/designers$query');
  }

  static Future<ApiResult> createMeasurementProfile(Map<String, dynamic> body) {
    return _send('POST', '/measurements/profiles', body: body);
  }

  static Future<ApiResult> updateMeasurementProfile(
    String profileId,
    Map<String, dynamic> body,
  ) {
    return _send('PUT', '/measurements/profiles/$profileId', body: body);
  }

  static Future<ApiResult> getMeasurementProfiles() {
    return _send('GET', '/measurements/profiles');
  }

  static Future<ApiResult> requestMeasurements(Map<String, dynamic> body) {
    return _send('POST', '/measurements/requests', body: body);
  }

  static Future<ApiResult> getMeasurementRequestTargets() {
    return _send('GET', '/measurements/request-targets');
  }

  static Future<ApiResult> requestMeasurementsForTarget(
    String measurementTargetId,
    Map<String, dynamic> body,
  ) {
    return _send(
      'POST',
      '/measurements/request-targets/$measurementTargetId',
      body: body,
    );
  }

  static Future<ApiResult> getMeasurementRequests() {
    return _send('GET', '/measurements/requests');
  }

  static Future<ApiResult> updatePortfolio(Map<String, dynamic> body) {
    return _send('PUT', '/tailor/portfolio', body: body);
  }

  static Future<ApiResult> updatePortfolioFiles({
    required List<File> images,
    required List<String> captions,
    required List<String> categories,
  }) {
    return _sendMultipart(
      'PUT',
      '/tailor/portfolio',
      fields: {
        'captions': jsonEncode(captions),
        'categories': jsonEncode(categories),
      },
      files: images,
      fileField: 'images',
    );
  }

  static Future<ApiResult> getDesignerProfile(String designerId) {
    return _send('GET', '/discovery/public/designers/$designerId', auth: false);
  }

  static Future<ApiResult> createDesignerReview(Map<String, dynamic> body) {
    return _send('POST', '/reputation/designer-reviews', body: body);
  }

  static Future<ApiResult> getReviewableOrders() {
    return _send('GET', '/reputation/reviewable-orders');
  }

  static Future<ApiResult> createReviewForTarget(
    String reviewTargetId,
    Map<String, dynamic> body,
  ) {
    return _send(
      'POST',
      '/reputation/reviewable-orders/$reviewTargetId/review',
      body: body,
    );
  }

  static Future<ApiResult> respondToReview(String reviewId, String response) {
    return _send(
      'POST',
      '/reputation/designer-reviews/$reviewId/respond',
      body: {'response': response},
    );
  }

  static Future<ApiResult> getDesignerReviews(String designerId) {
    return _send(
      'GET',
      '/reputation/designers/$designerId/reviews',
      auth: false,
    );
  }

  static Future<ApiResult> recordEscrowPayment(
    String escrowId,
    Map<String, dynamic> body,
  ) {
    return _send(
      'POST',
      '/custom-orders/escrow/$escrowId/payments',
      body: body,
    );
  }

  static Future<ApiResult> payCustomRequest(
    String requestId,
    String milestoneName,
  ) {
    return _send(
      'POST',
      '/custom-orders/requests/$requestId/pay',
      body: {'milestoneName': milestoneName},
    );
  }

  static Future<ApiResult> getDesignerEscrowWallet() {
    return _send('GET', '/custom-orders/designer/escrow-wallet');
  }

  static Future<ApiResult> refundEscrow(
    String escrowId,
    Map<String, dynamic> body,
  ) {
    return _send('POST', '/custom-orders/escrow/$escrowId/refund', body: body);
  }

  static Future<ApiResult> releaseEscrow(
    String escrowId,
    Map<String, dynamic> body,
  ) {
    return _send('POST', '/custom-orders/escrow/$escrowId/release', body: body);
  }

  static Future<ApiResult> updateWorkflow(Map<String, dynamic> body) {
    return _send('PUT', '/custom-orders/workflow', body: body);
  }

  static Future<ApiResult> createMoodboard(Map<String, dynamic> body) {
    return _send('POST', '/moodboards', body: body);
  }

  static Future<ApiResult> addMoodboardItem(
    String moodboardId,
    Map<String, dynamic> body,
  ) {
    return _send('POST', '/moodboards/$moodboardId/items', body: body);
  }

  static Future<ApiResult> addMoodboardImage(
    String moodboardId, {
    required File image,
    required String note,
  }) {
    return _sendMultipart(
      'POST',
      '/moodboards/$moodboardId/items',
      fields: {'itemType': 'image', 'note': note},
      files: [image],
      fileField: 'images',
    );
  }

  static Future<ApiResult> getMoodboards() {
    return _send('GET', '/moodboards');
  }

  static Future<ApiResult> removeMoodboardItem(
    String moodboardId,
    String itemId,
  ) {
    return _send('DELETE', '/moodboards/$moodboardId/items/$itemId');
  }

  static Future<ApiResult> createDispute(Map<String, dynamic> body) {
    return _send('POST', '/disputes', body: body);
  }

  static Future<ApiResult> getSupportOrders() {
    return _send('GET', '/disputes/support-orders');
  }

  static Future<ApiResult> createSupportTicketForTarget(
    String supportTargetId,
    Map<String, dynamic> body,
  ) {
    return _send(
      'POST',
      '/disputes/support-orders/$supportTargetId',
      body: body,
    );
  }

  static Future<ApiResult> getMyDisputes() {
    return _send('GET', '/disputes/mine');
  }

  static Future<ApiResult> getAdminDisputes() {
    return _send('GET', '/disputes/admin');
  }

  static Future<ApiResult> updateAdminDispute(
    String disputeId,
    Map<String, dynamic> body,
  ) {
    return _send('PUT', '/disputes/admin/$disputeId', body: body);
  }

  static Future<ApiResult> getDesignerAnalytics() {
    return _send('GET', '/designer-tools/analytics');
  }

  static Future<ApiResult> featureListing(String listingId, bool isFeatured) {
    return _send(
      'PUT',
      '/designer-tools/listings/$listingId/feature',
      body: {'isFeatured': isFeatured},
    );
  }

  static Future<ApiResult> updateListingRichMedia(
    String listingId,
    Map<String, dynamic> body,
  ) {
    return _send(
      'PUT',
      '/seller/updateSellerListingMedia/$listingId',
      body: body,
    );
  }

  static Future<ApiResult> updateListingRichMediaFiles(
    String listingId, {
    required List<File> images,
    required List<String> mediaSlots,
  }) {
    return _sendMultipart(
      'PUT',
      '/seller/updateSellerListingMedia/$listingId',
      fields: {'mediaSlots': jsonEncode(mediaSlots)},
      files: images,
      fileField: 'images',
    );
  }

  static Future<ApiResult> createCustomRequest(Map<String, dynamic> body) {
    return _send('POST', '/custom-orders/requests', body: body);
  }

  static Future<ApiResult> createCustomRequestMultipart({
    required Map<String, String> fields,
    required List<File> images,
  }) {
    return _sendMultipart(
      'POST',
      '/custom-orders/requests',
      fields: fields,
      files: images,
      fileField: 'images',
    );
  }

  static Future<ApiResult> designerRequestResponse(
    String requestId,
    Map<String, dynamic> body,
  ) {
    return _send(
      'POST',
      '/custom-orders/requests/$requestId/designer-response',
      body: body,
    );
  }

  static Future<ApiResult> submitQuote(
    String requestId,
    Map<String, dynamic> body,
  ) {
    return _send(
      'POST',
      '/custom-orders/requests/$requestId/quote',
      body: body,
    );
  }

  static Future<ApiResult> createRevision(String requestId, String note) {
    return _send(
      'POST',
      '/custom-orders/requests/$requestId/revisions',
      body: {'note': note},
    );
  }

  static Future<ApiResult> acceptQuote(String requestId) {
    return _send('POST', '/custom-orders/requests/$requestId/accept');
  }

  static Future<ApiResult> convertRequest(
    String requestId,
    Map<String, dynamic> body,
  ) {
    return _send(
      'POST',
      '/custom-orders/requests/$requestId/convert',
      body: body,
    );
  }

  static Future<ApiResult> createConversation(Map<String, dynamic> body) {
    return _send('POST', '/messaging/conversations', body: body);
  }

  static Future<ApiResult> getEligibleMessageThreads() {
    return _send('GET', '/messaging/eligible-threads');
  }

  static Future<ApiResult> sendMessage(
    String conversationId,
    Map<String, dynamic> body,
  ) {
    return _send(
      'POST',
      '/messaging/conversations/$conversationId/messages',
      body: body,
    );
  }

  static Future<ApiResult> sendMessageFiles(
    String conversationId, {
    required String topic,
    required String content,
    required List<File> files,
  }) {
    return _sendMultipart(
      'POST',
      '/messaging/conversations/$conversationId/messages',
      fields: {'topic': topic, 'content': content},
      files: files,
      fileField: 'files',
    );
  }

  static Future<ApiResult> getConversations() {
    return _send('GET', '/messaging/conversations');
  }

  static Future<ApiResult> getMessages(String conversationId) {
    return _send('GET', '/messaging/conversations/$conversationId/messages');
  }

  static Future<ApiResult> getAdminFlaggedConversations() {
    return _send('GET', '/messaging/admin/flagged-conversations');
  }

  static Future<ApiResult> createSupportConversation(
    Map<String, dynamic> body,
  ) {
    return _send('POST', '/support/conversations', body: body);
  }

  static Future<ApiResult> getSupportConversations() {
    return _send('GET', '/support/conversations');
  }

  static Future<ApiResult> sendSupportMessage(
    String conversationId,
    Map<String, dynamic> body,
  ) {
    return _send(
      'POST',
      '/support/conversations/$conversationId/messages',
      body: body,
    );
  }

  static Future<ApiResult> sendSupportMessageFiles(
    String conversationId, {
    required String content,
    required List<File> files,
  }) {
    return _sendMultipart(
      'POST',
      '/support/conversations/$conversationId/messages',
      fields: {'content': content},
      files: files,
      fileField: 'files',
    );
  }

  static Future<ApiResult> getSupportMessages(String conversationId) {
    return _send('GET', '/support/conversations/$conversationId/messages');
  }
}

List<Map<String, dynamic>> apiList(dynamic data) {
  if (data is List) {
    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  if (data is Map<String, dynamic>) {
    for (final key in [
      'data',
      'items',
      'listings',
      'designers',
      'profiles',
      'requests',
      'moodboards',
      'reviews',
      'disputes',
      'conversations',
      'messages',
      'threads',
    ]) {
      final value = data[key];
      if (value is List) {
        return value
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
  }
  return const [];
}

Map<String, dynamic> apiMap(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data;
  }
  return const {};
}
