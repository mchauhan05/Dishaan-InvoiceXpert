// lib/services/database/invoice_db.dart

import 'package:dishaan_invoice_xpert/models/invoice.dart';
import 'package:dishaan_invoice_xpert/models/invoice_item.dart';
import 'package:dishaan_invoice_xpert/services/database/database_service.dart';
import 'package:sqflite/sqflite.dart';

class InvoiceDatabase {
  final DatabaseService _databaseService = DatabaseService();

  // Get all invoices
  Future<List<Map<String, dynamic>>> getAllInvoices({int limit = 100, int offset = 0}) async {
    final db = await _databaseService.database;

    return await db.rawQuery('''
      SELECT 
        i.id, 
        i.invoice_number, 
        i.total_amount, 
        i.created_at,
        c.name as customer_name,
        c.id as customer_id
      FROM invoices i
      LEFT JOIN customers c ON i.customer_id = c.id
      ORDER BY i.created_at DESC
      LIMIT ? OFFSET ?
    ''', [limit, offset]);
  }

  // Get invoice by ID with items
  Future<Invoice?> getInvoice(int id) async {
    final db = await _databaseService.database;

    // Get invoice
    final List<Map<String, dynamic>> invoiceMaps = await db.query(
      'invoices',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (invoiceMaps.isEmpty) {
      return null;
    }

    // Get invoice items
    final List<Map<String, dynamic>> itemMaps = await db.query(
      'invoice_items',
      where: 'invoice_id = ?',
      whereArgs: [id],
    );

    final items = List.generate(itemMaps.length, (i) {
      return InvoiceItem.fromMap(itemMaps[i]);
    });

    return Invoice.fromMap(invoiceMaps.first, items: items);
  }

  // Search invoices
  Future<List<Map<String, dynamic>>> searchInvoices(String query) async {
    final db = await _databaseService.database;

    return await db.rawQuery('''
      SELECT 
        i.id, 
        i.invoice_number, 
        i.total_amount, 
        i.created_at,
        c.name as customer_name,
        c.id as customer_id
      FROM invoices i
      LEFT JOIN customers c ON i.customer_id = c.id
      WHERE i.invoice_number LIKE ? OR c.name LIKE ?
      ORDER BY i.created_at DESC
    ''', ['%$query%', '%$query%']);
  }

  // Create new invoice
  Future<int> createInvoice(Invoice invoice, List<InvoiceItem> items) async {
    final db = await _databaseService.database;

    int invoiceId = 0;

    await db.transaction((txn) async {
      // Insert invoice
      invoiceId = await txn.insert('invoices', invoice.toMap());

      // Insert invoice items
      for (var item in items) {
        await txn.insert('invoice_items', {
          ...item.toMap(),
          'invoice_id': invoiceId,
        });

        // Update product stock
        await txn.rawUpdate('''
          UPDATE products
          SET current_stock = current_stock - ?,
              updated_at = ?
          WHERE id = ?
        ''', [item.quantity, DateTime.now().toIso8601String(), item.productId]);

        // Record stock transaction
        await txn.insert('stock_transactions', {
          'product_id': item.productId,
          'transaction_type': 'SALE',
          'quantity': -item.quantity,
          'reference_id': invoice.invoiceNumber,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    });

    return invoiceId;
  }

  // Delete invoice
  Future<void> deleteInvoice(int id, String invoiceNumber) async {
    final db = await _databaseService.database;

    await db.transaction((txn) async {
      // Get invoice items to restore stock
      final List<Map<String, dynamic>> itemMaps = await txn.query(
        'invoice_items',
        where: 'invoice_id = ?',
        whereArgs: [id],
      );

      // Restore stock for each item
      for (var item in itemMaps) {
        // Update product stock
        await txn.rawUpdate('''
          UPDATE products
          SET current_stock = current_stock + ?,
              updated_at = ?
          WHERE id = ?
        ''', [item['quantity'], DateTime.now().toIso8601String(), item['product_id']]);

        // Record stock transaction
        await txn.insert('stock_transactions', {
          'product_id': item['product_id'],
          'transaction_type': 'ADJUSTMENT',
          'quantity': item['quantity'],
          'reference_id': 'VOID-$invoiceNumber',
          'notes': 'Invoice deleted',
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // Delete invoice items
      await txn.delete(
        'invoice_items',
        where: 'invoice_id = ?',
        whereArgs: [id],
      );

      // Delete invoice
      await txn.delete(
        'invoices',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  // Get next invoice number
  Future<String> getNextInvoiceNumber() async {
    final db = await _databaseService.database;

    // Get invoice prefix
    final settings = await db.query('settings', where: 'id = 1');
    final prefix = settings.isNotEmpty ? settings.first['invoice_prefix'] ?? 'INV-' : 'INV-';

    // Get last invoice number
    final result = await db.rawQuery('''
      SELECT invoice_number
      FROM invoices
      ORDER BY id DESC
      LIMIT 1
    ''');

    if (result.isEmpty) {
      return '$prefix${DateTime.now().year}0001';
    }

    // Extract the numeric part and increment
    final lastInvoiceNumber = result.first['invoice_number'] as String;

    try {
      final numericPart = lastInvoiceNumber.substring(prefix.toString().length);
      final nextNumber = int.parse(numericPart) + 1;
      return '$prefix$nextNumber';
    } catch (e) {
      // If parsing fails, use year and sequence
      return '$prefix${DateTime.now().year}0001';
    }
  }

  // Get sales report by date range
  Future<List<Map<String, dynamic>>> getSalesReport(DateTime startDate, DateTime endDate) async {
    final db = await _databaseService.database;

    // Format dates to match SQLite format
    final start = startDate.toIso8601String();
    final end = endDate.toIso8601String();

    return await db.rawQuery('''
      SELECT 
        strftime('%Y-%m-%d', created_at) as date,
        COUNT(*) as invoice_count,
        SUM(total_amount) as total_sales,
        SUM(tax_amount) as total_tax
      FROM invoices
      WHERE created_at BETWEEN ? AND ?
      GROUP BY strftime('%Y-%m-%d', created_at)
      ORDER BY date
    ''', [start, end]);
  }

  // Get top selling products
  Future<List<Map<String, dynamic>>> getTopSellingProducts(DateTime startDate, DateTime endDate, {int limit = 10}) async {
    final db = await _databaseService.database;

    // Format dates to match SQLite format
    final start = startDate.toIso8601String();
    final end = endDate.toIso8601String();

    return await db.rawQuery('''
      SELECT 
        ii.product_id,
        ii.product_name,
        SUM(ii.quantity) as total_quantity,
        SUM(ii.total_price) as total_sales
      FROM invoice_items ii
      JOIN invoices i ON ii.invoice_id = i.id
      WHERE i.created_at BETWEEN ? AND ?
      GROUP BY ii.product_id
      ORDER BY total_quantity DESC
      LIMIT ?
    ''', [start, end, limit]);
  }
}