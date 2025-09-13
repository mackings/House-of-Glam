import 'dart:convert';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Home/Model/TransModel.dart';
import 'package:http/http.dart' as http;

class TransactionService {
  static const String baseUrl = "https://hog-ymud.onrender.com/api/v1";

  static Future<TransactionListResponse?> getTransactions() async {
    try {
      final token = await SecurePrefs.getToken();
      final url = Uri.parse("$baseUrl/transaction/transactions");

      final response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      });

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TransactionListResponse.fromJson(jsonData);
      } else {
        print("❌ Failed to fetch transactions: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching transactions: $e");
    }
    return null;
  }
}

