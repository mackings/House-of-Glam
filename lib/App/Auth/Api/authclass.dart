import 'dart:convert';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:http/http.dart' as http;

class ApiService {
  
  static const String baseUrl = "https://hog-ymud.onrender.com/api/v1";

  /// Generic POST request with body
  static Future<Map<String, dynamic>> postRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse("$baseUrl/$endpoint");

    print("➡️ POST Request to: $url");
    print("📦 Payload: ${jsonEncode(body)}");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    print("⬅️ Response [${response.statusCode}]: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {"success": true, "data": jsonDecode(response.body)};
    } else {
      return {
        "success": false,
        "error":
            jsonDecode(response.body)["message"] ??
            "Something went wrong (${response.statusCode})",
      };
    }
  }





/// 🔹 Login
static Future<Map<String, dynamic>> login({
  required String email,
  required String password,
}) async {
  final result = await postRequest("user/login", {
    "email": email,
    "password": password,
  });

  if (result["success"] == true && result["data"] != null) {
    final data = result["data"];
    final token = data["token"];
    final user = data["user"];

    if (token != null && user != null) {
      // ✅ Save token
      await SecurePrefs.saveToken(token);

      // ✅ Save user details
      await SecurePrefs.saveUserData({
        "id": user["_id"],
        "fullName": user["fullName"],
        "email": user["email"],
        "phoneNumber": user["phoneNumber"],
        "role": user["role"],
        "image": user["image"],
        "address": user["address"],
        "subscriptionPlan": user["subscriptionPlan"],
        "billTerm": user["billTerm"],
        "subscriptionStartDate": user["subscriptionStartDate"],
        "subscriptionEndDate": user["subscriptionEndDate"],
        "isVendorEnabled": user["isVendorEnabled"],
        "wallet": user["wallet"],
        "isVerified": user["isVerified"],
        "isBlocked": user["isBlocked"],
      });

      // ✅ Flatten response before returning
      return {
        "success": true,
        "message": data["message"],
        "token": token,
        "user": user,
      };
    }
  }

  // fallback (error)
  return {
    "success": false,
    "error": result["error"] ?? "Login failed",
  };
}



  /// 🔹 Sign up
  static Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required String role,
    required String address,
  }) async {
    return await postRequest("user/register", {
      "fullName": fullName,
      "email": email,
      "password": password,
      "phoneNumber": phoneNumber,
      "role": role,
      "address": address,
    });
  }

  /// 🔹 Verify account with token (no body required)
  static Future<Map<String, dynamic>> verifyEmail({
    required String token,
  }) async {
    final url = Uri.parse("$baseUrl/user/verifyToken?token=$token");

    print("➡️ POST Request to: $url");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
    );

    print("⬅️ Response [${response.statusCode}]: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {"success": true, "data": jsonDecode(response.body)};
    } else {
      return {
        "success": false,
        "error":
            jsonDecode(response.body)["message"] ??
            "Something went wrong (${response.statusCode})",
      };
    }
  }

  /// 🔹 Forgot Password
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    return await postRequest("user/forgotPassword", {"email": email});
  }

  /// 🔹 Reset Password
  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String password,
  }) async {
    return await postRequest("user/resetPassword", {
      "token": token,
      "password": password,
    });
  }
}
