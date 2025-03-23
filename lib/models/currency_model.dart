import 'package:intl/intl.dart';

/// Class representing a currency with formatting options
class Currency {
  final String code;
  final String name;
  final String symbol;
  final bool symbolBefore;
  final int decimalPlaces;
  final String decimalSeparator;
  final String thousandSeparator;
  final double exchangeRate; // Rate relative to base currency (e.g., USD)
  final bool isActive;
  final String? countryCode;

  Currency({
    required this.code,
    required this.name,
    required this.symbol,
    this.symbolBefore = true,
    this.decimalPlaces = 2,
    this.decimalSeparator = '.',
    this.thousandSeparator = ',',
    required this.exchangeRate,
    this.isActive = true,
    this.countryCode,
  });

  /// Format a value according to this currency's rules
  String format(double value) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalPlaces,
    );

    String formatted = formatter.format(value);

    // Replace decimal and thousand separators if they don't match the default
    if (decimalSeparator != '.') {
      formatted = formatted.replaceAll('.', decimalSeparator);
    }

    if (thousandSeparator != ',') {
      formatted = formatted.replaceAll(',', thousandSeparator);
    }

    return formatted;
  }

  /// Convert a value from this currency to the base currency
  double toBaseCurrency(double value) {
    return value / exchangeRate;
  }

  /// Convert a value from the base currency to this currency
  double fromBaseCurrency(double value) {
    return value * exchangeRate;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'symbol': symbol,
      'symbolBefore': symbolBefore,
      'decimalPlaces': decimalPlaces,
      'decimalSeparator': decimalSeparator,
      'thousandSeparator': thousandSeparator,
      'exchangeRate': exchangeRate,
      'isActive': isActive,
      'countryCode': countryCode,
    };
  }

  /// Create from JSON
  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      code: json['code'],
      name: json['name'],
      symbol: json['symbol'],
      symbolBefore: json['symbolBefore'] ?? true,
      decimalPlaces: json['decimalPlaces'] ?? 2,
      decimalSeparator: json['decimalSeparator'] ?? '.',
      thousandSeparator: json['thousandSeparator'] ?? ',',
      exchangeRate: json['exchangeRate'],
      isActive: json['isActive'] ?? true,
      countryCode: json['countryCode'],
    );
  }

  /// Create a copy with modified fields
  Currency copyWith({
    String? code,
    String? name,
    String? symbol,
    bool? symbolBefore,
    int? decimalPlaces,
    String? decimalSeparator,
    String? thousandSeparator,
    double? exchangeRate,
    bool? isActive,
    String? countryCode,
  }) {
    return Currency(
      code: code ?? this.code,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      symbolBefore: symbolBefore ?? this.symbolBefore,
      decimalPlaces: decimalPlaces ?? this.decimalPlaces,
      decimalSeparator: decimalSeparator ?? this.decimalSeparator,
      thousandSeparator: thousandSeparator ?? this.thousandSeparator,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      isActive: isActive ?? this.isActive,
      countryCode: countryCode ?? this.countryCode,
    );
  }
}

/// Class containing a list of commonly used currencies with default information
class Currencies {
  /// Get a list of common currencies with default exchange rates
  static List<Currency> getCommonCurrencies() {
    return [
      Currency(
        code: 'USD',
        name: 'US Dollar',
        symbol: '\$',
        exchangeRate: 1.0, // Base currency
        countryCode: 'US',
      ),
      Currency(
        code: 'EUR',
        name: 'Euro',
        symbol: '€',
        exchangeRate: 0.92, // Example rate
        countryCode: 'EU',
      ),
      Currency(
        code: 'GBP',
        name: 'British Pound',
        symbol: '£',
        exchangeRate: 0.79, // Example rate
        countryCode: 'GB',
      ),
      Currency(
        code: 'CAD',
        name: 'Canadian Dollar',
        symbol: 'CA\$',
        exchangeRate: 1.37, // Example rate
        countryCode: 'CA',
      ),
      Currency(
        code: 'AUD',
        name: 'Australian Dollar',
        symbol: 'A\$',
        exchangeRate: 1.53, // Example rate
        countryCode: 'AU',
      ),
      Currency(
        code: 'JPY',
        name: 'Japanese Yen',
        symbol: '¥',
        decimalPlaces: 0, // Yen typically doesn't use decimal places
        exchangeRate: 151.16, // Example rate
        countryCode: 'JP',
      ),
      Currency(
        code: 'CNY',
        name: 'Chinese Yuan',
        symbol: '¥',
        exchangeRate: 7.24, // Example rate
        countryCode: 'CN',
      ),
      Currency(
        code: 'INR',
        name: 'Indian Rupee',
        symbol: '₹',
        exchangeRate: 83.38, // Example rate
        countryCode: 'IN',
      ),
      Currency(
        code: 'BRL',
        name: 'Brazilian Real',
        symbol: 'R\$',
        exchangeRate: 5.08, // Example rate
        countryCode: 'BR',
      ),
      Currency(
        code: 'MXN',
        name: 'Mexican Peso',
        symbol: 'Mex\$',
        exchangeRate: 16.7, // Example rate
        countryCode: 'MX',
      ),
      Currency(
        code: 'SGD',
        name: 'Singapore Dollar',
        symbol: 'S\$',
        exchangeRate: 1.34, // Example rate
        countryCode: 'SG',
      ),
      Currency(
        code: 'NZD',
        name: 'New Zealand Dollar',
        symbol: 'NZ\$',
        exchangeRate: 1.65, // Example rate
        countryCode: 'NZ',
      ),
      Currency(
        code: 'CHF',
        name: 'Swiss Franc',
        symbol: 'Fr',
        decimalSeparator: '.',
        thousandSeparator: '\'',
        exchangeRate: 0.90, // Example rate
        countryCode: 'CH',
      ),
      Currency(
        code: 'ZAR',
        name: 'South African Rand',
        symbol: 'R',
        exchangeRate: 18.45, // Example rate
        countryCode: 'ZA',
      ),
      Currency(
        code: 'AED',
        name: 'UAE Dirham',
        symbol: 'د.إ',
        exchangeRate: 3.67, // Example rate
        countryCode: 'AE',
      ),
    ];
  }

  /// Get a currency by code
  static Currency? getCurrencyByCode(String code, List<Currency> currencies) {
    try {
      return currencies.firstWhere((currency) => currency.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Convert a value from one currency to another
  static double convert({
    required double amount,
    required Currency fromCurrency,
    required Currency toCurrency,
  }) {
    // First convert to base currency (USD)
    final amountInBaseCurrency = fromCurrency.toBaseCurrency(amount);

    // Then convert from base currency to target currency
    return toCurrency.fromBaseCurrency(amountInBaseCurrency);
  }
}

/// Class representing exchange rates between currencies
class ExchangeRates {
  final DateTime lastUpdated;
  final String baseCurrency; // Usually USD
  final Map<String, double> rates;

  ExchangeRates({
    required this.lastUpdated,
    required this.baseCurrency,
    required this.rates,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'lastUpdated': lastUpdated.toIso8601String(),
      'baseCurrency': baseCurrency,
      'rates': rates,
    };
  }

  /// Create from JSON
  factory ExchangeRates.fromJson(Map<String, dynamic> json) {
    return ExchangeRates(
      lastUpdated: DateTime.parse(json['lastUpdated']),
      baseCurrency: json['baseCurrency'],
      rates: Map<String, double>.from(json['rates']),
    );
  }

  /// Get exchange rate for a specific currency
  double? getRate(String currencyCode) {
    return rates[currencyCode];
  }

  /// Convert amount between currencies
  double convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    if (fromCurrency == toCurrency) {
      return amount;
    }

    if (fromCurrency == baseCurrency) {
      final rate = rates[toCurrency];
      if (rate == null) {
        throw Exception('Exchange rate not found for $toCurrency');
      }
      return amount * rate;
    }

    if (toCurrency == baseCurrency) {
      final rate = rates[fromCurrency];
      if (rate == null) {
        throw Exception('Exchange rate not found for $fromCurrency');
      }
      return amount / rate;
    }

    // Convert from source to base first, then to target
    final fromRate = rates[fromCurrency];
    final toRate = rates[toCurrency];

    if (fromRate == null || toRate == null) {
      throw Exception('Exchange rate not found');
    }

    // First convert to base currency
    final amountInBaseCurrency = amount / fromRate;

    // Then convert to target currency
    return amountInBaseCurrency * toRate;
  }
}
