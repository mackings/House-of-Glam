import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Banks/Api/ExchangeService.dart';
import 'package:hog/constants/currency.dart';
import 'package:intl/intl.dart';

class CurrencyHelper {
  // Cache to avoid repeated API calls
  static final Map<String, double> _rateCache = {};
  static DateTime? _lastFetch;

  /// Get user's country from secure preferences
  static Future<String?> getUserCountry() async {
    try {
      final userData = await SecurePrefs.getUserData();
      final country = userData?['country'] as String?;

      print("🌍 User country from prefs: $country");
      return country;
    } catch (e) {
      print("❌ Error getting user country: $e");
      return null;
    }
  }

  /// Get current exchange rate (with 5-minute cache)
  static Future<double> getExchangeRate() async {
    if (Cur == 'NGN') return 1.0; // No conversion needed

    final now = DateTime.now();
    final cacheKey = Cur;

    // Return cached rate if less than 5 minutes old
    if (_lastFetch != null &&
        now.difference(_lastFetch!).inMinutes < 5 &&
        _rateCache.containsKey(cacheKey)) {
      return _rateCache[cacheKey]!;
    }

    // Fetch new rate
    final rate = await ConversionApiService.getExchangeRateOnly(
      targetCurrency: Cur,
    );

    if (rate != null) {
      _rateCache[cacheKey] = rate;
      _lastFetch = now;
      return rate;
    }

    return 1.0; // Fallback to no conversion
  }

  /// Convert NGN amount to user's currency
  static Future<double> convertFromNGN(int amountInNGN) async {
    if (Cur == 'NGN') return amountInNGN.toDouble();

    final rate = await getExchangeRate();
    return amountInNGN * rate;
  }

  /// Convert USD amount to user's currency (NGN for Nigerian users)
  static Future<double> convertFromUSD(double amountInUSD) async {
    // If user's currency is USD, no conversion needed
    if (Cur == 'USD') return amountInUSD;

    try {
      // Get NGN to USD rate from API
      final result = await ConversionApiService.getExchangeRate(
        amount: 1, // Get rate for 1 NGN
        targetCurrency: 'USD',
      );

      if (result['success'] == true) {
        final ngnToUsdRate = result['exchangeRate'] as double;

        if (ngnToUsdRate > 0) {
          // Reverse the rate: if 1 NGN = 0.00067 USD, then 1 USD = 1/0.00067 NGN
          final usdToNgnRate = 1 / ngnToUsdRate;

          // If user currency is NGN, convert USD to NGN
          if (Cur == 'NGN') {
            return amountInUSD * usdToNgnRate;
          } else {
            // For other currencies, first convert USD to NGN, then to user currency
            final amountInNGN = amountInUSD * usdToNgnRate;
            return convertFromNGN(amountInNGN.round());
          }
        }
      }

      // Fallback: use approximate rate (1 USD ≈ 1500 NGN)
      if (Cur == 'NGN') {
        return amountInUSD * 1500;
      }
      return amountInUSD;
    } catch (e) {
      // Fallback: use approximate rate
      if (Cur == 'NGN') {
        return amountInUSD * 1500;
      }
      return amountInUSD;
    }
  }

  /// Convert user's currency back to NGN (for API calls)
  static Future<int> convertToNGN(double amountInUserCurrency) async {
    if (Cur == 'NGN') return amountInUserCurrency.round();

    final rate = await getExchangeRate();
    if (rate == 0) return 0;

    return (amountInUserCurrency / rate).round();
  }

  /// Format amount with currency symbol
  static String formatAmount(double amount, {String? currencyCode}) {
    // Round to 2 decimal places, but remove trailing zeros
    final rounded = (amount * 100).round() / 100;

    // If the rounded amount is a whole number, don't show decimals
    final formatter =
        rounded == rounded.roundToDouble()
            ? NumberFormat('#,###')
            : NumberFormat('#,###.##');

    // Use provided currency code or default to user's currency
    final symbol =
        currencyCode != null
            ? _getCurrencySymbol(currencyCode)
            : currencySymbol;

    return '$symbol${formatter.format(rounded)}';
  }

  /// Get currency symbol from currency code
  static String _getCurrencySymbol(String code) {
    switch (code.toUpperCase()) {
      case 'NGN':
        return '₦';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'EUR':
        return '€';
      case 'INR':
        return '₹';
      case 'JPY':
      case 'CNY':
        return '¥';
      case 'ZAR':
        return 'R';
      case 'GHS':
        return 'GH₵';
      case 'KES':
        return 'KSh';
      case 'AUD':
        return 'A\$';
      case 'CAD':
        return 'C\$';
      default:
        return '$code ';
    }
  }
}
