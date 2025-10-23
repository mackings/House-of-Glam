import 'dart:convert';
import 'dart:io';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/UserProfile/model/profileViewModel.dart';
import 'package:http/http.dart' as http;

class UserProfileViewService {
  static const String baseUrl = "https://hog-ymud.onrender.com/api/v1";

  static Future<UserProfile?> getProfile() async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/user/getProfile");

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
        final jsonData = jsonDecode(response.body);
        return UserProfile.fromJson(jsonData["user"]);
      }
    } catch (e) {
      print("❌ Error fetching user profile: $e");
    }

    return null;
  }

  static Future<bool> uploadProfileImage(File imageFile) async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/user/uploadImage");

      final request =
          http.MultipartRequest("PUT", url)
            ..headers["Authorization"] = "Bearer $token"
            ..files.add(
              await http.MultipartFile.fromPath("images", imageFile.path),
            );

      final response = await request.send();

      final responseBody = await response.stream.bytesToString();
      print("➡️ PUT Request: $url");
      print("⬅️ Response: $responseBody");

      if (response.statusCode == 200) {
        return true;
      } else {
        print("❌ Upload failed: ${response.reasonPhrase}");
        return false;
      }
    } catch (e) {
      print("❌ Error uploading image: $e");
      return false;
    }
  }
}
