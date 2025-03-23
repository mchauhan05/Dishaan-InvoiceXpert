import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For currency and date formatting

// Invoice Status types
enum InvoiceStatus {
  draft,
  sent,
  viewed,
  paid,
  partiallyPaid,
  overdue,
  // void,
  deleted
}

// Payment Terms options
enum PaymentTerms { dueOnReceipt, net15, net30, net45, net60, custom }

// Invoice Item model
class InvoiceItem {
  String id;
  String name;
  String description;
  double quantity;
  double unitPrice;
  double tax; // Tax percentage
  bool taxable;
  String additionalInfo;

  InvoiceItem({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.tax = 0.0,
    this.taxable = false,
    this.additionalInfo = '',
  });

  // Calculate the amount
  double get amount => quantity * unitPrice;

  // Calculate tax amount
  double get taxAmount => taxable ? amount * (tax / 100) : 0.0;

  // Calculate total with tax
  double get total => amount + taxAmount;

  // Create a copy with updated values
  InvoiceItem copyWith({
    String? id,
    String? name,
    String? description,
    double? quantity,
    double? unitPrice,
    double? tax,
    bool? taxable,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      tax: tax ?? this.tax,
      taxable: taxable ?? this.taxable,
    );
  }
}

// **Customer Model**
class InvoiceCustomer {
  String id;
  String name;
  String email;
  String company;
  String address;
  String city;
  String state;
  String zipCode;
  String country;
  String billingAddress;
  String shippingAddress;
  String phone;

  InvoiceCustomer({
    required this.id,
    required this.name,
    required this.email,
    required this.billingAddress,
    this.shippingAddress = '',
    this.company = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.zipCode = '',
    this.country = '',
    required this.phone,
  });

  bool get hasCompany => company.isNotEmpty;
}

// **Invoice Model**
class Invoice {
  String id;
  String invoiceNumber;
  DateTime date;
  DateTime dueDate;
  InvoiceStatus status;
  InvoiceCustomer customer;
  List<InvoiceItem> items;
  PaymentTerms paymentTerms;
  String notes;
  String terms;
  double discountAmount;
  double discountPercent;
  double taxAmount;
  double taxRate;
  double amountPaid;
  double adjustmentValue; // For additional discounts or charges
  bool isAdjustmentPercentage; // Whether adjustment is % or fixed amount
  bool isAdjustmentPositive; // Whether it's a charge or discount

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.date,
    required this.dueDate,
    required this.status,
    required this.customer,
    required this.items,
    this.paymentTerms = PaymentTerms.dueOnReceipt,
    this.notes = '',
    this.terms = '',
    this.discountAmount = 0.0,
    this.discountPercent = 0.0,
    this.taxAmount = 0.0,
    this.taxRate = 0.0,
    this.amountPaid = 0.0,
    this.adjustmentValue = 0.0,
    this.isAdjustmentPercentage = false,
    this.isAdjustmentPositive = true,
  });

  // Calculate subtotal before tax
  double get subtotal => items.fold(0, (sum, item) => sum + item.amount);

  // Calculate total tax
  double get totalTax => items.fold(0, (sum, item) => sum + item.taxAmount);

  // Calculate discount based on percentage
  double get discount => subtotal * (discountPercent / 100) + discountAmount;

  // Calculate total after tax and discount
  double get total => subtotal + totalTax - discount;

  // Calculate adjustment amount
  double get adjustmentAmount {
    if (isAdjustmentPercentage) {
      return subtotal *
          (adjustmentValue / 100) *
          (isAdjustmentPositive ? 1 : -1);
    } else {
      return adjustmentValue * (isAdjustmentPositive ? 1 : -1);
    }
  }

  // Calculate grand total
  // double get total => subtotal + totalTax + adjustmentAmount;

  // Get status display text
  String get statusText {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.sent:
        return 'Sent';
      case InvoiceStatus.viewed:
        return 'Viewed';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.partiallyPaid:
        return 'Partially Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      // case InvoiceStatus.void:
      //   return 'Void';
      case InvoiceStatus.deleted:
        return 'Deleted';
      default:
        return 'Unknown';
    }
  }

  // Get status color
  Color get statusColor {
    switch (status) {
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.sent:
        return Colors.blue;
      case InvoiceStatus.viewed:
        return Colors.purple;
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.partiallyPaid:
        return Colors.orange;
      case InvoiceStatus.overdue:
        return Colors.red;
      // case InvoiceStatus.void:
      //   return Colors.blueGrey;
      case InvoiceStatus.deleted:
        return Colors.black45;
      default:
        return Colors.grey;
    }
  }

  // Get payment terms display text
  String get paymentTermsText {
    switch (paymentTerms) {
      case PaymentTerms.dueOnReceipt:
        return 'Due on Receipt';
      case PaymentTerms.net15:
        return 'Net 15';
      case PaymentTerms.net30:
        return 'Net 30';
      case PaymentTerms.net45:
        return 'Net 45';
      case PaymentTerms.net60:
        return 'Net 60';
      case PaymentTerms.custom:
        return 'Custom';
      default:
        return 'Due on Receipt';
    }
  }

  double calculateTotal() {
    return subtotal + totalTax + adjustmentAmount;
  }
}
