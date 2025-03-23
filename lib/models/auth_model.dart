import 'package:flutter/material.dart';

enum UserRole {
  admin,
  manager,
  accountant,
  employee,
  viewer
}

enum AccountStatus {
  active,
  inactive,
  suspended,
  pending
}

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? profileImageUrl;
  final UserRole role;
  final AccountStatus status;
  final DateTime createdAt;
  final DateTime lastLogin;
  final List<String> permissions;
  final bool isTwoFactorEnabled;
  final bool isEmailVerified;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profileImageUrl,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.lastLogin,
    required this.permissions,
    this.isTwoFactorEnabled = false,
    this.isEmailVerified = false,
  });

  // Get full name
  String get fullName => '$firstName $lastName';

  // Get initials for avatar
  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}';
    } else if (firstName.isNotEmpty) {
      return firstName[0];
    } else if (lastName.isNotEmpty) {
      return lastName[0];
    } else {
      return email[0].toUpperCase();
    }
  }

  // Get role display name
  String get roleDisplay {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.manager:
        return 'Manager';
      case UserRole.accountant:
        return 'Accountant';
      case UserRole.employee:
        return 'Employee';
      case UserRole.viewer:
        return 'Viewer';
      default:
        return 'Unknown';
    }
  }

  // Get status display name and color
  String get statusDisplay {
    switch (status) {
      case AccountStatus.active:
        return 'Active';
      case AccountStatus.inactive:
        return 'Inactive';
      case AccountStatus.suspended:
        return 'Suspended';
      case AccountStatus.pending:
        return 'Pending';
      default:
        return 'Unknown';
    }
  }

  Color get statusColor {
    switch (status) {
      case AccountStatus.active:
        return Colors.green;
      case AccountStatus.inactive:
        return Colors.grey;
      case AccountStatus.suspended:
        return Colors.red;
      case AccountStatus.pending:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Check if user has specific permission
  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  // Create a copy with updated fields
  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? profileImageUrl,
    UserRole? role,
    AccountStatus? status,
    DateTime? createdAt,
    DateTime? lastLogin,
    List<String>? permissions,
    bool? isTwoFactorEnabled,
    bool? isEmailVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      permissions: permissions ?? this.permissions,
      isTwoFactorEnabled: isTwoFactorEnabled ?? this.isTwoFactorEnabled,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}

class AuthToken {
  final String token;
  final DateTime expiresAt;
  final String refreshToken;

  AuthToken({
    required this.token,
    required this.expiresAt,
    required this.refreshToken,
  });

  // Check if token is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  // Time remaining until expiration
  Duration get timeRemaining => expiresAt.difference(DateTime.now());

  // Check if token needs refresh (less than 5 minutes remaining)
  bool get needsRefresh => timeRemaining.inMinutes < 5;
}
