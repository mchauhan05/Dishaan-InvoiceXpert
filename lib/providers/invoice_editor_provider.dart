import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/invoice_models.dart';
import '../models/dashboard_data.dart';

class InvoiceEditorProvider extends ChangeNotifier {
  // Current invoice being edited
  Invoice? _currentInvoice;

  // Flag to indicate if we're editing an existing invoice or creating a new one
  bool _isEditing = false;

  // Error messages
  String? _errorMessage;

  // Getters
  Invoice? get currentInvoice => _currentInvoice;
  bool get isEditing => _isEditing;
  String? get errorMessage => _errorMessage;

  // Generate a new invoice number
  String generateInvoiceNumber() {
    final formatter = DateFormat('yyyyMMdd');
    final today = formatter.format(DateTime.now());
    return 'INV-$today-${const Uuid().v4().substring(0, 4).toUpperCase()}';
  }

  // Initialize a new invoice for creation
  void initNewInvoice(List<Customer> customers) {
    if (customers.isEmpty) {
      _errorMessage = 'No customers available. Please add a customer first.';
      notifyListeners();
      return;
    }

    final customer = customers.first;
    final invoiceCustomer = InvoiceCustomer(
      id: customer.id,
      name: customer.name,
      email: customer.email,
      billingAddress: '', // Default empty address
      phone: customer.phone,
    );

    final now = DateTime.now();
    final dueDate = now.add(const Duration(days: 30)); // Default due date: 30 days

    _currentInvoice = Invoice(
      id: const Uuid().v4(),
      invoiceNumber: generateInvoiceNumber(),
      date: now,
      dueDate: dueDate,
      status: InvoiceStatus.draft,
      customer: invoiceCustomer,
      items: [],
      paymentTerms: PaymentTerms.net30,
    );

    _isEditing = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Load an existing invoice for editing
  void loadInvoiceForEditing(Invoice invoice) {
    _currentInvoice = invoice;
    _isEditing = true;
    _errorMessage = null;
    notifyListeners();
  }

  // Update customer information
  void updateCustomer(InvoiceCustomer customer) {
    if (_currentInvoice == null) return;

    _currentInvoice = Invoice(
      id: _currentInvoice!.id,
      invoiceNumber: _currentInvoice!.invoiceNumber,
      date: _currentInvoice!.date,
      dueDate: _currentInvoice!.dueDate,
      status: _currentInvoice!.status,
      customer: customer,
      items: _currentInvoice!.items,
      paymentTerms: _currentInvoice!.paymentTerms,
      notes: _currentInvoice!.notes,
      terms: _currentInvoice!.terms,
      adjustmentValue: _currentInvoice!.adjustmentValue,
      isAdjustmentPercentage: _currentInvoice!.isAdjustmentPercentage,
      isAdjustmentPositive: _currentInvoice!.isAdjustmentPositive,
    );

    notifyListeners();
  }

  // Add a new item to the invoice
  void addItem(InvoiceItem item) {
    if (_currentInvoice == null) return;

    final updatedItems = List<InvoiceItem>.from(_currentInvoice!.items)..add(item);

    _currentInvoice = Invoice(
      id: _currentInvoice!.id,
      invoiceNumber: _currentInvoice!.invoiceNumber,
      date: _currentInvoice!.date,
      dueDate: _currentInvoice!.dueDate,
      status: _currentInvoice!.status,
      customer: _currentInvoice!.customer,
      items: updatedItems,
      paymentTerms: _currentInvoice!.paymentTerms,
      notes: _currentInvoice!.notes,
      terms: _currentInvoice!.terms,
      adjustmentValue: _currentInvoice!.adjustmentValue,
      isAdjustmentPercentage: _currentInvoice!.isAdjustmentPercentage,
      isAdjustmentPositive: _currentInvoice!.isAdjustmentPositive,
    );

    notifyListeners();
  }

  // Update an existing item in the invoice
  void updateItem(String itemId, InvoiceItem updatedItem) {
    if (_currentInvoice == null) return;

    final itemIndex = _currentInvoice!.items.indexWhere((item) => item.id == itemId);
    if (itemIndex == -1) return;

    final updatedItems = List<InvoiceItem>.from(_currentInvoice!.items);
    updatedItems[itemIndex] = updatedItem;

    _currentInvoice = Invoice(
      id: _currentInvoice!.id,
      invoiceNumber: _currentInvoice!.invoiceNumber,
      date: _currentInvoice!.date,
      dueDate: _currentInvoice!.dueDate,
      status: _currentInvoice!.status,
      customer: _currentInvoice!.customer,
      items: updatedItems,
      paymentTerms: _currentInvoice!.paymentTerms,
      notes: _currentInvoice!.notes,
      terms: _currentInvoice!.terms,
      adjustmentValue: _currentInvoice!.adjustmentValue,
      isAdjustmentPercentage: _currentInvoice!.isAdjustmentPercentage,
      isAdjustmentPositive: _currentInvoice!.isAdjustmentPositive,
    );

    notifyListeners();
  }

  // Remove an item from the invoice
  void removeItem(String itemId) {
    if (_currentInvoice == null) return;

    final updatedItems = List<InvoiceItem>.from(_currentInvoice!.items)
      ..removeWhere((item) => item.id == itemId);

    _currentInvoice = Invoice(
      id: _currentInvoice!.id,
      invoiceNumber: _currentInvoice!.invoiceNumber,
      date: _currentInvoice!.date,
      dueDate: _currentInvoice!.dueDate,
      status: _currentInvoice!.status,
      customer: _currentInvoice!.customer,
      items: updatedItems,
      paymentTerms: _currentInvoice!.paymentTerms,
      notes: _currentInvoice!.notes,
      terms: _currentInvoice!.terms,
      adjustmentValue: _currentInvoice!.adjustmentValue,
      isAdjustmentPercentage: _currentInvoice!.isAdjustmentPercentage,
      isAdjustmentPositive: _currentInvoice!.isAdjustmentPositive,
    );

    notifyListeners();
  }

  // Update invoice dates
  void updateDates({DateTime? date, DateTime? dueDate}) {
    if (_currentInvoice == null) return;

    _currentInvoice = Invoice(
      id: _currentInvoice!.id,
      invoiceNumber: _currentInvoice!.invoiceNumber,
      date: date ?? _currentInvoice!.date,
      dueDate: dueDate ?? _currentInvoice!.dueDate,
      status: _currentInvoice!.status,
      customer: _currentInvoice!.customer,
      items: _currentInvoice!.items,
      paymentTerms: _currentInvoice!.paymentTerms,
      notes: _currentInvoice!.notes,
      terms: _currentInvoice!.terms,
      adjustmentValue: _currentInvoice!.adjustmentValue,
      isAdjustmentPercentage: _currentInvoice!.isAdjustmentPercentage,
      isAdjustmentPositive: _currentInvoice!.isAdjustmentPositive,
    );

    notifyListeners();
  }

  // Update payment terms
  void updatePaymentTerms(PaymentTerms terms) {
    if (_currentInvoice == null) return;

    // Calculate new due date based on payment terms
    DateTime newDueDate;
    final now = DateTime.now();

    switch (terms) {
      case PaymentTerms.dueOnReceipt:
        newDueDate = now;
        break;
      case PaymentTerms.net15:
        newDueDate = now.add(const Duration(days: 15));
        break;
      case PaymentTerms.net30:
        newDueDate = now.add(const Duration(days: 30));
        break;
      case PaymentTerms.net45:
        newDueDate = now.add(const Duration(days: 45));
        break;
      case PaymentTerms.net60:
        newDueDate = now.add(const Duration(days: 60));
        break;
      default:
        newDueDate = _currentInvoice!.dueDate;
    }

    _currentInvoice = Invoice(
      id: _currentInvoice!.id,
      invoiceNumber: _currentInvoice!.invoiceNumber,
      date: _currentInvoice!.date,
      dueDate: newDueDate,
      status: _currentInvoice!.status,
      customer: _currentInvoice!.customer,
      items: _currentInvoice!.items,
      paymentTerms: terms,
      notes: _currentInvoice!.notes,
      terms: _currentInvoice!.terms,
      adjustmentValue: _currentInvoice!.adjustmentValue,
      isAdjustmentPercentage: _currentInvoice!.isAdjustmentPercentage,
      isAdjustmentPositive: _currentInvoice!.isAdjustmentPositive,
    );

    notifyListeners();
  }

  // Update notes and terms
  void updateNotesAndTerms({String? notes, String? terms}) {
    if (_currentInvoice == null) return;

    _currentInvoice = Invoice(
      id: _currentInvoice!.id,
      invoiceNumber: _currentInvoice!.invoiceNumber,
      date: _currentInvoice!.date,
      dueDate: _currentInvoice!.dueDate,
      status: _currentInvoice!.status,
      customer: _currentInvoice!.customer,
      items: _currentInvoice!.items,
      paymentTerms: _currentInvoice!.paymentTerms,
      notes: notes ?? _currentInvoice!.notes,
      terms: terms ?? _currentInvoice!.terms,
      adjustmentValue: _currentInvoice!.adjustmentValue,
      isAdjustmentPercentage: _currentInvoice!.isAdjustmentPercentage,
      isAdjustmentPositive: _currentInvoice!.isAdjustmentPositive,
    );

    notifyListeners();
  }

  // Update adjustment
  void updateAdjustment({
    double? value,
    bool? isPercentage,
    bool? isPositive,
  }) {
    if (_currentInvoice == null) return;

    _currentInvoice = Invoice(
      id: _currentInvoice!.id,
      invoiceNumber: _currentInvoice!.invoiceNumber,
      date: _currentInvoice!.date,
      dueDate: _currentInvoice!.dueDate,
      status: _currentInvoice!.status,
      customer: _currentInvoice!.customer,
      items: _currentInvoice!.items,
      paymentTerms: _currentInvoice!.paymentTerms,
      notes: _currentInvoice!.notes,
      terms: _currentInvoice!.terms,
      adjustmentValue: value ?? _currentInvoice!.adjustmentValue,
      isAdjustmentPercentage: isPercentage ?? _currentInvoice!.isAdjustmentPercentage,
      isAdjustmentPositive: isPositive ?? _currentInvoice!.isAdjustmentPositive,
    );

    notifyListeners();
  }

  // Validate the invoice before saving
  bool validateInvoice() {
    if (_currentInvoice == null) {
      _errorMessage = 'No invoice to save';
      notifyListeners();
      return false;
    }

    if (_currentInvoice!.items.isEmpty) {
      _errorMessage = 'Invoice must have at least one item';
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    return true;
  }

  // Clear current invoice and reset the editor
  void clearInvoice() {
    _currentInvoice = null;
    _isEditing = false;
    _errorMessage = null;
    notifyListeners();
  }
}
