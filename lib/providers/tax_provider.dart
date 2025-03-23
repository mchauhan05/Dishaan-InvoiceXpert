import 'package:flutter/material.dart';
import '../models/tax_model.dart';
import '../models/product_model.dart';
import '../models/customer_model.dart';
import '../services/database_service.dart';

/// Provider for tax management
class TaxProvider extends ChangeNotifier {
  // List of all taxes
  List<Tax> _taxes = [];

  // List of tax jurisdictions
  List<TaxJurisdiction> _jurisdictions = [];

  // Default tax
  Tax? _defaultTax;

  // Active jurisdictions
  List<String> _activeJurisdictionIds = [];

  // Loading state
  bool _isLoading = false;

  // Error message
  String? _error;

  // Getters
  List<Tax> get taxes => _taxes;
  List<TaxJurisdiction> get jurisdictions => _jurisdictions;
  Tax get defaultTax => _defaultTax ?? _getDefaultTax();
  List<String> get activeJurisdictionIds => _activeJurisdictionIds;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Constructor
  TaxProvider() {
    _initialize();
  }

  // Initialize with default taxes
  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load taxes from storage if available
      final storedTaxes = await _loadTaxesFromStorage();
      final storedJurisdictions = await _loadJurisdictionsFromStorage();

      if (storedTaxes.isNotEmpty) {
        _taxes = storedTaxes;
      } else {
        // Otherwise use default taxes
        _taxes = _getDefaultTaxes();
        // Save to storage
        await _saveTaxesToStorage();
      }

      if (storedJurisdictions.isNotEmpty) {
        _jurisdictions = storedJurisdictions;
      } else {
        // Otherwise use default jurisdictions
        _jurisdictions = _getDefaultJurisdictions();
        // Save to storage
        await _saveJurisdictionsToStorage();
      }

      // Set default tax to first active tax
      _defaultTax = _taxes.firstWhere(
        (tax) => tax.isActive,
        orElse: () => _getDefaultTax(),
      );

      _error = null;
    } catch (e) {
      _error = 'Error initializing taxes: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get default tax (for backup)
  Tax _getDefaultTax() {
    return Tax(
      id: 'default_tax',
      name: 'Sales Tax',
      type: TaxType.salesTax,
      rate: 0.0, // 0% by default
      isActive: true,
    );
  }

  // Get default taxes
  List<Tax> _getDefaultTaxes() {
    final List<Tax> defaultTaxes = [];

    // Add common taxes from different countries
    defaultTaxes.addAll(TaxRegimes.getTaxesForCountry('US'));
    defaultTaxes.addAll(TaxRegimes.getTaxesForCountry('CA'));
    defaultTaxes.addAll(TaxRegimes.getTaxesForCountry('GB'));
    defaultTaxes.addAll(TaxRegimes.getTaxesForCountry('AU'));

    return defaultTaxes;
  }

  // Get default jurisdictions
  List<TaxJurisdiction> _getDefaultJurisdictions() {
    return [
      TaxJurisdiction(
        id: 'us',
        name: 'United States',
        countryCode: 'US',
        taxes: TaxRegimes.getTaxesForCountry('US'),
      ),
      TaxJurisdiction(
        id: 'ca',
        name: 'Canada',
        countryCode: 'CA',
        taxes: TaxRegimes.getTaxesForCountry('CA'),
      ),
      TaxJurisdiction(
        id: 'gb',
        name: 'United Kingdom',
        countryCode: 'GB',
        taxes: TaxRegimes.getTaxesForCountry('GB'),
      ),
      TaxJurisdiction(
        id: 'au',
        name: 'Australia',
        countryCode: 'AU',
        taxes: TaxRegimes.getTaxesForCountry('AU'),
      ),
      TaxJurisdiction(
        id: 'in',
        name: 'India',
        countryCode: 'IN',
        taxes: TaxRegimes.getTaxesForCountry('IN'),
      ),
    ];
  }

  // Set default tax
  void setDefaultTax(String taxId) {
    final tax = _taxes.firstWhere(
      (tax) => tax.id == taxId,
      orElse: () => _getDefaultTax(),
    );

    _defaultTax = tax;
    notifyListeners();
  }

  // Add a new tax
  Future<bool> addTax(Tax tax) async {
    // Check if tax with this ID already exists
    if (_taxes.any((t) => t.id == tax.id)) {
      _error = 'Tax with ID ${tax.id} already exists';
      notifyListeners();
      return false;
    }

    _taxes.add(tax);
    await _saveTaxesToStorage();
    notifyListeners();
    return true;
  }

  // Update a tax
  Future<bool> updateTax(Tax updatedTax) async {
    final index = _taxes.indexWhere((t) => t.id == updatedTax.id);
    if (index < 0) {
      _error = 'Tax with ID ${updatedTax.id} not found';
      notifyListeners();
      return false;
    }

    _taxes[index] = updatedTax;

    // If this is the default tax, update that reference too
    if (_defaultTax?.id == updatedTax.id) {
      _defaultTax = updatedTax;
    }

    // Update tax in jurisdictions
    for (int i = 0; i < _jurisdictions.length; i++) {
      final jurisdiction = _jurisdictions[i];
      final taxIndex = jurisdiction.taxes.indexWhere((t) => t.id == updatedTax.id);
      if (taxIndex >= 0) {
        final updatedTaxes = List<Tax>.from(jurisdiction.taxes);
        updatedTaxes[taxIndex] = updatedTax;
        _jurisdictions[i] = jurisdiction.copyWith(taxes: updatedTaxes);
      }
    }

    await _saveTaxesToStorage();
    await _saveJurisdictionsToStorage();
    notifyListeners();
    return true;
  }

  // Delete a tax
  Future<bool> deleteTax(String taxId) async {
    // Don't allow deleting the default tax
    if (_defaultTax?.id == taxId) {
      _error = 'Cannot delete the default tax';
      notifyListeners();
      return false;
    }

    // Find the tax to delete
    final index = _taxes.indexWhere((t) => t.id == taxId);
    if (index < 0) {
      _error = 'Tax with ID $taxId not found';
      notifyListeners();
      return false;
    }

    _taxes.removeAt(index);

    // Remove tax from jurisdictions
    for (int i = 0; i < _jurisdictions.length; i++) {
      final jurisdiction = _jurisdictions[i];
      final updatedTaxes = jurisdiction.taxes.where((t) => t.id != taxId).toList();
      if (updatedTaxes.length != jurisdiction.taxes.length) {
        _jurisdictions[i] = jurisdiction.copyWith(taxes: updatedTaxes);
      }
    }

    await _saveTaxesToStorage();
    await _saveJurisdictionsToStorage();
    notifyListeners();
    return true;
  }

  // Add a new jurisdiction
  Future<bool> addJurisdiction(TaxJurisdiction jurisdiction) async {
    // Check if jurisdiction with this ID already exists
    if (_jurisdictions.any((j) => j.id == jurisdiction.id)) {
      _error = 'Jurisdiction with ID ${jurisdiction.id} already exists';
      notifyListeners();
      return false;
    }

    _jurisdictions.add(jurisdiction);
    await _saveJurisdictionsToStorage();
    notifyListeners();
    return true;
  }

  // Update a jurisdiction
  Future<bool> updateJurisdiction(TaxJurisdiction updatedJurisdiction) async {
    final index = _jurisdictions.indexWhere((j) => j.id == updatedJurisdiction.id);
    if (index < 0) {
      _error = 'Jurisdiction with ID ${updatedJurisdiction.id} not found';
      notifyListeners();
      return false;
    }

    _jurisdictions[index] = updatedJurisdiction;
    await _saveJurisdictionsToStorage();
    notifyListeners();
    return true;
  }

  // Delete a jurisdiction
  Future<bool> deleteJurisdiction(String jurisdictionId) async {
    // Find the jurisdiction to delete
    final index = _jurisdictions.indexWhere((j) => j.id == jurisdictionId);
    if (index < 0) {
      _error = 'Jurisdiction with ID $jurisdictionId not found';
      notifyListeners();
      return false;
    }

    _jurisdictions.removeAt(index);

    // Remove from active jurisdictions
    _activeJurisdictionIds.remove(jurisdictionId);

    await _saveJurisdictionsToStorage();
    notifyListeners();
    return true;
  }

  // Set active jurisdictions
  void setActiveJurisdictions(List<String> jurisdictionIds) {
    _activeJurisdictionIds = jurisdictionIds;
    notifyListeners();
  }

  // Add active jurisdiction
  void addActiveJurisdiction(String jurisdictionId) {
    if (!_activeJurisdictionIds.contains(jurisdictionId)) {
      _activeJurisdictionIds.add(jurisdictionId);
      notifyListeners();
    }
  }

  // Remove active jurisdiction
  void removeActiveJurisdiction(String jurisdictionId) {
    if (_activeJurisdictionIds.contains(jurisdictionId)) {
      _activeJurisdictionIds.remove(jurisdictionId);
      notifyListeners();
    }
  }

  // Get taxes for a jurisdiction
  List<Tax> getTaxesForJurisdiction(String jurisdictionId) {
    final jurisdiction = _jurisdictions.firstWhere(
      (j) => j.id == jurisdictionId,
      orElse: () => TaxJurisdiction(
        id: 'default',
        name: 'Default',
        countryCode: 'US',
        taxes: [_getDefaultTax()],
      ),
    );

    return jurisdiction.taxes;
  }

  // Get all active taxes
  List<Tax> getActiveTaxes() {
    final Set<String> activeTaxIds = {};
    final List<Tax> activeTaxes = [];

    // Add taxes from active jurisdictions
    for (final jurisdictionId in _activeJurisdictionIds) {
      for (final tax in getTaxesForJurisdiction(jurisdictionId)) {
        if (tax.isActive && !activeTaxIds.contains(tax.id)) {
          activeTaxIds.add(tax.id);
          activeTaxes.add(tax);
        }
      }
    }

    // If no active taxes, add default tax
    if (activeTaxes.isEmpty) {
      activeTaxes.add(_defaultTax ?? _getDefaultTax());
    }

    return activeTaxes;
  }

  // Calculate tax for an invoice item
  double calculateTaxForItem({
    required double amount,
    required String category,
    List<String>? exemptCategories,
  }) {
    final activeTaxes = getActiveTaxes();

    // Check if the category is exempt from any tax
    final taxesToApply = activeTaxes.where((tax) {
      // Check category exemptions from the tax
      if (tax.exemptProductCategories.contains(category)) {
        return false;
      }

      // Check exemptions provided in the call
      if (exemptCategories != null &&
          exemptCategories.contains(tax.id)) {
        return false;
      }

      return true;
    }).toList();

    // Calculate total tax
    return TaxCalculator.calculateTotalTax(
      amount: amount,
      taxes: taxesToApply,
    );
  }

  // Calculate tax breakdown for an invoice
  Map<String, double> calculateTaxBreakdown({
    required double amount,
    String? category,
    List<String>? exemptCategories,
  }) {
    final activeTaxes = getActiveTaxes();

    // Check if the category is exempt from any tax
    final taxesToApply = activeTaxes.where((tax) {
      // Check category exemptions from the tax
      if (category != null && tax.exemptProductCategories.contains(category)) {
        return false;
      }

      // Check exemptions provided in the call
      if (exemptCategories != null &&
          exemptCategories.contains(tax.id)) {
        return false;
      }

      return true;
    }).toList();

    // Calculate tax breakdown
    return TaxCalculator.calculateTaxes(
      amount: amount,
      taxes: taxesToApply,
    );
  }

  // Load taxes from storage
  Future<List<Tax>> _loadTaxesFromStorage() async {
    // Load from database service
    try {
      // In a real app, you would load from database
      // For this demo, we'll just return an empty list to use defaults
      return [];
    } catch (e) {
      print('Error loading taxes from storage: $e');
      return [];
    }
  }

  // Save taxes to storage
  Future<void> _saveTaxesToStorage() async {
    // Save to database service
    try {
      // In a real app, you would save to database
      // For this demo, we'll just print a message
      print('Taxes saved: ${_taxes.length}');
    } catch (e) {
      print('Error saving taxes to storage: $e');
    }
  }

  // Load jurisdictions from storage
  Future<List<TaxJurisdiction>> _loadJurisdictionsFromStorage() async {
    // Load from database service
    try {
      // In a real app, you would load from database
      // For this demo, we'll just return an empty list to use defaults
      return [];
    } catch (e) {
      print('Error loading jurisdictions from storage: $e');
      return [];
    }
  }

  // Save jurisdictions to storage
  Future<void> _saveJurisdictionsToStorage() async {
    // Save to database service
    try {
      // In a real app, you would save to database
      // For this demo, we'll just print a message
      print('Jurisdictions saved: ${_jurisdictions.length}');
    } catch (e) {
      print('Error saving jurisdictions to storage: $e');
    }
  }
}
