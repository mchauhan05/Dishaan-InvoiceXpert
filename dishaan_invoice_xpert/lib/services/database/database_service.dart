// lib/services/database/database_service.dart

import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Initialize FFI for desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    // Get application documents directory
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'billing_app.db');

    // Initialize the database
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Read schema from asset file
    String schema = await rootBundle.loadString('assets/database/schema.sql');

    // Split the schema into individual statements and execute each one
    List<String> statements = schema.split(';');
    for (String statement in statements) {
      if (statement.trim().isNotEmpty) {
        await db.execute(statement);
      }
    }

    // Insert default category
    await db.insert('categories', {
      'name': 'General',
      'description': 'Default category for products'
    });

    // Insert default settings
    await db.insert('settings', {
      'id': 1,
      'business_name': 'My Business',
      'tax_percentage': 0.0,
      'currency_symbol': '\$',
      'invoice_prefix': 'INV-',
      'enable_login': 0
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations for future versions
  }

  // Utility method to reset the database (for development)
  Future<void> resetDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'billing_app.db');

    // Delete the existing database file
    File databaseFile = File(path);
    if (await databaseFile.exists()) {
      await databaseFile.delete();
    }

    // Reinitialize the database
    _database = await _initDatabase();
  }

  // Utility method to export database
  Future<String> exportDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(documentsDirectory.path, 'billing_app.db');
    String exportPath = join(documentsDirectory.path, 'billing_app_export.db');

    // Copy the database file
    File dbFile = File(dbPath);
    await dbFile.copy(exportPath);

    return exportPath;
  }

  // Utility method to import database
  Future<void> importDatabase(String importPath) async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(documentsDirectory.path, 'billing_app.db');

    // Copy the import file to the database path
    File importFile = File(importPath);
    await importFile.copy(dbPath);

    // Reinitialize the database
    _database = await _initDatabase();
  }
}