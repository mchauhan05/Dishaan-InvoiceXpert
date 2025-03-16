// lib/services/database/settings_db.dart

import 'package:dishaan_invoice_xpert/models/settings.dart';
import 'package:dishaan_invoice_xpert/services/database/database_service.dart';

class SettingsDatabase {
  final DatabaseService _databaseService = DatabaseService();

  // Get settings
  Future<Settings> getSettings() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('settings', where: 'id = 1');

    if (maps.isEmpty) {
      // Insert default settings
      await db.insert('settings', {
        'id': 1,
        'business_name': 'My Business',
        'tax_percentage': 0.0,
        'currency_symbol': '\$',
        'invoice_prefix': 'INV-',
        'enable_login': 0,
        'updated_at': DateTime.now().toIso8601String(),
      });

      return Settings();
    }

    return Settings.fromMap(maps.first);
  }

  // Update settings
  Future<void> updateSettings(Settings settings) async {
    final db = await _databaseService.database;

    await db.update(
      'settings',
      {
        ...settings.toMap(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = 1',
    );
  }

  // Update business logo
  Future<void> updateLogo(String logoPath) async {
    final db = await _databaseService.database;

    await db.update(
      'settings',
      {
        'logo_path': logoPath,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = 1',
    );
  }

  updateBusinessLogo(String path) {}
}