import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_model.dart';
import '../models/customer_model.dart';
import '../models/product_model.dart';

/// A service class for handling database operations
/// This is a simple implementation using SharedPreferences
/// In a real-world app, this would be replaced with a proper database solution
class DatabaseService {
  static const String _customersKey = 'customers_data';
  static const String _productsKey = 'products_data';
  static const String _usersKey = 'users_data';
  static const String _currentUserKey = 'current_user';

  // ==================== Customer Operations ====================

  /// Save customers to local storage
  static Future<bool> saveCustomers(List<Customer> customers) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert list of customers to List<Map<String, dynamic>> then to JSON string
      final customersJson = jsonEncode(customers.map((customer) =>
        _customerToJson(customer)
      ).toList());

      return await prefs.setString(_customersKey, customersJson);
    } catch (e) {
      print('Error saving customers: $e');
      return false;
    }
  }

  /// Load customers from local storage
  static Future<List<Customer>> loadCustomers() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final customersJson = prefs.getString(_customersKey);
      if (customersJson == null) {
        return [];
      }

      final List<dynamic> customersList = jsonDecode(customersJson);
      return customersList.map((item) => _customerFromJson(item)).toList();
    } catch (e) {
      print('Error loading customers: $e');
      return [];
    }
  }

  /// Convert Customer object to JSON
  static Map<String, dynamic> _customerToJson(Customer customer) {
    return {
      'id': customer.id,
      'displayName': customer.displayName,
      'companyName': customer.companyName,
      'email': customer.email,
      'phone': customer.phone,
      'website': customer.website,
      'billingAddress': {
        'street': customer.billingAddress.street,
        'city': customer.billingAddress.city,
        'state': customer.billingAddress.state,
        'zipCode': customer.billingAddress.zipCode,
        'country': customer.billingAddress.country,
      },
      'shippingAddress': customer.shippingAddress != null ? {
        'street': customer.shippingAddress!.street,
        'city': customer.shippingAddress!.city,
        'state': customer.shippingAddress!.state,
        'zipCode': customer.shippingAddress!.zipCode,
        'country': customer.shippingAddress!.country,
      } : null,
      'contacts': customer.contacts.map((contact) => {
        'firstName': contact.firstName,
        'lastName': contact.lastName,
        'email': contact.email,
        'phone': contact.phone,
        'mobile': contact.mobile,
        'jobTitle': contact.jobTitle,
        'isPrimary': contact.isPrimary,
      }).toList(),
      'currency': customer.currency,
      'taxNumber': customer.taxNumber,
      'notes': customer.notes,
      'status': customer.status.index,
      'createdAt': customer.createdAt.toIso8601String(),
      'outstandingAmount': customer.outstandingAmount,
      'totalInvoices': customer.totalInvoices,
      'tags': customer.tags,
    };
  }

  /// Convert JSON to Customer object
  static Customer _customerFromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      displayName: json['displayName'],
      companyName: json['companyName'],
      email: json['email'],
      phone: json['phone'],
      website: json['website'] ?? '',
      billingAddress: Address(
        street: json['billingAddress']['street'],
        city: json['billingAddress']['city'],
        state: json['billingAddress']['state'],
        zipCode: json['billingAddress']['zipCode'],
        country: json['billingAddress']['country'],
      ),
      shippingAddress: json['shippingAddress'] != null ? Address(
        street: json['shippingAddress']['street'],
        city: json['shippingAddress']['city'],
        state: json['shippingAddress']['state'],
        zipCode: json['shippingAddress']['zipCode'],
        country: json['shippingAddress']['country'],
      ) : null,
      contacts: (json['contacts'] as List).map((contactJson) => Contact(
        firstName: contactJson['firstName'],
        lastName: contactJson['lastName'],
        email: contactJson['email'],
        phone: contactJson['phone'],
        mobile: contactJson['mobile'],
        jobTitle: contactJson['jobTitle'],
        isPrimary: contactJson['isPrimary'],
      )).toList(),
      currency: json['currency'],
      taxNumber: json['taxNumber'],
      notes: json['notes'],
      status: CustomerStatus.values[json['status']],
      createdAt: DateTime.parse(json['createdAt']),
      outstandingAmount: json['outstandingAmount'],
      totalInvoices: json['totalInvoices'],
      tags: json['tags'],
    );
  }

  // ==================== Product Operations ====================

  /// Save products to local storage
  static Future<bool> saveProducts(List<Product> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert list of products to List<Map<String, dynamic>> then to JSON string
      final productsJson = jsonEncode(products.map((product) =>
        _productToJson(product)
      ).toList());

      return await prefs.setString(_productsKey, productsJson);
    } catch (e) {
      print('Error saving products: $e');
      return false;
    }
  }

  /// Load products from local storage
  static Future<List<Product>> loadProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final productsJson = prefs.getString(_productsKey);
      if (productsJson == null) {
        return [];
      }

      final List<dynamic> productsList = jsonDecode(productsJson);
      return productsList.map((item) => _productFromJson(item)).toList();
    } catch (e) {
      print('Error loading products: $e');
      return [];
    }
  }

  /// Convert Product object to JSON
  static Map<String, dynamic> _productToJson(Product product) {
    return {
      'id': product.id,
      'sku': product.sku,
      'barcode': product.barcode,
      'name': product.name,
      'description': product.description,
      'sellingPrice': product.sellingPrice,
      'costPrice': product.costPrice,
      'weight': product.weight,
      'unit': product.unit,
      'dimensions': product.dimensions,
      'manufacturer': product.manufacturer,
      'brand': product.brand,
      'type': product.type.index,
      'taxType': product.taxType.index,
      'taxRate': product.taxRate,
      'category': product.category,
      'inventoryTracking': product.inventoryTracking.index,
      'stockQuantity': product.stockQuantity,
      'lowStockAlert': product.lowStockAlert,
      'imageUrl': product.imageUrl,
      'isActive': product.isActive,
      'createdAt': product.createdAt.toIso8601String(),
      'updatedAt': product.updatedAt.toIso8601String(),
    };
  }

  /// Convert JSON to Product object
  static Product _productFromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      sku: json['sku'],
      barcode: json['barcode'],
      name: json['name'],
      description: json['description'],
      sellingPrice: json['sellingPrice'],
      costPrice: json['costPrice'],
      weight: json['weight'],
      unit: json['unit'],
      dimensions: json['dimensions'],
      manufacturer: json['manufacturer'],
      brand: json['brand'],
      type: ProductType.values[json['type']],
      taxType: TaxType.values[json['taxType']],
      taxRate: json['taxRate'],
      category: json['category'],
      inventoryTracking: InventoryTracking.values[json['inventoryTracking']],
      stockQuantity: json['stockQuantity'],
      lowStockAlert: json['lowStockAlert'],
      imageUrl: json['imageUrl'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // ==================== User Operations ====================

  /// Save users to local storage
  static Future<bool> saveUsers(List<User> users) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert list of users to List<Map<String, dynamic>> then to JSON string
      final usersJson = jsonEncode(users.map((user) =>
        _userToJson(user)
      ).toList());

      return await prefs.setString(_usersKey, usersJson);
    } catch (e) {
      print('Error saving users: $e');
      return false;
    }
  }

  /// Save current user to local storage
  static Future<bool> saveCurrentUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert user to JSON string
      final userJson = jsonEncode(_userToJson(user));

      return await prefs.setString(_currentUserKey, userJson);
    } catch (e) {
      print('Error saving current user: $e');
      return false;
    }
  }

  /// Load users from local storage
  static Future<List<User>> loadUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final usersJson = prefs.getString(_usersKey);
      if (usersJson == null) {
        return [];
      }

      final List<dynamic> usersList = jsonDecode(usersJson);
      return usersList.map((item) => _userFromJson(item)).toList();
    } catch (e) {
      print('Error loading users: $e');
      return [];
    }
  }

  /// Load current user from local storage
  static Future<User?> loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final userJson = prefs.getString(_currentUserKey);
      if (userJson == null) {
        return null;
      }

      final Map<String, dynamic> userData = jsonDecode(userJson);
      return _userFromJson(userData);
    } catch (e) {
      print('Error loading current user: $e');
      return null;
    }
  }

  /// Remove current user from local storage (logout)
  static Future<bool> removeCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_currentUserKey);
    } catch (e) {
      print('Error removing current user: $e');
      return false;
    }
  }

  /// Convert User object to JSON
  static Map<String, dynamic> _userToJson(User user) {
    return {
      'id': user.id,
      'email': user.email,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'profileImageUrl': user.profileImageUrl,
      'role': user.role.index,
      'status': user.status.index,
      'createdAt': user.createdAt.toIso8601String(),
      'lastLogin': user.lastLogin.toIso8601String(),
      'permissions': user.permissions,
      'isTwoFactorEnabled': user.isTwoFactorEnabled,
      'isEmailVerified': user.isEmailVerified,
    };
  }

  /// Convert JSON to User object
  static User _userFromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      profileImageUrl: json['profileImageUrl'],
      role: UserRole.values[json['role']],
      status: AccountStatus.values[json['status']],
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin: DateTime.parse(json['lastLogin']),
      permissions: List<String>.from(json['permissions']),
      isTwoFactorEnabled: json['isTwoFactorEnabled'],
      isEmailVerified: json['isEmailVerified'],
    );
  }
}
