import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';

import '../models/invoice_models.dart';
import '../models/upi_payment_model.dart';

/// Utility to generate UPI QR codes for invoices
class UpiQrGenerator {
  /// Generate a UPI QR code image widget
  static Widget generateUpiQrWidget({
    required String upiId,
    required String payeeName,
    double? amount,
    String? transactionNote,
    String? merchantCode,
    String? referenceId,
    double size = 200,
    Color backgroundColor = Colors.white,
    Color foregroundColor = Colors.black,
  }) {
    final UPIQRCode qrCode = UPIQRCode(
      upiId: upiId,
      payeeName: payeeName,
      amount: amount,
      transactionNote: transactionNote,
      merchantCode: merchantCode,
      referenceId: referenceId,
    );

    return QrImageView(
      data: qrCode.generateUpiUri(),
      version: QrVersions.auto,
      size: size,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: EdgeInsets.all(16),
      embeddedImage: AssetImage('assets/images/upi_logo.png'),
      embeddedImageStyle: QrEmbeddedImageStyle(
        size: Size(40, 40),
      ),
      errorStateBuilder: (context, error) {
        return Container(
          width: size,
          height: size,
          color: Colors.white,
          child: Center(
            child: Text(
              "Error generating QR code",
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      },
    );
  }

  /// Generate a UPI QR code for an invoice
  static Widget generateInvoiceUpiQr(Invoice invoice, {
    required String upiId,
    required String payeeName,
    String? merchantCode,
    double size = 200,
  }) {
    // Calculate the total amount
    final double totalAmount = invoice.calculateTotal();

    // Create a reference ID using the invoice number
    final String referenceId = invoice.invoiceNumber;

    // Create a transaction note with invoice details
    final String transactionNote = "Payment for Invoice #${invoice.invoiceNumber}";

    return generateUpiQrWidget(
      upiId: upiId,
      payeeName: payeeName,
      amount: totalAmount,
      transactionNote: transactionNote,
      merchantCode: merchantCode,
      referenceId: referenceId,
      size: size,
    );
  }

  /// Capture QR widget as image for PDF embedding
  static Future<Uint8List> captureQrCodeAsImage(Widget qrWidget, {double size = 200}) async {
    final RenderRepaintBoundary boundary = RenderRepaintBoundary();
    final RenderObject renderObject = boundary.attachRenderObject(
      RenderObject(),
    );

    final BuildContext context = BuildContext(
      renderObject,
    );

    final qrImage = RepaintBoundary(
      key: GlobalKey(),
      child: SizedBox(
        width: size,
        height: size,
        child: qrWidget,
      ),
    );

    // Wait for the first frame to be rendered
    await Future.delayed(Duration(milliseconds: 100));

    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Failed to capture QR code as image');
    }

    return byteData.buffer.asUint8List();
  }

  /// Add UPI QR code to PDF
  static Future<pw.Widget> addUpiQrToPdf({
    required String upiId,
    required String payeeName,
    double? amount,
    String? transactionNote,
    String? merchantCode,
    String? referenceId,
  }) async {
    final UPIQRCode qrCode = UPIQRCode(
      upiId: upiId,
      payeeName: payeeName,
      amount: amount,
      transactionNote: transactionNote,
      merchantCode: merchantCode,
      referenceId: referenceId,
    );

    // Generate QR code data
    final String qrData = qrCode.generateUpiUri();

    // Create PDF barcode widget
    return pw.BarcodeWidget(
      barcode: pw.Barcode.qrCode(),
      data: qrData,
      width: 120,
      height: 120,
      color: PdfColors.black,
      backgroundColor: PdfColors.white,
    );
  }

  /// Generate payment links for popular UPI apps
  static List<UPIApp> getPaymentAppLinks({
    bool popularOnly = true,
  }) {
    if (popularOnly) {
      return UPIApps.popularApps;
    } else {
      return UPIApps.allApps;
    }
  }
}
