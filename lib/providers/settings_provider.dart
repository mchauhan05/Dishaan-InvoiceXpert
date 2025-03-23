import 'package:flutter/material.dart';
import '../models/settings_model.dart';

class SettingsProvider extends ChangeNotifier {
  late AppSettings _settings;

  SettingsProvider() {
    // Initialize with default settings
    _settings = AppSettings(
      companyProfile: CompanyProfile(
        companyName: 'Demo Company',
        contactPerson: 'John Doe',
        email: 'contact@democompany.com',
        phone: '(555) 123-4567',
        website: 'www.democompany.com',
        address: '123 Main Street',
        city: 'New York',
        state: 'NY',
        zipCode: '10001',
        country: 'United States',
        taxId: 'TAX-1234567',
      ),
      taxSettings: TaxSettings(
        enableTax: true,
        taxName: 'Sales Tax',
        defaultTaxRate: 7.5,
        compoundTax: false,
        taxableShipping: true,
      ),
      emailSettings: EmailSettings(
        senderName: 'Demo Company',
        senderEmail: 'invoices@democompany.com',
        replyToEmail: 'support@democompany.com',
        emailSignature: 'Thank you for your business.\nDemo Company Team',
      ),
      invoiceSettings: InvoiceSettings(
        invoicePrefix: 'INV-',
        nextInvoiceNumber: 1001,
        defaultTerms: 'Payment is due within 30 days. Please make checks payable to Demo Company.',
        defaultNotes: 'Thank you for your business!',
        dueDays: 30,
        autoNumbering: true,
        showDueDate: true,
        showPaidStamp: true,
        showLogo: true,
      ),
      currencySettings: CurrencySettings(
        defaultCurrency: 'USD',
        currencySymbol: '\$',
        symbolBefore: true,
        decimalPlaces: 2,
        thousandsSeparator: ',',
        decimalSeparator: '.',
      ),
      darkMode: false,
    );
  }

  // Getters
  AppSettings get settings => _settings;
  CompanyProfile get companyProfile => _settings.companyProfile;
  TaxSettings get taxSettings => _settings.taxSettings;
  EmailSettings get emailSettings => _settings.emailSettings;
  InvoiceSettings get invoiceSettings => _settings.invoiceSettings;
  CurrencySettings get currencySettings => _settings.currencySettings;
  bool get darkMode => _settings.darkMode;

  // Update company profile
  void updateCompanyProfile(CompanyProfile profile) {
    _settings = _settings.copyWith(companyProfile: profile);
    notifyListeners();
  }

  // Update tax settings
  void updateTaxSettings(TaxSettings taxSettings) {
    _settings = _settings.copyWith(taxSettings: taxSettings);
    notifyListeners();
  }

  // Update email settings
  void updateEmailSettings(EmailSettings emailSettings) {
    _settings = _settings.copyWith(emailSettings: emailSettings);
    notifyListeners();
  }

  // Update invoice settings
  void updateInvoiceSettings(InvoiceSettings invoiceSettings) {
    _settings = _settings.copyWith(invoiceSettings: invoiceSettings);
    notifyListeners();
  }

  // Update currency settings
  void updateCurrencySettings(CurrencySettings currencySettings) {
    _settings = _settings.copyWith(currencySettings: currencySettings);
    notifyListeners();
  }

  // Toggle dark mode
  void toggleDarkMode() {
    _settings = _settings.copyWith(darkMode: !_settings.darkMode);
    notifyListeners();
  }

  // Format currency based on settings
  String formatCurrency(double amount) {
    // Format the number according to decimal places
    String formattedNumber = amount.toStringAsFixed(currencySettings.decimalPlaces);

    // Split into integer and decimal parts
    List<String> parts = formattedNumber.split('.');

    // Format integer part with thousands separator
    String integerPart = parts[0];
    final RegExp regex = RegExp(r'\B(?=(\d{3})+(?!\d))');
    integerPart = integerPart.replaceAllMapped(
      regex,
      (Match match) => currencySettings.thousandsSeparator
    );

    // Combine with decimal part
    String result = parts.length > 1
        ? '$integerPart${currencySettings.decimalSeparator}${parts[1]}'
        : integerPart;

    // Add currency symbol in correct position
    return currencySettings.symbolBefore
        ? '${currencySettings.currencySymbol}$result'
        : '$result ${currencySettings.currencySymbol}';
  }

  // Generate next invoice number
  String getNextInvoiceNumber() {
    String number = '${invoiceSettings.nextInvoiceNumber}'.padLeft(4, '0');
    return '${invoiceSettings.invoicePrefix}$number';
  }

  // Increment the invoice number
  void incrementInvoiceNumber() {
    final updatedSettings = invoiceSettings.copyWith(
      nextInvoiceNumber: invoiceSettings.nextInvoiceNumber + 1
    );

    _settings = _settings.copyWith(invoiceSettings: updatedSettings);
    notifyListeners();
  }
}
