import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/customer_model.dart';
import '../services/database_service.dart';

class CustomerProvider extends ChangeNotifier {
  // Current customer being edited
  Customer? _currentCustomer;

  // List of all customers
  List<Customer> _customers = [];

  // Loading state
  bool _isLoading = false;

  // Error state
  String? _error;

  // Sample data - in a real app this would come from API/database
  Future<void> _loadSampleData() async {
    // Clear existing data
    _customers = [];

    // Add sample customers if none exist
    List<Customer> existingCustomers = await DatabaseService.loadCustomers();

    if (existingCustomers.isNotEmpty) {
      _customers = existingCustomers;
      return;
    }

    final now = DateTime.now();

    _customers.addAll([
      Customer(
        id: 'CUST001',
        displayName: 'Ethan Clark',
        companyName: 'Tech Innovations LLC',
        email: 'ethan.clark@example.com',
        phone: '(555) 123-4567',
        website: 'www.techinnovations.example.com',
        billingAddress: Address(
          street: '123 Main St',
          city: 'New York',
          state: 'NY',
          zipCode: '10001',
          country: 'United States',
        ),
        contacts: [
          Contact(
            firstName: 'Ethan',
            lastName: 'Clark',
            email: 'ethan.clark@example.com',
            phone: '(555) 123-4567',
            jobTitle: 'CEO',
            isPrimary: true,
          ),
        ],
        currency: 'USD',
        taxNumber: 'TAX-1234567',
        notes: 'VIP client, provide priority service',
        createdAt: now.subtract(const Duration(days: 180)),
        outstandingAmount: 0.00,
        totalInvoices: 5,
      ),
      Customer(
        id: 'CUST002',
        displayName: 'Sophia Hall',
        companyName: 'Digital Solutions Inc.',
        email: 'sophia.hall@example.com',
        phone: '(555) 234-5678',
        website: 'www.digitalsolutions.example.com',
        billingAddress: Address(
          street: '456 Oak Ave',
          city: 'San Francisco',
          state: 'CA',
          zipCode: '94103',
          country: 'United States',
        ),
        contacts: [
          Contact(
            firstName: 'Sophia',
            lastName: 'Hall',
            email: 'sophia.hall@example.com',
            phone: '(555) 234-5678',
            jobTitle: 'Marketing Director',
            isPrimary: true,
          ),
          Contact(
            firstName: 'Mike',
            lastName: 'Peterson',
            email: 'mike.peterson@example.com',
            phone: '(555) 876-5432',
            jobTitle: 'Accounts Manager',
            isPrimary: false,
          ),
        ],
        currency: 'USD',
        taxNumber: 'TAX-7654321',
        notes: 'Prefers email communication',
        createdAt: now.subtract(const Duration(days: 120)),
        outstandingAmount: 780.50,
        totalInvoices: 3,
      ),
      Customer(
        id: 'CUST003',
        displayName: 'James Wilson',
        companyName: 'Creative Designs Co.',
        email: 'james.wilson@example.com',
        phone: '(555) 345-6789',
        website: 'www.creativedesigns.example.com',
        billingAddress: Address(
          street: '789 Pine Rd',
          city: 'Chicago',
          state: 'IL',
          zipCode: '60007',
          country: 'United States',
        ),
        contacts: [
          Contact(
            firstName: 'James',
            lastName: 'Wilson',
            email: 'james.wilson@example.com',
            phone: '(555) 345-6789',
            jobTitle: 'Owner',
            isPrimary: true,
          ),
        ],
        currency: 'USD',
        createdAt: now.subtract(const Duration(days: 90)),
        outstandingAmount: 2340.00,
        totalInvoices: 2,
      ),
      Customer(
        id: 'CUST004',
        displayName: 'Emma Davis',
        companyName: 'Bright Ideas Ltd.',
        email: 'emma.davis@example.com',
        phone: '(555) 456-7890',
        website: 'www.brightideas.example.com',
        billingAddress: Address(
          street: '321 Cedar Ln',
          city: 'Miami',
          state: 'FL',
          zipCode: '33101',
          country: 'United States',
        ),
        contacts: [
          Contact(
            firstName: 'Emma',
            lastName: 'Davis',
            email: 'emma.davis@example.com',
            phone: '(555) 456-7890',
            mobile: '(555) 987-6543',
            jobTitle: 'Founder',
            isPrimary: true,
          ),
        ],
        currency: 'USD',
        taxNumber: 'TAX-9876543',
        createdAt: now.subtract(const Duration(days: 60)),
        outstandingAmount: 1830.25,
        totalInvoices: 1,
      ),
      Customer(
        id: 'CUST005',
        displayName: 'Oliver Brown',
        companyName: 'Global Ventures Group',
        email: 'oliver.brown@example.com',
        phone: '(555) 567-8901',
        website: 'www.globalventures.example.com',
        billingAddress: Address(
          street: '654 Maple Dr',
          city: 'Seattle',
          state: 'WA',
          zipCode: '98101',
          country: 'United States',
        ),
        shippingAddress: Address(
          street: '987 Elm St',
          city: 'Seattle',
          state: 'WA',
          zipCode: '98102',
          country: 'United States',
        ),
        contacts: [
          Contact(
            firstName: 'Oliver',
            lastName: 'Brown',
            email: 'oliver.brown@example.com',
            phone: '(555) 567-8901',
            jobTitle: 'CEO',
            isPrimary: true,
          ),
          Contact(
            firstName: 'Mia',
            lastName: 'Fisher',
            email: 'mia.fisher@example.com',
            phone: '(555) 234-5678',
            mobile: '(555) 111-2222',
            jobTitle: 'Office Manager',
            isPrimary: false,
          ),
        ],
        currency: 'USD',
        taxNumber: 'TAX-8765432',
        notes: 'International shipping required for products',
        createdAt: now.subtract(const Duration(days: 30)),
        outstandingAmount: 0.00,
        totalInvoices: 4,
      ),
    ]);

    // Save loaded sample data to storage
    await DatabaseService.saveCustomers(_customers);
  }

  // Constructor - load data
  CustomerProvider() {
    _loadData();
  }

  // Load data from storage or initialize with sample data
  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadSampleData();
      _error = null;
    } catch (e) {
      _error = 'Failed to load customer data: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Getters
  List<Customer> get customers => _customers;
  Customer? get currentCustomer => _currentCustomer;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize a new customer
  void initNewCustomer() {
    // Generate a new ID
    final newId = 'CUST${_customers.length + 1}'.padLeft(7, '0');

    // Create empty address
    final emptyAddress = Address(
      street: '',
      city: '',
      state: '',
      zipCode: '',
      country: 'United States', // Default
    );

    // Create empty contact
    final emptyContact = Contact(
      firstName: '',
      lastName: '',
      email: '',
      phone: '',
      isPrimary: true,
    );

    // Create new customer with default values
    _currentCustomer = Customer(
      id: newId,
      displayName: '',
      companyName: '',
      email: '',
      phone: '',
      billingAddress: emptyAddress,
      contacts: [emptyContact],
      createdAt: DateTime.now(),
    );

    notifyListeners();
  }

  // Load customer for editing
  void loadCustomerForEditing(String customerId) {
    try {
      _currentCustomer = _customers.firstWhere((customer) => customer.id == customerId);
      notifyListeners();
    } catch (e) {
      print('Customer not found: $customerId');
      _error = 'Customer not found: $customerId';
      notifyListeners();
    }
  }

  // Save current customer
  Future<bool> saveCustomer({
    required String displayName,
    required String companyName,
    required String email,
    required String phone,
    String website = '',
    required Address billingAddress,
    Address? shippingAddress,
    required List<Contact> contacts,
    String currency = 'USD',
    String? taxNumber,
    String? notes,
    CustomerStatus status = CustomerStatus.active,
  }) async {
    if (_currentCustomer == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedCustomer = _currentCustomer!.copyWith(
        displayName: displayName,
        companyName: companyName,
        email: email,
        phone: phone,
        website: website,
        billingAddress: billingAddress,
        shippingAddress: shippingAddress,
        contacts: contacts,
        currency: currency,
        taxNumber: taxNumber,
        notes: notes,
        status: status,
      );

      // Check if this is a new customer or an update
      final existingIndex = _customers.indexWhere((c) => c.id == _currentCustomer!.id);
      if (existingIndex >= 0) {
        // Update existing customer
        _customers[existingIndex] = updatedCustomer;
      } else {
        // Add new customer
        _customers.add(updatedCustomer);
      }

      _currentCustomer = updatedCustomer;

      // Save to database
      final success = await DatabaseService.saveCustomers(_customers);
      _error = success ? null : 'Failed to save customer data';

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Error saving customer: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete a customer
  Future<bool> deleteCustomer(String customerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _customers.removeWhere((customer) => customer.id == customerId);
      if (_currentCustomer?.id == customerId) {
        _currentCustomer = null;
      }

      // Save to database
      final success = await DatabaseService.saveCustomers(_customers);
      _error = success ? null : 'Failed to delete customer';

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Error deleting customer: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Filter customers by text search
  List<Customer> searchCustomers(String query) {
    if (query.isEmpty) return _customers;

    final lowercaseQuery = query.toLowerCase();
    return _customers.where((customer) {
      return customer.displayName.toLowerCase().contains(lowercaseQuery) ||
             customer.companyName.toLowerCase().contains(lowercaseQuery) ||
             customer.email.toLowerCase().contains(lowercaseQuery) ||
             customer.phone.contains(query);
    }).toList();
  }

  // Filter customers by status
  List<Customer> filterCustomersByStatus(CustomerStatus status) {
    return _customers.where((customer) => customer.status == status).toList();
  }

  // Get customers with outstanding balance
  List<Customer> get customersWithOutstandingBalance {
    return _customers.where((customer) => customer.outstandingAmount > 0).toList();
  }

  // Format date for display
  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // Format currency for display
  String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
  }

  // Refresh data from storage
  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<Customer> loadedCustomers = await DatabaseService.loadCustomers();
      if (loadedCustomers.isNotEmpty) {
        _customers = loadedCustomers;
        _error = null;
      } else {
        await _loadSampleData();
      }
    } catch (e) {
      _error = 'Failed to refresh customer data: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update customer details
  Future<bool> updateCustomerDetails(Customer updatedCustomer) async {
    _isLoading = true;
    notifyListeners();

    try {
      final index = _customers.indexWhere((c) => c.id == updatedCustomer.id);
      if (index >= 0) {
        _customers[index] = updatedCustomer;
        if (_currentCustomer?.id == updatedCustomer.id) {
          _currentCustomer = updatedCustomer;
        }

        // Save to database
        final success = await DatabaseService.saveCustomers(_customers);
        _error = success ? null : 'Failed to update customer details';

        _isLoading = false;
        notifyListeners();
        return success;
      } else {
        _error = 'Customer not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error updating customer: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
