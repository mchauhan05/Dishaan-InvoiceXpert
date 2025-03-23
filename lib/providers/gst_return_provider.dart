import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GstReturn {
  final String id;
  final String returnType; // GSTR-1, GSTR-2, GSTR-3B, etc.
  final String period; // Format: MM-YYYY
  final DateTime filingDate;
  final double totalTaxableValue;
  final double totalCgst;
  final double totalSgst;
  final double totalIgst;
  final double totalCess;
  final double totalTax;
  final String status; // Draft, Filed, Verified
  final String gstin;
  final String arnNumber; // Acknowledgment Reference Number
  final List<GstReturnSection> sections;

  GstReturn({
    required this.id,
    required this.returnType,
    required this.period,
    required this.filingDate,
    required this.totalTaxableValue,
    required this.totalCgst,
    required this.totalSgst,
    required this.totalIgst,
    required this.totalCess,
    required this.totalTax,
    required this.status,
    required this.gstin,
    required this.arnNumber,
    required this.sections,
  });

  factory GstReturn.fromJson(Map<String, dynamic> json) {
    return GstReturn(
      id: json['id'],
      returnType: json['returnType'],
      period: json['period'],
      filingDate: DateTime.parse(json['filingDate']),
      totalTaxableValue: json['totalTaxableValue'],
      totalCgst: json['totalCgst'],
      totalSgst: json['totalSgst'],
      totalIgst: json['totalIgst'],
      totalCess: json['totalCess'],
      totalTax: json['totalTax'],
      status: json['status'],
      gstin: json['gstin'],
      arnNumber: json['arnNumber'],
      sections: (json['sections'] as List)
          .map((section) => GstReturnSection.fromJson(section))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'returnType': returnType,
      'period': period,
      'filingDate': filingDate.toIso8601String(),
      'totalTaxableValue': totalTaxableValue,
      'totalCgst': totalCgst,
      'totalSgst': totalSgst,
      'totalIgst': totalIgst,
      'totalCess': totalCess,
      'totalTax': totalTax,
      'status': status,
      'gstin': gstin,
      'arnNumber': arnNumber,
      'sections': sections.map((section) => section.toJson()).toList(),
    };
  }
}

class GstReturnSection {
  final String id;
  final String name; // e.g., "B2B", "B2C", "CDNR", etc.
  final String description;
  final double totalTaxableValue;
  final double totalTax;
  final List<GstReturnTransaction> transactions;

  GstReturnSection({
    required this.id,
    required this.name,
    required this.description,
    required this.totalTaxableValue,
    required this.totalTax,
    required this.transactions,
  });

  factory GstReturnSection.fromJson(Map<String, dynamic> json) {
    return GstReturnSection(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      totalTaxableValue: json['totalTaxableValue'],
      totalTax: json['totalTax'],
      transactions: (json['transactions'] as List)
          .map((transaction) => GstReturnTransaction.fromJson(transaction))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'totalTaxableValue': totalTaxableValue,
      'totalTax': totalTax,
      'transactions': transactions.map((transaction) => transaction.toJson()).toList(),
    };
  }
}

class GstReturnTransaction {
  final String id;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final String customerGstin;
  final String customerName;
  final String placeOfSupply;
  final String hsnSac;
  final double taxableValue;
  final double cgstRate;
  final double cgstAmount;
  final double sgstRate;
  final double sgstAmount;
  final double igstRate;
  final double igstAmount;
  final double cessRate;
  final double cessAmount;

  GstReturnTransaction({
    required this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.customerGstin,
    required this.customerName,
    required this.placeOfSupply,
    required this.hsnSac,
    required this.taxableValue,
    required this.cgstRate,
    required this.cgstAmount,
    required this.sgstRate,
    required this.sgstAmount,
    required this.igstRate,
    required this.igstAmount,
    required this.cessRate,
    required this.cessAmount,
  });

  factory GstReturnTransaction.fromJson(Map<String, dynamic> json) {
    return GstReturnTransaction(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      invoiceDate: DateTime.parse(json['invoiceDate']),
      customerGstin: json['customerGstin'],
      customerName: json['customerName'],
      placeOfSupply: json['placeOfSupply'],
      hsnSac: json['hsnSac'],
      taxableValue: json['taxableValue'],
      cgstRate: json['cgstRate'],
      cgstAmount: json['cgstAmount'],
      sgstRate: json['sgstRate'],
      sgstAmount: json['sgstAmount'],
      igstRate: json['igstRate'],
      igstAmount: json['igstAmount'],
      cessRate: json['cessRate'],
      cessAmount: json['cessAmount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'invoiceDate': invoiceDate.toIso8601String(),
      'customerGstin': customerGstin,
      'customerName': customerName,
      'placeOfSupply': placeOfSupply,
      'hsnSac': hsnSac,
      'taxableValue': taxableValue,
      'cgstRate': cgstRate,
      'cgstAmount': cgstAmount,
      'sgstRate': sgstRate,
      'sgstAmount': sgstAmount,
      'igstRate': igstRate,
      'igstAmount': igstAmount,
      'cessRate': cessRate,
      'cessAmount': cessAmount,
    };
  }
}

class GstReturnProvider extends ChangeNotifier {
  List<GstReturn> _gstReturns = [];
  List<GstReturn> get gstReturns => _gstReturns;

  // Mock data for initial development
  final List<String> _returnTypes = ['GSTR-1', 'GSTR-2', 'GSTR-3B', 'GSTR-9'];
  List<String> get returnTypes => _returnTypes;

  final List<String> _statuses = ['Draft', 'Filed', 'Verified'];
  List<String> get statuses => _statuses;

  GstReturnProvider() {
    _loadGstReturns();
  }

  Future<void> _loadGstReturns() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? gstReturnsJson = prefs.getString('gstReturns');

      if (gstReturnsJson != null && gstReturnsJson.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(gstReturnsJson);
        _gstReturns = decodedList.map((item) => GstReturn.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading GST returns: $e');
    }
  }

  Future<void> _saveGstReturns() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> encodedList = _gstReturns.map((gstReturn) => gstReturn.toJson()).toList();
      await prefs.setString('gstReturns', jsonEncode(encodedList));
    } catch (e) {
      debugPrint('Error saving GST returns: $e');
    }
  }

  Future<String> createGstReturn({
    required String returnType,
    required String period,
    required DateTime filingDate,
    required double totalTaxableValue,
    required double totalCgst,
    required double totalSgst,
    required double totalIgst,
    required double totalCess,
    required String status,
    required String gstin,
    required List<GstReturnSection> sections,
  }) async {
    const uuid = Uuid();
    final id = uuid.v4();

    // Calculate total tax
    final totalTax = totalCgst + totalSgst + totalIgst + totalCess;

    // Generate a random ARN number (in real implementation, this would come from the GST portal)
    final arnNumber = status == 'Draft' ? '' : 'ARN${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    final gstReturn = GstReturn(
      id: id,
      returnType: returnType,
      period: period,
      filingDate: filingDate,
      totalTaxableValue: totalTaxableValue,
      totalCgst: totalCgst,
      totalSgst: totalSgst,
      totalIgst: totalIgst,
      totalCess: totalCess,
      totalTax: totalTax,
      status: status,
      gstin: gstin,
      arnNumber: arnNumber,
      sections: sections,
    );

    _gstReturns.add(gstReturn);
    await _saveGstReturns();
    notifyListeners();

    return id;
  }

  Future<void> updateGstReturn({
    required String id,
    required String returnType,
    required String period,
    required DateTime filingDate,
    required double totalTaxableValue,
    required double totalCgst,
    required double totalSgst,
    required double totalIgst,
    required double totalCess,
    required String status,
    required String gstin,
    required List<GstReturnSection> sections,
  }) async {
    final index = _gstReturns.indexWhere((gstReturn) => gstReturn.id == id);

    if (index != -1) {
      // Calculate total tax
      final totalTax = totalCgst + totalSgst + totalIgst + totalCess;

      // Generate ARN if status changes from Draft to Filed or Verified
      String arnNumber = _gstReturns[index].arnNumber;
      if (_gstReturns[index].status == 'Draft' && status != 'Draft') {
        arnNumber = 'ARN${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      }

      final updatedReturn = GstReturn(
        id: id,
        returnType: returnType,
        period: period,
        filingDate: filingDate,
        totalTaxableValue: totalTaxableValue,
        totalCgst: totalCgst,
        totalSgst: totalSgst,
        totalIgst: totalIgst,
        totalCess: totalCess,
        totalTax: totalTax,
        status: status,
        gstin: gstin,
        arnNumber: arnNumber,
        sections: sections,
      );

      _gstReturns[index] = updatedReturn;
      await _saveGstReturns();
      notifyListeners();
    }
  }

  Future<void> deleteGstReturn(String id) async {
    _gstReturns.removeWhere((gstReturn) => gstReturn.id == id);
    await _saveGstReturns();
    notifyListeners();
  }

  GstReturn? getGstReturnById(String id) {
    try {
      return _gstReturns.firstWhere((gstReturn) => gstReturn.id == id);
    } catch (e) {
      return null;
    }
  }

  List<GstReturn> getGstReturnsByPeriod(String period) {
    return _gstReturns.where((gstReturn) => gstReturn.period == period).toList();
  }

  List<GstReturn> getGstReturnsByType(String returnType) {
    return _gstReturns.where((gstReturn) => gstReturn.returnType == returnType).toList();
  }

  List<GstReturn> getGstReturnsByGstin(String gstin) {
    return _gstReturns.where((gstReturn) => gstReturn.gstin == gstin).toList();
  }

  // Create a GST return section
  GstReturnSection createGstReturnSection({
    required String name,
    required String description,
    required double totalTaxableValue,
    required double totalTax,
    required List<GstReturnTransaction> transactions,
  }) {
    const uuid = Uuid();
    final id = uuid.v4();

    return GstReturnSection(
      id: id,
      name: name,
      description: description,
      totalTaxableValue: totalTaxableValue,
      totalTax: totalTax,
      transactions: transactions,
    );
  }

  // Create a GST return transaction
  GstReturnTransaction createGstReturnTransaction({
    required String invoiceNumber,
    required DateTime invoiceDate,
    required String customerGstin,
    required String customerName,
    required String placeOfSupply,
    required String hsnSac,
    required double taxableValue,
    required double cgstRate,
    required double cgstAmount,
    required double sgstRate,
    required double sgstAmount,
    required double igstRate,
    required double igstAmount,
    required double cessRate,
    required double cessAmount,
  }) {
    const uuid = Uuid();
    final id = uuid.v4();

    return GstReturnTransaction(
      id: id,
      invoiceNumber: invoiceNumber,
      invoiceDate: invoiceDate,
      customerGstin: customerGstin,
      customerName: customerName,
      placeOfSupply: placeOfSupply,
      hsnSac: hsnSac,
      taxableValue: taxableValue,
      cgstRate: cgstRate,
      cgstAmount: cgstAmount,
      sgstRate: sgstRate,
      sgstAmount: sgstAmount,
      igstRate: igstRate,
      igstAmount: igstAmount,
      cessRate: cessRate,
      cessAmount: cessAmount,
    );
  }
}
