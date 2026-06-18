import 'dart:convert';

import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/constants/api_config.dart';
import 'package:http/http.dart' as http;

class AdminInvitationResult {
  final bool success;
  final String message;
  final Map<String, dynamic> data;

  const AdminInvitationResult({
    required this.success,
    required this.message,
    this.data = const {},
  });
}

class AdminInvitationService {
  static Future<AdminInvitationResult> sendInvitation({
    required String fullName,
    required String email,
    required String role,
    String? phoneNumber,
    String? country,
    String? address,
    List<String> responsibilities = const [],
  }) async {
    final token = await SecurePrefs.getToken();
    if (token == null || token.isEmpty) {
      return const AdminInvitationResult(
        success: false,
        message: 'No authentication token found.',
      );
    }

    final body = <String, dynamic>{
      'fullName': fullName.trim(),
      'email': email.trim(),
      'role': role,
      if ((phoneNumber ?? '').trim().isNotEmpty)
        'phoneNumber': phoneNumber!.trim(),
      if ((country ?? '').trim().isNotEmpty) 'country': country!.trim(),
      if ((address ?? '').trim().isNotEmpty) 'address': address!.trim(),
      if (responsibilities.isNotEmpty) 'responsibilities': responsibilities,
    };

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.apiBaseUrl}/admin/invitations'),
        headers: ApiConfig.getAuthHeaders(token),
        body: jsonEncode(body),
      );
      final decoded =
          response.body.isEmpty
              ? const <String, dynamic>{}
              : Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      final success = response.statusCode >= 200 && response.statusCode < 300;
      return AdminInvitationResult(
        success: success && decoded['success'] != false,
        message:
            decoded['message']?.toString() ??
            (success ? 'Invitation sent successfully.' : 'Invitation failed.'),
        data:
            decoded['data'] is Map
                ? Map<String, dynamic>.from(decoded['data'] as Map)
                : const {},
      );
    } catch (_) {
      return const AdminInvitationResult(
        success: false,
        message: 'Unable to send the invitation. Please try again.',
      );
    }
  }
}
