import 'package:flutter/material.dart';

/// GSTIN (Goods and Services Tax Identification Number) validator helper
class GSTINValidator {
  /// Validates a GSTIN number
  /// Format: 2 digit state code + 10 digit PAN + 1 digit entity number + 1 digit checksum Z
  static bool isValid(String gstin) {
    if (gstin.isEmpty) return false;

    // Basic pattern matching
    RegExp gstinPattern = RegExp(r'^\d{2}[A-Z]{5}\d{4}[A-Z]{1}[A-Z\d]{1}[Z]{1}[A-Z\d]{1}$');
    return gstinPattern.hasMatch(gstin);
  }

  /// Get state code from GSTIN
  static String? getStateCode(String gstin) {
    if (!isValid(gstin)) return null;
    return gstin.substring(0, 2);
  }

  /// Get PAN from GSTIN
  static String? getPAN(String gstin) {
    if (!isValid(gstin)) return null;
    return gstin.substring(2, 12);
  }

  /// Get state name from state code
  static String? getStateName(String stateCode) {
    final Map<String, String> stateCodes = {
      '01': 'Jammu and Kashmir',
      '02': 'Himachal Pradesh',
      '03': 'Punjab',
      '04': 'Chandigarh',
      '05': 'Uttarakhand',
      '06': 'Haryana',
      '07': 'Delhi',
      '08': 'Rajasthan',
      '09': 'Uttar Pradesh',
      '10': 'Bihar',
      '11': 'Sikkim',
      '12': 'Arunachal Pradesh',
      '13': 'Nagaland',
      '14': 'Manipur',
      '15': 'Mizoram',
      '16': 'Tripura',
      '17': 'Meghalaya',
      '18': 'Assam',
      '19': 'West Bengal',
      '20': 'Jharkhand',
      '21': 'Odisha',
      '22': 'Chhattisgarh',
      '23': 'Madhya Pradesh',
      '24': 'Gujarat',
      '26': 'Dadra and Nagar Haveli and Daman and Diu',
      '27': 'Maharashtra',
      '28': 'Andhra Pradesh',
      '29': 'Karnataka',
      '30': 'Goa',
      '31': 'Lakshadweep',
      '32': 'Kerala',
      '33': 'Tamil Nadu',
      '34': 'Puducherry',
      '35': 'Andaman and Nicobar Islands',
      '36': 'Telangana',
      '37': 'Andhra Pradesh (New)',
      '38': 'Ladakh',
    };

    return stateCodes[stateCode];
  }
}

/// HSN code (Harmonized System of Nomenclature) for products
class HSNCode {
  final String code;
  final String description;
  final double gstRate; // Standard GST rate for this HSN code

  HSNCode({
    required this.code,
    required this.description,
    required this.gstRate,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'description': description,
      'gstRate': gstRate,
    };
  }

  /// Create from JSON
  factory HSNCode.fromJson(Map<String, dynamic> json) {
    return HSNCode(
      code: json['code'],
      description: json['description'],
      gstRate: json['gstRate'],
    );
  }
}

/// Indian GST Invoice extensions
class GSTInvoiceDetails {
  final String? sellerGstin;
  final String? buyerGstin;
  final String? placeOfSupply; // State code
  final bool isInterState;
  final bool reverseCharge;
  final String? eCommerceGstin;
  final bool exportInvoice;
  final String? shippingBillNumber;
  final DateTime? shippingBillDate;
  final String? portCode;
  final String? invoiceType; // Regular, SEZ, Export, etc.

  // GST breakdown
  final double? cgstAmount;
  final double? sgstAmount;
  final double? igstAmount;
  final double? cessAmount;

  GSTInvoiceDetails({
    this.sellerGstin,
    this.buyerGstin,
    this.placeOfSupply,
    this.isInterState = false,
    this.reverseCharge = false,
    this.eCommerceGstin,
    this.exportInvoice = false,
    this.shippingBillNumber,
    this.shippingBillDate,
    this.portCode,
    this.invoiceType = 'Regular',
    this.cgstAmount,
    this.sgstAmount,
    this.igstAmount,
    this.cessAmount,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'sellerGstin': sellerGstin,
      'buyerGstin': buyerGstin,
      'placeOfSupply': placeOfSupply,
      'isInterState': isInterState,
      'reverseCharge': reverseCharge,
      'eCommerceGstin': eCommerceGstin,
      'exportInvoice': exportInvoice,
      'shippingBillNumber': shippingBillNumber,
      'shippingBillDate': shippingBillDate?.toIso8601String(),
      'portCode': portCode,
      'invoiceType': invoiceType,
      'cgstAmount': cgstAmount,
      'sgstAmount': sgstAmount,
      'igstAmount': igstAmount,
      'cessAmount': cessAmount,
    };
  }

  /// Create from JSON
  factory GSTInvoiceDetails.fromJson(Map<String, dynamic> json) {
    return GSTInvoiceDetails(
      sellerGstin: json['sellerGstin'],
      buyerGstin: json['buyerGstin'],
      placeOfSupply: json['placeOfSupply'],
      isInterState: json['isInterState'] ?? false,
      reverseCharge: json['reverseCharge'] ?? false,
      eCommerceGstin: json['eCommerceGstin'],
      exportInvoice: json['exportInvoice'] ?? false,
      shippingBillNumber: json['shippingBillNumber'],
      shippingBillDate: json['shippingBillDate'] != null
          ? DateTime.parse(json['shippingBillDate'])
          : null,
      portCode: json['portCode'],
      invoiceType: json['invoiceType'] ?? 'Regular',
      cgstAmount: json['cgstAmount'],
      sgstAmount: json['sgstAmount'],
      igstAmount: json['igstAmount'],
      cessAmount: json['cessAmount'],
    );
  }

  /// Create a copy with updated fields
  GSTInvoiceDetails copyWith({
    String? sellerGstin,
    String? buyerGstin,
    String? placeOfSupply,
    bool? isInterState,
    bool? reverseCharge,
    String? eCommerceGstin,
    bool? exportInvoice,
    String? shippingBillNumber,
    DateTime? shippingBillDate,
    String? portCode,
    String? invoiceType,
    double? cgstAmount,
    double? sgstAmount,
    double? igstAmount,
    double? cessAmount,
  }) {
    return GSTInvoiceDetails(
      sellerGstin: sellerGstin ?? this.sellerGstin,
      buyerGstin: buyerGstin ?? this.buyerGstin,
      placeOfSupply: placeOfSupply ?? this.placeOfSupply,
      isInterState: isInterState ?? this.isInterState,
      reverseCharge: reverseCharge ?? this.reverseCharge,
      eCommerceGstin: eCommerceGstin ?? this.eCommerceGstin,
      exportInvoice: exportInvoice ?? this.exportInvoice,
      shippingBillNumber: shippingBillNumber ?? this.shippingBillNumber,
      shippingBillDate: shippingBillDate ?? this.shippingBillDate,
      portCode: portCode ?? this.portCode,
      invoiceType: invoiceType ?? this.invoiceType,
      cgstAmount: cgstAmount ?? this.cgstAmount,
      sgstAmount: sgstAmount ?? this.sgstAmount,
      igstAmount: igstAmount ?? this.igstAmount,
      cessAmount: cessAmount ?? this.cessAmount,
    );
  }

  /// Get total GST amount
  double get totalGstAmount {
    double total = 0.0;
    if (cgstAmount != null) total += cgstAmount!;
    if (sgstAmount != null) total += sgstAmount!;
    if (igstAmount != null) total += igstAmount!;
    if (cessAmount != null) total += cessAmount!;
    return total;
  }
}

/// Extension to product model for Indian GST
class ProductGSTDetails {
  final String? hsnCode;
  final String? sacCode; // For services
  final double? cgstRate;
  final double? sgstRate;
  final double? igstRate;
  final double? cessRate;

  ProductGSTDetails({
    this.hsnCode,
    this.sacCode,
    this.cgstRate,
    this.sgstRate,
    this.igstRate,
    this.cessRate,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'hsnCode': hsnCode,
      'sacCode': sacCode,
      'cgstRate': cgstRate,
      'sgstRate': sgstRate,
      'igstRate': igstRate,
      'cessRate': cessRate,
    };
  }

  /// Create from JSON
  factory ProductGSTDetails.fromJson(Map<String, dynamic> json) {
    return ProductGSTDetails(
      hsnCode: json['hsnCode'],
      sacCode: json['sacCode'],
      cgstRate: json['cgstRate'],
      sgstRate: json['sgstRate'],
      igstRate: json['igstRate'],
      cessRate: json['cessRate'],
    );
  }

  /// Create a copy with updated fields
  ProductGSTDetails copyWith({
    String? hsnCode,
    String? sacCode,
    double? cgstRate,
    double? sgstRate,
    double? igstRate,
    double? cessRate,
  }) {
    return ProductGSTDetails(
      hsnCode: hsnCode ?? this.hsnCode,
      sacCode: sacCode ?? this.sacCode,
      cgstRate: cgstRate ?? this.cgstRate,
      sgstRate: sgstRate ?? this.sgstRate,
      igstRate: igstRate ?? this.igstRate,
      cessRate: cessRate ?? this.cessRate,
    );
  }
}
