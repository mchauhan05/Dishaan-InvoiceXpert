import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class IndianPaymentMethod {
  final String id;
  final String name;
  final String type; // Bank Transfer, NEFT, RTGS, IMPS, UPI, Cash, Cheque
  final bool isEnabled;
  final Map<String, dynamic> details;

  IndianPaymentMethod({
    required this.id,
    required this.name,
    required this.type,
    required this.isEnabled,
    required this.details,
  });

  factory IndianPaymentMethod.fromJson(Map<String, dynamic> json) {
    return IndianPaymentMethod(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      isEnabled: json['isEnabled'],
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'isEnabled': isEnabled,
      'details': details,
    };
  }
}

class IndianPaymentTransaction {
  final String id;
  final String invoiceId;
  final String customerId;
  final double amount;
  final String paymentMethodId;
  final String paymentMethodType;
  final DateTime date;
  final String reference;
  final String notes;
  final Map<String, dynamic> metadata;

  IndianPaymentTransaction({
    required this.id,
    required this.invoiceId,
    required this.customerId,
    required this.amount,
    required this.paymentMethodId,
    required this.paymentMethodType,
    required this.date,
    required this.reference,
    required this.notes,
    required this.metadata,
  });

  factory IndianPaymentTransaction.fromJson(Map<String, dynamic> json) {
    return IndianPaymentTransaction(
      id: json['id'],
      invoiceId: json['invoiceId'],
      customerId: json['customerId'],
      amount: json['amount'],
      paymentMethodId: json['paymentMethodId'],
      paymentMethodType: json['paymentMethodType'],
      date: DateTime.parse(json['date']),
      reference: json['reference'],
      notes: json['notes'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'customerId': customerId,
      'amount': amount,
      'paymentMethodId': paymentMethodId,
      'paymentMethodType': paymentMethodType,
      'date': date.toIso8601String(),
      'reference': reference,
      'notes': notes,
      'metadata': metadata,
    };
  }
}

class IndianPaymentProvider extends ChangeNotifier {
  List<IndianPaymentMethod> _paymentMethods = [];
  List<IndianPaymentTransaction> _paymentTransactions = [];

  List<IndianPaymentMethod> get paymentMethods => _paymentMethods;
  List<IndianPaymentTransaction> get paymentTransactions => _paymentTransactions;

  // Standard payment method types in India
  final List<String> _paymentMethodTypes = [
    'Bank Transfer',
    'NEFT',
    'RTGS',
    'IMPS',
    'UPI',
    'Cash',
    'Cheque',
    'Demand Draft'
  ];
  List<String> get paymentMethodTypes => _paymentMethodTypes;

  IndianPaymentProvider() {
    _loadPaymentMethods();
    _loadPaymentTransactions();
    _initializeDefaultMethods();
  }

  Future<void> _initializeDefaultMethods() async {
    // If no payment methods exist, create default ones
    if (_paymentMethods.isEmpty) {
      // Add default cash payment method
      await addPaymentMethod(
        name: 'Cash',
        type: 'Cash',
        details: {},
      );

      // Add default bank transfer method
      await addPaymentMethod(
        name: 'Bank Transfer',
        type: 'Bank Transfer',
        details: {
          'accountName': 'Company Account',
          'accountNumber': '',
          'ifscCode': '',
          'bankName': '',
          'branch': '',
        },
      );

      // Add default UPI method
      await addPaymentMethod(
        name: 'UPI',
        type: 'UPI',
        details: {
          'upiId': '',
          'qrCode': '',
        },
      );

      // Add default cheque method
      await addPaymentMethod(
        name: 'Cheque',
        type: 'Cheque',
        details: {
          'payableTo': 'Company Name',
          'instructions': 'Please make cheques payable to Company Name',
        },
      );
    }
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? methodsJson = prefs.getString('indianPaymentMethods');

      if (methodsJson != null && methodsJson.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(methodsJson);
        _paymentMethods = decodedList.map((item) => IndianPaymentMethod.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading Indian payment methods: $e');
    }
  }

  Future<void> _savePaymentMethods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> encodedList = _paymentMethods.map((method) => method.toJson()).toList();
      await prefs.setString('indianPaymentMethods', jsonEncode(encodedList));
    } catch (e) {
      debugPrint('Error saving Indian payment methods: $e');
    }
  }

  Future<void> _loadPaymentTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? transactionsJson = prefs.getString('indianPaymentTransactions');

      if (transactionsJson != null && transactionsJson.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(transactionsJson);
        _paymentTransactions = decodedList.map((item) => IndianPaymentTransaction.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading Indian payment transactions: $e');
    }
  }

  Future<void> _savePaymentTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> encodedList = _paymentTransactions.map((transaction) => transaction.toJson()).toList();
      await prefs.setString('indianPaymentTransactions', jsonEncode(encodedList));
    } catch (e) {
      debugPrint('Error saving Indian payment transactions: $e');
    }
  }

  Future<String> addPaymentMethod({
    required String name,
    required String type,
    required Map<String, dynamic> details,
    bool isEnabled = true,
  }) async {
    const uuid = Uuid();
    final id = uuid.v4();

    final paymentMethod = IndianPaymentMethod(
      id: id,
      name: name,
      type: type,
      isEnabled: isEnabled,
      details: details,
    );

    _paymentMethods.add(paymentMethod);
    await _savePaymentMethods();
    notifyListeners();

    return id;
  }

  Future<void> updatePaymentMethod({
    required String id,
    required String name,
    required String type,
    required bool isEnabled,
    required Map<String, dynamic> details,
  }) async {
    final index = _paymentMethods.indexWhere((method) => method.id == id);

    if (index != -1) {
      final updatedMethod = IndianPaymentMethod(
        id: id,
        name: name,
        type: type,
        isEnabled: isEnabled,
        details: details,
      );

      _paymentMethods[index] = updatedMethod;
      await _savePaymentMethods();
      notifyListeners();
    }
  }

  Future<void> deletePaymentMethod(String id) async {
    _paymentMethods.removeWhere((method) => method.id == id);
    await _savePaymentMethods();
    notifyListeners();
  }

  IndianPaymentMethod? getPaymentMethodById(String id) {
    try {
      return _paymentMethods.firstWhere((method) => method.id == id);
    } catch (e) {
      return null;
    }
  }

  List<IndianPaymentMethod> getPaymentMethodsByType(String type) {
    return _paymentMethods.where((method) => method.type == type).toList();
  }

  Future<String> recordPaymentTransaction({
    required String invoiceId,
    required String customerId,
    required double amount,
    required String paymentMethodId,
    required String paymentMethodType,
    required DateTime date,
    required String reference,
    String notes = '',
    Map<String, dynamic> metadata = const {},
  }) async {
    const uuid = Uuid();
    final id = uuid.v4();

    final transaction = IndianPaymentTransaction(
      id: id,
      invoiceId: invoiceId,
      customerId: customerId,
      amount: amount,
      paymentMethodId: paymentMethodId,
      paymentMethodType: paymentMethodType,
      date: date,
      reference: reference,
      notes: notes,
      metadata: metadata,
    );

    _paymentTransactions.add(transaction);
    await _savePaymentTransactions();
    notifyListeners();

    return id;
  }

  Future<void> updatePaymentTransaction({
    required String id,
    required String invoiceId,
    required String customerId,
    required double amount,
    required String paymentMethodId,
    required String paymentMethodType,
    required DateTime date,
    required String reference,
    required String notes,
    required Map<String, dynamic> metadata,
  }) async {
    final index = _paymentTransactions.indexWhere((transaction) => transaction.id == id);

    if (index != -1) {
      final updatedTransaction = IndianPaymentTransaction(
        id: id,
        invoiceId: invoiceId,
        customerId: customerId,
        amount: amount,
        paymentMethodId: paymentMethodId,
        paymentMethodType: paymentMethodType,
        date: date,
        reference: reference,
        notes: notes,
        metadata: metadata,
      );

      _paymentTransactions[index] = updatedTransaction;
      await _savePaymentTransactions();
      notifyListeners();
    }
  }

  Future<void> deletePaymentTransaction(String id) async {
    _paymentTransactions.removeWhere((transaction) => transaction.id == id);
    await _savePaymentTransactions();
    notifyListeners();
  }

  IndianPaymentTransaction? getPaymentTransactionById(String id) {
    try {
      return _paymentTransactions.firstWhere((transaction) => transaction.id == id);
    } catch (e) {
      return null;
    }
  }

  List<IndianPaymentTransaction> getPaymentTransactionsByInvoiceId(String invoiceId) {
    return _paymentTransactions.where((transaction) => transaction.invoiceId == invoiceId).toList();
  }

  List<IndianPaymentTransaction> getPaymentTransactionsByCustomerId(String customerId) {
    return _paymentTransactions.where((transaction) => transaction.customerId == customerId).toList();
  }

  List<IndianPaymentTransaction> getPaymentTransactionsByDateRange(DateTime start, DateTime end) {
    return _paymentTransactions.where((transaction) =>
      (transaction.date.isAfter(start) || transaction.date.isAtSameMomentAs(start)) &&
      (transaction.date.isBefore(end) || transaction.date.isAtSameMomentAs(end))
    ).toList();
  }

  double getTotalPaymentsForInvoice(String invoiceId) {
    final transactions = getPaymentTransactionsByInvoiceId(invoiceId);
    double total = 0;
    for (var transaction in transactions) {
      total += transaction.amount;
    }
    return total;
  }
}
