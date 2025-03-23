import 'package:flutter/material.dart';
import '../models/indian_invoice_model.dart';
import '../models/invoice_models.dart';
import '../services/database_service.dart';

/// Provider for Indian GST-specific functionality
class IndianGSTProvider extends ChangeNotifier {
  // Map of invoice IDs to GST details
  Map<String, GSTInvoiceDetails> _gstInvoiceDetails = {};

  // Map of product IDs to GST details
  Map<String, ProductGSTDetails> _productGSTDetails = {};

  // Common HSN codes
  List<HSNCode> _hsnCodes = [];

  // Loading state
  bool _isLoading = false;

  // Error message
  String? _error;

  // Getters
  Map<String, GSTInvoiceDetails> get gstInvoiceDetails => _gstInvoiceDetails;
  Map<String, ProductGSTDetails> get productGSTDetails => _productGSTDetails;
  List<HSNCode> get hsnCodes => _hsnCodes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Constructor
  IndianGSTProvider() {
    _initialize();
  }

  // Initialize provider
  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load GST data from storage
      await _loadGSTDataFromStorage();

      // If HSN codes are empty, load defaults
      if (_hsnCodes.isEmpty) {
        _hsnCodes = _getDefaultHSNCodes();
        await _saveHSNCodesToStorage();
      }

      _error = null;
    } catch (e) {
      _error = 'Error initializing GST provider: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load GST data from storage
  Future<void> _loadGSTDataFromStorage() async {
    try {
      // Load invoice GST details
      final invoiceDetailsJson = await DatabaseService.instance.getObject('gst_invoice_details');
      if (invoiceDetailsJson != null) {
        final Map<String, dynamic> detailsMap = Map<String, dynamic>.from(invoiceDetailsJson);
        _gstInvoiceDetails = detailsMap.map((key, value) {
          return MapEntry(key, GSTInvoiceDetails.fromJson(value));
        });
      }

      // Load product GST details
      final productDetailsJson = await DatabaseService.instance.getObject('gst_product_details');
      if (productDetailsJson != null) {
        final Map<String, dynamic> detailsMap = Map<String, dynamic>.from(productDetailsJson);
        _productGSTDetails = detailsMap.map((key, value) {
          return MapEntry(key, ProductGSTDetails.fromJson(value));
        });
      }

      // Load HSN codes
      final hsnCodesJson = await DatabaseService.instance.getObject('hsn_codes');
      if (hsnCodesJson != null) {
        final List<dynamic> codesList = List<dynamic>.from(hsnCodesJson);
        _hsnCodes = codesList.map((code) => HSNCode.fromJson(code)).toList();
      }
    } catch (e) {
      print('Error loading GST data: $e');
      throw e;
    }
  }

  // Save invoice GST details to storage
  Future<void> _saveInvoiceDetailsToStorage() async {
    try {
      final Map<String, dynamic> detailsMap = {};
      _gstInvoiceDetails.forEach((key, value) {
        detailsMap[key] = value.toJson();
      });

      await DatabaseService.instance.setObject('gst_invoice_details', detailsMap);
    } catch (e) {
      print('Error saving invoice GST details: $e');
      throw e;
    }
  }

  // Save product GST details to storage
  Future<void> _saveProductDetailsToStorage() async {
    try {
      final Map<String, dynamic> detailsMap = {};
      _productGSTDetails.forEach((key, value) {
        detailsMap[key] = value.toJson();
      });

      await DatabaseService.instance.setObject('gst_product_details', detailsMap);
    } catch (e) {
      print('Error saving product GST details: $e');
      throw e;
    }
  }

  // Save HSN codes to storage
  Future<void> _saveHSNCodesToStorage() async {
    try {
      final List<Map<String, dynamic>> codesList = _hsnCodes.map((code) => code.toJson()).toList();
      await DatabaseService.instance.setObject('hsn_codes', codesList);
    } catch (e) {
      print('Error saving HSN codes: $e');
      throw e;
    }
  }

  // Get default HSN codes
  List<HSNCode> _getDefaultHSNCodes() {
    return [
      HSNCode(
        code: '8471',
        description: 'Computers and computer peripherals',
        gstRate: 18.0,
      ),
      HSNCode(
        code: '8517',
        description: 'Telephones and smartphones',
        gstRate: 18.0,
      ),
      HSNCode(
        code: '8523',
        description: 'Software on storage media',
        gstRate: 18.0,
      ),
      HSNCode(
        code: '9403',
        description: 'Office furniture',
        gstRate: 18.0,
      ),
      HSNCode(
        code: '4901',
        description: 'Books and printed matter',
        gstRate: 0.0,
      ),
      HSNCode(
        code: '4820',
        description: 'Stationery items',
        gstRate: 12.0,
      ),
      HSNCode(
        code: '3926',
        description: 'Office supplies (plastic)',
        gstRate: 18.0,
      ),
      HSNCode(
        code: '8443',
        description: 'Printers and printing machinery',
        gstRate: 28.0,
      ),
      HSNCode(
        code: '8504',
        description: 'Power adapters and UPS',
        gstRate: 18.0,
      ),
      HSNCode(
        code: '8528',
        description: 'Monitors and projectors',
        gstRate: 28.0,
      ),
      // Food and agricultural products
      HSNCode(
        code: '0401',
        description: 'Milk and cream',
        gstRate: 5.0,
      ),
      HSNCode(
        code: '1001',
        description: 'Wheat',
        gstRate: 0.0,
      ),
      HSNCode(
        code: '1006',
        description: 'Rice',
        gstRate: 0.0,
      ),
      // Clothing and textiles
      HSNCode(
        code: '6101',
        description: 'Men's apparel',
        gstRate: 5.0,
      ),
      HSNCode(
        code: '6201',
        description: 'Women's apparel',
        gstRate: 5.0,
      ),
      // Services SAC codes
      HSNCode(
        code: '998311',
        description: 'IT consulting services',
        gstRate: 18.0,
      ),
      HSNCode(
        code: '998315',
        description: 'Software support services',
        gstRate: 18.0,
      ),
      HSNCode(
        code: '998439',
        description: 'Online platform services',
        gstRate: 18.0,
      ),
    ];
  }

  // Add or update GST details for an invoice
  Future<void> setInvoiceGSTDetails(String invoiceId, GSTInvoiceDetails details) async {
    _isLoading = true;
    notifyListeners();

    try {
      _gstInvoiceDetails[invoiceId] = details;
      await _saveInvoiceDetailsToStorage();
      _error = null;
    } catch (e) {
      _error = 'Error setting invoice GST details: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get GST details for an invoice
  GSTInvoiceDetails? getInvoiceGSTDetails(String invoiceId) {
    return _gstInvoiceDetails[invoiceId];
  }

  // Calculate GST breakup (CGST, SGST, IGST) for an invoice
  GSTInvoiceDetails calculateGSTBreakup(Invoice invoice, bool isInterstate) {
    double cgstAmount = 0.0;
    double sgstAmount = 0.0;
    double igstAmount = 0.0;
    double cessAmount = 0.0;

    if (isInterstate) {
      // For interstate supply, only IGST applies
      igstAmount = invoice.taxAmount;
    } else {
      // For intrastate supply, CGST and SGST apply equally
      cgstAmount = invoice.taxAmount / 2;
      sgstAmount = invoice.taxAmount / 2;
    }

    return GSTInvoiceDetails(
      isInterState: isInterstate,
      cgstAmount: cgstAmount,
      sgstAmount: sgstAmount,
      igstAmount: igstAmount,
      cessAmount: cessAmount,
    );
  }

  // Add or update GST details for a product
  Future<void> setProductGSTDetails(String productId, ProductGSTDetails details) async {
    _isLoading = true;
    notifyListeners();

    try {
      _productGSTDetails[productId] = details;
      await _saveProductDetailsToStorage();
      _error = null;
    } catch (e) {
      _error = 'Error setting product GST details: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get GST details for a product
  ProductGSTDetails? getProductGSTDetails(String productId) {
    return _productGSTDetails[productId];
  }

  // Add a new HSN code
  Future<void> addHSNCode(HSNCode code) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if code already exists
      final existingIndex = _hsnCodes.indexWhere((c) => c.code == code.code);
      if (existingIndex >= 0) {
        _hsnCodes[existingIndex] = code; // Update existing
      } else {
        _hsnCodes.add(code); // Add new
      }

      await _saveHSNCodesToStorage();
      _error = null;
    } catch (e) {
      _error = 'Error adding HSN code: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Find HSN codes by partial code or description
  List<HSNCode> searchHSNCodes(String query) {
    query = query.toLowerCase();
    return _hsnCodes.where((code) {
      return code.code.toLowerCase().contains(query) ||
             code.description.toLowerCase().contains(query);
    }).toList();
  }

  // Get HSN code by exact code
  HSNCode? getHSNCodeByCode(String code) {
    try {
      return _hsnCodes.firstWhere((c) => c.code == code);
    } catch (e) {
      return null;
    }
  }

  // Validate a GSTIN
  bool validateGSTIN(String? gstin) {
    if (gstin == null || gstin.isEmpty) return false;
    return GSTINValidator.isValid(gstin);
  }
}
