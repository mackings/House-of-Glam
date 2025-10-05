import 'package:hog/App/Auth/Api/secure.dart';


late String Cur;

/// Call this at app startup
Future<void> loadCurrency() async {
  // Fallback to NGN if not set
  Cur = await SecurePrefs.getUserCurrency() ?? "NGN";
}

/// Utility to return symbol from code
String get currencySymbol {
  switch (Cur) {
    case 'NGN':
      return '₦';
    case 'USD':
      return '\$';
    case 'GBP':
      return '£';
    default:
      return '$Cur ';
  }
}
