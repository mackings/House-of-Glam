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

/// Map country code or country name to currency code
String getCurrencyFromCountry(String country) {
  final countryUpper = country.toUpperCase().trim();

  switch (countryUpper) {
    // United States
    case 'US':
    case 'USA':
    case 'UNITED STATES':
    case 'UNITED STATES OF AMERICA':
      return 'USD';

    // Nigeria
    case 'NG':
    case 'NGA':
    case 'NIGERIA':
      return 'NGN';

    // United Kingdom
    case 'GB':
    case 'UK':
    case 'GBR':
    case 'UNITED KINGDOM':
    case 'GREAT BRITAIN':
    case 'ENGLAND':
    case 'SCOTLAND':
    case 'WALES':
      return 'GBP';

    // Canada
    case 'CA':
    case 'CAN':
    case 'CANADA':
      return 'CAD';

    // Australia
    case 'AU':
    case 'AUS':
    case 'AUSTRALIA':
      return 'AUD';

    // European Union countries
    case 'EU':
    case 'DE':
    case 'DEU':
    case 'GERMANY':
    case 'FR':
    case 'FRA':
    case 'FRANCE':
    case 'IT':
    case 'ITA':
    case 'ITALY':
    case 'ES':
    case 'ESP':
    case 'SPAIN':
    case 'NL':
    case 'NLD':
    case 'NETHERLANDS':
    case 'BE':
    case 'BEL':
    case 'BELGIUM':
    case 'AT':
    case 'AUT':
    case 'AUSTRIA':
    case 'PT':
    case 'PRT':
    case 'PORTUGAL':
    case 'IE':
    case 'IRL':
    case 'IRELAND':
      return 'EUR';

    // India
    case 'IN':
    case 'IND':
    case 'INDIA':
      return 'INR';

    // China
    case 'CN':
    case 'CHN':
    case 'CHINA':
      return 'CNY';

    // Japan
    case 'JP':
    case 'JPN':
    case 'JAPAN':
      return 'JPY';

    // South Africa
    case 'ZA':
    case 'ZAF':
    case 'SOUTH AFRICA':
      return 'ZAR';

    // Ghana
    case 'GH':
    case 'GHA':
    case 'GHANA':
      return 'GHS';

    // Kenya
    case 'KE':
    case 'KEN':
    case 'KENYA':
      return 'KES';

    default:
      return 'NGN'; // Fallback to NGN
  }
}

/// Derive currency from phone number country code
String getCurrencyFromPhoneNumber(String phoneNumber) {
  // Remove any non-digit characters except +
  final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

  if (cleaned.startsWith('+1') || cleaned.startsWith('1')) {
    return 'USD'; // US/Canada
  } else if (cleaned.startsWith('+234')) {
    return 'NGN'; // Nigeria
  } else if (cleaned.startsWith('+44')) {
    return 'GBP'; // UK
  } else if (cleaned.startsWith('+91')) {
    return 'INR'; // India
  } else if (cleaned.startsWith('+86')) {
    return 'CNY'; // China
  } else if (cleaned.startsWith('+81')) {
    return 'JPY'; // Japan
  } else if (cleaned.startsWith('+27')) {
    return 'ZAR'; // South Africa
  } else if (cleaned.startsWith('+233')) {
    return 'GHS'; // Ghana
  } else if (cleaned.startsWith('+254')) {
    return 'KES'; // Kenya
  } else if (cleaned.startsWith('+61')) {
    return 'AUD'; // Australia
  }

  return 'NGN'; // Default fallback
}
