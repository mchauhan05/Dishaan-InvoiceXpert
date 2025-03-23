import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Utility class for barcode handling
class BarcodeUtils {
  /// Validates an EAN-13 barcode
  static bool validateEan13(String barcode) {
    // Check if the barcode has exactly 13 digits
    if (barcode.length != 13 || !RegExp(r'^\d{13}$').hasMatch(barcode)) {
      return false;
    }

    // Calculate check digit
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      final digit = int.parse(barcode[i]);
      sum += digit * (i % 2 == 0 ? 1 : 3);
    }

    final checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == int.parse(barcode[12]);
  }

  /// Generates a valid EAN-13 barcode
  static String generateEan13() {
    final random = Random();

    // Generate 12 digits
    final List<int> digits = List.generate(12, (_) => random.nextInt(10));

    // Calculate check digit
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      sum += digits[i] * (i % 2 == 0 ? 1 : 3);
    }

    final checkDigit = (10 - (sum % 10)) % 10;
    digits.add(checkDigit);

    return digits.join();
  }

  /// Generates a valid UPC-A barcode (12 digits)
  static String generateUpcA() {
    final random = Random();

    // Generate 11 digits
    final List<int> digits = List.generate(11, (_) => random.nextInt(10));

    // Calculate check digit
    int sum = 0;
    for (int i = 0; i < 11; i++) {
      sum += digits[i] * (i % 2 == 0 ? 3 : 1);
    }

    final checkDigit = (10 - (sum % 10)) % 10;
    digits.add(checkDigit);

    return digits.join();
  }

  /// Formats a barcode for display, adding spaces for readability
  static String formatBarcode(String barcode, {int groupSize = 4}) {
    if (barcode.length <= groupSize) return barcode;

    final List<String> parts = [];
    for (int i = 0; i < barcode.length; i += groupSize) {
      final end = (i + groupSize < barcode.length) ? i + groupSize : barcode.length;
      parts.add(barcode.substring(i, end));
    }

    return parts.join(' ');
  }

  /// Gets barcode type based on length and pattern
  static String getBarcodeType(String barcode) {
    // Remove any spaces or formatting
    final cleanBarcode = barcode.replaceAll(RegExp(r'\s'), '');

    if (cleanBarcode.length == 13 && RegExp(r'^\d{13}$').hasMatch(cleanBarcode)) {
      return 'EAN-13';
    } else if (cleanBarcode.length == 12 && RegExp(r'^\d{12}$').hasMatch(cleanBarcode)) {
      return 'UPC-A';
    } else if (cleanBarcode.length == 8 && RegExp(r'^\d{8}$').hasMatch(cleanBarcode)) {
      return 'EAN-8';
    } else if (RegExp(r'^[A-Z0-9]+$').hasMatch(cleanBarcode)) {
      return 'CODE-39';
    } else {
      return 'Unknown';
    }
  }

  /// Mock function to simulate barcode scanning
  /// In a real app, this would integrate with the device's camera
  static Future<String?> scanBarcode(BuildContext context) async {
    // Simulate a camera scan
    await Future.delayed(const Duration(seconds: 2));

    // Return a mock barcode (in real app, this would be the scanned result)
    return generateEan13();
  }

  /// Mock function to generate a barcode image
  /// In a real app, this would use a library to generate an actual barcode image
  static Widget buildBarcodeWidget(String barcode, {double width = 200, double height = 80}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Draw a mockup barcode with vertical lines
            SizedBox(
              width: width * 0.8,
              height: height * 0.6,
              child: CustomPaint(
                painter: _BarcodePainter(barcode),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatBarcode(barcode),
              style: const TextStyle(
                fontSize: 12,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter to draw a mock barcode
class _BarcodePainter extends CustomPainter {
  final String barcode;

  _BarcodePainter(this.barcode);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final Random random = Random(barcode.hashCode); // Use barcode as random seed

    // Draw vertical bars
    final double barWidth = size.width / (barcode.length * 2);
    double x = 0;

    for (int i = 0; i < barcode.length; i++) {
      final digit = int.parse(barcode[i % barcode.length].toString());
      final width = barWidth * (0.5 + (digit / 10.0));

      // Skip some bars to create spaces
      if (random.nextDouble() > 0.3) {
        canvas.drawRect(
          Rect.fromLTWH(x, 0, width, size.height),
          paint,
        );
      }

      x += width + barWidth * 0.5;
    }

    // Draw start and end markers
    canvas.drawRect(
      Rect.fromLTWH(0, 0, barWidth * 1.5, size.height),
      paint,
    );

    canvas.drawRect(
      Rect.fromLTWH(size.width - barWidth * 1.5, 0, barWidth * 1.5, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
