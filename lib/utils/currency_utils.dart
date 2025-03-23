import '../models/currency_model.dart';

/// Utility class for currency operations
class Currencies {
  /// Get a list of common currencies
  static List<Currency> getCommonCurrencies() {
    return [
      // Indian Rupee
      Currency(
        code: 'INR',
        name: 'Indian Rupee',
        symbol: '₹',
        symbolBefore: true,
        decimalPlaces: 2,
        decimalSeparator: '.',
        thousandSeparator: ',',
        exchangeRate: 83.15, // Example rate vs USD, update with real-time data
        isActive: true,
        countryCode: 'IN',
      ),

      // US Dollar (base currency)
      Currency(
        code: 'USD',
        name: 'US Dollar',
        symbol: '\$',
        symbolBefore: true,
        decimalPlaces: 2,
        decimalSeparator: '.',
        thousandSeparator: ',',
        exchangeRate: 1.0, // Base currency
        isActive: true,
        countryCode: 'US',
      ),

      // Euro
      Currency(
        code: 'EUR',
        name: 'Euro',
        symbol: '€',
        symbolBefore: true,
        decimalPlaces: 2,
        decimalSeparator: ',',
        thousandSeparator: '.',
        exchangeRate: 0.93, // Example rate vs USD
        isActive: true,
        countryCode: 'EU',
      ),

      // British Pound
      Currency(
        code: 'GBP',
        name: 'British Pound',
        symbol: '£',
        symbolBefore: true,
        decimalPlaces: 2,
        decimalSeparator: '.',
        thousandSeparator: ',',
        exchangeRate: 0.80, // Example rate vs USD
        isActive: true,
        countryCode: 'GB',
      ),

      // Canadian Dollar
      Currency(
        code: 'CAD',
        name: 'Canadian Dollar',
        symbol: 'C\$',
        symbolBefore: true,
        decimalPlaces: 2,
        decimalSeparator: '.',
        thousandSeparator: ',',
        exchangeRate: 1.38, // Example rate vs USD
        isActive: true,
        countryCode: 'CA',
      ),

      // Australian Dollar
      Currency(
        code: 'AUD',
        name: 'Australian Dollar',
        symbol: 'A\$',
        symbolBefore: true,
        decimalPlaces: 2,
        decimalSeparator: '.',
        thousandSeparator: ',',
        exchangeRate: 1.55, // Example rate vs USD
        isActive: true,
        countryCode: 'AU',
      ),

      // Japanese Yen
      Currency(
        code: 'JPY',
        name: 'Japanese Yen',
        symbol: '¥',
        symbolBefore: true,
        decimalPlaces: 0, // Yen typically doesn't use decimal places
        decimalSeparator: '.',
        thousandSeparator: ',',
        exchangeRate: 153.50, // Example rate vs USD
        isActive: true,
        countryCode: 'JP',
      ),

      // Chinese Yuan
      Currency(
        code: 'CNY',
        name: 'Chinese Yuan',
        symbol: '¥',
        symbolBefore: true,
        decimalPlaces: 2,
        decimalSeparator: '.',
        thousandSeparator: ',',
        exchangeRate: 7.25, // Example rate vs USD
        isActive: true,
        countryCode: 'CN',
      ),

      // Singapore Dollar
      Currency(
        code: 'SGD',
        name: 'Singapore Dollar',
        symbol: 'S\$',
        symbolBefore: true,
        decimalPlaces: 2,
        decimalSeparator: '.',
        thousandSeparator: ',',
        exchangeRate: 1.35, // Example rate vs USD
        isActive: true,
        countryCode: 'SG',
      ),

      // UAE Dirham
      Currency(
        code: 'AED',
        name: 'UAE Dirham',
        symbol: 'د.إ',
        symbolBefore: true,
        decimalPlaces: 2,
        decimalSeparator: '.',
        thousandSeparator: ',',
        exchangeRate: 3.67, // Example rate vs USD
        isActive: true,
        countryCode: 'AE',
      ),

      // Other Asian currencies important for Indian businesses
      Currency(
        code: 'MYR',
        name: 'Malaysian Ringgit',
        symbol: 'RM',
        symbolBefore: true,
        decimalPlaces: 2,
        decimalSeparator: '.',
        thousandSeparator: ',',
        exchangeRate: 4.73, // Example rate vs USD
        isActive: true,
        countryCode: 'MY',
      ),

      Currency(
        code: 'THB',
        name: 'Thai Baht',
        symbol: '฿',
        symbolBefore: true,
        decimalPlaces: 2,
        decimalSeparator: '.',
        thousandSeparator: ',',
        exchangeRate: 36.50, // Example rate vs USD
        isActive: true,
        countryCode: 'TH',
      ),
    ];
  }

  /// Get a currency by its code
  static Currency? getCurrencyByCode(String code, List<Currency> currencies) {
    try {
      return currencies.firstWhere((currency) => currency.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Format a number according to Indian numbering system (lakhs, crores)
  static String formatIndianNumber(double value) {
    // Convert to String with 2 decimal places
    String valueStr = value.toStringAsFixed(2);

    // Split into whole number and decimal parts
    List<String> parts = valueStr.split('.');
    String wholeNumber = parts[0];
    String decimal = parts.length > 1 ? parts[1] : '';

    // Format according to Indian system (1,23,456.78)
    String result = '';
    int length = wholeNumber.length;

    // Handle the first part (hundreds, tens, ones)
    if (length <= 3) {
      result = wholeNumber;
    } else {
      // First add the last 3 digits
      result = wholeNumber.substring(length - 3);

      // Then add the rest in groups of 2
      int i = length - 3;
      while (i > 0) {
        int chunkSize = i >= 2 ? 2 : 1;
        result = wholeNumber.substring(max(0, i - chunkSize), i) + ',' + result;
        i -= chunkSize;
      }
    }

    // Add the decimal part back
    if (decimal.isNotEmpty) {
      result += '.' + decimal;
    }

    return result;
  }

  /// Get symbol for currency code
  static String getSymbolForCurrencyCode(String code) {
    switch (code) {
      case 'INR': return '₹';
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      case 'JPY': return '¥';
      case 'CNY': return '¥';
      case 'AUD': return 'A\$';
      case 'CAD': return 'C\$';
      case 'SGD': return 'S\$';
      case 'AED': return 'د.إ';
      default: return code;
    }
  }

  /// Convert a value from one currency to another
  static double convert(
    double amount,
    String fromCurrencyCode,
    String toCurrencyCode,
    List<Currency> currencies,
  ) {
    Currency? fromCurrency = getCurrencyByCode(fromCurrencyCode, currencies);
    Currency? toCurrency = getCurrencyByCode(toCurrencyCode, currencies);

    if (fromCurrency == null || toCurrency == null) {
      return amount; // Return original amount if currencies not found
    }

    // Convert to base currency (USD) first, then to target currency
    double inBaseCurrency = amount / fromCurrency.exchangeRate;
    return inBaseCurrency * toCurrency.exchangeRate;
  }
}

// Helper function to find maximum of two integers
int max(int a, int b) {
  return a > b ? a : b;
}
