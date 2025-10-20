import 'package:budgeting/models/currency.dart';

/// Complete list of world currencies
class CurrencyData {
  static final List<Currency> allCurrencies = [
    // Major Currencies
    Currency('USD', '\$'),
    Currency('EUR', '€'),
    Currency('GBP', '£'),
    Currency('JPY', '¥'),
    Currency('CNY', '¥'),
    Currency('KRW', '₩'),
    Currency('CAD', 'CAD'),
    Currency('AUD', 'AUD'),
    Currency('CHF', 'CHF'),
    Currency('HKD', 'HKD'),
    Currency('SGD', 'SGD'),
    Currency('NZD', 'NZD'),
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

  /// Search currencies by code or symbol
  static List<Currency> searchCurrencies(String query) {
    if (query.isEmpty) return allCurrencies;
    
    final lowerQuery = query.toLowerCase();
    return allCurrencies.where((currency) {
      return currency.code.toLowerCase().contains(lowerQuery) ||
          currency.symbol.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}