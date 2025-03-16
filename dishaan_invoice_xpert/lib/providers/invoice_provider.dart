
// lib/providers/invoice_provider.dart

import 'package:flutter/foundation.dart';
import 'package:dishaan_invoice_xpert/models/invoice.dart';
import 'package:dishaan_invoice_xpert/models/invoice_item.dart';
import 'package:dishaan_invoice_xpert/services/database/database_service.dart';
import 'package:dishaan_invoice_xpert/providers/product_provider.dart';
import 'package:dishaan_invoice_xpert/providers/settings_provider.dart';

import '../models/customer.dart';

class InvoiceProvider with ChangeNotifier {
  List<Invoice> _invoices = [];
  bool _isLoading = false;

  final ProductProvider _productProvider;
  final SettingsProvider _settingsProvider;

  InvoiceProvider({
    required ProductProvider productProvider,
    required SettingsProvider settingsProvider,
  }) : _productProvider = productProvider,
        _settingsProvider = settingsProvider;

  List<Invoice> get invoices => _invoices;
  bool get isLoading => _isLoading;

  // Load all invoices from the database
  Future<void> loadInvoices({int limit = 100}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseService().database;
      final result = await db.query(
        'invoices',
        orderBy: 'created_at DESC',
        limit: limit,
      );

      List<Invoice> loadedInvoices = [];

      for (var invoiceMap in result) {
        // Get invoice items for this invoice
        final itemsResult = await db.query(
          'invoice_items',
          where: 'invoice_id = ?',
          whereArgs: [invoiceMap['id']],
        );

        List<InvoiceItem> items = itemsResult
            .map((item) => InvoiceItem.fromMap(item))
            .toList();

        loadedInvoices.add(Invoice.fromMap(invoiceMap, items: items));
      }

      _invoices = loadedInvoices;
    } catch (e) {
      print('Error loading invoices: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Generate next invoice number
  Future<String> generateInvoiceNumber() async {
    final prefix = _settingsProvider.invoicePrefix ?? 'INV-';
    final date = DateTime.now();
    final yearMonth = '${date.year}${date.month.toString().padLeft(2, '0')}';

    try {
      final db = await DatabaseService().database;

      // Get highest invoice number for current month
      final result = await db.rawQuery('''
        SELECT invoice_number FROM invoices 
        WHERE invoice_number LIKE '$prefix$yearMonth%' 
        ORDER BY invoice_number DESC LIMIT 1
      ''');

      int nextNumber = 1;

      if (result.isNotEmpty) {
        String lastInvoice = result.first['invoice_number'] as String;
        // Extract the sequential number part
        String numStr = lastInvoice.substring(prefix.length + yearMonth.length);
        nextNumber = int.parse(numStr) + 1;
      }

      return '$prefix$yearMonth${nextNumber.toString().padLeft(4, '0')}';
    } catch (e) {
      print('Error generating invoice number: $e');
      // Fallback in case of error
      return '$prefix$yearMonth${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // Create a new invoice
  Future<Invoice?> createInvoice(Invoice invoice, List<InvoiceItem> items) async {
    try {
      final db = await DatabaseService().database;

      // Generate invoice number if not provided
      String invoiceNumber = invoice.invoiceNumber;
      if (invoiceNumber.isEmpty) {
        invoiceNumber = await generateInvoiceNumber();
      }

      // Begin transaction
      await db.transaction((txn) async {
        // Insert invoice
        final invoiceMap = invoice.toMap();
        invoiceMap['invoice_number'] = invoiceNumber;

        final invoiceId = await txn.insert('invoices', invoiceMap);

        // Insert invoice items
        for (var item in items) {
          final itemMap = item.toMap();
          itemMap['invoice_id'] = invoiceId;
          await txn.insert('invoice_items', itemMap);

          // Update product stock
          await _productProvider.updateStock(
            item.productId,
            item.quantity,
            'SALE',
            reference: invoiceNumber,
          );
        }
      });

      // Reload invoices
      await loadInvoices();

      // Find and return the newly created invoice
      return _invoices.firstWhere(
            (inv) => inv.invoiceNumber == invoiceNumber,
        orElse: () => invoice,
      );
    } catch (e) {
      print('Error creating invoice: $e');
      return null;
    }
  }

  // Get a single invoice by ID
  Future<Invoice?> getInvoiceById(int id) async {
    try {
      final db = await DatabaseService().database;
      final result = await db.query(
        'invoices',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (result.isEmpty) {
        return null;
      }

      // Get invoice items
      final itemsResult = await db.query(
        'invoice_items',
        where: 'invoice_id = ?',
        whereArgs: [id],
      );

      List<InvoiceItem> items = itemsResult
          .map((item) => InvoiceItem.fromMap(item))
          .toList();

      return Invoice.fromMap(result.first, items: items);
    } catch (e) {
      print('Error getting invoice by ID: $e');
      return null;
    }
  }

  // Get invoices for a specific time period
  Future<List<Invoice>> getInvoicesForPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final db = await DatabaseService().database;

      // Format dates for SQLite comparison
      final formattedStartDate = startDate.toIso8601String();
      final formattedEndDate = endDate.toIso8601String();

      final result = await db.query(
        'invoices',
        where: 'created_at BETWEEN ? AND ?',
        whereArgs: [formattedStartDate, formattedEndDate],
        orderBy: 'created_at DESC',
      );

      List<Invoice> periodInvoices = [];

      for (var invoiceMap in result) {
        // Get invoice items for this invoice
        final itemsResult = await db.query(
          'invoice_items',
          where: 'invoice_id = ?',
          whereArgs: [invoiceMap['id']],
        );

        List<InvoiceItem> items = itemsResult
            .map((item) => InvoiceItem.fromMap(item))
            .toList();

        periodInvoices.add(Invoice.fromMap(invoiceMap, items: items));
      }

      return periodInvoices;
    } catch (e) {
      print('Error getting invoices for period: $e');
      return [];
    }
  }

  // Get sales summary for a specific period (for reports)
  Future<Map<String, dynamic>> getSalesSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final invoices = await getInvoicesForPeriod(
        startDate: startDate,
        endDate: endDate,
      );

      double totalSales = 0;
      double totalTax = 0;
      double totalDiscount = 0;
      int totalInvoices = invoices.length;
      Set<int?> uniqueCustomers = {};

      for (var invoice in invoices) {
        totalSales += invoice.totalAmount;
        totalTax += invoice.taxAmount;
        totalDiscount += invoice.discountAmount;
        uniqueCustomers.add(invoice.customerId);
      }

      return {
        'totalSales': totalSales,
        'totalTax': totalTax,
        'totalDiscount': totalDiscount,
        'totalInvoices': totalInvoices,
        'uniqueCustomers': uniqueCustomers.where((id) => id != null).length,
        'averageInvoiceValue': totalInvoices > 0 ? totalSales / totalInvoices : 0,
      };
    } catch (e) {
      print('Error getting sales summary: $e');
      return {
        'totalSales': 0,
        'totalTax': 0,
        'totalDiscount': 0,
        'totalInvoices': 0,
        'uniqueCustomers': 0,
        'averageInvoiceValue': 0,
      };
    }
  }
}