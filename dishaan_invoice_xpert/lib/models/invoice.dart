// lib/models/invoice.dart

import 'invoice_item.dart';

class Invoice {
  final int? id;
  final String invoiceNumber;
  final int? customerId;
  final double subtotal;
  final double discountPercentage;
  final double discountAmount;
  final double taxPercentage;
  final double taxAmount;
  final double totalAmount;
  final String? paymentMethod;
  final String paymentStatus;
  final String? notes;
  final DateTime createdAt;
  final List<InvoiceItem> items;

  Invoice({
    this.id,
    required this.invoiceNumber,
    this.customerId,
    required this.subtotal,
    this.discountPercentage = 0,
    this.discountAmount = 0,
    this.taxPercentage = 0,
    this.taxAmount = 0,
    required this.totalAmount,
    this.paymentMethod,
    this.paymentStatus = 'PAID',
    this.notes,
    DateTime? createdAt,
    this.items = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  factory Invoice.fromMap(Map<String, dynamic> map, {List<InvoiceItem>? items}) {
    return Invoice(
      id: map['id'],
      invoiceNumber: map['invoice_number'],
      customerId: map['customer_id'],
      subtotal: map['subtotal'],
      discountPercentage: map['discount_percentage'] ?? 0,
      discountAmount: map['discount_amount'] ?? 0,
      taxPercentage: map['tax_percentage'] ?? 0,
      taxAmount: map['tax_amount'] ?? 0,
      totalAmount: map['total_amount'],
      paymentMethod: map['payment_method'],
      paymentStatus: map['payment_status'] ?? 'PAID',
      notes: map['notes'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      items: items ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'invoice_number': invoiceNumber,
      'customer_id': customerId,
      'subtotal': subtotal,
      'discount_percentage': discountPercentage,
      'discount_amount': discountAmount,
      'tax_percentage': taxPercentage,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
