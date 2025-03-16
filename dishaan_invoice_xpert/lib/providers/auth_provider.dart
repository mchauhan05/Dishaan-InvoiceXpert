// lib/providers/auth_provider.dart

import 'package:flutter/foundation.dart';
import 'package:dishaan_invoice_xpert/services/database/database_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isInitialized = false;
  String? _currentUsername;

  bool get isLoggedIn => _isLoggedIn;
  bool get isInitialized => _isInitialized;
  String? get currentUsername => _currentUsername;

  // Check login status on app startup
  Future<void> checkLoginStatus() async {
    try {
      final db = await DatabaseService().database;
      final settingsResult = await db.query('settings', where: 'id = 1');

      if (settingsResult.isNotEmpty) {
        bool enableLogin = settingsResult.first['enable_login'] == 1;
        // If login is not enabled, auto-login the user
        if (!enableLogin) {
          _isLoggedIn = true;
        }
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error checking login status: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Hash password for secure storage
  String _hashPassword(String password) {
    final key = encrypt.Key.fromLength(32);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(password, iv: iv);
    return encrypted.base64;
  }

  // Login user
  Future<bool> login(String username, String password) async {
    try {
      final db = await DatabaseService().database;

      // Check if login is enabled
      final settingsResult = await db.query('settings', where: 'id = 1');
      if (settingsResult.isNotEmpty) {
        bool enableLogin = settingsResult.first['enable_login'] == 1;
        if (!enableLogin) {
          _isLoggedIn = true;
          notifyListeners();
          return true;
        }
      }

      // Verify credentials
      final result = await db.query(
        'users',
        where: 'username = ? AND is_active = 1',
        whereArgs: [username],
      );

      if (result.isNotEmpty) {
        String storedHash = result.first['password_hash'] as String;
        String inputHash = _hashPassword(password);

        // In a real app, you would use a proper password verification mechanism
        // This is simplified for demonstration purposes
        if (storedHash == inputHash) {
          _isLoggedIn = true;
          _currentUsername = username;
          notifyListeners();
          return true;
        }
      }

      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    _isLoggedIn = false;
    _currentUsername = null;
    notifyListeners();
  }

  // Create initial user
  Future<bool> createInitialUser(String username, String password) async {
    try {
      final db = await DatabaseService().database;

      // Check if any users exist
      final userCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM users')
      );

      if (userCount == 0) {
        // Create the initial user
        await db.insert('users', {
          'username': username,
          'password_hash': _hashPassword(password),
          'is_active': 1,
        });

        // Enable login in settings
        await db.update(
          'settings',
          {'enable_login': 1},
          where: 'id = 1',
        );

        return true;
      }

      return false;
    } catch (e) {
      print('Error creating initial user: $e');
      return false;
    }
  }
}