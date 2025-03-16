// lib/providers/product_provider.dart

import 'package:flutter/foundation.dart';
import 'package:dishaan_invoice_xpert/models/product.dart';
import 'package:dishaan_invoice_xpert/services/database/product_db.dart';

class ProductProvider with ChangeNotifier {
  final ProductDatabase _productDb = ProductDatabase();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;
  String _searchQuery = '';
  int? _categoryFilter;

  List<Product> get products => _products;
  List<Product> get filteredProducts => _filteredProducts;
  List<Map<String, dynamic>> get categories => _categories;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  int? get categoryFilter => _categoryFilter;

  Future<void> loadProducts({bool activeOnly = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await _productDb.getAllProducts(activeOnly: activeOnly);
      _applyFilter();
    } catch (e) {
      debugPrint('Error loading products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _productDb.getCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<Product?> getProduct(int id) async {
    return await _productDb.getProduct(id);
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    return await _productDb.getProductByBarcode(barcode);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void setCategoryFilter(int? categoryId) {
    _categoryFilter = categoryId;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty && _categoryFilter == null) {
      _filteredProducts = List.from(_products);
      return;
    }

    _filteredProducts = _products.where((product) {
      bool matchesSearch = true;
      bool matchesCategory = true;

      if (_searchQuery.isNotEmpty) {
        final name = product.name.toLowerCase();
        final barcode = product.barcode?.toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        matchesSearch = name.contains(query) || barcode.contains(query);
      }

      if (_categoryFilter != null) {
        matchesCategory = product.categoryId == _categoryFilter;
      }

      return matchesSearch && matchesCategory;
    }).toList();
  }

  Future<bool> addProduct(Product product) async {
    try {
      final id = await _productDb.insertProduct(product);
      final newProduct = product.copyWith(id: id);
      _products.add(newProduct);
      _applyFilter();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding product: $e');
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      await _productDb.updateProduct(product);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        _applyFilter();
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error updating product: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      await _productDb.deleteProduct(id);
      _products.removeWhere((product) => product.id == id);
      _applyFilter();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting product: $e');
      return false;
    }
  }

  Future<bool> updateStock(int productId, int quantity, String transactionType, {String? reference}) async {
    try {
      await _productDb.updateStock(productId, quantity, transactionType, reference: reference);

      // Update local product list
      final productIndex = _products.indexWhere((p) => p.id == productId);
      if (productIndex != -1) {
        final product = _products[productIndex];
        _products[productIndex] = product.copyWith(
          currentStock: product.currentStock + quantity,
          updatedAt: DateTime.now(),
        );
        _applyFilter();
        notifyListeners();
      }

      return true;
    } catch (e) {
      debugPrint('Error updating stock: $e');
      return false;
    }
  }

  Future<bool> addCategory(String name, {String? description}) async {
    try {
      final id = await _productDb.addCategory(name, description: description);
      _categories.add({
        'id': id,
        'name': name,
        'description': description,
      });
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding category: $e');
      return false;
    }
  }

  Future<List<Product>> getLowStockProducts() async {
    return await _productDb.getLowStockProducts();
  }

  Future<List<Map<String, dynamic>>> getProductSalesHistory(int productId) async {
    return await _productDb.getProductSalesHistory(productId);
  }
}