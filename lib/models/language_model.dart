import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// Represents a supported language in the application
class AppLanguage {
  final String code;
  final String name;
  final String localName;
  final String flagIcon;
  final TextDirection textDirection;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.localName,
    required this.flagIcon,
    this.textDirection = TextDirection.ltr,
  });
}

/// List of supported Indian languages
class IndianLanguages {
  static const english = AppLanguage(
    code: 'en',
    name: 'English',
    localName: 'English',
    flagIcon: '🇮🇳', // Indian flag for Indian English
  );

  static const hindi = AppLanguage(
    code: 'hi',
    name: 'Hindi',
    localName: 'हिन्दी',
    flagIcon: '🇮🇳',
  );

  static const bengali = AppLanguage(
    code: 'bn',
    name: 'Bengali',
    localName: 'বাংলা',
    flagIcon: '🇮🇳',
  );

  static const marathi = AppLanguage(
    code: 'mr',
    name: 'Marathi',
    localName: 'मराठी',
    flagIcon: '🇮🇳',
  );

  static const tamil = AppLanguage(
    code: 'ta',
    name: 'Tamil',
    localName: 'தமிழ்',
    flagIcon: '🇮🇳',
  );

  static const telugu = AppLanguage(
    code: 'te',
    name: 'Telugu',
    localName: 'తెలుగు',
    flagIcon: '🇮🇳',
  );

  static const gujarati = AppLanguage(
    code: 'gu',
    name: 'Gujarati',
    localName: 'ગુજરાતી',
    flagIcon: '🇮🇳',
  );

  static const kannada = AppLanguage(
    code: 'kn',
    name: 'Kannada',
    localName: 'ಕನ್ನಡ',
    flagIcon: '🇮🇳',
  );

  static const malayalam = AppLanguage(
    code: 'ml',
    name: 'Malayalam',
    localName: 'മലയാളം',
    flagIcon: '🇮🇳',
  );

  static const punjabi = AppLanguage(
    code: 'pa',
    name: 'Punjabi',
    localName: 'ਪੰਜਾਬੀ',
    flagIcon: '🇮🇳',
  );

  static const odia = AppLanguage(
    code: 'or',
    name: 'Odia',
    localName: 'ଓଡ଼ିଆ',
    flagIcon: '🇮🇳',
  );

  /// List of all supported languages
  static List<AppLanguage> get supportedLanguages => [
    english,
    hindi,
    bengali,
    marathi,
    tamil,
    telugu,
    gujarati,
    kannada,
    malayalam,
    punjabi,
    odia,
  ];

  /// Get a language by its code
  static AppLanguage getLanguageByCode(String code) {
    return supportedLanguages.firstWhere(
      (lang) => lang.code == code,
      orElse: () => english, // Default to English
    );
  }
}

/// Model to hold translations for a specific language
class TranslationModel {
  final Map<String, String> translations;

  TranslationModel(this.translations);

  /// Load translations from a JSON file
  static Future<TranslationModel> load(String languageCode) async {
    try {
      final jsonString = await rootBundle.loadString('assets/translations/$languageCode.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final translations = jsonMap.map((key, value) => MapEntry(key, value.toString()));
      return TranslationModel(translations);
    } catch (e) {
      // If language file not found, return empty translations
      return TranslationModel({});
    }
  }

  String translate(String key) {
    return translations[key] ?? key;
  }
}

/// Regional number and currency formatting for Indian languages
class RegionalNumberFormat {
  final String languageCode;
  final String currencySymbol;
  final bool useLakhCrore;

  RegionalNumberFormat({
    required this.languageCode,
    required this.currencySymbol,
    this.useLakhCrore = true,
  });

  /// Format a number according to Indian conventions (lakhs, crores)
  String formatNumber(num number) {
    if (!useLakhCrore) return number.toString();

    final numStr = number.toString();
    final parts = numStr.split('.');
    final wholePart = parts[0];

    // For numbers less than 1000, just return as is
    if (wholePart.length <= 3) {
      return numStr;
    }

    // For numbers between 1,000 and 9,999
    if (wholePart.length <= 4) {
      return '${wholePart.substring(0, wholePart.length - 3)},${wholePart.substring(wholePart.length - 3)}${parts.length > 1 ? '.${parts[1]}' : ''}';
    }

    // For numbers 10,000 and above - use lakh, crore format
    final lastThree = wholePart.substring(wholePart.length - 3);
    final remaining = wholePart.substring(0, wholePart.length - 3);
    var formatted = '';
    var i = remaining.length;

    // First group of 2 after the last 3 (for lakhs)
    if (i > 2) {
      formatted = '${remaining.substring(i - 2)},';
      i -= 2;
    } else {
      formatted = remaining;
      i = 0;
    }

    // Remaining groups in sets of 2 (for crores and above)
    while (i > 0) {
      if (i >= 2) {
        formatted = '${remaining.substring(i - 2, i)},${formatted}';
        i -= 2;
      } else {
        formatted = '${remaining.substring(0, i)},${formatted}';
        i = 0;
      }
    }

    return '$formatted$lastThree${parts.length > 1 ? '.${parts[1]}' : ''}';
  }

  /// Format a currency amount
  String formatCurrency(num amount) {
    return '$currencySymbol ${formatNumber(amount)}';
  }

  /// Convert number to words in the regional language
  /// This is a placeholder - actual implementation would use language-specific logic
  String numberToWords(num number) {
    // Default to English - would need separate implementation for each language
    return 'Amount in words not available in this language';
  }

  /// Get regional number format for a specific language
  static RegionalNumberFormat forLanguage(String languageCode) {
    switch (languageCode) {
      case 'en':
        return RegionalNumberFormat(
          languageCode: 'en',
          currencySymbol: '₹',
          useLakhCrore: true,
        );
      case 'hi':
        return RegionalNumberFormat(
          languageCode: 'hi',
          currencySymbol: '₹',
          useLakhCrore: true,
        );
      // Add other languages with their specific formatting
      default:
        return RegionalNumberFormat(
          languageCode: 'en',
          currencySymbol: '₹',
          useLakhCrore: true,
        );
    }
  }
}
