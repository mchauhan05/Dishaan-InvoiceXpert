import 'dart:math';

import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/database_service.dart';

class ProductProvider extends ChangeNotifier {
  // List of products
  List<Product> _products = [];

  // Categories
  final List<String> _categories = [
    'Electronics',
    'Furniture',
    'Clothing',
    'Food & Beverages',
    'Office Supplies',
    'Software',
    'Hardware',
    'Accessories',
    'Books',
    'Services',
  ];

  // Currently selected product
  Product? _currentProduct;

  // Loading state
  bool _isLoading = false;

  // Error state
  String? _error;

  // Stock history log
  final List<StockHistoryEntry> _stockHistory = [];

  // Getters
  List<Product> get products => _products;
  Product? get currentProduct => _currentProduct;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<StockHistoryEntry> get stockHistory => _stockHistory;

  // Constructor with sample data
  ProductProvider() {
    _loadData();
  }

  // Load data from storage or initialize with sample data
  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Try to load existing data first
      final List<Product> loadedProducts = await DatabaseService.loadProducts();

      if (loadedProducts.isNotEmpty) {
        _products = loadedProducts;
      } else {
        await _loadSampleProducts();
      }

      _error = null;
    } catch (e) {
      _error = 'Failed to load product data: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load sample products
  Future<void> _loadSampleProducts() async {
    final now = DateTime.now();

    _products = [
      Product(
        id: 'PROD-001',
        sku: 'LT-001',
        barcode: '7890123456789',
        name: 'Laptop Pro 15"',
        description: 'High performance laptop with 16GB RAM and 512GB SSD',
        sellingPrice: 1299.99,
        costPrice: 899.99,
        weight: 2.1,
        unit: 'piece',
        dimensions: '36 x 25 x 1.8 cm',
        manufacturer: 'TechCorp',
        brand: 'ProBook',
        type: ProductType.goods,
        taxType: TaxType.taxable,
        taxRate: 7.5,
        category: 'Electronics',
        inventoryTracking: InventoryTracking.track,
        stockQuantity: 25,
        lowStockAlert: 5,
        imageUrl: 'https://example.com/images/laptop-pro.jpg',
        createdAt: now.subtract(const Duration(days: 100)),
        updatedAt: now.subtract(const Duration(days: 30)),
      ),
      Product(
        id: 'PROD-002',
        sku: 'MB-002',
        barcode: '9876543210987',
        name: 'Wireless Mouse',
        description: 'Ergonomic wireless mouse with long battery life',
        sellingPrice: 49.99,
        costPrice: 22.50,
        weight: 0.12,
        unit: 'piece',
        dimensions: '10 x 6 x 3.5 cm',
        manufacturer: 'PeripheralTech',
        brand: 'ComfortPoint',
        type: ProductType.goods,
        taxType: TaxType.taxable,
        taxRate: 7.5,
        category: 'Electronics',
        inventoryTracking: InventoryTracking.track,
        stockQuantity: 42,
        lowStockAlert: 10,
        imageUrl: 'https://example.com/images/wireless-mouse.jpg',
        createdAt: now.subtract(const Duration(days: 75)),
        updatedAt: now.subtract(const Duration(days: 15)),
      ),
      Product(
        id: 'PROD-003',
        sku: 'KB-003',
        barcode: '1234567890123',
        name: 'Mechanical Keyboard',
        description: 'RGB backlit mechanical keyboard with Cherry MX switches',
        sellingPrice: 129.99,
        costPrice: 75.00,
        weight: 1.1,
        unit: 'piece',
        dimensions: '44 x 14 x 4 cm',
        manufacturer: 'PeripheralTech',
        brand: 'KeyMaster',
        type: ProductType.goods,
        taxType: TaxType.taxable,
        taxRate: 7.5,
        category: 'Electronics',
        inventoryTracking: InventoryTracking.track,
        stockQuantity: 0,
        lowStockAlert: 5,
        imageUrl: 'https://example.com/images/mechanical-keyboard.jpg',
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      Product(
        id: 'PROD-004',
        sku: 'SVC-001',
        barcode: '5678901234567',
        name: 'Website Design',
        description: 'Professional website design service including responsive layouts',
        sellingPrice: 1500.00,
        type: ProductType.service,
        taxType: TaxType.exempt,
        category: 'Services',
        inventoryTracking: InventoryTracking.dontTrack,
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now.subtract(const Duration(days: 45)),
      ),
      Product(
        id: 'PROD-005',
        sku: 'SVC-002',
        barcode: '6789012345678',
        name: 'IT Consultation',
        description: 'Hourly IT consultation services',
        sellingPrice: 120.00,
        type: ProductType.service,
        taxType: TaxType.taxable,
        taxRate: 7.5,
        category: 'Services',
        inventoryTracking: InventoryTracking.dontTrack,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
    ];

    // Save sample data to storage
    await DatabaseService.saveProducts(_products);
  }

  // Generate a unique barcode
  String generateBarcode() {
    final random = Random();
    String barcode;

    do {
      // Generate a 13-digit EAN-13 barcode
      // In a real application, we'd use proper barcode validation
      final List<int> digits = List.generate(12, (_) => random.nextInt(10));

      // Calculate check digit (simplified here)
      int sum = 0;
      for (int i = 0; i < 12; i++) {
        sum += digits[i] * (i % 2 == 0 ? 1 : 3);
      }
      final int checkDigit = (10 - (sum % 10)) % 10;

      digits.add(checkDigit);
      barcode = digits.join();
    } while (_barcodeExists(barcode));

    return barcode;
  }

  // Check if barcode exists
  bool _barcodeExists(String barcode) {
    return _products.any((product) => product.barcode == barcode);
  }

  // Generate a unique SKU
  String generateSku(String prefix, int padding) {
    int highestNumber = 0;

    // Find the highest existing SKU with this prefix
    for (final product in _products) {
      if (product.sku.startsWith(prefix)) {
        try {
          final numberPart = product.sku.substring(prefix.length);
          final number = int.parse(numberPart);
          if (number > highestNumber) {
            highestNumber = number;
          }
        } catch (e) {
          // Not a number, skip this SKU
        }
      }
    }

    // Generate the new SKU number
    final nextNumber = highestNumber + 1;
    return '$prefix${nextNumber.toString().padLeft(padding, '0')}';
  }

  // Add a new product
  Future<bool> addProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    try {
      _products.add(product);

      // Save to storage
      final success = await DatabaseService.saveProducts(_products);

      if (!success) {
        _error = 'Failed to save product data';
      } else {
        _error = null;

        // Add to stock history if tracking inventory
        if (product.inventoryTracking == InventoryTracking.track &&
            product.stockQuantity != null && product.stockQuantity! > 0) {
          _addStockHistoryEntry(
            productId: product.id,
            previousQuantity: 0,
            newQuantity: product.stockQuantity!,
            reason: 'Initial Stock',
            date: DateTime.now(),
          );
        }
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Error adding product: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update an existing product
  Future<bool> updateProduct(Product updatedProduct) async {
    _isLoading = true;
    notifyListeners();

    try {
      final index = _products.indexWhere((p) => p.id == updatedProduct.id);
      if (index >= 0) {
        // Get the previous product to compare stock quantity
        final previousProduct = _products[index];
        final previousQuantity = previousProduct.stockQuantity ?? 0;
        final newQuantity = updatedProduct.stockQuantity ?? 0;

        // Update product
        _products[index] = updatedProduct;

        // Track inventory changes if needed
        if (previousProduct.inventoryTracking == InventoryTracking.track &&
            updatedProduct.inventoryTracking == InventoryTracking.track &&
            previousQuantity != newQuantity) {
          _addStockHistoryEntry(
            productId: updatedProduct.id,
            previousQuantity: previousQuantity,
            newQuantity: newQuantity,
            reason: 'Manual Adjustment',
            date: DateTime.now(),
          );
        }

        // Save to storage
        final success = await DatabaseService.saveProducts(_products);

        if (!success) {
          _error = 'Failed to save product data';
        } else {
          _error = null;
        }

        _isLoading = false;
        notifyListeners();
        return success;
      } else {
        _error = 'Product not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error updating product: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete a product
  Future<bool> deleteProduct(String productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _products.removeWhere((p) => p.id == productId);
      if (_currentProduct?.id == productId) {
        _currentProduct = null;
      }

      // Save to storage
      final success = await DatabaseService.saveProducts(_products);

      if (!success) {
        _error = 'Failed to delete product';
      } else {
        _error = null;
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Error deleting product: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Set current product
  void setCurrentProduct(String productId) {
    try {
      _currentProduct = _products.firstWhere(
        (p) => p.id == productId,
        orElse: () => _products.first,
      );
      notifyListeners();
    } catch (e) {
      _error = 'Error setting current product: $e';
      notifyListeners();
    }
  }

  // Clear current product
  void clearCurrentProduct() {
    _currentProduct = null;
    notifyListeners();
  }

  // Add a new category
  void addCategory(String category) {
    if (!_categories.contains(category)) {
      _categories.add(category);
      notifyListeners();
    }
  }

  // Get products by category
  List<Product> getProductsByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }

  // Search products
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;

    final lowercaseQuery = query.toLowerCase();
    return _products.where((p) =>
      p.name.toLowerCase().contains(lowercaseQuery) ||
      p.description.toLowerCase().contains(lowercaseQuery) ||
      p.sku.toLowerCase().contains(lowercaseQuery) ||
      p.barcode.contains(query)
    ).toList();
  }

  // Get products with low stock
  List<Product> get lowStockProducts {
    return _products.where((p) =>
      p.inventoryTracking == InventoryTracking.track && p.isLowStock
    ).toList();
  }

  // Get out of stock products
  List<Product> get outOfStockProducts {
    return _products.where((p) =>
      p.inventoryTracking == InventoryTracking.track &&
      p.stockQuantity != null && p.stockQuantity! <= 0
    ).toList();
  }

  // Update stock quantity
  Future<bool> updateStock(String productId, int quantity, String reason) async {
    _isLoading = true;
    notifyListeners();

    try {
      final index = _products.indexWhere((p) => p.id == productId);
      if (index >= 0) {
        final product = _products[index];

        if (product.inventoryTracking == InventoryTracking.track &&
            product.stockQuantity != null) {

          final previousQuantity = product.stockQuantity!;
          final newQuantity = previousQuantity + quantity;

          final updatedProduct = product.copyWith(
            stockQuantity: newQuantity,
            updatedAt: DateTime.now(),
          );

          _products[index] = updatedProduct;

          if (_currentProduct?.id == productId) {
            _currentProduct = updatedProduct;
          }

          // Add to stock history
          _addStockHistoryEntry(
            productId: productId,
            previousQuantity: previousQuantity,
            newQuantity: newQuantity,
            reason: reason,
            date: DateTime.now(),
          );

          // Save to storage
          final success = await DatabaseService.saveProducts(_products);

          if (!success) {
            _error = 'Failed to update stock';
          } else {
            _error = null;
          }

          _isLoading = false;
          notifyListeners();
          return success;
        } else {
          _error = 'This product does not track inventory';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _error = 'Product not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error updating stock: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Refresh data from storage
  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<Product> loadedProducts = await DatabaseService.loadProducts();
      if (loadedProducts.isNotEmpty) {
        _products = loadedProducts;
        _error = null;
      } else {
        await _loadSampleProducts();
      }
    } catch (e) {
      _error = 'Failed to refresh product data: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add stock history entry
  void _addStockHistoryEntry({
    required String productId,
    required int previousQuantity,
    required int newQuantity,
    required String reason,
    required DateTime date,
  }) {
    final product = _products.firstWhere((p) => p.id == productId);

    _stockHistory.add(
      StockHistoryEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: productId,
        productName: product.name,
        previousQuantity: previousQuantity,
        newQuantity: newQuantity,
        change: newQuantity - previousQuantity,
        reason: reason,
        date: date,
      )
    );
  }

  // Get stock history for a specific product
  List<StockHistoryEntry> getStockHistoryForProduct(String productId) {
    return _stockHistory.where((entry) => entry.productId == productId).toList();
  }
}

/// Represents a stock history entry for tracking inventory changes
class StockHistoryEntry {
  final String id;
  final String productId;
  final String productName;
  final int previousQuantity;
  final int newQuantity;
  final int change;
  final String reason;
  final DateTime date;

  StockHistoryEntry({
    required this.id,
    required this.productId,
    required this.productName,
    required this.previousQuantity,
    required this.newQuantity,
    required this.change,
    required this.reason,
    required this.date,
  });
}
