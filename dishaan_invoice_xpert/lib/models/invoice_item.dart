
// lib/models/invoice_item.dart

class InvoiceItem {
  final int? id;
  final int? invoiceId;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double discountPercentage;
  final double taxPercentage;
  final double totalPrice;

  InvoiceItem({
    this.id,
    this.invoiceId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.discountPercentage = 0,
    this.taxPercentage = 0,
    required this.totalPrice,
  });

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      id: map['id'],
      invoiceId: map['invoice_id'],
      productId: map['product_id'],
      productName: map['product_name'],
      quantity: map['quantity'],
      unitPrice: map['unit_price'],
      discountPercentage: map['discount_percentage'] ?? 0,
      taxPercentage: map['tax_percentage'] ?? 0,
      totalPrice: map['total_price'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'discount_percentage': discountPercentage,
      'tax_percentage': taxPercentage,
      'total_price': totalPrice,
    };
  }
}

