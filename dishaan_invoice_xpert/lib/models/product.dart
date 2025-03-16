
// lib/models/product.dart

class Product {
  final int? id;
  final String? barcode;
  final String name;
  final String? description;
  final int? categoryId;
  final double costPrice;
  final double sellingPrice;
  final int currentStock;
  final int minStockAlert;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    this.id,
    this.barcode,
    required this.name,
    this.description,
    this.categoryId,
    required this.costPrice,
    required this.sellingPrice,
    this.currentStock = 0,
    this.minStockAlert = 5,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      barcode: map['barcode'],
      name: map['name'],
      description: map['description'],
      categoryId: map['category_id'],
      costPrice: map['cost_price'],
      sellingPrice: map['selling_price'],
      currentStock: map['current_stock'] ?? 0,
      minStockAlert: map['min_stock_alert'] ?? 5,
      isActive: map['is_active'] == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'barcode': barcode,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'current_stock': currentStock,
      'min_stock_alert': minStockAlert,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Product copyWith({
    int? id,
    String? barcode,
    String? name,
    String? description,
    int? categoryId,
    double? costPrice,
    double? sellingPrice,
    int? currentStock,
    int? minStockAlert,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      currentStock: currentStock ?? this.currentStock,
      minStockAlert: minStockAlert ?? this.minStockAlert,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Check if product is low on stock
  bool get isLowStock => currentStock <= minStockAlert;

  // Calculate profit margin
  double get profitMargin => sellingPrice - costPrice;

  // Calculate profit margin percentage
  double get profitMarginPercentage =>
      costPrice > 0 ? ((sellingPrice - costPrice) / costPrice) * 100 : 0;
}

