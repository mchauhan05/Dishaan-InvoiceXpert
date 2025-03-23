class CompanyProfile {
  final String companyName;
  final String contactPerson;
  final String email;
  final String phone;
  final String website;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String taxId;
  final String? logoUrl;

  CompanyProfile({
    required this.companyName,
    required this.contactPerson,
    required this.email,
    required this.phone,
    this.website = '',
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    this.taxId = '',
    this.logoUrl,
  });

  CompanyProfile copyWith({
    String? companyName,
    String? contactPerson,
    String? email,
    String? phone,
    String? website,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    String? taxId,
    String? logoUrl,
  }) {
    return CompanyProfile(
      companyName: companyName ?? this.companyName,
      contactPerson: contactPerson ?? this.contactPerson,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      taxId: taxId ?? this.taxId,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }
}

class TaxSettings {
  final bool enableTax;
  final String taxName;
  final double defaultTaxRate;
  final bool compoundTax;
  final bool taxableShipping;

  TaxSettings({
    this.enableTax = true,
    this.taxName = 'Tax',
    this.defaultTaxRate = 0.0,
    this.compoundTax = false,
    this.taxableShipping = false,
  });

  TaxSettings copyWith({
    bool? enableTax,
    String? taxName,
    double? defaultTaxRate,
    bool? compoundTax,
    bool? taxableShipping,
  }) {
    return TaxSettings(
      enableTax: enableTax ?? this.enableTax,
      taxName: taxName ?? this.taxName,
      defaultTaxRate: defaultTaxRate ?? this.defaultTaxRate,
      compoundTax: compoundTax ?? this.compoundTax,
      taxableShipping: taxableShipping ?? this.taxableShipping,
    );
  }
}

class EmailSettings {
  final String senderName;
  final String senderEmail;
  final String replyToEmail;
  final String ccEmail;
  final String bccEmail;
  final String emailSignature;

  EmailSettings({
    required this.senderName,
    required this.senderEmail,
    this.replyToEmail = '',
    this.ccEmail = '',
    this.bccEmail = '',
    this.emailSignature = '',
  });

  EmailSettings copyWith({
    String? senderName,
    String? senderEmail,
    String? replyToEmail,
    String? ccEmail,
    String? bccEmail,
    String? emailSignature,
  }) {
    return EmailSettings(
      senderName: senderName ?? this.senderName,
      senderEmail: senderEmail ?? this.senderEmail,
      replyToEmail: replyToEmail ?? this.replyToEmail,
      ccEmail: ccEmail ?? this.ccEmail,
      bccEmail: bccEmail ?? this.bccEmail,
      emailSignature: emailSignature ?? this.emailSignature,
    );
  }
}

class InvoiceSettings {
  final String invoicePrefix;
  final int nextInvoiceNumber;
  final String defaultTerms;
  final String defaultNotes;
  final int dueDays;
  final bool autoNumbering;
  final bool showDueDate;
  final bool showPaidStamp;
  final bool showLogo;

  InvoiceSettings({
    this.invoicePrefix = 'INV-',
    this.nextInvoiceNumber = 1,
    this.defaultTerms = 'Payment is due within 30 days',
    this.defaultNotes = 'Thank you for your business',
    this.dueDays = 30,
    this.autoNumbering = true,
    this.showDueDate = true,
    this.showPaidStamp = true,
    this.showLogo = true,
  });

  InvoiceSettings copyWith({
    String? invoicePrefix,
    int? nextInvoiceNumber,
    String? defaultTerms,
    String? defaultNotes,
    int? dueDays,
    bool? autoNumbering,
    bool? showDueDate,
    bool? showPaidStamp,
    bool? showLogo,
  }) {
    return InvoiceSettings(
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      nextInvoiceNumber: nextInvoiceNumber ?? this.nextInvoiceNumber,
      defaultTerms: defaultTerms ?? this.defaultTerms,
      defaultNotes: defaultNotes ?? this.defaultNotes,
      dueDays: dueDays ?? this.dueDays,
      autoNumbering: autoNumbering ?? this.autoNumbering,
      showDueDate: showDueDate ?? this.showDueDate,
      showPaidStamp: showPaidStamp ?? this.showPaidStamp,
      showLogo: showLogo ?? this.showLogo,
    );
  }
}

class CurrencySettings {
  final String defaultCurrency;
  final String currencySymbol;
  final bool symbolBefore;
  final int decimalPlaces;
  final String thousandsSeparator;
  final String decimalSeparator;

  CurrencySettings({
    this.defaultCurrency = 'USD',
    this.currencySymbol = '\$',
    this.symbolBefore = true,
    this.decimalPlaces = 2,
    this.thousandsSeparator = ',',
    this.decimalSeparator = '.',
  });

  CurrencySettings copyWith({
    String? defaultCurrency,
    String? currencySymbol,
    bool? symbolBefore,
    int? decimalPlaces,
    String? thousandsSeparator,
    String? decimalSeparator,
  }) {
    return CurrencySettings(
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      symbolBefore: symbolBefore ?? this.symbolBefore,
      decimalPlaces: decimalPlaces ?? this.decimalPlaces,
      thousandsSeparator: thousandsSeparator ?? this.thousandsSeparator,
      decimalSeparator: decimalSeparator ?? this.decimalSeparator,
    );
  }
}

class AppSettings {
  final CompanyProfile companyProfile;
  final TaxSettings taxSettings;
  final EmailSettings emailSettings;
  final InvoiceSettings invoiceSettings;
  final CurrencySettings currencySettings;
  final bool darkMode;

  AppSettings({
    required this.companyProfile,
    required this.taxSettings,
    required this.emailSettings,
    required this.invoiceSettings,
    required this.currencySettings,
    this.darkMode = false,
  });

  AppSettings copyWith({
    CompanyProfile? companyProfile,
    TaxSettings? taxSettings,
    EmailSettings? emailSettings,
    InvoiceSettings? invoiceSettings,
    CurrencySettings? currencySettings,
    bool? darkMode,
  }) {
    return AppSettings(
      companyProfile: companyProfile ?? this.companyProfile,
      taxSettings: taxSettings ?? this.taxSettings,
      emailSettings: emailSettings ?? this.emailSettings,
      invoiceSettings: invoiceSettings ?? this.invoiceSettings,
      currencySettings: currencySettings ?? this.currencySettings,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}
