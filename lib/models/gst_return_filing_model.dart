import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Model for GSTR-1 Return Filing
class GSTR1Return {
  final String financialYear;
  final String taxPeriod;
  final DateTime dueDate;
  final DateTime? filingDate;
  final String status; // PENDING, FILED, LATE
  final List<GSTR1Section> sections;

  GSTR1Return({
    required this.financialYear,
    required this.taxPeriod,
    required this.dueDate,
    this.filingDate,
    required this.status,
    required this.sections,
  });

  // Create from JSON
  factory GSTR1Return.fromJson(Map<String, dynamic> json) {
    return GSTR1Return(
      financialYear: json['financial_year'] as String,
      taxPeriod: json['tax_period'] as String,
      dueDate: DateTime.parse(json['due_date'] as String),
      filingDate: json['filing_date'] != null
          ? DateTime.parse(json['filing_date'] as String)
          : null,
      status: json['status'] as String,
      sections: (json['sections'] as List)
          .map((section) => GSTR1Section.fromJson(section))
          .toList(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'financial_year': financialYear,
      'tax_period': taxPeriod,
      'due_date': dueDate.toIso8601String(),
      'filing_date': filingDate?.toIso8601String(),
      'status': status,
      'sections': sections.map((section) => section.toJson()).toList(),
    };
  }

  // Get formatted due date
  String get formattedDueDate => DateFormat('dd MMM yyyy').format(dueDate);

  // Get formatted filing date
  String? get formattedFilingDate {
    if (filingDate == null) return null;
    return DateFormat('dd MMM yyyy').format(filingDate!);
  }

  // Check if return is due soon (within 5 days)
  bool get isDueSoon {
    if (status != 'PENDING') return false;

    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    return difference >= 0 && difference <= 5;
  }

  // Check if return is overdue
  bool get isOverdue {
    if (status != 'PENDING') return false;

    final now = DateTime.now();
    return now.isAfter(dueDate);
  }

  // Calculate the totals for GSTR-1
  Map<String, double> calculateTotals() {
    double totalTaxableValue = 0;
    double totalCGST = 0;
    double totalSGST = 0;
    double totalIGST = 0;
    double totalCess = 0;

    for (final section in sections) {
      for (final invoice in section.invoices) {
        totalTaxableValue += invoice.taxableValue;
        totalCGST += invoice.cgst;
        totalSGST += invoice.sgst;
        totalIGST += invoice.igst;
        totalCess += invoice.cess;
      }
    }

    return {
      'taxable_value': totalTaxableValue,
      'cgst': totalCGST,
      'sgst': totalSGST,
      'igst': totalIGST,
      'cess': totalCess,
      'total': totalTaxableValue + totalCGST + totalSGST + totalIGST + totalCess,
    };
  }
}

/// Model for GSTR-1 Section
class GSTR1Section {
  final String sectionName;
  final String sectionCode;
  final List<GSTR1Invoice> invoices;

  GSTR1Section({
    required this.sectionName,
    required this.sectionCode,
    required this.invoices,
  });

  // Create from JSON
  factory GSTR1Section.fromJson(Map<String, dynamic> json) {
    return GSTR1Section(
      sectionName: json['section_name'] as String,
      sectionCode: json['section_code'] as String,
      invoices: (json['invoices'] as List)
          .map((invoice) => GSTR1Invoice.fromJson(invoice))
          .toList(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'section_name': sectionName,
      'section_code': sectionCode,
      'invoices': invoices.map((invoice) => invoice.toJson()).toList(),
    };
  }

  // Calculate section totals
  Map<String, double> calculateTotals() {
    double totalTaxableValue = 0;
    double totalCGST = 0;
    double totalSGST = 0;
    double totalIGST = 0;
    double totalCess = 0;

    for (final invoice in invoices) {
      totalTaxableValue += invoice.taxableValue;
      totalCGST += invoice.cgst;
      totalSGST += invoice.sgst;
      totalIGST += invoice.igst;
      totalCess += invoice.cess;
    }

    return {
      'taxable_value': totalTaxableValue,
      'cgst': totalCGST,
      'sgst': totalSGST,
      'igst': totalIGST,
      'cess': totalCess,
      'total': totalTaxableValue + totalCGST + totalSGST + totalIGST + totalCess,
    };
  }
}

/// Model for GSTR-1 Invoice
class GSTR1Invoice {
  final String invoiceNumber;
  final DateTime invoiceDate;
  final String? customerGstin;
  final String placeOfSupply;
  final bool reverseCharge;
  final String invoiceType; // B2B, B2C
  final double taxableValue;
  final double cgst;
  final double sgst;
  final double igst;
  final double cess;
  final String? ecommOperator;

  GSTR1Invoice({
    required this.invoiceNumber,
    required this.invoiceDate,
    this.customerGstin,
    required this.placeOfSupply,
    required this.reverseCharge,
    required this.invoiceType,
    required this.taxableValue,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.cess,
    this.ecommOperator,
  });

  // Create from JSON
  factory GSTR1Invoice.fromJson(Map<String, dynamic> json) {
    return GSTR1Invoice(
      invoiceNumber: json['invoice_number'] as String,
      invoiceDate: DateTime.parse(json['invoice_date'] as String),
      customerGstin: json['customer_gstin'] as String?,
      placeOfSupply: json['place_of_supply'] as String,
      reverseCharge: json['reverse_charge'] as bool,
      invoiceType: json['invoice_type'] as String,
      taxableValue: json['taxable_value'] as double,
      cgst: json['cgst'] as double,
      sgst: json['sgst'] as double,
      igst: json['igst'] as double,
      cess: json['cess'] as double,
      ecommOperator: json['ecomm_operator'] as String?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate.toIso8601String(),
      'customer_gstin': customerGstin,
      'place_of_supply': placeOfSupply,
      'reverse_charge': reverseCharge,
      'invoice_type': invoiceType,
      'taxable_value': taxableValue,
      'cgst': cgst,
      'sgst': sgst,
      'igst': igst,
      'cess': cess,
      'ecomm_operator': ecommOperator,
    };
  }

  // Get formatted invoice date
  String get formattedInvoiceDate => DateFormat('dd/MM/yyyy').format(invoiceDate);

  // Get total invoice value
  double get totalValue => taxableValue + cgst + sgst + igst + cess;
}

/// Model for GSTR-3B Return Filing
class GSTR3BReturn {
  final String financialYear;
  final String taxPeriod;
  final DateTime dueDate;
  final DateTime? filingDate;
  final String status; // PENDING, FILED, LATE
  final GSTR3BData? returnData;

  GSTR3BReturn({
    required this.financialYear,
    required this.taxPeriod,
    required this.dueDate,
    this.filingDate,
    required this.status,
    this.returnData,
  });

  // Create from JSON
  factory GSTR3BReturn.fromJson(Map<String, dynamic> json) {
    return GSTR3BReturn(
      financialYear: json['financial_year'] as String,
      taxPeriod: json['tax_period'] as String,
      dueDate: DateTime.parse(json['due_date'] as String),
      filingDate: json['filing_date'] != null
          ? DateTime.parse(json['filing_date'] as String)
          : null,
      status: json['status'] as String,
      returnData: json['return_data'] != null
          ? GSTR3BData.fromJson(json['return_data'])
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'financial_year': financialYear,
      'tax_period': taxPeriod,
      'due_date': dueDate.toIso8601String(),
      'filing_date': filingDate?.toIso8601String(),
      'status': status,
      'return_data': returnData?.toJson(),
    };
  }

  // Get formatted due date
  String get formattedDueDate => DateFormat('dd MMM yyyy').format(dueDate);

  // Get formatted filing date
  String? get formattedFilingDate {
    if (filingDate == null) return null;
    return DateFormat('dd MMM yyyy').format(filingDate!);
  }

  // Check if return is due soon (within 5 days)
  bool get isDueSoon {
    if (status != 'PENDING') return false;

    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    return difference >= 0 && difference <= 5;
  }

  // Check if return is overdue
  bool get isOverdue {
    if (status != 'PENDING') return false;

    final now = DateTime.now();
    return now.isAfter(dueDate);
  }
}

/// Model for GSTR-3B Data
class GSTR3BData {
  final GSTR3BOutwardSupplies outwardSupplies;
  final GSTR3BInwardSupplies inwardSupplies;
  final GSTR3BItcDetails itcDetails;
  final double interestPayable;
  final double lateFee;

  GSTR3BData({
    required this.outwardSupplies,
    required this.inwardSupplies,
    required this.itcDetails,
    required this.interestPayable,
    required this.lateFee,
  });

  // Create from JSON
  factory GSTR3BData.fromJson(Map<String, dynamic> json) {
    return GSTR3BData(
      outwardSupplies: GSTR3BOutwardSupplies.fromJson(json['outward_supplies']),
      inwardSupplies: GSTR3BInwardSupplies.fromJson(json['inward_supplies']),
      itcDetails: GSTR3BItcDetails.fromJson(json['itc_details']),
      interestPayable: json['interest_payable'] as double,
      lateFee: json['late_fee'] as double,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'outward_supplies': outwardSupplies.toJson(),
      'inward_supplies': inwardSupplies.toJson(),
      'itc_details': itcDetails.toJson(),
      'interest_payable': interestPayable,
      'late_fee': lateFee,
    };
  }

  // Calculate total tax liability
  double calculateTotalTaxLiability() {
    return outwardSupplies.totalTax + inwardSupplies.totalReverseTaxLiability;
  }

  // Calculate total tax payable
  double calculateTotalTaxPayable() {
    final totalLiability = calculateTotalTaxLiability();
    final totalITC = itcDetails.totalITC;
    return totalLiability > totalITC ? totalLiability - totalITC : 0;
  }

  // Calculate total amount payable
  double calculateTotalAmountPayable() {
    return calculateTotalTaxPayable() + interestPayable + lateFee;
  }
}

/// Model for GSTR-3B Outward Supplies
class GSTR3BOutwardSupplies {
  final double taxableValueInterstate;
  final double igstInterstate;
  final double taxableValueIntrastate;
  final double cgstIntrastate;
  final double sgstIntrastate;
  final double taxableValueZeroRated;

  GSTR3BOutwardSupplies({
    required this.taxableValueInterstate,
    required this.igstInterstate,
    required this.taxableValueIntrastate,
    required this.cgstIntrastate,
    required this.sgstIntrastate,
    required this.taxableValueZeroRated,
  });

  // Create from JSON
  factory GSTR3BOutwardSupplies.fromJson(Map<String, dynamic> json) {
    return GSTR3BOutwardSupplies(
      taxableValueInterstate: json['taxable_value_interstate'] as double,
      igstInterstate: json['igst_interstate'] as double,
      taxableValueIntrastate: json['taxable_value_intrastate'] as double,
      cgstIntrastate: json['cgst_intrastate'] as double,
      sgstIntrastate: json['sgst_intrastate'] as double,
      taxableValueZeroRated: json['taxable_value_zero_rated'] as double,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'taxable_value_interstate': taxableValueInterstate,
      'igst_interstate': igstInterstate,
      'taxable_value_intrastate': taxableValueIntrastate,
      'cgst_intrastate': cgstIntrastate,
      'sgst_intrastate': sgstIntrastate,
      'taxable_value_zero_rated': taxableValueZeroRated,
    };
  }

  // Calculate total taxable value
  double get totalTaxableValue {
    return taxableValueInterstate + taxableValueIntrastate + taxableValueZeroRated;
  }

  // Calculate total tax
  double get totalTax {
    return igstInterstate + cgstIntrastate + sgstIntrastate;
  }
}

/// Model for GSTR-3B Inward Supplies
class GSTR3BInwardSupplies {
  final double taxableValueRCM;
  final double igstRCM;
  final double cgstRCM;
  final double sgstRCM;

  GSTR3BInwardSupplies({
    required this.taxableValueRCM,
    required this.igstRCM,
    required this.cgstRCM,
    required this.sgstRCM,
  });

  // Create from JSON
  factory GSTR3BInwardSupplies.fromJson(Map<String, dynamic> json) {
    return GSTR3BInwardSupplies(
      taxableValueRCM: json['taxable_value_rcm'] as double,
      igstRCM: json['igst_rcm'] as double,
      cgstRCM: json['cgst_rcm'] as double,
      sgstRCM: json['sgst_rcm'] as double,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'taxable_value_rcm': taxableValueRCM,
      'igst_rcm': igstRCM,
      'cgst_rcm': cgstRCM,
      'sgst_rcm': sgstRCM,
    };
  }

  // Calculate total reverse charge tax liability
  double get totalReverseTaxLiability {
    return igstRCM + cgstRCM + sgstRCM;
  }
}

/// Model for GSTR-3B ITC Details
class GSTR3BItcDetails {
  final double igstITC;
  final double cgstITC;
  final double sgstITC;
  final double cessITC;

  GSTR3BItcDetails({
    required this.igstITC,
    required this.cgstITC,
    required this.sgstITC,
    required this.cessITC,
  });

  // Create from JSON
  factory GSTR3BItcDetails.fromJson(Map<String, dynamic> json) {
    return GSTR3BItcDetails(
      igstITC: json['igst_itc'] as double,
      cgstITC: json['cgst_itc'] as double,
      sgstITC: json['sgst_itc'] as double,
      cessITC: json['cess_itc'] as double,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'igst_itc': igstITC,
      'cgst_itc': cgstITC,
      'sgst_itc': sgstITC,
      'cess_itc': cessITC,
    };
  }

  // Calculate total ITC
  double get totalITC {
    return igstITC + cgstITC + sgstITC + cessITC;
  }
}

/// Model for GST Return Filing Calendar
class GSTReturnCalendar {
  final List<GSTReturnDue> upcomingReturns;
  final List<GSTReturnDue> pastReturns;

  GSTReturnCalendar({
    required this.upcomingReturns,
    required this.pastReturns,
  });

  // Create from JSON
  factory GSTReturnCalendar.fromJson(Map<String, dynamic> json) {
    return GSTReturnCalendar(
      upcomingReturns: (json['upcoming_returns'] as List)
          .map((item) => GSTReturnDue.fromJson(item))
          .toList(),
      pastReturns: (json['past_returns'] as List)
          .map((item) => GSTReturnDue.fromJson(item))
          .toList(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'upcoming_returns': upcomingReturns.map((item) => item.toJson()).toList(),
      'past_returns': pastReturns.map((item) => item.toJson()).toList(),
    };
  }
}

/// Model for GST Return Due Date
class GSTReturnDue {
  final String returnType; // GSTR-1, GSTR-3B
  final String financialYear;
  final String taxPeriod;
  final DateTime dueDate;
  final String status; // PENDING, FILED, LATE

  GSTReturnDue({
    required this.returnType,
    required this.financialYear,
    required this.taxPeriod,
    required this.dueDate,
    required this.status,
  });

  // Create from JSON
  factory GSTReturnDue.fromJson(Map<String, dynamic> json) {
    return GSTReturnDue(
      returnType: json['return_type'] as String,
      financialYear: json['financial_year'] as String,
      taxPeriod: json['tax_period'] as String,
      dueDate: DateTime.parse(json['due_date'] as String),
      status: json['status'] as String,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'return_type': returnType,
      'financial_year': financialYear,
      'tax_period': taxPeriod,
      'due_date': dueDate.toIso8601String(),
      'status': status,
    };
  }

  // Get formatted due date
  String get formattedDueDate => DateFormat('dd MMM yyyy').format(dueDate);

  // Check if return is due soon (within 5 days)
  bool get isDueSoon {
    if (status != 'PENDING') return false;

    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    return difference >= 0 && difference <= 5;
  }

  // Check if return is overdue
  bool get isOverdue {
    if (status != 'PENDING') return false;

    final now = DateTime.now();
    return now.isAfter(dueDate);
  }

  // Get days until due
  int get daysUntilDue {
    final now = DateTime.now();
    return dueDate.difference(now).inDays;
  }

  // Get color for status
  Color get statusColor {
    if (status == 'FILED') return Colors.green;
    if (status == 'LATE') return Colors.red;
    if (isOverdue) return Colors.red;
    if (isDueSoon) return Colors.orange;
    return Colors.blue;
  }

  // Get icon for status
  IconData get statusIcon {
    if (status == 'FILED') return Icons.check_circle;
    if (status == 'LATE') return Icons.error;
    if (isOverdue) return Icons.warning;
    if (isDueSoon) return Icons.access_time;
    return Icons.event;
  }
}
