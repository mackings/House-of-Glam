import 'dart:convert';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Home/Model/category.dart';
import 'package:hog/App/Home/Model/tailor.dart';
import 'package:hog/App/Home/Model/vendor.dart';
import 'package:http/http.dart' as http;



class HomeApiService {


  static const String baseUrl = "https://hog-ymud.onrender.com/api/v1";

  static Future<List<Tailor>> getAllTailors() async {
    try {
      final token = await SecurePrefs.getToken(); // retrieve token
      final url = Uri.parse("$baseUrl/user/getAllTailor");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // pass token
        },
      );

      print("➡️ GET Request: $url");
      print("⬅️ Response: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> tailorsJson = jsonDecode(response.body)["data"] ?? [];
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

    if (response.statusCode == 200) {
      final List<dynamic> categoriesJson = jsonDecode(response.body)["data"] ?? [];
      final categories = categoriesJson.map((c) => Category.fromJson(c)).toList();

      // Save to prefs ✅
      await SecurePrefs.saveCategories(categories);

      return categories;
    }
  } catch (e) {
    print("❌ Error fetching categories: $e");
  }

  return [];
}



  static Future<VendorDetailsResponse?> getVendorDetails(String vendorId) async {
    try {
      final token = await SecurePrefs.getToken(); // retrieve token
      final url = Uri.parse("$baseUrl/material/getVendorDetails?vendorId=$vendorId");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // pass token
        },
      );

      print("➡️ GET Request: $url");
      print("⬅️ Response: ${response.body}");

      if (response.statusCode == 200) {
        return VendorDetailsResponse.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("❌ Error fetching vendor details: $e");
    }

    return null;
  }

}

