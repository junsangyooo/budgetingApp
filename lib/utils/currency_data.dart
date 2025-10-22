import 'package:budgeting/models/currency.dart';

/// Complete list of world currencies
class CurrencyData {
  static final List<Currency> allCurrencies = [
    // Major Currencies
     Currency('USD', '\$', 'US Dollar'),
    Currency('EUR', '€', 'Euro'),
    Currency('GBP', '£', 'British Pound'),
    Currency('JPY', '¥', 'Japanese Yen'),
    Currency('CNY', '¥', 'Chinese Yuan'),
    Currency('KRW', '₩', 'Korean Won'),
    Currency('CAD', 'C\$', 'Canadian Dollar'),
    Currency('AUD', 'A\$', 'Australian Dollar'),
    Currency('CHF', 'CHF', 'Swiss Franc'),
    Currency('HKD', 'HK\$', 'Hong Kong Dollar'),
    Currency('SGD', 'S\$', 'Singapore Dollar'),
    Currency('NZD', 'NZ\$', 'New Zealand Dollar'),
  ];

  /// Get currency by code
  static Currency? getCurrency(String code) {
    try {
      return allCurrencies.firstWhere(
        (c) => c.code.toUpperCase() == code.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get default currency by language
  static String getDefaultCurrencyForLanguage(String languageCode) {
    switch (languageCode) {
      case 'ko':
        return 'KRW';
      case 'en':
      default:
        return 'USD';
    }
  }

  /// Search currencies by name or code
  static List<Currency> searchCurrencies(String query) {
    if (query.isEmpty) return allCurrencies;
    
    final lowerQuery = query.toLowerCase();
    return allCurrencies.where((currency) {
      return currency.code.toLowerCase().contains(lowerQuery) ||
          currency.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}