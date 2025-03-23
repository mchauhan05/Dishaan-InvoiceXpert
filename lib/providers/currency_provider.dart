import 'package:flutter/material.dart';

import '../models/currency_model.dart';

/// Provider for currency management
class CurrencyProvider extends ChangeNotifier {
  // List of available currencies
  List<Currency> _currencies = [];

  // Selected base currency (default USD)
  Currency? _baseCurrency;

  // Selected display currency
  Currency? _displayCurrency;

  // Exchange rates
  ExchangeRates? _exchangeRates;

  // Loading state
  bool _isLoading = false;

  // Error message
  String? _error;

  // Getters
  List<Currency> get currencies => _currencies;
  Currency get baseCurrency => _baseCurrency ?? _getDefaultCurrency();
  Currency get displayCurrency => _displayCurrency ?? _baseCurrency ?? _getDefaultCurrency();
  ExchangeRates? get exchangeRates => _exchangeRates;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Constructor
  CurrencyProvider() {
    _initialize();
  }

  // Initialize with default currencies
  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load currencies from storage if available
      final storedCurrencies = await _loadCurrenciesFromStorage();

      if (storedCurrencies.isNotEmpty) {
        _currencies = storedCurrencies;
      } else {
        // Otherwise use default list
        _currencies = Currencies.getCommonCurrencies();
        // Save to storage
        await _saveCurrenciesToStorage();
      }

      // Set default base currency to USD
      _baseCurrency = Currencies.getCurrencyByCode('USD', _currencies);
      _displayCurrency = _baseCurrency;

      // Load exchange rates
      await fetchExchangeRates();

      _error = null;
    } catch (e) {
      _error = 'Error initializing currencies: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get default USD currency
  Currency _getDefaultCurrency() {
    return Currency(
      code: 'USD',
      name: 'US Dollar',
      symbol: '\$',
      exchangeRate: 1.0,
    );
  }

  // Fetch latest exchange rates from API
  Future<void> fetchExchangeRates() async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, you would fetch from an API like:
      // final response = await http.get(Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'));
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   _exchangeRates = ExchangeRates(
      //     lastUpdated: DateTime.now(),
      //     baseCurrency: data['base'],
      //     rates: Map<String, double>.from(data['rates']),
      //   );
      // }

      // For the demo, we'll use the exchange rates from the currencies list
      final Map<String, double> rates = {};
      for (final currency in _currencies) {
        rates[currency.code] = currency.exchangeRate;
      }

      _exchangeRates = ExchangeRates(
        lastUpdated: DateTime.now(),
        baseCurrency: 'USD',
        rates: rates,
      );

      // Update currency exchange rates
      for (int i = 0; i < _currencies.length; i++) {
        final currency = _currencies[i];
        final rate = _exchangeRates!.getRate(currency.code);
        if (rate != null) {
          _currencies[i] = currency.copyWith(exchangeRate: rate);
        }
      }

      _error = null;
    } catch (e) {
      _error = 'Error fetching exchange rates: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set base currency
  void setBaseCurrency(String currencyCode) {
    final currency = Currencies.getCurrencyByCode(currencyCode, _currencies);
    if (currency != null) {
      _baseCurrency = currency;
      notifyListeners();
    }
  }

  // Set display currency
  void setDisplayCurrency(String currencyCode) {
    final currency = Currencies.getCurrencyByCode(currencyCode, _currencies);
    if (currency != null) {
      _displayCurrency = currency;
      notifyListeners();
    }
  }

  // Add a new currency
  Future<bool> addCurrency(Currency currency) async {
    // Check if currency with this code already exists
    if (_currencies.any((c) => c.code == currency.code)) {
      _error = 'Currency with code ${currency.code} already exists';
      notifyListeners();
      return false;
    }

    _currencies.add(currency);
    await _saveCurrenciesToStorage();
    notifyListeners();
    return true;
  }

  // Update a currency
  Future<bool> updateCurrency(Currency updatedCurrency) async {
    final index = _currencies.indexWhere((c) => c.code == updatedCurrency.code);
    if (index < 0) {
      _error = 'Currency with code ${updatedCurrency.code} not found';
      notifyListeners();
      return false;
    }

    _currencies[index] = updatedCurrency;

    // If this is the base or display currency, update those references too
    if (_baseCurrency?.code == updatedCurrency.code) {
      _baseCurrency = updatedCurrency;
    }

    if (_displayCurrency?.code == updatedCurrency.code) {
      _displayCurrency = updatedCurrency;
    }

    await _saveCurrenciesToStorage();
    notifyListeners();
    return true;
  }

  // Delete a currency
  Future<bool> deleteCurrency(String currencyCode) async {
    // Don't allow deleting the base currency
    if (_baseCurrency?.code == currencyCode) {
      _error = 'Cannot delete the base currency';
      notifyListeners();
      return false;
    }

    // Find the currency to delete
    final index = _currencies.indexWhere((c) => c.code == currencyCode);
    if (index < 0) {
      _error = 'Currency with code $currencyCode not found';
      notifyListeners();
      return false;
    }

    _currencies.removeAt(index);

    // If this was the display currency, reset to base currency
    if (_displayCurrency?.code == currencyCode) {
      _displayCurrency = _baseCurrency;
    }

    await _saveCurrenciesToStorage();
    notifyListeners();
    return true;
  }

  // Convert amount between currencies
  double convert({
    required double amount,
    required String fromCurrencyCode,
    required String toCurrencyCode,
  }) {
    if (fromCurrencyCode == toCurrencyCode) {
      return amount;
    }

    final fromCurrency = Currencies.getCurrencyByCode(fromCurrencyCode, _currencies);
    final toCurrency = Currencies.getCurrencyByCode(toCurrencyCode, _currencies);

    if (fromCurrency == null || toCurrency == null) {
      throw Exception('Currency not found');
    }

    return Currencies.convert(
      amount: amount,
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
    );
  }

  // Format amount according to currency rules
  String format(double amount, {String? currencyCode}) {
    final code = currencyCode ?? displayCurrency.code;
    final currency = Currencies.getCurrencyByCode(code, _currencies) ?? displayCurrency;

    return currency.format(amount);
  }

  // Get active currencies
  List<Currency> getActiveCurrencies() {
    return _currencies.where((c) => c.isActive).toList();
  }

  // Load currencies from storage
  Future<List<Currency>> _loadCurrenciesFromStorage() async {
    // Load from database service
    try {
      // In a real app, you would load from database
      // For this demo, we'll just return an empty list to use defaults
      return [];
    } catch (e) {
      print('Error loading currencies from storage: $e');
      return [];
    }
  }

  // Save currencies to storage
  Future<void> _saveCurrenciesToStorage() async {
    // Save to database service
    try {
      // In a real app, you would save to database
      // For this demo, we'll just print a message
      print('Currencies saved: ${_currencies.length}');
    } catch (e) {
      print('Error saving currencies to storage: $e');
    }
  }
}
