import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/indian_invoice_model.dart';
import '../models/invoice_models.dart';
import '../models/settings_model.dart';

/// Specialized PDF generator for Indian GST invoices
class IndianPdfGenerator {
  /// Generate a GST-compliant invoice PDF
  static Future<Uint8List> generateGSTInvoicePdf(
    Invoice invoice,
    AppSettings settings,
    GSTInvoiceDetails gstDetails, {
    bool addWatermark = false,
    String watermarkText = 'UNPAID',
    PdfColor watermarkColor = const PdfColor(0.9, 0.1, 0.1, 0.3),
  }) async {
    final pdf = pw.Document();

    // Load logo if it exists
    pw.MemoryImage? logoImage;
    try {
      if (settings.companyProfile.logoUrl != null &&
          settings.companyProfile.logoUrl!.isNotEmpty) {
        final logoBytes = await NetworkAssetBundle(Uri.parse(settings.companyProfile.logoUrl!))
            .load(settings.companyProfile.logoUrl!);
        logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
      }
    } catch (e) {
      print('Error loading logo: $e');
    }

    // Define font styles
    final titleStyle = pw.TextStyle(
      fontSize: 22,
      fontWeight: pw.FontWeight.bold,
    );

    final subTitleStyle = pw.TextStyle(
      fontSize: 16,
      fontWeight: pw.FontWeight.bold,
    );

    final headerStyle = pw.TextStyle(
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
    );

    final normalStyle = pw.TextStyle(
      fontSize: 10,
    );

    final smallStyle = pw.TextStyle(
      fontSize: 8,
      color: PdfColors.grey700,
    );

    final boldStyle = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
    );

    // Format currency
    final currencyFormatter = NumberFormat.currency(
      symbol: settings.currencySettings.currencySymbol,
      decimalDigits: settings.currencySettings.decimalPlaces,
    );

    // Format date
    final dateFormatter = DateFormat('dd-MM-yyyy');

    // Define table styles
    final tableHeaderStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 10,
      color: PdfColors.white,
    );

    final tableHeaderBackground = PdfColors.indigo;
    final tableAlternateColor = PdfColors.grey100;

    // Add the invoice page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header with company info and GST details
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(5)),
                    ),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Company info
                        pw.Expanded(
                          flex: 3,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              if (logoImage != null)
                                pw.Container(
                                  height: 60,
                                  width: 160,
                                  margin: const pw.EdgeInsets.only(bottom: 8),
                                  child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                                ),
                              pw.Text(settings.companyProfile.companyName, style: titleStyle),
                              pw.SizedBox(height: 4),
                              pw.Text(settings.companyProfile.address, style: normalStyle),
                              pw.Text(
                                '${settings.companyProfile.city}, ${settings.companyProfile.state}, ${settings.companyProfile.zipCode}',
                                style: normalStyle,
                              ),
                              pw.Text(settings.companyProfile.country, style: normalStyle),
                              pw.SizedBox(height: 4),
                              if (gstDetails.sellerGstin != null)
                                pw.Text('GSTIN: ${gstDetails.sellerGstin}', style: boldStyle),
                              pw.Text('Phone: ${settings.companyProfile.phone}', style: normalStyle),
                              pw.Text('Email: ${settings.companyProfile.email}', style: normalStyle),
                            ],
                          ),
                        ),

                        // Invoice details
                        pw.Expanded(
                          flex: 2,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text('TAX INVOICE', style: titleStyle),
                              pw.SizedBox(height: 8),
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text('Invoice Number:', style: boldStyle),
                                  pw.Text('${invoice.invoiceNumber}', style: normalStyle),
                                ]
                              ),
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text('Invoice Date:', style: boldStyle),
                                  pw.Text(dateFormatter.format(invoice.invoiceDate), style: normalStyle),
                                ]
                              ),
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text('Due Date:', style: boldStyle),
                                  pw.Text(dateFormatter.format(invoice.dueDate), style: normalStyle),
                                ]
                              ),
                              if (gstDetails.reverseCharge)
                                pw.Text('Reverse Charge: Yes', style: boldStyle),
                              if (gstDetails.invoiceType != null && gstDetails.invoiceType != 'Regular')
                                pw.Text('Type: ${gstDetails.invoiceType}', style: boldStyle),
                              if (gstDetails.exportInvoice)
                                pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                                  children: [
                                    pw.Text('Export Invoice', style: boldStyle),
                                    if (gstDetails.shippingBillNumber != null)
                                      pw.Text('Shipping Bill No: ${gstDetails.shippingBillNumber}', style: normalStyle),
                                    if (gstDetails.shippingBillDate != null)
                                      pw.Text('Shipping Bill Date: ${dateFormatter.format(gstDetails.shippingBillDate!)}', style: normalStyle),
                                    if (gstDetails.portCode != null)
                                      pw.Text('Port Code: ${gstDetails.portCode}', style: normalStyle),
                                  ]
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 20),

                  // Customer details
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Bill to
                      pw.Expanded(
                        child: pw.Container(
                          padding: const pw.EdgeInsets.all(10),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey300),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Bill To:', style: headerStyle),
                              pw.SizedBox(height: 4),
                              pw.Text(invoice.customer.displayName, style: boldStyle),
                              if (invoice.customer.companyName.isNotEmpty)
                                pw.Text(invoice.customer.companyName, style: normalStyle),
                              pw.Text(invoice.customer.billingAddress.street, style: normalStyle),
                              pw.Text(
                                '${invoice.customer.billingAddress.city}, ${invoice.customer.billingAddress.state}, ${invoice.customer.billingAddress.zipCode}',
                                style: normalStyle,
                              ),
                              pw.Text(invoice.customer.billingAddress.country, style: normalStyle),
                              if (gstDetails.buyerGstin != null)
                                pw.Text('GSTIN: ${gstDetails.buyerGstin}', style: boldStyle),
                              pw.Text('Phone: ${invoice.customer.phone}', style: normalStyle),
                              pw.Text('Email: ${invoice.customer.email}', style: normalStyle),
                            ],
                          ),
                        ),
                      ),

                      pw.SizedBox(width: 10),

                      // Ship to (if different)
                      if (invoice.customer.shippingAddress != null)
                        pw.Expanded(
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(10),
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.grey300),
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('Ship To:', style: headerStyle),
                                pw.SizedBox(height: 4),
                                pw.Text(invoice.customer.displayName, style: boldStyle),
                                if (invoice.customer.companyName.isNotEmpty)
                                  pw.Text(invoice.customer.companyName, style: normalStyle),
                                pw.Text(invoice.customer.shippingAddress!.street, style: normalStyle),
                                pw.Text(
                                  '${invoice.customer.shippingAddress!.city}, ${invoice.customer.shippingAddress!.state}, ${invoice.customer.shippingAddress!.zipCode}',
                                  style: normalStyle,
                                ),
                                pw.Text(invoice.customer.shippingAddress!.country, style: normalStyle),
                                if (gstDetails.placeOfSupply != null)
                                  pw.Text('Place of Supply: ${GSTINValidator.getStateName(gstDetails.placeOfSupply!) ?? gstDetails.placeOfSupply}', style: boldStyle),
                                if (gstDetails.isInterState)
                                  pw.Text('Interstate Supply', style: boldStyle),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                  pw.SizedBox(height: 20),

                  // Invoice items table
                  pw.Table.fromTextArray(
                    headerStyle: tableHeaderStyle,
                    headerDecoration: pw.BoxDecoration(
                      color: tableHeaderBackground,
                    ),
                    cellHeight: 30,
                    cellAlignments: {
                      0: pw.Alignment.centerLeft,
                      1: pw.Alignment.center,
                      2: pw.Alignment.center,
                      3: pw.Alignment.center,
                      4: pw.Alignment.center,
                      5: pw.Alignment.centerRight,
                      6: pw.Alignment.centerRight,
                    },
                    headerAlignments: {
                      0: pw.Alignment.centerLeft,
                      1: pw.Alignment.center,
                      2: pw.Alignment.center,
                      3: pw.Alignment.center,
                      4: pw.Alignment.center,
                      5: pw.Alignment.centerRight,
                      6: pw.Alignment.centerRight,
                    },
                    columnWidths: {
                      0: const pw.FlexColumnWidth(3), // Description
                      1: const pw.FlexColumnWidth(1), // HSN/SAC
                      2: const pw.FlexColumnWidth(1), // Qty
                      3: const pw.FlexColumnWidth(1), // Rate
                      4: const pw.FlexColumnWidth(1), // Tax Rate
                      5: const pw.FlexColumnWidth(1), // Tax Amount
                      6: const pw.FlexColumnWidth(1), // Amount
                    },
                    headers: [
                      'Description',
                      'HSN/SAC',
                      'Qty',
                      'Rate',
                      'Tax Rate',
                      'Tax',
                      'Amount',
                    ],
                    data: invoice.items.map((item) {
                      final productGst = item.product.metadata != null &&
                              item.product.metadata!['gstDetails'] != null
                          ? ProductGSTDetails.fromJson(item.product.metadata!['gstDetails'])
                          : null;

                      final hsnCode = productGst?.hsnCode ?? 'N/A';
                      final sacCode = productGst?.sacCode;
                      final displayCode = sacCode != null ? sacCode : hsnCode;

                      final taxRate = item.taxRate;
                      final taxAmount = item.taxAmount;

                      return [
                        item.description,
                        displayCode,
                        item.quantity.toString(),
                        currencyFormatter.format(item.unitPrice),
                        '${taxRate.toStringAsFixed(2)}%',
                        currencyFormatter.format(taxAmount),
                        currencyFormatter.format(item.total),
                      ];
                    }).toList(),
                    oddRowDecoration: pw.BoxDecoration(
                      color: tableAlternateColor,
                    ),
                  ),

                  pw.SizedBox(height: 20),

                  // Totals and GST breakdown
                  pw.Row(
                    children: [
                      // Notes
                      pw.Expanded(
                        flex: 3,
                        child: pw.Container(
                          padding: const pw.EdgeInsets.all(10),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey300),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Notes:', style: headerStyle),
                              pw.SizedBox(height: 5),
                              pw.Text(invoice.notes ?? '', style: normalStyle),

                              pw.SizedBox(height: 10),
                              pw.Text('Terms & Conditions:', style: headerStyle),
                              pw.SizedBox(height: 5),
                              pw.Text(invoice.terms ?? 'Payment is due within the stipulated time.', style: normalStyle),

                              pw.SizedBox(height: 10),
                              if (invoice.paymentInfo != null)
                                pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text('Payment Information:', style: headerStyle),
                                    pw.SizedBox(height: 5),
                                    pw.Text(invoice.paymentInfo!, style: normalStyle),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),

                      pw.SizedBox(width: 10),

                      // Totals
                      pw.Expanded(
                        flex: 2,
                        child: pw.Container(
                          padding: const pw.EdgeInsets.all(10),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey300),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                          ),
                          child: pw.Column(
                            children: [
                              // Subtotal
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text('Subtotal:', style: normalStyle),
                                  pw.Text(currencyFormatter.format(invoice.subtotal), style: normalStyle),
                                ],
                              ),

                              pw.SizedBox(height: 5),

                              // Discount
                              if (invoice.discountAmount > 0)
                                pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text('Discount:', style: normalStyle),
                                    pw.Text('- ${currencyFormatter.format(invoice.discountAmount)}', style: normalStyle),
                                  ],
                                ),

                              pw.SizedBox(height: 5),

                              // GST breakdown
                              if (gstDetails.cgstAmount != null && gstDetails.cgstAmount! > 0)
                                pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text('CGST:', style: normalStyle),
                                    pw.Text(currencyFormatter.format(gstDetails.cgstAmount!), style: normalStyle),
                                  ],
                                ),

                              if (gstDetails.sgstAmount != null && gstDetails.sgstAmount! > 0)
                                pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text('SGST:', style: normalStyle),
                                    pw.Text(currencyFormatter.format(gstDetails.sgstAmount!), style: normalStyle),
                                  ],
                                ),

                              if (gstDetails.igstAmount != null && gstDetails.igstAmount! > 0)
                                pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text('IGST:', style: normalStyle),
                                    pw.Text(currencyFormatter.format(gstDetails.igstAmount!), style: normalStyle),
                                  ],
                                ),

                              if (gstDetails.cessAmount != null && gstDetails.cessAmount! > 0)
                                pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text('CESS:', style: normalStyle),
                                    pw.Text(currencyFormatter.format(gstDetails.cessAmount!), style: normalStyle),
                                  ],
                                ),

                              // Shipping
                              if (invoice.shippingAmount > 0)
                                pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text('Shipping:', style: normalStyle),
                                    pw.Text(currencyFormatter.format(invoice.shippingAmount), style: normalStyle),
                                  ],
                                ),

                              pw.Divider(thickness: 1),

                              // Grand total
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text('Grand Total:', style: boldStyle),
                                  pw.Text(currencyFormatter.format(invoice.total), style: titleStyle),
                                ],
                              ),

                              // Amount in words
                              pw.SizedBox(height: 10),
                              pw.Text(
                                'Amount in words: ${_convertToWords(invoice.total, settings.currencySettings.defaultCurrency)}',
                                style: smallStyle,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 20),

                  // Footer with authorized signatory
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Declaration:', style: smallStyle),
                            pw.Text(
                              'We declare that this invoice shows the actual price of the goods/services described and that all particulars are true and correct.',
                              style: smallStyle,
                            ),

                            if (invoice.status == InvoiceStatus.paid)
                              pw.Container(
                                margin: const pw.EdgeInsets.only(top: 10),
                                child: pw.Text('PAID',
                                  style: pw.TextStyle(
                                    color: PdfColors.green700,
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('For ${settings.companyProfile.companyName}', style: normalStyle),
                          pw.SizedBox(height: 40), // Space for signature
                          pw.Text('Authorized Signatory', style: normalStyle),
                        ],
                      ),
                    ],
                  ),

                  // Digital footer
                  pw.Container(
                    margin: const pw.EdgeInsets.only(top: 20),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      'This is a computer-generated invoice and does not require a physical signature.',
                      style: smallStyle,
                    ),
                  ),

                  // QR code placeholder - In a real app, you would generate a QR code
                  // containing invoice details for digital verification
                  // pw.Container(
                  //   alignment: pw.Alignment.bottomRight,
                  //   child: pw.BarcodeWidget(
                  //     data: 'INVOICE:${invoice.invoiceNumber}',
                  //     barcode: pw.Barcode.qrCode(),
                  //     width: 80,
                  //     height: 80,
                  //   ),
                  // ),
                ],
              ),

              // Watermark if unpaid
              if (addWatermark)
                pw.Center(
                  child: pw.Transform.rotate(
                    angle: -0.5, // Rotate by -30 degrees
                    child: pw.Text(
                      watermarkText,
                      style: pw.TextStyle(
                        color: watermarkColor,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 100,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Convert number to words (simplified, only handles basic cases)
  static String _convertToWords(double amount, String currencyCode) {
    // This is a simplified implementation
    // In a production app, use a proper number-to-words library

    String currency = 'Rupees';
    String subCurrency = 'Paise';

    switch (currencyCode) {
      case 'INR':
        currency = 'Rupees';
        subCurrency = 'Paise';
        break;
      case 'USD':
        currency = 'Dollars';
        subCurrency = 'Cents';
        break;
      case 'EUR':
        currency = 'Euros';
        subCurrency = 'Cents';
        break;
      case 'GBP':
        currency = 'Pounds';
        subCurrency = 'Pence';
        break;
    }

    int rupees = amount.toInt();
    int paise = ((amount - rupees) * 100).round();

    // Very basic implementation - would need a proper library in production
    return '${_numberToWords(rupees)} $currency and ${_numberToWords(paise)} $subCurrency Only';
  }

  /// Convert number to words (simplified)
  static String _numberToWords(int number) {
    // Simplified implementation
    // In a real app, use a proper library or more comprehensive algorithm
    if (number == 0) return 'Zero';

    const ones = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine'];
    const teens = ['Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'];
    const tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];

    if (number < 10) return ones[number];
    if (number < 20) return teens[number - 10];
    if (number < 100) {
      return '${tens[number ~/ 10]} ${ones[number % 10]}'.trim();
    }

    // Simplified for larger numbers - in a real app, handle more cases
    return '$number';
  }
}
