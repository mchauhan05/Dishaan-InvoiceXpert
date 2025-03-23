import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/upi_payment_model.dart';
import '../models/invoice_models.dart';

/// Provider to manage UPI payment functionality
class UpiPaymentProvider extends ChangeNotifier {
  List<UPIDetails> _upiAccounts = [];
  UPIDetails? _primaryUpiAccount;
  bool _isLoading = false;
  List<UPIPaymentStatus> _recentPayments = [];

  // Getters
  List<UPIDetails> get upiAccounts => _upiAccounts;
  UPIDetails? get primaryUpiAccount => _primaryUpiAccount;
  bool get isLoading => _isLoading;
  List<UPIPaymentStatus> get recentPayments => _recentPayments;

  // Initialize the provider
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await _loadUpiAccounts();
    await _loadRecentPayments();

    _isLoading = false;
    notifyListeners();
  }

  // Load UPI accounts from shared preferences
  Future<void> _loadUpiAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final upiAccountsJson = prefs.getString('upi_accounts');

    if (upiAccountsJson != null) {
      final List<dynamic> decodedList = jsonDecode(upiAccountsJson);
      _upiAccounts = decodedList.map((json) => UPIDetails.fromJson(json)).toList();

      // Find primary account
      _primaryUpiAccount = _upiAccounts.firstWhere(
        (account) => account.primary,
        orElse: () => _upiAccounts.isNotEmpty ? _upiAccounts.first : null,
      );
    }
  }

  // Save UPI accounts to shared preferences
  Future<void> _saveUpiAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedList = jsonEncode(_upiAccounts.map((account) => account.toJson()).toList());
    await prefs.setString('upi_accounts', encodedList);
  }

  // Add a new UPI account
  Future<void> addUpiAccount(UPIDetails account) async {
    _isLoading = true;
    notifyListeners();

    // If this is the first account or marked as primary, set it as primary
    if (_upiAccounts.isEmpty || account.primary) {
      // If there's already a primary account, update it
      if (_primaryUpiAccount != null) {
        final index = _upiAccounts.indexWhere((a) => a.primary);
        if (index != -1) {
          _upiAccounts[index] = _upiAccounts[index].copyWith(primary: false);
        }
      }

      _primaryUpiAccount = account;
    }

    _upiAccounts.add(account);
    await _saveUpiAccounts();

    _isLoading = false;
    notifyListeners();
  }

  // Update an existing UPI account
  Future<void> updateUpiAccount(String upiId, UPIDetails updatedAccount) async {
    _isLoading = true;
    notifyListeners();

    final index = _upiAccounts.indexWhere((account) => account.upiId == upiId);

    if (index != -1) {
      // If this account is being set as primary, update the previous primary
      if (updatedAccount.primary && !_upiAccounts[index].primary) {
        final primaryIndex = _upiAccounts.indexWhere((a) => a.primary);
        if (primaryIndex != -1) {
          _upiAccounts[primaryIndex] = _upiAccounts[primaryIndex].copyWith(primary: false);
        }
        _primaryUpiAccount = updatedAccount;
      }

      // If this was the primary account but is no longer primary
      if (!updatedAccount.primary && _upiAccounts[index].primary) {
        // If there are other accounts, set the first one as primary
        if (_upiAccounts.length > 1) {
          final newPrimaryIndex = index == 0 ? 1 : 0;
          _upiAccounts[newPrimaryIndex] = _upiAccounts[newPrimaryIndex].copyWith(primary: true);
          _primaryUpiAccount = _upiAccounts[newPrimaryIndex];
        } else {
          _primaryUpiAccount = null;
        }
      }

      _upiAccounts[index] = updatedAccount;
      await _saveUpiAccounts();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Remove a UPI account
  Future<void> removeUpiAccount(String upiId) async {
    _isLoading = true;
    notifyListeners();

    final index = _upiAccounts.indexWhere((account) => account.upiId == upiId);

    if (index != -1) {
      final isRemovingPrimary = _upiAccounts[index].primary;
      _upiAccounts.removeAt(index);

      // If we removed the primary account and there are other accounts,
      // set a new primary account
      if (isRemovingPrimary && _upiAccounts.isNotEmpty) {
        _upiAccounts[0] = _upiAccounts[0].copyWith(primary: true);
        _primaryUpiAccount = _upiAccounts[0];
      } else if (_upiAccounts.isEmpty) {
        _primaryUpiAccount = null;
      }

      await _saveUpiAccounts();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Set a UPI account as primary
  Future<void> setPrimaryUpiAccount(String upiId) async {
    _isLoading = true;
    notifyListeners();

    // Clear primary flag from current primary account
    final currentPrimaryIndex = _upiAccounts.indexWhere((account) => account.primary);
    if (currentPrimaryIndex != -1) {
      _upiAccounts[currentPrimaryIndex] = _upiAccounts[currentPrimaryIndex].copyWith(primary: false);
    }

    // Set new primary account
    final newPrimaryIndex = _upiAccounts.indexWhere((account) => account.upiId == upiId);
    if (newPrimaryIndex != -1) {
      _upiAccounts[newPrimaryIndex] = _upiAccounts[newPrimaryIndex].copyWith(primary: true);
      _primaryUpiAccount = _upiAccounts[newPrimaryIndex];
    }

    await _saveUpiAccounts();

    _isLoading = false;
    notifyListeners();
  }

  // Generate a UPI payment link for an invoice
  String generateUpiPaymentLink(Invoice invoice, {UPIDetails? account}) {
    final upiAccount = account ?? _primaryUpiAccount;

    if (upiAccount == null) {
      throw Exception('No UPI account available for payment');
    }

    final UPIQRCode qrCode = UPIQRCode(
      upiId: upiAccount.upiId,
      payeeName: upiAccount.payeeName,
      amount: invoice.calculateTotal(),
      transactionNote: 'Payment for Invoice #${invoice.invoiceNumber}',
      merchantCode: upiAccount.merchantCode,
      referenceId: invoice.invoiceNumber,
    );

    return qrCode.generateUpiUri();
  }

  // Launch a UPI payment app
  Future<bool> launchUpiApp(UPIApp app, String upiUri) async {
    if (app.urlScheme != null) {
      // Try to launch with URL scheme (works on iOS and some Android devices)
      final Uri uriScheme = Uri.parse('${app.urlScheme}pay?${upiUri.split('?')[1]}');
      if (await canLaunchUrl(uriScheme)) {
        return launchUrl(uriScheme);
      }
    }

    // For Android intent
    final Uri androidIntent = Uri.parse('intent://${upiUri.substring(6)}#Intent;package=${app.packageName};scheme=upi;end');
    if (await canLaunchUrl(androidIntent)) {
      return launchUrl(androidIntent);
    }

    // Fallback to normal URL
    final Uri normalUri = Uri.parse(upiUri);
    if (await canLaunchUrl(normalUri)) {
      return launchUrl(normalUri);
    }

    return false;
  }

  // Load recent payments from storage
  Future<void> _loadRecentPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final recentPaymentsJson = prefs.getString('recent_payments');

    if (recentPaymentsJson != null) {
      final List<dynamic> decodedList = jsonDecode(recentPaymentsJson);
      _recentPayments = decodedList.map((json) => UPIPaymentStatus.fromJson(json)).toList();
    }
  }

  // Save recent payments to storage
  Future<void> _saveRecentPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedList = jsonEncode(_recentPayments.map((payment) => payment.toJson()).toList());
    await prefs.setString('recent_payments', encodedList);
  }

  // Add a payment status to recent payments
  Future<void> addPaymentStatus(UPIPaymentStatus paymentStatus) async {
    _recentPayments.insert(0, paymentStatus);

    // Keep only the 20 most recent payments
    if (_recentPayments.length > 20) {
      _recentPayments = _recentPayments.sublist(0, 20);
    }

    await _saveRecentPayments();
    notifyListeners();
  }

  // Verify a payment using a mock API (in a real app, this would call your backend)
  Future<UPIPaymentStatus?> verifyPayment(String referenceId) async {
    try {
      // In a real app, this would be an API call to your backend
      // Here we're just simulating it with a delay and a mock response
      await Future.delayed(Duration(seconds: 2));

      // Look for the payment in recent payments
      final existingPayment = _recentPayments.firstWhere(
        (payment) => payment.referenceId == referenceId,
        orElse: () => null,
      );

      if (existingPayment != null) {
        return existingPayment;
      }

      // Simulate a random payment status for demo purposes
      final status = ['SUCCESS', 'PENDING', 'FAILURE'][DateTime.now().second % 3];

      final paymentStatus = UPIPaymentStatus(
        transactionId: 'TX${DateTime.now().millisecondsSinceEpoch}',
        referenceId: referenceId,
        amount: 1000.0, // This would be the actual amount in a real app
        status: status,
        timestamp: DateTime.now(),
        responseCode: status == 'SUCCESS' ? '00' : (status == 'PENDING' ? 'P1' : 'F1'),
        responseMessage: status == 'SUCCESS' ? 'Payment successful' :
                         (status == 'PENDING' ? 'Payment pending' : 'Payment failed'),
      );

      await addPaymentStatus(paymentStatus);
      return paymentStatus;
    } catch (e) {
      print('Error verifying payment: $e');
      return null;
    }
  }

  // Copy UPI ID to clipboard
  Future<bool> copyUpiIdToClipboard(String upiId) async {
    try {
      await Clipboard.setData(ClipboardData(text: upiId));
      return true;
    } catch (e) {
      print('Error copying UPI ID: $e');
      return false;
    }
  }
}
