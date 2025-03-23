import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/dashboard_data.dart';
import '../models/invoice_models.dart';

class InvoiceProvider extends ChangeNotifier {
  // Current invoice being edited
  Invoice? _currentInvoice;

  // Selected customer for new invoice
  InvoiceCustomer? _selectedCustomer;

  // Tax rates available
  final List<double> _taxRates = [0.0, 5.0, 10.0, 18.0];

  // Sample invoice items/products
  final List<Map<String, dynamic>> _itemCatalog = [
    {
      'id': 'ITM001',
      'name': 'Web Design',
      'description': 'Custom website design services',
      'rate': 120.0,
    },
    {
      'id': 'ITM002',
      'name': 'Web Development',
      'description': 'Custom website development services',
      'rate': 150.0,
    },
    {
      'id': 'ITM003',
      'name': 'Logo Design',
      'description': 'Professional logo design',
      'rate': 200.0,
    },
    {
      'id': 'ITM004',
      'name': 'SEO Optimization',
      'description': 'Search engine optimization services',
      'rate': 80.0,
    },
    {
      'id': 'ITM005',
      'name': 'Consulting Hours',
      'description': 'Professional consulting services',
      'rate': 100.0,
    },
  ];

  // Sample customers
  final List<InvoiceCustomer> _customers = [
    InvoiceCustomer(
      id: 'CUST001',
      name: 'Ethan Clark',
      email: 'ethan.clark@example.com',
      phone: '(555) 123-4567',
      billingAddress: '123 Main St, New York, NY 10001',
    ),
    InvoiceCustomer(
      id: 'CUST002',
      name: 'Sophia Hall',
      email: 'sophia.hall@example.com',
      phone: '(555) 234-5678',
      billingAddress: '456 Oak Ave, San Francisco, CA 94103',
    ),
    InvoiceCustomer(
      id: 'CUST003',
      name: 'James Wilson',
      email: 'james.wilson@example.com',
      phone: '(555) 345-6789',
      billingAddress: '789 Pine Rd, Chicago, IL 60007',
    ),
    InvoiceCustomer(
      id: 'CUST004',
      name: 'Emma Davis',
      email: 'emma.davis@example.com',
      phone: '(555) 456-7890',
      billingAddress: '321 Cedar Ln, Miami, FL 33101',
    ),
    InvoiceCustomer(
      id: 'CUST005',
      name: 'Oliver Brown',
      email: 'oliver.brown@example.com',
      phone: '(555) 567-8901',
      billingAddress: '654 Maple Dr, Seattle, WA 98101',
    ),
  ];

  // Getters
  Invoice? get currentInvoice => _currentInvoice;
  InvoiceCustomer? get selectedCustomer => _selectedCustomer;
  List<double> get taxRates => _taxRates;
  List<Map<String, dynamic>> get itemCatalog => _itemCatalog;
  List<InvoiceCustomer> get customers => _customers;

  // Initialize a new invoice
  void initializeNewInvoice() {
    final String invoiceNumber = 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final DateTime now = DateTime.now();
    final DateTime dueDate = now.add(const Duration(days: 30));

    _currentInvoice = Invoice(
      id: 'INV-${DateTime.now().millisecondsSinceEpoch.toString()}',
      invoiceNumber: invoiceNumber,
      date: now,
      dueDate: dueDate,
      status: InvoiceStatus.draft,
      customer: _customers[0], // Default to first customer
      items: [], // Start with empty items
      paymentTerms: PaymentTerms.net30,
    );

    _selectedCustomer = _customers[0];

    notifyListeners();
  }

  // Load an existing invoice for editing
  void loadInvoiceForEditing(String invoiceId) {
    // In a real app, you would fetch this from API/database
    // For now, we'll just create a sample invoice

    final DateTime now = DateTime.now();
    final DateTime invoiceDate = now.subtract(const Duration(days: 15));
    final DateTime dueDate = invoiceDate.add(const Duration(days: 30));

    // Sample invoice items
    final List<InvoiceItem> items = [
      InvoiceItem(
        id: 'ITEM001',
        name: 'Web Design',
        description: 'Custom website design services',
        quantity: 10,
        rate: 120.0,
        tax: 10.0,
        taxable: true,
      ),
      InvoiceItem(
        id: 'ITEM002',
        name: 'Logo Design',
        description: 'Professional logo design',
        quantity: 1,
        rate: 200.0,
        tax: 0.0,
        taxable: false,
      ),
    ];

    _currentInvoice = Invoice(
      id: invoiceId,
      invoiceNumber: 'INV-12345',
      date: invoiceDate,
      dueDate: dueDate,
      status: InvoiceStatus.draft,
      customer: _customers[1], // Use second customer
      items: items,
      paymentTerms: PaymentTerms.net30,
      notes: 'Thank you for your business!',
      terms: 'Payment is due within 30 days.',
    );

    _selectedCustomer = _currentInvoice!.customer;

    notifyListeners();
  }

  // Add a new item to the invoice
  void addItemToInvoice(InvoiceItem item) {
    if (_currentInvoice != null) {
      _currentInvoice!.items.add(item);
      notifyListeners();
    }
  }

  // Update an existing item in the invoice
  void updateItemInInvoice(InvoiceItem updatedItem, int index) {
    if (_currentInvoice != null && index >= 0 && index < _currentInvoice!.items.length) {
      _currentInvoice!.items[index] = updatedItem;
      notifyListeners();
    }
  }

  // Remove an item from the invoice
  void removeItemFromInvoice(int index) {
    if (_currentInvoice != null && index >= 0 && index < _currentInvoice!.items.length) {
      _currentInvoice!.items.removeAt(index);
      notifyListeners();
    }
  }

  // Update customer for the invoice
  void updateCustomer(InvoiceCustomer customer) {
    _selectedCustomer = customer;

    if (_currentInvoice != null) {
      _currentInvoice!.customer = customer;
      notifyListeners();
    }
  }

  // Update invoice date
  void updateInvoiceDate(DateTime date) {
    if (_currentInvoice != null) {
      _currentInvoice!.date = date;
      notifyListeners();
    }
  }

  // Update due date
  void updateDueDate(DateTime date) {
    if (_currentInvoice != null) {
      _currentInvoice!.dueDate = date;
      notifyListeners();
    }
  }

  // Update payment terms
  void updatePaymentTerms(PaymentTerms terms) {
    if (_currentInvoice != null) {
      _currentInvoice!.paymentTerms = terms;

      // Auto-calculate due date based on terms
      final DateTime invoiceDate = _currentInvoice!.date;
      switch (terms) {
        case PaymentTerms.dueOnReceipt:
          _currentInvoice!.dueDate = invoiceDate;
          break;
        case PaymentTerms.net15:
          _currentInvoice!.dueDate = invoiceDate.add(const Duration(days: 15));
          break;
        case PaymentTerms.net30:
          _currentInvoice!.dueDate = invoiceDate.add(const Duration(days: 30));
          break;
        case PaymentTerms.net45:
          _currentInvoice!.dueDate = invoiceDate.add(const Duration(days: 45));
          break;
        case PaymentTerms.net60:
          _currentInvoice!.dueDate = invoiceDate.add(const Duration(days: 60));
          break;
        case PaymentTerms.custom:
          // Don't change the due date for custom terms
          break;
      }

      notifyListeners();
    }
  }

  // Save the invoice
  void saveInvoice() {
    // In a real app, this would save to API/database
    // For now, we just notify listeners
    notifyListeners();
  }

  // Format currency
  String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
  }

  // Format date
  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
