// lib/providers/customer_provider.dart

import 'package:flutter/foundation.dart';
import 'package:dishaan_invoice_xpert/models/customer.dart';
import 'package:dishaan_invoice_xpert/services/database/customer_db.dart';

class CustomerProvider with ChangeNotifier {
  final CustomerDatabase _customerDb = CustomerDatabase();
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Customer> get customers => _customers;
  List<Customer> get filteredCustomers => _filteredCustomers;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  Future<void> loadCustomers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _customers = await _customerDb.getAllCustomers();
      _applyFilter();
    } catch (e) {
      debugPrint('Error loading customers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Customer?> getCustomer(int id) async {
    return await _customerDb.getCustomer(id);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredCustomers = List.from(_customers);
    } else {
      _filteredCustomers = _customers.where((customer) {
        final name = customer.name.toLowerCase();
        final phone = customer.phone?.toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || phone.contains(query);
      }).toList();
    }
  }

  Future<bool> addCustomer(Customer customer) async {
    try {
      final id = await _customerDb.insertCustomer(customer);
      final newCustomer = customer.copyWith(id: id);
      _customers.add(newCustomer);
      _applyFilter();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding customer: $e');
      return false;
    }
  }

  Future<bool> updateCustomer(Customer customer) async {
    try {
      await _customerDb.updateCustomer(customer);
      final index = _customers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        _customers[index] = customer;
        _applyFilter();
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error updating customer: $e');
      return false;
    }
  }

  Future<bool> deleteCustomer(int id) async {
    try {
      await _customerDb.deleteCustomer(id);
      _customers.removeWhere((customer) => customer.id == id);
      _applyFilter();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting customer: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getCustomerPurchaseHistory(int customerId) async {
    return await _customerDb.getCustomerPurchaseHistory(customerId);
  }

  Future<Map<String, dynamic>> getCustomerStatistics(int customerId) async {
    return await _customerDb.getCustomerStatistics(customerId);
  }
}