import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/language_model.dart';

class LanguageProvider extends ChangeNotifier {
  AppLanguage _currentLanguage = IndianLanguages.english;
  TranslationModel _translations = TranslationModel({});
  RegionalNumberFormat _numberFormat = RegionalNumberFormat(
    languageCode: 'en',
    currencySymbol: '₹',
  );
  bool _isLoading = true;

  // Getter for loading state
  bool get isLoading => _isLoading;

  // Getter for current language
  AppLanguage get currentLanguage => _currentLanguage;

  // Getter for text direction
  TextDirection get textDirection => _currentLanguage.textDirection;

  // Getter for number formatter
  RegionalNumberFormat get numberFormat => _numberFormat;

  // Initialize the provider
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    // Load saved language preference from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('app_language') ?? 'en';

    await setLanguage(languageCode);

    _isLoading = false;
    notifyListeners();
  }

  // Change the app language
  Future<void> setLanguage(String languageCode) async {
    _currentLanguage = IndianLanguages.getLanguageByCode(languageCode);
    _numberFormat = RegionalNumberFormat.forLanguage(languageCode);

    // Load translations for the selected language
    _translations = await TranslationModel.load(languageCode);

    // Save the language preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', languageCode);

    notifyListeners();
  }

  // Translate a key
  String translate(String key) {
    return _translations.translate(key);
  }

  // Format a number according to the current language's conventions
  String formatNumber(num number) {
    return _numberFormat.formatNumber(number);
  }

  // Format a currency amount according to the current language's conventions
  String formatCurrency(num amount) {
    return _numberFormat.formatCurrency(amount);
  }

  // Convert a number to words in the current language
  String numberToWords(num number) {
    return _numberFormat.numberToWords(number);
  }
}
