import 'dart:async';

import 'package:flutter/material.dart';

import '../models/auth_model.dart';
import '../services/database_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  AuthToken? _authToken;
  bool _isLoading = false;
  String? _error;

  // List of available users
  List<User> _users = [];

  // Permission groups with their descriptions
  final Map<String, String> _permissionGroups = {
    'dashboard': 'Access to dashboard and analytics',
    'invoices': 'Manage invoices',
    'customers': 'Manage customers',
    'products': 'Manage products',
    'reports': 'Access to reports',
    'settings': 'Change application settings',
    'users': 'Manage users and permissions',
  };

  // Permissions within each group
  final Map<String, List<String>> _permissions = {
    'dashboard': ['dashboard.view'],
    'invoices': ['invoices.view', 'invoices.create', 'invoices.edit', 'invoices.delete', 'invoices.send'],
    'customers': ['customers.view', 'customers.create', 'customers.edit', 'customers.delete'],
    'products': ['products.view', 'products.create', 'products.edit', 'products.delete', 'products.inventory'],
    'reports': ['reports.view', 'reports.export'],
    'settings': ['settings.view', 'settings.edit'],
    'users': ['users.view', 'users.create', 'users.edit', 'users.delete'],
  };

  // Default permissions for each role
  final Map<UserRole, List<String>> _defaultRolePermissions = {
    UserRole.admin: [
      'dashboard.view',
      'invoices.view', 'invoices.create', 'invoices.edit', 'invoices.delete', 'invoices.send',
      'customers.view', 'customers.create', 'customers.edit', 'customers.delete',
      'products.view', 'products.create', 'products.edit', 'products.delete', 'products.inventory',
      'reports.view', 'reports.export',
      'settings.view', 'settings.edit',
      'users.view', 'users.create', 'users.edit', 'users.delete',
    ],
    UserRole.manager: [
      'dashboard.view',
      'invoices.view', 'invoices.create', 'invoices.edit', 'invoices.send',
      'customers.view', 'customers.create', 'customers.edit',
      'products.view', 'products.create', 'products.edit', 'products.inventory',
      'reports.view', 'reports.export',
      'settings.view',
    ],
    UserRole.accountant: [
      'dashboard.view',
      'invoices.view', 'invoices.create', 'invoices.edit', 'invoices.send',
      'customers.view',
      'products.view',
      'reports.view', 'reports.export',
    ],
    UserRole.employee: [
      'dashboard.view',
      'invoices.view', 'invoices.create',
      'customers.view',
      'products.view',
      'reports.view',
    ],
    UserRole.viewer: [
      'dashboard.view',
      'invoices.view',
      'customers.view',
      'products.view',
      'reports.view',
    ],
  };

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null && _authToken != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<User> get users => _users;
  Map<String, String> get permissionGroups => _permissionGroups;
  Map<String, List<String>> get permissions => _permissions;

  // Get all available permissions in flat list
  List<String> get allPermissions {
    final List<String> allPermissions = [];
    for (var permList in _permissions.values) {
      allPermissions.addAll(permList);
    }
    return allPermissions;
  }

  // Get default permissions for a specific role
  List<String> getDefaultPermissionsForRole(UserRole role) {
    return _defaultRolePermissions[role] ?? [];
  }

  // Constructor with sample user for demo
  AuthProvider() {
    _loadData();
  }

  // Load user data
  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load saved users
      _users = await DatabaseService.loadUsers();

      // If there are no saved users, create sample users
      if (_users.isEmpty) {
        await _createSampleUsers();
      }

      // Check if there's a saved current user session
      final savedUser = await DatabaseService.loadCurrentUser();
      if (savedUser != null) {
        _currentUser = savedUser;

        // Create a token with 1 hour expiry
        _authToken = AuthToken(
          token: 'session-token-${savedUser.id}',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
          refreshToken: 'refresh-token-${savedUser.id}',
        );
      }

      _error = null;
    } catch (e) {
      _error = 'Failed to load user data: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create sample users for demonstration
  Future<void> _createSampleUsers() async {
    final now = DateTime.now();

    final List<User> sampleUsers = [
      // Admin user
      User(
        id: 'USR001',
        email: 'admin@example.com',
        firstName: 'Admin',
        lastName: 'User',
        profileImageUrl: null,
        role: UserRole.admin,
        status: AccountStatus.active,
        createdAt: now.subtract(const Duration(days: 30)),
        lastLogin: now,
        permissions: _defaultRolePermissions[UserRole.admin]!,
        isEmailVerified: true,
      ),

      // Manager user
      User(
        id: 'USR002',
        email: 'manager@example.com',
        firstName: 'Manager',
        lastName: 'User',
        profileImageUrl: null,
        role: UserRole.manager,
        status: AccountStatus.active,
        createdAt: now.subtract(const Duration(days: 20)),
        lastLogin: now.subtract(const Duration(days: 1)),
        permissions: _defaultRolePermissions[UserRole.manager]!,
        isEmailVerified: true,
      ),

      // Accountant user
      User(
        id: 'USR003',
        email: 'accountant@example.com',
        firstName: 'Accountant',
        lastName: 'User',
        profileImageUrl: null,
        role: UserRole.accountant,
        status: AccountStatus.active,
        createdAt: now.subtract(const Duration(days: 15)),
        lastLogin: now.subtract(const Duration(days: 2)),
        permissions: _defaultRolePermissions[UserRole.accountant]!,
        isEmailVerified: true,
      ),

      // Employee user
      User(
        id: 'USR004',
        email: 'employee@example.com',
        firstName: 'Employee',
        lastName: 'User',
        profileImageUrl: null,
        role: UserRole.employee,
        status: AccountStatus.active,
        createdAt: now.subtract(const Duration(days: 10)),
        lastLogin: now.subtract(const Duration(days: 3)),
        permissions: _defaultRolePermissions[UserRole.employee]!,
        isEmailVerified: true,
      ),

      // Viewer user
      User(
        id: 'USR005',
        email: 'viewer@example.com',
        firstName: 'Viewer',
        lastName: 'User',
        profileImageUrl: null,
        role: UserRole.viewer,
        status: AccountStatus.active,
        createdAt: now.subtract(const Duration(days: 5)),
        lastLogin: now.subtract(const Duration(days: 4)),
        permissions: _defaultRolePermissions[UserRole.viewer]!,
        isEmailVerified: true,
      ),

      // Inactive user
      User(
        id: 'USR006',
        email: 'inactive@example.com',
        firstName: 'Inactive',
        lastName: 'User',
        profileImageUrl: null,
        role: UserRole.employee,
        status: AccountStatus.inactive,
        createdAt: now.subtract(const Duration(days: 60)),
        lastLogin: now.subtract(const Duration(days: 45)),
        permissions: _defaultRolePermissions[UserRole.employee]!,
        isEmailVerified: true,
      ),
    ];

    _users = sampleUsers;
    await DatabaseService.saveUsers(_users);
  }

  // Log in user
  Future<bool> login(String email, String password) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Email is required
      if (email.isEmpty) {
        _error = 'Email is required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Password is required
      if (password.isEmpty) {
        _error = 'Password is required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Find user by email
      final user = _users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
        orElse: () => throw Exception('User not found'),
      );

      // Check if user is active
      if (user.status != AccountStatus.active) {
        throw Exception('Account is not active');
      }

      // In a real app, you would validate the password here
      // For demo purposes, we'll accept any password

      // Update user's last login time
      final updatedUser = user.copyWith(
        lastLogin: DateTime.now(),
      );

      // Update user in the list
      final index = _users.indexWhere((u) => u.id == user.id);
      if (index >= 0) {
        _users[index] = updatedUser;
        await DatabaseService.saveUsers(_users);
      }

      // Set current user
      _currentUser = updatedUser;

      // Create auth token with 1 hour expiry
      _authToken = AuthToken(
        token: 'token-${user.id}-${DateTime.now().millisecondsSinceEpoch}',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        refreshToken: 'refresh-token-${user.id}-${DateTime.now().millisecondsSinceEpoch}',
      );

      // Save current user to storage
      await DatabaseService.saveCurrentUser(updatedUser);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().contains('Exception: ')
          ? e.toString().split('Exception: ')[1]
          : 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Log out
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Remove current user from storage
      await DatabaseService.removeCurrentUser();

      _currentUser = null;
      _authToken = null;
      _error = null;
    } catch (e) {
      _error = 'Logout failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      // Check if email exists
      final userExists = _users.any((user) =>
        user.email.toLowerCase() == email.toLowerCase() &&
        user.status == AccountStatus.active
      );

      if (!userExists) {
        _error = 'Email not found or account is not active';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // In a real app, you would send a password reset email here

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Password reset failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Check if current user has specific permission
  bool hasPermission(String permission) {
    if (!isAuthenticated || _currentUser == null) return false;
    return _currentUser!.hasPermission(permission);
  }

  // Add a new user
  Future<bool> addUser({
    required String email,
    required String firstName,
    required String lastName,
    required UserRole role,
    String? profileImageUrl,
    required List<String> permissions,
  }) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      // Check if email already exists
      if (_users.any((user) => user.email.toLowerCase() == email.toLowerCase())) {
        _error = 'Email already exists';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Generate new user ID
      final newId = 'USR${(_users.length + 1).toString().padLeft(3, '0')}';

      // Create new user
      final newUser = User(
        id: newId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        profileImageUrl: profileImageUrl,
        role: role,
        status: AccountStatus.active,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        permissions: permissions,
        isTwoFactorEnabled: false,
        isEmailVerified: false,
      );

      // Add to list
      _users.add(newUser);

      // Save to storage
      final success = await DatabaseService.saveUsers(_users);

      if (!success) {
        _error = 'Failed to save user data';
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Error adding user: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update an existing user
  Future<bool> updateUser({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
    required UserRole role,
    String? profileImageUrl,
    required List<String> permissions,
    required AccountStatus status,
  }) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      // Find user index
      final index = _users.indexWhere((user) => user.id == userId);

      if (index < 0) {
        _error = 'User not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check if email already exists for another user
      if (_users.any((user) =>
        user.id != userId &&
        user.email.toLowerCase() == email.toLowerCase()
      )) {
        _error = 'Email already exists for another user';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Get existing user
      final existingUser = _users[index];

      // Create updated user
      final updatedUser = existingUser.copyWith(
        email: email,
        firstName: firstName,
        lastName: lastName,
        profileImageUrl: profileImageUrl,
        role: role,
        status: status,
        permissions: permissions,
      );

      // Update list
      _users[index] = updatedUser;

      // If updating current user, update that too
      if (_currentUser?.id == userId) {
        _currentUser = updatedUser;
        await DatabaseService.saveCurrentUser(updatedUser);
      }

      // Save to storage
      final success = await DatabaseService.saveUsers(_users);

      if (!success) {
        _error = 'Failed to save user data';
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Error updating user: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete a user
  Future<bool> deleteUser(String userId) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      // Cannot delete current user
      if (_currentUser?.id == userId) {
        _error = 'Cannot delete the currently logged in user';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Remove from list
      _users.removeWhere((user) => user.id == userId);

      // Save to storage
      final success = await DatabaseService.saveUsers(_users);

      if (!success) {
        _error = 'Failed to save user data';
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Error deleting user: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Refresh user data
  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final loadedUsers = await DatabaseService.loadUsers();
      if (loadedUsers.isNotEmpty) {
        _users = loadedUsers;

        // If current user exists, update with latest data
        if (_currentUser != null) {
          final updatedCurrentUser = _users.firstWhere(
            (u) => u.id == _currentUser!.id,
            orElse: () => _currentUser!,
          );

          _currentUser = updatedCurrentUser;
        }

        _error = null;
      }
    } catch (e) {
      _error = 'Failed to refresh user data: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
