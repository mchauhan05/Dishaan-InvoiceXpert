import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/branding_model.dart';
import '../services/database_service.dart';

/// Provider for branding and customization settings
class BrandingProvider extends ChangeNotifier {
  // Current branding settings
  BrandingSettings _brandingSettings = BrandingSettings.defaults();

  // Loading state
  bool _isLoading = false;

  // Error message
  String? _error;

  // Getters
  BrandingSettings get brandingSettings => _brandingSettings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Constructor
  BrandingProvider() {
    _initialize();
  }

  // Initialize with default or stored branding settings
  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load branding settings from storage if available
      final storedSettings = await _loadBrandingFromStorage();

      if (storedSettings != null) {
        _brandingSettings = storedSettings;
      } else {
        // Otherwise use default settings
        _brandingSettings = BrandingSettings.defaults();
        // Save to storage
        await _saveBrandingToStorage();
      }

      _error = null;
    } catch (e) {
      _error = 'Error initializing branding settings: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load branding settings from storage
  Future<BrandingSettings?> _loadBrandingFromStorage() async {
    try {
      final databaseService = DatabaseService();
      final json = await DatabaseService.instance.getObject('branding_settings');
      if (json != null) {
        return BrandingSettings.fromJson(json);
      }
    } catch (e) {
      print('Error loading branding settings: $e');
    }
    return null;
  }

  // Save branding settings to storage
  Future<void> _saveBrandingToStorage() async {
    try {
      await DatabaseService.instance.setObject(
        'branding_settings',
        _brandingSettings.toJson(),
      );
    } catch (e) {
      print('Error saving branding settings: $e');
      _error = 'Failed to save branding settings';
      notifyListeners();
    }
  }

  // Update colors
  Future<void> updateColors(BrandColors colors) async {
    _isLoading = true;
    notifyListeners();

    try {
      _brandingSettings = _brandingSettings.copyWith(colors: colors);
      await _saveBrandingToStorage();
      _error = null;
    } catch (e) {
      _error = 'Error updating colors: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update logo configuration
  Future<void> updateLogoConfig(LogoConfig logoConfig) async {
    _isLoading = true;
    notifyListeners();

    try {
      _brandingSettings = _brandingSettings.copyWith(logoConfig: logoConfig);
      await _saveBrandingToStorage();
      _error = null;
    } catch (e) {
      _error = 'Error updating logo configuration: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload and set logo from file
  Future<void> uploadLogo(File logoFile) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would upload the file to a server
      // For now, we'll just store the file path
      final bytes = await logoFile.readAsBytes();
      final base64Logo = base64Encode(bytes);

      // Store the file path for local use
      final customLogoPath = logoFile.path;
      final existingConfig = _brandingSettings.logoConfig;

      _brandingSettings = _brandingSettings.copyWith(
        logoConfig: existingConfig.copyWith(
          customLogoPath: customLogoPath,
          // In a real app, you would set the logoUrl to the uploaded file URL
          // logoUrl: 'https://example.com/logos/your_logo.png',
        ),
      );

      await _saveBrandingToStorage();
      _error = null;
    } catch (e) {
      _error = 'Error uploading logo: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update font configuration
  Future<void> updateFontConfig(FontConfig fontConfig) async {
    _isLoading = true;
    notifyListeners();

    try {
      _brandingSettings = _brandingSettings.copyWith(fontConfig: fontConfig);
      await _saveBrandingToStorage();
      _error = null;
    } catch (e) {
      _error = 'Error updating font configuration: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update invoice template
  Future<void> updateInvoiceTemplate(InvoiceTemplate template) async {
    _isLoading = true;
    notifyListeners();

    try {
      _brandingSettings = _brandingSettings.copyWith(selectedInvoiceTemplate: template);
      await _saveBrandingToStorage();
      _error = null;
    } catch (e) {
      _error = 'Error updating invoice template: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Apply Indian theme
  Future<void> applyIndianTheme() async {
    _isLoading = true;
    notifyListeners();

    try {
      _brandingSettings = BrandingSettings.indianTheme();
      await _saveBrandingToStorage();
      _error = null;
    } catch (e) {
      _error = 'Error applying Indian theme: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Apply custom theme
  Future<void> applyCustomTheme(BrandingSettings settings) async {
    _isLoading = true;
    notifyListeners();

    try {
      _brandingSettings = settings;
      await _saveBrandingToStorage();
      _error = null;
    } catch (e) {
      _error = 'Error applying custom theme: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Apply custom CSS
  Future<void> updateCustomCss(String css) async {
    _isLoading = true;
    notifyListeners();

    try {
      _brandingSettings = _brandingSettings.copyWith(customCss: css);
      await _saveBrandingToStorage();
      _error = null;
    } catch (e) {
      _error = 'Error updating custom CSS: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset to default
  Future<void> resetToDefault() async {
    _isLoading = true;
    notifyListeners();

    try {
      _brandingSettings = BrandingSettings.defaults();
      await _saveBrandingToStorage();
      _error = null;
    } catch (e) {
      _error = 'Error resetting branding settings: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
