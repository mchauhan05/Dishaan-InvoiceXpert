import 'package:flutter/material.dart';

enum CustomerStatus {
  active,
  inactive,
  blocked
}

class Address {
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
  });

  // Get formatted address as a string
  String get formattedAddress {
    return '$street, $city, $state $zipCode, $country';
  }

  // Create a copy with updated fields
  Address copyWith({
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? country,
  }) {
    return Address(
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
    );
  }
}

class Contact {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? mobile;
  final String? jobTitle;
  final bool isPrimary;

  Contact({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.mobile,
    this.jobTitle,
    this.isPrimary = false,
  });

  // Get full name
  String get fullName => '$firstName $lastName';

  // Create a copy with updated fields
  Contact copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? mobile,
    String? jobTitle,
    bool? isPrimary,
  }) {
    return Contact(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      mobile: mobile ?? this.mobile,
      jobTitle: jobTitle ?? this.jobTitle,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}

class Customer {
  final String id;
  final String displayName;
  final String companyName;
  final String email;
  final String phone;
  final String website;
  final Address billingAddress;
  final Address? shippingAddress; // Optional, can be same as billing
  final List<Contact> contacts;
  final String currency;
  final String? taxNumber;
  final String? notes;
  final CustomerStatus status;
  final DateTime createdAt;
  final double outstandingAmount;
  final int totalInvoices;
  final String? tags;

  Customer({
    required this.id,
    required this.displayName,
    required this.companyName,
    required this.email,
    required this.phone,
    this.website = '',
    required this.billingAddress,
    this.shippingAddress,
    required this.contacts,
    this.currency = 'USD',
    this.taxNumber,
    this.notes,
    this.status = CustomerStatus.active,
    required this.createdAt,
    this.outstandingAmount = 0.0,
    this.totalInvoices = 0,
    this.tags,
  });

  // Get primary contact
  Contact? get primaryContact {
    try {
      return contacts.firstWhere((contact) => contact.isPrimary);
    } catch (e) {
      return contacts.isNotEmpty ? contacts.first : null;
    }
  }

  // Get status text
  String get statusText {
    switch (status) {
      case CustomerStatus.active:
        return 'Active';
      case CustomerStatus.inactive:
        return 'Inactive';
      case CustomerStatus.blocked:
        return 'Blocked';
      default:
        return 'Unknown';
    }
  }

  // Get status color
  Color get statusColor {
    switch (status) {
      case CustomerStatus.active:
        return Colors.green;
      case CustomerStatus.inactive:
        return Colors.grey;
      case CustomerStatus.blocked:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Create a copy with updated fields
  Customer copyWith({
    String? id,
    String? displayName,
    String? companyName,
    String? email,
    String? phone,
    String? website,
    Address? billingAddress,
    Address? shippingAddress,
    List<Contact>? contacts,
    String? currency,
    String? taxNumber,
    String? notes,
    CustomerStatus? status,
    DateTime? createdAt,
    double? outstandingAmount,
    int? totalInvoices,
    String? tags,
  }) {
    return Customer(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      billingAddress: billingAddress ?? this.billingAddress,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      contacts: contacts ?? this.contacts,
      currency: currency ?? this.currency,
      taxNumber: taxNumber ?? this.taxNumber,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      outstandingAmount: outstandingAmount ?? this.outstandingAmount,
      totalInvoices: totalInvoices ?? this.totalInvoices,
      tags: tags ?? this.tags,
    );
  }
}
