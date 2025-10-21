import 'dart:convert';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:http/http.dart' as http;



class OfferService {
  static const String _apiRoot = "https://hog-ymud.onrender.com/api/v1";

  // 🔹 Helper method for logging API calls
  static void _logApi({
    required String method,
    required Uri url,
    Map<String, String>? headers,
    dynamic body,
    required http.Response response,
    required Duration duration,
  }) {
    print("""
==================== 🌐 API CALL LOG ====================
🧭 METHOD: $method
📡 URL: $url
🕒 TIME: ${duration.inMilliseconds} ms
📋 HEADERS: ${jsonEncode(headers)}
📦 BODY: ${body is String ? body : jsonEncode(body)}
---------------------------------------------------------
✅ STATUS: ${response.statusCode}
📨 RESPONSE: ${response.body}
=========================================================
""");
  }

  // 🔹 GET all offers
  static Future<List<dynamic>> getAllOffers() async {
    final token = await SecurePrefs.getToken();
    final url = Uri.parse("$_apiRoot/makeOffer/getAllMakeOffers");

    final headers = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    final start = DateTime.now();
    final response = await http.get(url, headers: headers);
    final duration = DateTime.now().difference(start);

    _logApi(
      method: "GET",
      url: url,
      headers: headers,
      body: null,
      response: response,
      duration: duration,
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData["data"] ?? [];
    } else {
      return [];
    }
  }

  // 🔹 POST: Buyer creates a new offer
  static Future<Map<String, dynamic>> makeOffer({
    required String reviewId,
    required String comment,
    required String materialTotalCost,
    required String workmanshipTotalCost,
  }) async {
    final token = await SecurePrefs.getToken();
    final url = Uri.parse("$_apiRoot/makeOffer/createMakeOffer/$reviewId");

    final headers = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    final body = {
      "comment": comment,
      "materialTotalCost": materialTotalCost,
      "workmanshipTotalCost": workmanshipTotalCost,
    };

    final start = DateTime.now();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
    final duration = DateTime.now().difference(start);

    _logApi(
      method: "POST",
      url: url,
      headers: headers,
      body: body,
      response: response,
      duration: duration,
    );

    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      print("OfferService.makeOffer parse error: $e");
      return {"success": false, "message": "Invalid response"};
    }
  }

  // 🔹 POST: Vendor replies to an offer
  static Future<Map<String, dynamic>> vendorReplyOffer({
    required String offerId,
    required String comment,
    required String counterMaterialCost,
    required String counterWorkmanshipCost,
    required String action, // countered, accepted, rejected
  }) async {
    final token = await SecurePrefs.getToken();
    final url = Uri.parse("$_apiRoot/makeOffer/vendorReplyOffer/$offerId");

    final headers = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    final body = {
      "comment": comment,
      "counterMaterialCost": counterMaterialCost,
      "counterWorkmanshipCost": counterWorkmanshipCost,
      "action": action,
    };

    final start = DateTime.now();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
    final duration = DateTime.now().difference(start);

    _logApi(
      method: "POST",
      url: url,
      headers: headers,
      body: body,
      response: response,
      duration: duration,
    );

    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      print("OfferService.vendorReplyOffer parse error: $e");
      return {"success": false, "message": "Invalid response"};
    }
  }

  // 🔹 POST: Buyer replies to vendor's counter offer
  static Future<Map<String, dynamic>> buyerReplyOffer({
    required String offerId,
    required String comment,
    required String counterMaterialCost,
    required String counterWorkmanshipCost,
    required String action, // countered, accepted, rejected
  }) async {
    final token = await SecurePrefs.getToken();
    final url = Uri.parse("$_apiRoot/makeOffer/buyerReplyToOffer/$offerId");

    final headers = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    final body = {
      "comment": comment,
      "counterMaterialCost": counterMaterialCost,
      "counterWorkmanshipCost": counterWorkmanshipCost,
      "action": action,
    };

    final start = DateTime.now();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
    final duration = DateTime.now().difference(start);

    _logApi(
      method: "POST",
      url: url,
      headers: headers,
      body: body,
      response: response,
      duration: duration,
    );

    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      print("OfferService.buyerReplyOffer parse error: $e");
      return {"success": false, "message": "Invalid response"};
    }
  }
}
