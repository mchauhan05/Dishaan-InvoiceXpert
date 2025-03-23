import 'package:flutter/material.dart';

/// Tax type enum (VAT, GST, Sales Tax, etc.)
enum TaxType {
  vat,       // Value Added Tax
  gst,       // Goods and Services Tax
  salesTax,  // Sales Tax
  incomeTax, // Income Tax
  serviceTax, // Service Tax
  customTax, // Custom Tax
  none,      // No Tax
}

/// Tax calculation method
enum TaxCalculationMethod {
  exclusive, // Tax is added to the subtotal (most common)
  inclusive, // Tax is included in the price
}

/// Tax class for representing a tax rate
class Tax {
  final String id;
  final String name;
  final TaxType type;
  final double rate; // as a percentage
  final bool isCompound; // Whether this tax is applied after other taxes
  final bool isActive;
  final String? jurisdiction; // Country, state, or region
  final String? registrationNumber; // Tax registration number
  final String? description;
  final TaxCalculationMethod calculationMethod;
  final bool appliesToShipping;
  final List<String> exemptProductCategories; // Categories exempt from this tax

  Tax({
    required this.id,
    required this.name,
    required this.type,
    required this.rate,
    this.isCompound = false,
    this.isActive = true,
    this.jurisdiction,
    this.registrationNumber,
    this.description,
    this.calculationMethod = TaxCalculationMethod.exclusive,
    this.appliesToShipping = false,
    this.exemptProductCategories = const [],
  });

  /// Create a copy with updated fields
  Tax copyWith({
    String? id,
    String? name,
    TaxType? type,
    double? rate,
    bool? isCompound,
    bool? isActive,
    String? jurisdiction,
    String? registrationNumber,
    String? description,
    TaxCalculationMethod? calculationMethod,
    bool? appliesToShipping,
    List<String>? exemptProductCategories,
  }) {
    return Tax(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      rate: rate ?? this.rate,
      isCompound: isCompound ?? this.isCompound,
      isActive: isActive ?? this.isActive,
      jurisdiction: jurisdiction ?? this.jurisdiction,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      description: description ?? this.description,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      appliesToShipping: appliesToShipping ?? this.appliesToShipping,
      exemptProductCategories: exemptProductCategories ?? this.exemptProductCategories,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'rate': rate,
      'isCompound': isCompound,
      'isActive': isActive,
      'jurisdiction': jurisdiction,
      'registrationNumber': registrationNumber,
      'description': description,
      'calculationMethod': calculationMethod.index,
      'appliesToShipping': appliesToShipping,
      'exemptProductCategories': exemptProductCategories,
    };
  }

  /// Create from JSON
  factory Tax.fromJson(Map<String, dynamic> json) {
    return Tax(
      id: json['id'],
      name: json['name'],
      type: TaxType.values[json['type']],
      rate: json['rate'],
      isCompound: json['isCompound'] ?? false,
      isActive: json['isActive'] ?? true,
      jurisdiction: json['jurisdiction'],
      registrationNumber: json['registrationNumber'],
      description: json['description'],
      calculationMethod: TaxCalculationMethod.values[json['calculationMethod'] ?? 0],
      appliesToShipping: json['appliesToShipping'] ?? false,
      exemptProductCategories: json['exemptProductCategories'] != null
          ? List<String>.from(json['exemptProductCategories'])
          : const [],
    );
  }

  /// Get formatted tax rate (e.g., "10.00%")
  String get formattedRate {
    return '${rate.toStringAsFixed(2)}%';
  }

  /// Get tax type display name
  String get typeDisplayName {
    switch (type) {
      case TaxType.vat:
        return 'VAT';
      case TaxType.gst:
        return 'GST';
      case TaxType.salesTax:
        return 'Sales Tax';
      case TaxType.incomeTax:
        return 'Income Tax';
      case TaxType.serviceTax:
        return 'Service Tax';
      case TaxType.customTax:
        return 'Custom Tax';
      case TaxType.none:
        return 'No Tax';
    }
  }
}

/// Tax jurisdiction class for representing a tax region
class TaxJurisdiction {
  final String id;
  final String name;
  final String countryCode;
  final String? stateOrProvince;
  final String? city;
  final String? postalCode;
  final List<Tax> taxes;
  final bool isActive;

  TaxJurisdiction({
    required this.id,
    required this.name,
    required this.countryCode,
    this.stateOrProvince,
    this.city,
    this.postalCode,
    required this.taxes,
    this.isActive = true,
  });

  /// Create a copy with updated fields
  TaxJurisdiction copyWith({
    String? id,
    String? name,
    String? countryCode,
    String? stateOrProvince,
    String? city,
    String? postalCode,
    List<Tax>? taxes,
    bool? isActive,
  }) {
    return TaxJurisdiction(
      id: id ?? this.id,
      name: name ?? this.name,
      countryCode: countryCode ?? this.countryCode,
      stateOrProvince: stateOrProvince ?? this.stateOrProvince,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      taxes: taxes ?? this.taxes,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'countryCode': countryCode,
      'stateOrProvince': stateOrProvince,
      'city': city,
      'postalCode': postalCode,
      'taxes': taxes.map((tax) => tax.toJson()).toList(),
      'isActive': isActive,
    };
  }

  /// Create from JSON
  factory TaxJurisdiction.fromJson(Map<String, dynamic> json) {
    return TaxJurisdiction(
      id: json['id'],
      name: json['name'],
      countryCode: json['countryCode'],
      stateOrProvince: json['stateOrProvince'],
      city: json['city'],
      postalCode: json['postalCode'],
      taxes: (json['taxes'] as List?)
          ?.map((taxJson) => Tax.fromJson(taxJson))
          .toList() ?? [],
      isActive: json['isActive'] ?? true,
    );
  }

  /// Get formatted display name
  String get formattedName {
    final List<String> parts = [name];

    if (stateOrProvince != null && stateOrProvince!.isNotEmpty) {
      parts.add(stateOrProvince!);
    }

    if (city != null && city!.isNotEmpty) {
      parts.add(city!);
    }

    return parts.join(', ');
  }
}

/// Class for tax calculations
class TaxCalculator {
  /// Calculate tax on a single amount with a single tax
  static double calculateTax({
    required double amount,
    required Tax tax,
    bool isExempt = false,
  }) {
    if (isExempt || tax.type == TaxType.none || !tax.isActive) {
      return 0.0;
    }

    final double rate = tax.rate / 100.0; // Convert percentage to decimal

    if (tax.calculationMethod == TaxCalculationMethod.exclusive) {
      // Tax is added to the amount
      return amount * rate;
    } else {
      // Tax is included in the amount
      // Formula: amount - (amount / (1 + rate))
      return amount - (amount / (1 + rate));
    }
  }

  /// Calculate taxes on an amount with multiple taxes
  static Map<String, double> calculateTaxes({
    required double amount,
    required List<Tax> taxes,
    bool isExempt = false,
  }) {
    final Map<String, double> result = {};

    if (isExempt) {
      return result;
    }

    // First calculate non-compound taxes
    double subtotal = amount;
    double totalTax = 0.0;

    // First pass: Calculate regular (non-compound) taxes
    for (final tax in taxes.where((t) => t.isActive && !t.isCompound)) {
      final taxAmount = calculateTax(
        amount: subtotal,
        tax: tax,
        isExempt: isExempt,
      );

      if (taxAmount > 0) {
        result[tax.id] = taxAmount;
        totalTax += taxAmount;
      }
    }

    // Second pass: Calculate compound taxes (taxes on taxes)
    for (final tax in taxes.where((t) => t.isActive && t.isCompound)) {
      final taxAmount = calculateTax(
        amount: subtotal + totalTax,
        tax: tax,
        isExempt: isExempt,
      );

      if (taxAmount > 0) {
        result[tax.id] = taxAmount;
        totalTax += taxAmount;
      }
    }

    return result;
  }

  /// Calculate the total tax amount
  static double calculateTotalTax({
    required double amount,
    required List<Tax> taxes,
    bool isExempt = false,
  }) {
    final taxMap = calculateTaxes(
      amount: amount,
      taxes: taxes,
      isExempt: isExempt,
    );

    return taxMap.values.fold(0.0, (sum, taxAmount) => sum + taxAmount);
  }

  /// Get the tax-inclusive total
  static double calculateTotalWithTax({
    required double amount,
    required List<Tax> taxes,
    bool isExempt = false,
  }) {
    final totalTax = calculateTotalTax(
      amount: amount,
      taxes: taxes,
      isExempt: isExempt,
    );

    return amount + totalTax;
  }
}

/// Class for common tax configurations for different countries
class TaxRegimes {
  /// Get default tax configuration for a specific country
  static List<Tax> getTaxesForCountry(String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'US':
        return _getUSTaxes();
      case 'CA':
        return _getCanadaTaxes();
      case 'GB':
        return _getUKTaxes();
      case 'AU':
        return _getAustraliaTaxes();
      case 'IN':
        return _getIndiaTaxes();
      default:
        return [];
    }
  }

  /// Get US sales tax configuration
  static List<Tax> _getUSTaxes() {
    return [
      Tax(
        id: 'us_sales_tax',
        name: 'Sales Tax',
        type: TaxType.salesTax,
        rate: 7.25, // Example rate - varies by state and locality
        jurisdiction: 'US',
        description: 'US Sales Tax varies by state and local jurisdiction',
      ),
    ];
  }

  /// Get Canadian tax configuration
  static List<Tax> _getCanadaTaxes() {
    return [
      Tax(
        id: 'ca_gst',
        name: 'GST',
        type: TaxType.gst,
        rate: 5.0,
        jurisdiction: 'CA',
        description: 'Canada Goods and Services Tax',
      ),
      Tax(
        id: 'ca_pst',
        name: 'PST',
        type: TaxType.salesTax,
        rate: 7.0, // Example rate - varies by province
        jurisdiction: 'CA-BC', // British Columbia example
        description: 'Provincial Sales Tax',
      ),
      Tax(
        id: 'ca_hst',
        name: 'HST',
        type: TaxType.gst,
        rate: 13.0, // Example rate - varies by province
        jurisdiction: 'CA-ON', // Ontario example
        description: 'Harmonized Sales Tax',
      ),
    ];
  }

  /// Get UK tax configuration
  static List<Tax> _getUKTaxes() {
    return [
      Tax(
        id: 'uk_vat_standard',
        name: 'Standard VAT',
        type: TaxType.vat,
        rate: 20.0,
        jurisdiction: 'GB',
        description: 'UK Value Added Tax - Standard Rate',
      ),
      Tax(
        id: 'uk_vat_reduced',
        name: 'Reduced VAT',
        type: TaxType.vat,
        rate: 5.0,
        jurisdiction: 'GB',
        description: 'UK Value Added Tax - Reduced Rate',
        isActive: false, // Not active by default
      ),
      Tax(
        id: 'uk_vat_zero',
        name: 'Zero Rate VAT',
        type: TaxType.vat,
        rate: 0.0,
        jurisdiction: 'GB',
        description: 'UK Value Added Tax - Zero Rate',
        isActive: false, // Not active by default
      ),
    ];
  }

  /// Get Australia tax configuration
  static List<Tax> _getAustraliaTaxes() {
    return [
      Tax(
        id: 'au_gst',
        name: 'GST',
        type: TaxType.gst,
        rate: 10.0,
        jurisdiction: 'AU',
        description: 'Australia Goods and Services Tax',
      ),
    ];
  }

  /// Get India tax configuration
  static List<Tax> _getIndiaTaxes() {
    return [
      Tax(
        id: 'in_gst',
        name: 'GST',
        type: TaxType.gst,
        rate: 18.0, // Example rate - varies by product/service category
        jurisdiction: 'IN',
        description: 'India Goods and Services Tax',
      ),
      Tax(
        id: 'in_cgst',
        name: 'CGST',
        type: TaxType.gst,
        rate: 9.0,
        jurisdiction: 'IN',
        description: 'Central GST',
        isActive: false, // Not active by default
      ),
      Tax(
        id: 'in_sgst',
        name: 'SGST',
        type: TaxType.gst,
        rate: 9.0,
        jurisdiction: 'IN',
        description: 'State GST',
        isActive: false, // Not active by default
      ),
    ];
  }
}
