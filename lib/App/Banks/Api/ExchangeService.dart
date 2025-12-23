import 'package:hog/App/Auth/Api/secure.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConversionApiService {
  static const String baseUrl = "https://hog-ymud.onrender.com";

  /// 📝 Custom Logger
  static void _log(String message, {String level = 'INFO'}) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] [$level] $message';
    print(logMessage);
  }

  /// 📤 Log Request Details
  static void _logRequest({
    required String method,
    required String endpoint,
    Map<String, String>? headers,
  }) {
    _log('═══════════════════════════════════════════════════════');
    _log('🚀 REQUEST: $method $endpoint');
    if (headers != null) {
      _log('📋 Headers:', level: 'DEBUG');
      headers.forEach((key, value) {
        if (key.toLowerCase() == 'authorization') {
          _log('   $key: ${value.substring(0, 20)}...***', level: 'DEBUG');
        } else {
          _log('   $key: $value', level: 'DEBUG');
        }
      });
    }
  }

  /// 📥 Log Response Details
  static void _logResponse({
    required int statusCode,
    required String body,
    required String endpoint,
  }) {
    _log('📥 RESPONSE: $endpoint');
    _log('📊 Status Code: $statusCode', level: statusCode >= 200 && statusCode < 300 ? 'SUCCESS' : 'ERROR');
    
    try {
      final jsonBody = jsonDecode(body);
      _log('📄 Response Body:', level: 'DEBUG');
      _log('   ${JsonEncoder.withIndent('  ').convert(jsonBody)}', level: 'DEBUG');
    } catch (e) {
      _log('📄 Response Body (Raw):', level: 'DEBUG');
      _log('   $body', level: 'DEBUG');
    }
    _log('═══════════════════════════════════════════════════════');
  }

  /// 💱 Get Exchange Rate from NGN to Target Currency
  static Future<Map<String, dynamic>> getExchangeRate({
    required double amount,
    required String targetCurrency,
  }) async {
    final endpoint = "$baseUrl/api/v1/conversion/naira-exchange-rate?amount=$amount&currency=$targetCurrency";
    
    try {
      final token = await SecurePrefs.getToken();
      if (token == null) {
        _log('❌ No authentication token found', level: 'ERROR');
        return {"success": false, "error": "No authentication token found"};
      }

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      _logRequest(
        method: 'GET',
        endpoint: endpoint,
        headers: headers,
      );

      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      );

      _logResponse(
        statusCode: response.statusCode,
        body: response.body,
        endpoint: endpoint,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _log('✅ Exchange rate fetched: ${data['baseCurrency']} → ${data['targetCurrency']} = ${data['exchangeRate']}', level: 'SUCCESS');
        return {
          "success": true,
          "message": data['message'],
          "baseCurrency": data['baseCurrency'],
          "targetCurrency": data['targetCurrency'],
          "exchangeRate": data['exchangeRate'],
          "originalAmount": data['originalAmount'],
          "convertedAmount": data['convertedAmount'],
        };
      } else {
        final error = jsonDecode(response.body);
        _log('❌ Failed to fetch exchange rate: ${error['message']}', level: 'ERROR');
        return {
          "success": false,
          "error": error['message'] ?? "Failed to fetch exchange rate",
        };
      }
    } catch (e, stackTrace) {
      _log('❌ Exception fetching exchange rate: $e', level: 'ERROR');
      _log('Stack trace: $stackTrace', level: 'DEBUG');
      return {"success": false, "error": "Network error: $e"};
    }
  }

  /// 💱 Convert Amount with Cached Rate (Helper method)
  static Future<double?> convertAmount({
    required double amountInNGN,
    required String targetCurrency,
  }) async {
    final result = await getExchangeRate(
      amount: amountInNGN,
      targetCurrency: targetCurrency,
    );

    if (result['success'] == true) {
      return result['convertedAmount'];
    }
    
    _log('❌ Conversion failed, returning null', level: 'ERROR');
    return null;
  }

  /// 💱 Get Exchange Rate Only (without conversion)
  static Future<double?> getExchangeRateOnly({
    required String targetCurrency,
  }) async {
    final result = await getExchangeRate(
      amount: 1, // Use 1 to get the base rate
      targetCurrency: targetCurrency,
    );

    if (result['success'] == true) {
      return result['exchangeRate'];
    }
    
    _log('❌ Failed to get exchange rate', level: 'ERROR');
    return null;
  }
}