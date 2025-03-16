// lib/screens/billing/new_invoice_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'package:dishaan_invoice_xpert/models/customer.dart';
import 'package:dishaan_invoice_xpert/models/product.dart';
import 'package:dishaan_invoice_xpert/models/invoice.dart';
import 'package:dishaan_invoice_xpert/models/invoice_item.dart';
import 'package:dishaan_invoice_xpert/providers/customer_provider.dart';
import 'package:dishaan_invoice_xpert/providers/product_provider.dart';
import 'package:dishaan_invoice_xpert/providers/invoice_provider.dart';
import 'package:dishaan_invoice_xpert/providers/settings_provider.dart';
import 'package:dishaan_invoice_xpert/services/pdf_service.dart';
import 'package:dishaan_invoice_xpert/services/printer_service.dart';
import 'package:dishaan_invoice_xpert/widgets/customer_search_dialog.dart';

class NewInvoiceScreen extends StatefulWidget {
  const NewInvoiceScreen({Key? key}) : super(key: key);

  @override
  _NewInvoiceScreenState createState() => _NewInvoiceScreenState();
}

class _NewInvoiceScreenState extends State<NewInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  Customer? _selectedCustomer;
  List<InvoiceItemEntry> _items = [];
  double _subtotal = 0;
  double _discountPercentage = 0;
  double _discountAmount = 0;
  double _taxPercentage = 0;
  double _taxAmount = 0;
  double _totalAmount = 0;
  String _paymentMethod = 'CASH';
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      setState(() {
        _taxPercentage = settingsProvider.taxPercentage;
        _taxController.text = _taxPercentage.toString();
      });
    });
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _discountController.dispose();
    _taxController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _selectCustomer() async {
    final Customer? customer = await showDialog<Customer>(
      context: context,
      builder: (BuildContext context) {
        return const CustomerSearchDialog();
      },
    );

    if (customer != null) {
      setState(() {
        _selectedCustomer = customer;
      });
    }
  }

  Future<void> _scanBarcode() async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#FF6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );

      if (barcodeScanRes != '-1') {
        _barcodeController.text = barcodeScanRes;
        _addProductByBarcode(barcodeScanRes);
      }
    } on PlatformException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to scan barcode')),
      );
    }
  }

  void _addProductByBarcode(String barcode) async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final Product? product = await productProvider.getProductByBarcode(barcode);

    if (product != null) {
      _addProductToInvoice(product);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product with barcode $barcode not found')),
      );
    }
  }

  void _showProductSearch() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final products = await productProvider.getAllProducts();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Product'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text(
                    'Stock: ${product.currentStock} | Price: ${_formatCurrency(product.sellingPrice)}',
                  ),
                  trailing: product.isLowStock
                      ? const Icon(Icons.warning, color: Colors.amber)
                      : null,
                  onTap: () {
                    Navigator.of(context).pop();
                    _addProductToInvoice(product);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _addProductToInvoice(Product product) {
    // Check if product already exists in invoice
    int existingIndex = _items.indexWhere((item) => item.product.id == product.id);

    setState(() {
      if (existingIndex >= 0) {
        // Increment quantity if product already in invoice
        _items[existingIndex].quantity++;
        _items[existingIndex].calculateTotal();
      } else {
        // Add new product to invoice
        _items.add(InvoiceItemEntry(
          product: product,
          quantity: 1,
          unitPrice: product.sellingPrice,
          taxPercentage: _taxPercentage,
        ));
      }
      _calculateInvoiceTotal();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      _calculateInvoiceTotal();
    });
  }

  void _calculateInvoiceTotal() {
    double subtotal = 0;

    for (var item in _items) {
      subtotal += item.totalPrice;
    }

    double discountAmount = (_discountPercentage / 100) * subtotal;
    double taxableAmount = subtotal - discountAmount;
    double taxAmount = (_taxPercentage / 100) * taxableAmount;
    double totalAmount = taxableAmount + taxAmount;

    setState(() {
      _subtotal = subtotal;
      _discountAmount = discountAmount;
      _taxAmount = taxAmount;
      _totalAmount = totalAmount;
    });
  }

  String _formatCurrency(double amount) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    return '${settingsProvider.currencySymbol}${amount.toStringAsFixed(2)}';
  }

  Future<void> _saveInvoice() async {
    if (_formKey.currentState!.validate()) {
      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add at least one product to the invoice')),
        );
        return;
      }

      setState(() {
        _isProcessing = true;
      });

      try {
        final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

        // Generate invoice number
        String invoicePrefix = settingsProvider.invoicePrefix;
        String invoiceNumber = await invoiceProvider.generateInvoiceNumber(invoicePrefix);

        // Create invoice items
        List<InvoiceItem> invoiceItems = _items.map((item) => InvoiceItem(
          productId: item.product.id!,
          productName: item.product.name,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          discountPercentage: 0, // Item-level discount not implemented in this example
          taxPercentage: item.taxPercentage,
          totalPrice: item.totalPrice,
        )).toList();

        // Create invoice
        final Invoice invoice = Invoice(
          invoiceNumber: invoiceNumber,
          customerId: _selectedCustomer?.id,
          subtotal: _subtotal,
          discountPercentage: _discountPercentage,
          discountAmount: _discountAmount,
          taxPercentage: _taxPercentage,
          taxAmount: _taxAmount,
          totalAmount: _totalAmount,
          paymentMethod: _paymentMethod,
          paymentStatus: 'PAID', // Assume paid for simplicity
          notes: _notesController.text,
          items: invoiceItems,
        );

        // Save invoice to database
        final int invoiceId = await invoiceProvider.saveInvoice(invoice, invoiceItems);

        // Generate PDF
        final pdfService = PDFService();
        final pdfFile = await pdfService.generateInvoicePDF(
          invoice.copyWith(id: invoiceId),
          _selectedCustomer,
          invoiceItems,
          settingsProvider,
        );

        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice saved successfully')),
        );

        // Show options dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Invoice Created'),
              content: const Text('What would you like to do next?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(true); // Return to previous screen
                  },
                  child: const Text('Close'),
                ),
                TextButton(
                  onPressed: () {
                    PrinterService().printPdf(pdfFile);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Print'),
                ),
                TextButton(
                  onPressed: () {
                    pdfService.sharePdf(pdfFile);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Share PDF'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Reset form for new invoice
                    _resetForm();
                  },
                  child: const Text('New Invoice'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving invoice: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _resetForm() {
    setState(() {
      _selectedCustomer = null;
      _items = [];
      _subtotal = 0;
      _discountPercentage = 0;
      _discountAmount = 0;
      _taxPercentage = Provider.of<SettingsProvider>(context, listen: false).taxPercentage;
      _taxAmount = 0;
      _totalAmount = 0;
      _paymentMethod = 'CASH';
      _barcodeController.clear();
      _discountController.clear();
      _taxController.text = _taxPercentage.toString();
      _notesController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: const Text('New Invoice'),