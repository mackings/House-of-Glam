import 'package:hog/App/Banks/Api/ExchangeService.dart';
import 'package:hog/constants/currency.dart';
import 'package:intl/intl.dart';

class CurrencyHelper {
  // Cache to avoid repeated API calls
  static final Map<String, double> _rateCache = {};
  static DateTime? _lastFetch;

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

  /// Convert user's currency back to NGN (for API calls)
  static Future<int> convertToNGN(double amountInUserCurrency) async {
    if (Cur == 'NGN') return amountInUserCurrency.round();
    
    final rate = await getExchangeRate();
    if (rate == 0) return 0;
    
    return (amountInUserCurrency / rate).round();
  }

  /// Format amount with currency symbol
  static String formatAmount(double amount) {
    final formatter = NumberFormat('#,###.##');
    return '$currencySymbol${formatter.format(amount)}';
  }
}