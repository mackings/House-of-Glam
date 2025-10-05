import 'dart:convert';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:http/http.dart' as http;

class BidPaymentService {
  static const String baseUrl = "https://hog-ymud.onrender.com/api/v1";

  static Future<Map<String, dynamic>?> purchaseListings({
    required List<String> listingIds,
    String? address,
    required String shipmentMethod,
  }) async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/buyer/purchaseMultipleListings");

      final body = {
        "listingIds": listingIds,
        if (address != null && address.isNotEmpty) "address": address,
        "shipmentMethod": shipmentMethod,
      };

      print("➡️ POST to $url with body: $body");

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      print("⬅️ Response [${response.statusCode}]: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception("❌ Purchase failed: ${response.body}");
      }
    } catch (e) {
      print("⚠️ Error during purchase: $e");
      return null;
    }
  }
}
