// lib/services/database/product_db.dart

import 'package:dishaan_invoice_xpert/models/product.dart';
import 'package:dishaan_invoice_xpert/services/database/database_service.dart';
import 'package:sqflite/sqflite.dart';

class ProductDatabase {
  final DatabaseService _databaseService = DatabaseService();

  // Get all products
  Future<List<Product>> getAllProducts({bool activeOnly = false}) async {
    final db = await _databaseService.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: activeOnly ? 'is_active = ?' : null,
      whereArgs: activeOnly ? [1] : null,
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  // Get product by ID
  Future<Product?> getProduct(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  // Get product by barcode
  Future<Product?> getProductByBarcode(String barcode) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );

    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  // Search products
  Future<List<Product>> searchProducts(String query) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'name LIKE ? OR barcode LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  // Insert product
  Future<int> insertProduct(Product product) async {
    final db = await _databaseService.database;
    return await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update product
  Future<int> updateProduct(Product product) async {
    final db = await _databaseService.database;
    return await db.update(
      'products',
      {...product.toMap(), 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // Delete product
  Future<int> deleteProduct(int id) async {
    final db = await _databaseService.database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update stock quantity
  Future<void> updateStock(int productId, int quantity, String transactionType, {String? reference}) async {
    final db = await _databaseService.database;

    // Start a transaction
    await db.transaction((txn) async {
      // Update the product's stock
      await txn.rawUpdate('''
        UPDATE products
        SET current_stock = current_stock + ?,
            updated_at = ?
        WHERE id = ?
      ''', [quantity, DateTime.now().toIso8601String(), productId]);

      // Record the stock transaction
      await txn.insert('stock_transactions', {
        'product_id': productId,
        'transaction_type': transactionType,
        'quantity': quantity,
        'reference_id': reference,
        'created_at': DateTime.now().toIso8601String(),
      });
    });
  }

  // Get low stock products
  Future<List<Product>> getLowStockProducts() async {
    final db = await _databaseService.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM products
      WHERE current_stock <= min_stock_alert
        AND is_active = 1
      ORDER BY (current_stock - min_stock_alert) ASC
    ''');

    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  // Get product categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await _databaseService.database;
    return await db.query('categories', orderBy: 'name ASC');
  }

  // Add category
  Future<int> addCategory(String name, {String? description}) async {
    final db = await _databaseService.database;
    return await db.insert('categories', {
      'name': name,
      'description': description,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // Get products by category
  Future<List<Product>> getProductsByCategory(int categoryId) async {
    final db = await _databaseService.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'category_id = ? AND is_active = 1',
      whereArgs: [categoryId],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  // Get product sales history
  Future<List<Map<String, dynamic>>> getProductSalesHistory(int productId) async {
    final db = await _databaseService.database;

    return await db.rawQuery('''
      SELECT 
        ii.invoice_id,
        i.invoice_number,
        ii.quantity,
        ii.unit_price,
        ii.total_price,
        i.created_at
      FROM invoice_items ii
      JOIN invoices i ON ii.invoice_id = i.id
      WHERE ii.product_id = ?
      ORDER BY i.created_at DESC
    ''', [productId]);
  }
}