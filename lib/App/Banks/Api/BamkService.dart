
import 'dart:math' as developer;

import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Banks/Model/bankModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';




class BankApiService {
  static const String baseUrl = "https://hog-ymud.onrender.com";

  /// 📝 Custom Logger
  static void _log(String message, {String level = 'INFO'}) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] [$level] $message';
   // developer.log(logMessage as num, name: 'BankApiService');
    print(logMessage);
  }

  /// 📤 Log Request Details
  static void _logRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) {
    _log('═══════════════════════════════════════════════════════');
    _log('🚀 REQUEST: $method $endpoint');
    if (headers != null) {
      _log('📋 Headers:', level: 'DEBUG');
      headers.forEach((key, value) {
        // Mask sensitive headers
        if (key.toLowerCase() == 'authorization') {
          _log('   $key: ${value.substring(0, 20)}...***', level: 'DEBUG');
        } else {
          _log('   $key: $value', level: 'DEBUG');
        }
      });
    }
    if (body != null) {
      _log('📦 Body:', level: 'DEBUG');
      _log('   ${JsonEncoder.withIndent('  ').convert(body)}', level: 'DEBUG');
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




/// 🌍 Create Stripe Connected Account
static Future<Map<String, dynamic>> createStripeAccount() async {
  final endpoint = "$baseUrl/api/v1/stripe/create-account";
  
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
      method: 'POST',
      endpoint: endpoint,
      headers: headers,
    );

    final response = await http.post(
      Uri.parse(endpoint),
      headers: headers,
    );

    _logResponse(
      statusCode: response.statusCode,
      body: response.body,
      endpoint: endpoint,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      _log('✅ Stripe account creation initiated', level: 'SUCCESS');
      return {
        "success": true,
        "stripeAccountId": data['data']['stripeAccountId'],
        "onboardingUrl": data['data']['onboardingUrl'],
        "data": data,
      };
    } else {
      final error = jsonDecode(response.body);
      _log('❌ Failed to create Stripe account: ${error['message']}', level: 'ERROR');
      return {
        "success": false,
        "error": error['message'] ?? "Failed to create Stripe account",
      };
    }
  } catch (e, stackTrace) {
    _log('❌ Exception creating Stripe account: $e', level: 'ERROR');
    _log('Stack trace: $stackTrace', level: 'DEBUG');
    return {"success": false, "error": "Network error: $e"};
  }
}

/// 💸 Stripe Transfer to Connected Account
static Future<Map<String, dynamic>> stripeTransfer({
  required String bankId,
  required double amount,
}) async {
  final endpoint = "$baseUrl/api/v1/stripe/make-stripe-transfer";
  
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

    final body = {
      "amount": amount,
      "bankId": bankId, // Optional: if backend needs it
    };

    _logRequest(
      method: 'POST',
      endpoint: endpoint,
      headers: headers,
      body: body,
    );

    final response = await http.post(
      Uri.parse(endpoint),
      headers: headers,
      body: jsonEncode(body),
    );

    _logResponse(
      statusCode: response.statusCode,
      body: response.body,
      endpoint: endpoint,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      _log('✅ Stripe transfer successful. Amount: \$${amount}', level: 'SUCCESS');
      return {
        "success": true,
        "message": "Transfer successful",
        "data": data,
      };
    } else {
      final error = jsonDecode(response.body);
      _log('❌ Stripe transfer failed: ${error['message']}', level: 'ERROR');
      return {
        "success": false,
        "error": error['message'] ?? "Transfer failed",
      };
    }
  } catch (e, stackTrace) {
    _log('❌ Exception during Stripe transfer: $e', level: 'ERROR');
    _log('Stack trace: $stackTrace', level: 'DEBUG');
    return {"success": false, "error": "Network error: $e"};
  }
}

/// ✅ Check Stripe Account Status
static Future<Map<String, dynamic>> getStripeAccountStatus() async {
  final endpoint = "$baseUrl/api/v1/stripe/account-status";
  
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
      return {
        "success": true,
        "data": data,
      };
    } else {
      final error = jsonDecode(response.body);
      return {
        "success": false,
        "error": error['message'] ?? "Failed to get status",
      };
    }
  } catch (e, stackTrace) {
    _log('❌ Exception getting Stripe status: $e', level: 'ERROR');
    return {"success": false, "error": "Network error: $e"};
  }
}














  /// 🏦 Create Bank Account
  static Future<Map<String, dynamic>> createBankAccount({
    required String bankName,
    required String accountNumber,
    required String accountName,
    required String bankCode,
  }) async {
    final endpoint = "$baseUrl/api/v1/bank/create";
    
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

      final body = {
        "bankName": bankName,
        "accountNumber": accountNumber,
        "accountName": accountName,
        "bankCode": bankCode,
      };

      _logRequest(
        method: 'POST',
        endpoint: endpoint,
        headers: headers,
        body: body,
      );

      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(body),
      );

      _logResponse(
        statusCode: response.statusCode,
        body: response.body,
        endpoint: endpoint,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _log('✅ Bank account created successfully', level: 'SUCCESS');
        return {
          "success": true,
          "message": "Bank account added successfully",
          "data": data,
        };
      } else {
        final error = jsonDecode(response.body);
        _log('❌ Failed to create bank account: ${error['message']}', level: 'ERROR');
        return {
          "success": false,
          "error": error['message'] ?? "Failed to add bank account",
        };
      }
    } catch (e, stackTrace) {
      _log('❌ Exception creating bank account: $e', level: 'ERROR');
      _log('Stack trace: $stackTrace', level: 'DEBUG');
      return {"success": false, "error": "Network error: $e"};
    }
  }



  /// 🏦 Get All Banks (Stripe + Local)
  static Future<List<Bank>> getAllBanks() async {
    final endpoint = "$baseUrl/api/v1/bank/account";

    try {
      final token = await SecurePrefs.getToken();
      if (token == null) {
        _log('❌ No authentication token found', level: 'ERROR');
        return [];
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
        final jsonData = jsonDecode(response.body);

        // Ensure data exists and is a Map
        if (jsonData['data'] == null) {
          _log('❌ No data found in response', level: 'ERROR');
          return [];
        }

        final data = jsonData['data'] as Map<String, dynamic>;
        List<Bank> allBanks = [];

        // ✅ Parse Stripe bank accounts
        if (data['stripeBankAccounts'] != null && data['stripeBankAccounts'] is List) {
          final List<dynamic> stripeAccounts = data['stripeBankAccounts'] as List<dynamic>;
          final stripeBanks = stripeAccounts
              .map((json) => Bank.fromStripeJson(json as Map<String, dynamic>))
              .toList();
          allBanks.addAll(stripeBanks);
          _log('✅ Fetched ${stripeBanks.length} Stripe account(s)', level: 'SUCCESS');
        }

        // ✅ Parse Local bank accounts
        if (data['localBankAccounts'] != null && data['localBankAccounts'] is List) {
          final List<dynamic> localAccounts = data['localBankAccounts'] as List<dynamic>;
          final localBanks = localAccounts
              .map((json) => Bank.fromLocalJson(json as Map<String, dynamic>))
              .toList();
          allBanks.addAll(localBanks);
          _log('✅ Fetched ${localBanks.length} local bank account(s)', level: 'SUCCESS');
        }

        _log('✅ Total banks fetched: ${allBanks.length}', level: 'SUCCESS');
        return allBanks;
      } else {
        _log('❌ Failed to fetch banks. Status: ${response.statusCode}', level: 'ERROR');
        return [];
      }
    } catch (e, stackTrace) {
      _log('❌ Exception fetching banks: $e', level: 'ERROR');
      _log('Stack trace: $stackTrace', level: 'DEBUG');
      return [];
    }
  }



  /// 💸 Bank Transfer
  static Future<Map<String, dynamic>> bankTransfer({
    required String bankId,
    required double amount,
    String? pin,
  }) async {
    final endpoint = "$baseUrl/api/v1/bank/transfer/$bankId";
    
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

      final body = {
        "amount": amount,
        if (pin != null) "pin": "***", // Mask PIN in logs
      };

      _logRequest(
        method: 'POST',
        endpoint: endpoint,
        headers: headers,
        body: body,
      );

      final actualBody = {
        "amount": amount,
        if (pin != null) "pin": pin,
      };

      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(actualBody),
      );

      _logResponse(
        statusCode: response.statusCode,
        body: response.body,
        endpoint: endpoint,
      );


      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _log('✅ Bank transfer successful. Amount: ₦$amount', level: 'SUCCESS');
        return {
          "success": true,
          "message": "Transfer successful",
          "data": data,
        };
      } else {
        final error = jsonDecode(response.body);
        _log('❌ Bank transfer failed: ${error['message']}', level: 'ERROR');
        return {
          "success": false,
          "error": error['message'] ?? "Transfer failed",
        };
      }
    } catch (e, stackTrace) {
      _log('❌ Exception during bank transfer: $e', level: 'ERROR');
      _log('Stack trace: $stackTrace', level: 'DEBUG');
      return {"success": false, "error": "Network error: $e"};
    }
  }

  /// ✅ Verify Account Details
  static Future<Map<String, dynamic>> verifyAccountDetails({
    required String accountNumber,
    required String bankCode,
  }) async {
    final endpoint = "$baseUrl/api/v1/bank/verify?accountNumber=$accountNumber&bankCode=$bankCode";

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

      final response = await http.post(
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
        _log('✅ Account verified successfully', level: 'SUCCESS');

        // Return the data directly since it already has the correct structure
        return data;  // ✅ CHANGED: Don't wrap it again

      } else {
        final error = jsonDecode(response.body);
        _log('❌ Account verification failed: ${error['message']}', level: 'ERROR');
        return {
          "success": false,
          "error": error['message'] ?? "Verification failed",
        };
      }
    } catch (e, stackTrace) {
      _log('❌ Exception verifying account: $e', level: 'ERROR');
      _log('Stack trace: $stackTrace', level: 'DEBUG');
      return {"success": false, "error": "Network error: $e"};
    }
  }

  /// 💳 Stripe Checkout Payment for Review/Quotation
  static Future<Map<String, dynamic>> stripeCheckoutPayment({
    required String reviewId,
    required String shipmentMethod,
    String? amount, // For part payment
    String? address, // For full payment
  }) async {
    final endpoint = "$baseUrl/api/v1/stripe/make-payment/$reviewId";

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

      // Build request body
      final body = {
        "shipmentMethod": shipmentMethod,
        if (amount != null) "amount": amount,
        if (address != null) "address": address,
      };

      _logRequest(
        method: 'POST',
        endpoint: endpoint,
        headers: headers,
        body: body,
      );

      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(body),
      );

      _logResponse(
        statusCode: response.statusCode,
        body: response.body,
        endpoint: endpoint,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _log('✅ Stripe checkout created successfully', level: 'SUCCESS');
        return {
          "success": true,
          "message": data['message'],
          "checkoutUrl": data['data']['checkoutUrl'],
          "order": data['data']['order'],
          "data": data['data'],
        };
      } else {
        final error = jsonDecode(response.body);
        _log('❌ Stripe checkout failed: ${error['message']}', level: 'ERROR');
        return {
          "success": false,
          "error": error['message'] ?? "Checkout creation failed",
        };
      }
    } catch (e, stackTrace) {
      _log('❌ Exception creating Stripe checkout: $e', level: 'ERROR');
      _log('Stack trace: $stackTrace', level: 'DEBUG');
      return {"success": false, "error": "Network error: $e"};
    }
  }

  /// 💰 Get User Wallet Balance
  static Future<Map<String, dynamic>> getUserWalletBalance() async {
    final endpoint = "$baseUrl/api/v1/user/getUserWalletBalance";

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
        // ✅ Fix: Extract from data.wallet instead of balance
        final balance = (data['data']?['wallet'] ?? 0).toDouble();
        _log('✅ Wallet balance fetched: ₦$balance', level: 'SUCCESS');
        return {
          "success": true,
          "balance": balance,
          "data": data,
        };
      } else {
        final error = jsonDecode(response.body);
        _log('❌ Failed to fetch wallet balance: ${error['message']}', level: 'ERROR');
        return {
          "success": false,
          "error": error['message'] ?? "Failed to fetch balance",
        };
      }
    } catch (e, stackTrace) {
      _log('❌ Exception fetching wallet balance: $e', level: 'ERROR');
      _log('Stack trace: $stackTrace', level: 'DEBUG');
      return {"success": false, "error": "Network error: $e"};
    }
  }
}