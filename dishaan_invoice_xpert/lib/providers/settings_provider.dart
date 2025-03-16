// lib/providers/settings_provider.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:dishaan_invoice_xpert/models/settings.dart';
import 'package:dishaan_invoice_xpert/services/database/settings_db.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsDatabase _settingsDB = SettingsDatabase();
  Settings? _settings;
  bool _isLoading = false;

  Settings? get settings => _settings;
  bool get isLoading => _isLoading;

  // Convenience getters
  String? get businessName => _settings?.businessName;
  String? get businessAddress => _settings?.businessAddress;
  String? get businessPhone => _settings?.businessPhone;
  String? get businessEmail => _settings?.businessEmail;
  String? get businessWebsite => _settings?.businessWebsite;
  double get taxPercentage => _settings?.taxPercentage ?? 0;
  String get currencySymbol => _settings?.currencySymbol ?? '\$';
  String get invoicePrefix => _settings?.invoicePrefix ?? 'INV-';
  bool get enableLogin => _settings?.enableLogin ?? false;
  String? get logoPath => _settings?.logoPath;
  String? get invoiceFooter => _settings?.invoiceFooter;

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _settings = await _settingsDB.getSettings();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateSettings(Settings settings) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _settingsDB.updateSettings(settings);
      _settings = settings;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating settings: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBusinessLogo(File logoFile) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Copy the logo file to the app's documents directory
      final documentsDir = await getApplicationDocumentsDirectory();
      final fileName = 'logo_${DateTime.now().millisecondsSinceEpoch}${path.extension(logoFile.path)}';
      final targetPath = path.join(documentsDir.path, fileName);

      // Copy and save the file
      final newLogoFile = await logoFile.copy(targetPath);

      // Update settings with the new logo path
      await _settingsDB.updateBusinessLogo(newLogoFile.path);

      // Update the in-memory settings
      if (_settings != null) {
        _settings = Settings(
          id: _settings!.id,
          businessName: _settings!.businessName,
          businessAddress: _settings!.businessAddress,
          businessPhone: _settings!.businessPhone,
          businessEmail: _settings!.businessEmail,
          businessWebsite: _settings!.businessWebsite,
          taxPercentage: _settings!.taxPercentage,
          currencySymbol: _settings!.currencySymbol,
          invoicePrefix: _settings!.invoicePrefix,
          enableLogin: _settings!.enableLogin,
          logoPath: newLogoFile.path,
          invoiceFooter: _settings!.invoiceFooter,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating business logo: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}