import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';

/// Extension on BuildContext that provides easy access to translations
extension TranslationExtension on BuildContext {
  /// Translate a key using the current language
  String tr(String key) {
    final languageProvider = Provider.of<LanguageProvider>(this, listen: false);
    return languageProvider.translate(key);
  }

  /// Format a number according to the current language's conventions
  String formatNumber(num number) {
    final languageProvider = Provider.of<LanguageProvider>(this, listen: false);
    return languageProvider.formatNumber(number);
  }

  /// Format a currency amount according to the current language's conventions
  String formatCurrency(num amount) {
    final languageProvider = Provider.of<LanguageProvider>(this, listen: false);
    return languageProvider.formatCurrency(amount);
  }

  /// Get the current text direction
  TextDirection get textDirection {
    final languageProvider = Provider.of<LanguageProvider>(this, listen: false);
    return languageProvider.textDirection;
  }

  /// Get the current language code
  String get languageCode {
    final languageProvider = Provider.of<LanguageProvider>(this, listen: false);
    return languageProvider.currentLanguage.code;
  }

  /// Convert a number to words in the current language
  String numberToWords(num number) {
    final languageProvider = Provider.of<LanguageProvider>(this, listen: false);
    return languageProvider.numberToWords(number);
  }
}
