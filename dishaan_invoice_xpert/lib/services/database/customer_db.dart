// lib/services/database/customer_db.dart

import 'package:dishaan_invoice_xpert/models/customer.dart';
import 'package:dishaan_invoice_xpert/services/database/database_service.dart';
import 'package:sqflite/sqflite.dart';

class CustomerDatabase {
  final DatabaseService _databaseService = DatabaseService();

  // Get all customers
  Future<List<Customer>> getAllCustomers() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
        'customers',
        orderBy: 'name ASC'
    );

    return List.generate(maps.length, (i) {
      return Customer.fromMap(maps[i]);
    });
  }

  // Get customer by ID
  Future<Customer?> getCustomer(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Customer.fromMap(maps.first);
    }
    return null;
  }

  // Search customers
  Future<List<Customer>> searchCustomers(String query) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      where: 'name LIKE ? OR phone LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return Customer.fromMap(maps[i]);
    });
  }

  // Insert customer
  Future<int> insertCustomer(Customer customer) async {
    final db = await _databaseService.database;
    return await db.insert(
      'customers',
      customer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update customer
  Future<int> updateCustomer(Customer customer) async {
    final db = await _databaseService.database;
    return await db.update(
      'customers',
      {...customer.toMap(), 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  // Delete customer
  Future<int> deleteCustomer(int id) async {
    final db = await _databaseService.database;
    return await db.delete(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get customer purchase history
  Future<List<Map<String, dynamic>>> getCustomerPurchaseHistory(int customerId) async {
    final db = await _databaseService.database;

    return await db.rawQuery('''
      SELECT 
        i.id, 
        i.invoice_number, 
        i.total_amount, 
        i.created_at, 
        COUNT(ii.id) as item_count
      FROM invoices i
      LEFT JOIN invoice_items ii ON i.id = ii.invoice_id
      WHERE i.customer_id = ?
      GROUP BY i.id
      ORDER BY i.created_at DESC
    ''', [customerId]);
  }

  // Get customer statistics
  Future<Map<String, dynamic>> getCustomerStatistics(int customerId) async {
    final db = await _databaseService.database;

    // Get total purchase amount
    final totalResult = await db.rawQuery('''
      SELECT SUM(total_amount) as total
      FROM invoices
      WHERE customer_id = ?
    ''', [customerId]);

    // Get purchase count
    final countResult = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM invoices
      WHERE customer_id = ?
    ''', [customerId]);

    // Get last purchase date
    final dateResult = await db.rawQuery('''
      SELECT created_at
      FROM invoices
      WHERE customer_id = ?
      ORDER BY created_at DESC
      LIMIT 1
    ''', [customerId]);

    return {
      'total_purchases': totalResult.first['total'] ?? 0,
      'purchase_count': countResult.first['count'] ?? 0,
      'last_purchase_date': dateResult.isNotEmpty ? dateResult.first['created_at'] : null,
    };
  }
}