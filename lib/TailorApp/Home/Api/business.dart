import 'dart:io';

import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/TailorApp/Home/Api/TailorHomeservice.dart';
import 'package:hog/utils/error_handler.dart';
import 'package:http/http.dart' as http;

extension TailorServiceExtension on TailorHomeService {
  Future<void> createTailor({
    required String address,
    required String businessName,
    required String businessEmail,
    required String businessPhone,
    required String city,
    required String state,
    required String yearOfExperience,
    required String description,
    File? imageFile,
    String? businessRegNo,
  }) async {
    try {
      final token = await SecurePrefs.getToken();

      var uri = Uri.parse("$baseUrl/tailor/createTailor");
      var request = http.MultipartRequest("POST", uri);

      request.headers["Authorization"] = "Bearer $token";

      request.fields["address"] = address;
      request.fields["businessName"] = businessName;
      request.fields["businessEmail"] = businessEmail;
      request.fields["businessPhone"] = businessPhone;
      request.fields["city"] = city;
      request.fields["state"] = state;
      request.fields["yearOfExperience"] = yearOfExperience;
      request.fields["description"] = description;

      // Only add business registration number if provided
      if (businessRegNo != null && businessRegNo.isNotEmpty) {
        request.fields["businessRegistrationNumber"] = businessRegNo;
      }

      request.fields["registeredIn"] = city;

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath("images", imageFile.path),
        );
      }

      var response = await request.send();

      final resBody = await response.stream.bytesToString();
      print("⬅️ Response [${response.statusCode}]: $resBody");

      if (response.statusCode != 201) {
        final errorMessage = ErrorHandler.parseApiError(
          resBody,
          response.statusCode,
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      final friendlyMessage = ErrorHandler.getUserFriendlyMessage(e);
      throw Exception(friendlyMessage);
    }
  }
}
