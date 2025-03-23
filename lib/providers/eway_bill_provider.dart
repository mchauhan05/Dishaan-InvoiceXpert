import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EwayBill {
  final String id;
  final String billNumber;
  final String fromGstin;
  final String toGstin;
  final String transporterId;
  final String vehicleNumber;
  final DateTime validFrom;
  final DateTime validUntil;
  final double totalValue;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final String documentType;
  final String documentNumber;
  final List<EwayBillItem> items;

  EwayBill({
    required this.id,
    required this.billNumber,
    required this.fromGstin,
    required this.toGstin,
    required this.transporterId,
    required this.vehicleNumber,
    required this.validFrom,
    required this.validUntil,
    required this.totalValue,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.documentType,
    required this.documentNumber,
    required this.items,
  });

  factory EwayBill.fromJson(Map<String, dynamic> json) {
    return EwayBill(
      id: json['id'],
      billNumber: json['billNumber'],
      fromGstin: json['fromGstin'],
      toGstin: json['toGstin'],
      transporterId: json['transporterId'],
      vehicleNumber: json['vehicleNumber'],
      validFrom: DateTime.parse(json['validFrom']),
      validUntil: DateTime.parse(json['validUntil']),
      totalValue: json['totalValue'],
      cgstAmount: json['cgstAmount'],
      sgstAmount: json['sgstAmount'],
      igstAmount: json['igstAmount'],
      documentType: json['documentType'],
      documentNumber: json['documentNumber'],
      items: (json['items'] as List)
          .map((item) => EwayBillItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'billNumber': billNumber,
      'fromGstin': fromGstin,
      'toGstin': toGstin,
      'transporterId': transporterId,
      'vehicleNumber': vehicleNumber,
      'validFrom': validFrom.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'totalValue': totalValue,
      'cgstAmount': cgstAmount,
      'sgstAmount': sgstAmount,
      'igstAmount': igstAmount,
      'documentType': documentType,
      'documentNumber': documentNumber,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class EwayBillItem {
  final String id;
  final String productName;
  final double quantity;
  final String unit;
  final double taxableAmount;
  final double taxRate;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;

  EwayBillItem({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.taxableAmount,
    required this.taxRate,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
  });

  factory EwayBillItem.fromJson(Map<String, dynamic> json) {
    return EwayBillItem(
      id: json['id'],
      productName: json['productName'],
      quantity: json['quantity'],
      unit: json['unit'],
      taxableAmount: json['taxableAmount'],
      taxRate: json['taxRate'],
      cgstAmount: json['cgstAmount'],
      sgstAmount: json['sgstAmount'],
      igstAmount: json['igstAmount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productName': productName,
      'quantity': quantity,
      'unit': unit,
      'taxableAmount': taxableAmount,
      'taxRate': taxRate,
      'cgstAmount': cgstAmount,
      'sgstAmount': sgstAmount,
      'igstAmount': igstAmount,
    };
  }
}

class EwayBillProvider extends ChangeNotifier {
  List<EwayBill> _ewayBills = [];
  List<EwayBill> get ewayBills => _ewayBills;

  // Mock data for initial development
  final List<String> _documentTypes = ['Invoice', 'Bill of Supply', 'Delivery Challan', 'Bill of Entry'];
  List<String> get documentTypes => _documentTypes;

  EwayBillProvider() {
    _loadEwayBills();
  }

  Future<void> _loadEwayBills() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? ewayBillsJson = prefs.getString('ewayBills');

      if (ewayBillsJson != null && ewayBillsJson.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(ewayBillsJson);
        _ewayBills = decodedList.map((item) => EwayBill.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading e-way bills: $e');
    }
  }

  Future<void> _saveEwayBills() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> encodedList = _ewayBills.map((bill) => bill.toJson()).toList();
      await prefs.setString('ewayBills', jsonEncode(encodedList));
    } catch (e) {
      debugPrint('Error saving e-way bills: $e');
    }
  }

  Future<String> createEwayBill({
    required String fromGstin,
    required String toGstin,
    required String transporterId,
    required String vehicleNumber,
    required DateTime validFrom,
    required DateTime validUntil,
    required double totalValue,
    required double cgstAmount,
    required double sgstAmount,
    required double igstAmount,
    required String documentType,
    required String documentNumber,
    required List<EwayBillItem> items,
  }) async {
    const uuid = Uuid();
    final id = uuid.v4();

    // Generate a random e-way bill number (in real implementation, this would come from the GST portal)
    final billNumber = 'EWB${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    final ewayBill = EwayBill(
      id: id,
      billNumber: billNumber,
      fromGstin: fromGstin,
      toGstin: toGstin,
      transporterId: transporterId,
      vehicleNumber: vehicleNumber,
      validFrom: validFrom,
      validUntil: validUntil,
      totalValue: totalValue,
      cgstAmount: cgstAmount,
      sgstAmount: sgstAmount,
      igstAmount: igstAmount,
      documentType: documentType,
      documentNumber: documentNumber,
      items: items,
    );

    _ewayBills.add(ewayBill);
    await _saveEwayBills();
    notifyListeners();

    return id;
  }

  Future<void> updateEwayBill({
    required String id,
    required String fromGstin,
    required String toGstin,
    required String transporterId,
    required String vehicleNumber,
    required DateTime validFrom,
    required DateTime validUntil,
    required double totalValue,
    required double cgstAmount,
    required double sgstAmount,
    required double igstAmount,
    required String documentType,
    required String documentNumber,
    required List<EwayBillItem> items,
  }) async {
    final index = _ewayBills.indexWhere((bill) => bill.id == id);

    if (index != -1) {
      final billNumber = _ewayBills[index].billNumber;

      final updatedBill = EwayBill(
        id: id,
        billNumber: billNumber,
        fromGstin: fromGstin,
        toGstin: toGstin,
        transporterId: transporterId,
        vehicleNumber: vehicleNumber,
        validFrom: validFrom,
        validUntil: validUntil,
        totalValue: totalValue,
        cgstAmount: cgstAmount,
        sgstAmount: sgstAmount,
        igstAmount: igstAmount,
        documentType: documentType,
        documentNumber: documentNumber,
        items: items,
      );

      _ewayBills[index] = updatedBill;
      await _saveEwayBills();
      notifyListeners();
    }
  }

  Future<void> deleteEwayBill(String id) async {
    _ewayBills.removeWhere((bill) => bill.id == id);
    await _saveEwayBills();
    notifyListeners();
  }

  EwayBill? getEwayBillById(String id) {
    try {
      return _ewayBills.firstWhere((bill) => bill.id == id);
    } catch (e) {
      return null;
    }
  }

  List<EwayBill> getEwayBillsByDateRange(DateTime start, DateTime end) {
    return _ewayBills.where((bill) =>
      (bill.validFrom.isAfter(start) || bill.validFrom.isAtSameMomentAs(start)) &&
      (bill.validFrom.isBefore(end) || bill.validFrom.isAtSameMomentAs(end))
    ).toList();
  }

  List<EwayBill> getEwayBillsByGstin(String gstin) {
    return _ewayBills.where((bill) =>
      bill.fromGstin == gstin || bill.toGstin == gstin
    ).toList();
  }

  // Create an eway bill item
  EwayBillItem createEwayBillItem({
    required String productName,
    required double quantity,
    required String unit,
    required double taxableAmount,
    required double taxRate,
    required double cgstAmount,
    required double sgstAmount,
    required double igstAmount,
  }) {
    const uuid = Uuid();
    final id = uuid.v4();

    return EwayBillItem(
      id: id,
      productName: productName,
      quantity: quantity,
      unit: unit,
      taxableAmount: taxableAmount,
      taxRate: taxRate,
      cgstAmount: cgstAmount,
      sgstAmount: sgstAmount,
      igstAmount: igstAmount,
    );
  }
}
