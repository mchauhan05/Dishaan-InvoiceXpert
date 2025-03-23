import 'package:flutter/material.dart';

/// Model to represent UPI payment details
class UPIDetails {
  final String upiId;
  final String payeeName;
  final String? merchantCode;
  final String? virtualPaymentAddress;
  final bool primary;

  UPIDetails({
    required this.upiId,
    required this.payeeName,
    this.merchantCode,
    this.virtualPaymentAddress,
    this.primary = false,
  });

  // Create from JSON
  factory UPIDetails.fromJson(Map<String, dynamic> json) {
    return UPIDetails(
      upiId: json['upi_id'] as String,
      payeeName: json['payee_name'] as String,
      merchantCode: json['merchant_code'] as String?,
      virtualPaymentAddress: json['virtual_payment_address'] as String?,
      primary: json['primary'] as bool? ?? false,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'upi_id': upiId,
      'payee_name': payeeName,
      'merchant_code': merchantCode,
      'virtual_payment_address': virtualPaymentAddress,
      'primary': primary,
    };
  }

  // Copy with modifications
  UPIDetails copyWith({
    String? upiId,
    String? payeeName,
    String? merchantCode,
    String? virtualPaymentAddress,
    bool? primary,
  }) {
    return UPIDetails(
      upiId: upiId ?? this.upiId,
      payeeName: payeeName ?? this.payeeName,
      merchantCode: merchantCode ?? this.merchantCode,
      virtualPaymentAddress: virtualPaymentAddress ?? this.virtualPaymentAddress,
      primary: primary ?? this.primary,
    );
  }
}

/// Model to represent QR code for UPI payments
class UPIQRCode {
  final String upiId;
  final String payeeName;
  final double? amount;
  final String? transactionNote;
  final String? merchantCode;
  final String? referenceId;
  final String? currency;

  UPIQRCode({
    required this.upiId,
    required this.payeeName,
    this.amount,
    this.transactionNote,
    this.merchantCode,
    this.referenceId,
    this.currency = 'INR',
  });

  // Generate UPI URI for QR code
  String generateUpiUri() {
    StringBuffer uriBuffer = StringBuffer('upi://pay?');

    // Add required parameters
    uriBuffer.write('pa=$upiId');
    uriBuffer.write('&pn=${Uri.encodeComponent(payeeName)}');

    // Add optional parameters if available
    if (amount != null) {
      uriBuffer.write('&am=$amount');
    }

    if (currency != null) {
      uriBuffer.write('&cu=$currency');
    }

    if (transactionNote != null) {
      uriBuffer.write('&tn=${Uri.encodeComponent(transactionNote!)}');
    }

    if (merchantCode != null) {
      uriBuffer.write('&mc=$merchantCode');
    }

    if (referenceId != null) {
      uriBuffer.write('&tr=$referenceId');
    }

    return uriBuffer.toString();
  }
}

/// Model to track payment status
class UPIPaymentStatus {
  final String transactionId;
  final String referenceId;
  final double amount;
  final String status; // SUCCESS, FAILURE, PENDING
  final DateTime timestamp;
  final String? responseCode;
  final String? responseMessage;

  UPIPaymentStatus({
    required this.transactionId,
    required this.referenceId,
    required this.amount,
    required this.status,
    required this.timestamp,
    this.responseCode,
    this.responseMessage,
  });

  // Create from JSON
  factory UPIPaymentStatus.fromJson(Map<String, dynamic> json) {
    return UPIPaymentStatus(
      transactionId: json['transaction_id'] as String,
      referenceId: json['reference_id'] as String,
      amount: json['amount'] as double,
      status: json['status'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      responseCode: json['response_code'] as String?,
      responseMessage: json['response_message'] as String?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'reference_id': referenceId,
      'amount': amount,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'response_code': responseCode,
      'response_message': responseMessage,
    };
  }

  // Check if payment is successful
  bool get isSuccessful => status == 'SUCCESS';

  // Check if payment is pending
  bool get isPending => status == 'PENDING';

  // Check if payment failed
  bool get isFailed => status == 'FAILURE';
}

/// List of popular Indian UPI apps for deep linking
class UPIApp {
  final String name;
  final String packageName; // For Android intent
  final String? urlScheme;  // For iOS and web
  final IconData icon;
  final bool isPopular;

  const UPIApp({
    required this.name,
    required this.packageName,
    this.urlScheme,
    required this.icon,
    this.isPopular = false,
  });
}

class UPIApps {
  static const UPIApp googlePay = UPIApp(
    name: 'Google Pay',
    packageName: 'com.google.android.apps.nbu.paisa.user',
    urlScheme: 'gpay://',
    icon: Icons.account_balance_wallet,
    isPopular: true,
  );

  static const UPIApp phonePe = UPIApp(
    name: 'PhonePe',
    packageName: 'com.phonepe.app',
    urlScheme: 'phonepe://',
    icon: Icons.account_balance_wallet,
    isPopular: true,
  );

  static const UPIApp paytm = UPIApp(
    name: 'Paytm',
    packageName: 'net.one97.paytm',
    urlScheme: 'paytmmp://',
    icon: Icons.account_balance_wallet,
    isPopular: true,
  );

  static const UPIApp bhim = UPIApp(
    name: 'BHIM',
    packageName: 'in.org.npci.upiapp',
    urlScheme: 'bhim://',
    icon: Icons.account_balance_wallet,
    isPopular: true,
  );

  static const UPIApp amazonPay = UPIApp(
    name: 'Amazon Pay',
    packageName: 'in.amazon.mShop.android.shopping',
    urlScheme: 'amazonpay://',
    icon: Icons.account_balance_wallet,
    isPopular: false,
  );

  static const UPIApp whatsapp = UPIApp(
    name: 'WhatsApp',
    packageName: 'com.whatsapp',
    urlScheme: 'whatsapp://',
    icon: Icons.chat,
    isPopular: false,
  );

  static const List<UPIApp> allApps = [
    googlePay,
    phonePe,
    paytm,
    bhim,
    amazonPay,
    whatsapp,
  ];

  static const List<UPIApp> popularApps = [
    googlePay,
    phonePe,
    paytm,
    bhim,
  ];
}
