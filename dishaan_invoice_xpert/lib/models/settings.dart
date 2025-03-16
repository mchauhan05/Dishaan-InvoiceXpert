// lib/models/settings.dart

class Settings {
  final int id;
  final String? businessName;
  final String? businessAddress;
  final String? businessPhone;
  final String? businessEmail;
  final String? businessWebsite;
  final double taxPercentage;
  final String currencySymbol;
  final String invoicePrefix;
  final bool enableLogin;
  final String? logoPath;
  final String? invoiceFooter;
  final DateTime updatedAt;

  Settings({
    this.id = 1,
    this.businessName,
    this.businessAddress,
    this.businessPhone,
    this.businessEmail,
    this.businessWebsite,
    this.taxPercentage = 0,
    this.currencySymbol = '\$',
    this.invoicePrefix = 'INV-',
    this.enableLogin = false,
    this.logoPath,
    this.invoiceFooter,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
        id: map['id'] ?? 1,
        businessName: map['business_name'],
        businessAddress: map['business_address'],
        businessPhone: map['business_phone'],
        businessEmail: map['business_email'],
        businessWebsite: map['business_website'],
        taxPercentage: map['tax_percentage'] ?? 0,
        currencySymbol: map['currency_symbol'] ?? '\$',
        invoicePrefix: map['invoice_prefix'] ?? 'INV-',
        enableLogin: (map['enable_login'] ?? 0) == 1,
        logoPath: map['logo_path'],
        invoiceFooter: map['invoice_footer'],
        updatedAt: map['updated_at'] != null
            ? DateTime.parse(map['updated_at'])
            : DateTime.now());
  }

  toMap() {}
}