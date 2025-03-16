// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dishaan_invoice_xpert/providers/product_provider.dart';
import 'package:dishaan_invoice_xpert/providers/invoice_provider.dart';
import 'package:dishaan_invoice_xpert/providers/settings_provider.dart';
import 'package:dishaan_invoice_xpert/widgets/app_drawer.dart';
import 'package:dishaan_invoice_xpert/screens/billing/new_invoice_screen.dart';
import 'package:dishaan_invoice_xpert/screens/products/product_list_screen.dart';
import 'package:dishaan_invoice_xpert/screens/customers/customer_list_screen.dart';
import 'package:dishaan_invoice_xpert/screens/reports/sales_report_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _todaySummary = {};
  Map<String, dynamic> _weekSummary = {};
  List<Map<String, dynamic>> _recentInvoices = [];
  List<Map<String, dynamic>> _lowStockProducts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Load providers data
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);

    // Load products and invoices
    await productProvider.loadProducts();
    await invoiceProvider.loadInvoices(limit: 10);

    // Get today's sales summary
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

    _todaySummary = await invoiceProvider.getSalesSummary(
      startDate: startOfDay,
      endDate: endOfDay,
    );

    // Get week sales summary
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    _weekSummary = await invoiceProvider.getSalesSummary(
      startDate: startOfWeekDay,
      endDate: endOfDay,
    );

    // Get recent invoices
    _recentInvoices = invoiceProvider.invoices
        .take(5)
        .map((invoice) => {
      'id': invoice.id,
      'invoice_number': invoice.invoiceNumber,
      'date': invoice.createdAt,
      'customer': 'Customer ${invoice.customerId ?? "Walk-in"}',
      'total': invoice.totalAmount,
    })
        .toList();

    // Get low stock products
    _lowStockProducts = productProvider.lowStockProducts
        .take(5)
        .map((product) => {
      'id': product.id,
      'name': product.name,
      'stock': product.currentStock,
      'min_stock': product.minStockAlert,
    })
        .toList();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final currencyFormat = NumberFormat.currency(symbol: settingsProvider.currencySymbol);

    return Scaffold(
        appBar: AppBar(
        title: Text(settingsProvider.businessName ?? 'Billing App'),
    actions: [
    IconButton(
    icon: const Icon(Icons.refresh),