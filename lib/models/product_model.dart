import 'package:flutter/material.dart';

enum ProductType {
  goods,
  service
}

enum TaxType {
  taxable,
  nonTaxable,
  exempt
}

enum InventoryTracking {
  track,
  dontTrack
}

class Product {
  final String id;
  final String sku;
  final String barcode;
  final String name;
  final String description;
  final double sellingPrice;
  final double? costPrice;
  final double? weight;
  final String? unit;
  final String? dimensions;
  final String? manufacturer;
  final String? brand;
  final ProductType type;
  final TaxType taxType;
  final double? taxRate;
  final String? category;
  final InventoryTracking inventoryTracking;
  final int? stockQuantity;
  final int? lowStockAlert;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.sku,
    required this.barcode,
    required this.name,
    required this.description,
    required this.sellingPrice,
    this.costPrice,
    this.weight,
    this.unit,
    this.dimensions,
    this.manufacturer,
    this.brand,
    required this.type,
    required this.taxType,
    this.taxRate,
    this.category,
    required this.inventoryTracking,
    this.stockQuantity,
    this.lowStockAlert,
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate profit margin
  double? get profitMargin {
    if (costPrice == null || costPrice == 0) return null;
    return ((sellingPrice - costPrice!) / sellingPrice) * 100;
  }

  // Check if stock is low
  bool get isLowStock {
    if (inventoryTracking == InventoryTracking.dontTrack) return false;
    if (stockQuantity == null || lowStockAlert == null) return false;
    return stockQuantity! <= lowStockAlert!;
  }

  // Get stock status text
  String get stockStatus {
    if (inventoryTracking == InventoryTracking.dontTrack) return 'Not Tracked';
    if (stockQuantity == null) return 'Unknown';
    if (stockQuantity! <= 0) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    return 'In Stock';
  }

  // Get stock status color
  Color get stockStatusColor {
    if (inventoryTracking == InventoryTracking.dontTrack) return Colors.grey;
    if (stockQuantity == null) return Colors.grey;
    if (stockQuantity! <= 0) return Colors.red;
    if (isLowStock) return Colors.orange;
    return Colors.green;
  }

  // Get formatted barcode for display
  String get formattedBarcode {
    if (barcode.length <= 8) return barcode;

    // Format longer barcodes with spaces for readability
    final List<String> parts = [];
    for (int i = 0; i < barcode.length; i += 4) {
      final end = (i + 4 < barcode.length) ? i + 4 : barcode.length;
      parts.add(barcode.substring(i, end));
    }
    return parts.join(' ');
  }

  // Get tax status text
  String get taxStatusText {
    switch (taxType) {
      case TaxType.taxable:
        return taxRate != null ? 'Taxable (${taxRate!.toStringAsFixed(2)}%)' : 'Taxable';
      case TaxType.nonTaxable:
        return 'Non-taxable';
      case TaxType.exempt:
        return 'Tax Exempt';
      default:
        return 'Unknown';
    }
  }

  // Create a copy with updated fields
  Product copyWith({
    String? id,
    String? sku,
    String? barcode,
    String? name,
    String? description,
    double? sellingPrice,
    double? costPrice,
    double? weight,
    String? unit,
    String? dimensions,
    String? manufacturer,
    String? brand,
    ProductType? type,
    TaxType? taxType,
    double? taxRate,
    String? category,
    InventoryTracking? inventoryTracking,
    int? stockQuantity,
    int? lowStockAlert,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      description: description ?? this.description,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      costPrice: costPrice ?? this.costPrice,
      weight: weight ?? this.weight,
      unit: unit ?? this.unit,
      dimensions: dimensions ?? this.dimensions,
      manufacturer: manufacturer ?? this.manufacturer,
      brand: brand ?? this.brand,
      type: type ?? this.type,
      taxType: taxType ?? this.taxType,
      taxRate: taxRate ?? this.taxRate,
      category: category ?? this.category,
      inventoryTracking: inventoryTracking ?? this.inventoryTracking,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockAlert: lowStockAlert ?? this.lowStockAlert,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
