import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../models/invoice_models.dart';
import '../models/settings_model.dart';

/// A utility class to generate PDF invoices with advanced customization options
class PdfGenerator {
  /// Generate a PDF invoice from the provided invoice data
  ///
  /// Returns a future that resolves to a Uint8List representing the PDF
  static Future<Uint8List> generateInvoicePdf(
    Invoice invoice,
    AppSettings settings, {
    bool addWatermark = false,
    String watermarkText = 'UNPAID',
    PdfColor watermarkColor = const PdfColor(0.9, 0.1, 0.1, 0.3),
  }) async {
    final pdf = pw.Document();

    // Load logo if it exists
    pw.MemoryImage? logoImage;
    try {
      var logoUrl = settings.companyProfile.logoUrl;
      if (logoUrl != null && logoUrl.isNotEmpty) {
        final logoBytes =
            await NetworkAssetBundle(Uri.parse(logoUrl)).load(logoUrl);
        logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
      }
    } catch (e) {
      print('Error loading logo: $e');
    }

    // Define font styles
    final titleStyle = pw.TextStyle(
      fontSize: 24,
      fontWeight: pw.FontWeight.bold,
    );

    final headerStyle = pw.TextStyle(
      fontSize: 18,
      fontWeight: pw.FontWeight.bold,
    );

    final subheaderStyle = pw.TextStyle(
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
    );

    final normalStyle = pw.TextStyle(
      fontSize: 12,
    );

    final smallStyle = pw.TextStyle(
      fontSize: 10,
    );

    // Format currency
    final currencyFormatter = NumberFormat.currency(
      symbol: settings.currencySettings.currencySymbol,
      decimalDigits: settings.currencySettings.decimalPlaces,
    );

    // Format date
    final dateFormatter = DateFormat(settings.dateTimeSettings.dateFormat);

    // Add the invoice page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header with company info and invoice details
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Company info
                      pw.Expanded(
                        flex: 2,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            if (logoImage != null)
                              pw.Container(
                                height: 60,
                                width: 160,
                                margin: const pw.EdgeInsets.only(bottom: 8),
                                child:
                                    pw.Image(logoImage, fit: pw.BoxFit.contain),
                              ),
                            pw.Text(
                              settings.companyProfile.companyName,
                              style: titleStyle,
                            ),
                            pw.SizedBox(height: 8),
                            pw.Text(settings.companyProfile.address,
                                style: normalStyle),
                            pw.Text(
                              '${settings.companyProfile.city}, ${settings.companyProfile.state} ${settings.companyProfile.zipCode}',
                              style: normalStyle,
                            ),
                            pw.Text(settings.companyProfile.country,
                                style: normalStyle),
                            pw.SizedBox(height: 8),
                            pw.Text('Phone: ${settings.companyProfile.phone}',
                                style: normalStyle),
                            pw.Text('Email: ${settings.companyProfile.email}',
                                style: normalStyle),
                            if (settings.companyProfile.website.isNotEmpty)
                              pw.Text('Web: ${settings.companyProfile.website}',
                                  style: normalStyle),
                          ],
                        ),
                      ),

                      // Invoice info
                      pw.Expanded(
                        flex: 1,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Container(
                              padding: const pw.EdgeInsets.all(8),
                              color: PdfColors.grey200,
                              child: pw.Text(
                                'INVOICE',
                                style: pw.TextStyle(
                                  fontSize: 20,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blue900,
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.end,
                              children: [
                                pw.Text('Invoice #:', style: normalStyle),
                                pw.SizedBox(width: 8),
                                pw.Text(invoice.invoiceNumber,
                                    style: subheaderStyle),
                              ],
                            ),
                            pw.SizedBox(height: 4),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.end,
                              children: [
                                pw.Text('Date:', style: normalStyle),
                                pw.SizedBox(width: 8),
                                pw.Text(dateFormatter.format(invoice.date),
                                    style: normalStyle),
                              ],
                            ),
                            pw.SizedBox(height: 4),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.end,
                              children: [
                                pw.Text('Due Date:', style: normalStyle),
                                pw.SizedBox(width: 8),
                                pw.Text(dateFormatter.format(invoice.dueDate),
                                    style: normalStyle),
                              ],
                            ),
                            pw.SizedBox(height: 16),
                            if (invoice.status.toLowerCase() != 'paid')
                              pw.Container(
                                padding: const pw.EdgeInsets.all(6),
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.red100,
                                  border: pw.Border.all(color: PdfColors.red),
                                  borderRadius: const pw.BorderRadius.all(
                                      pw.Radius.circular(4)),
                                ),
                                child: pw.Text(
                                  invoice.status.toUpperCase(),
                                  style: pw.TextStyle(
                                    color: PdfColors.red,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              )
                            else
                              pw.Container(
                                padding: const pw.EdgeInsets.all(6),
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.green100,
                                  border: pw.Border.all(color: PdfColors.green),
                                  borderRadius: const pw.BorderRadius.all(
                                      pw.Radius.circular(4)),
                                ),
                                child: pw.Text(
                                  'PAID',
                                  style: pw.TextStyle(
                                    color: PdfColors.green,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 32),

                  // Bill to section
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    color: PdfColors.grey200,
                    child: pw.Text(
                      'BILL TO',
                      style: subheaderStyle,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(invoice.customer.name, style: normalStyle),
                  if (invoice.customer.company.isNotEmpty)
                    pw.Text(invoice.customer.company, style: normalStyle),
                  pw.Text(invoice.customer.address, style: normalStyle),
                  pw.Text(
                    '${invoice.customer.city}, ${invoice.customer.state} ${invoice.customer.zipCode}',
                    style: normalStyle,
                  ),
                  pw.Text(invoice.customer.country, style: normalStyle),
                  pw.SizedBox(height: 4),
                  pw.Text('Phone: ${invoice.customer.phone}',
                      style: normalStyle),
                  pw.Text('Email: ${invoice.customer.email}',
                      style: normalStyle),

                  pw.SizedBox(height: 24),

                  // Invoice items table
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey400),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(5), // Description
                      1: const pw.FlexColumnWidth(1), // Quantity
                      2: const pw.FlexColumnWidth(2), // Unit Price
                      3: const pw.FlexColumnWidth(2), // Amount
                    },
                    children: [
                      // Table header
                      pw.TableRow(
                        decoration:
                            const pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Description',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Qty',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Unit Price',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Amount',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      // Table rows with invoice items
                      ...invoice.items.map((item) => pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(item.description,
                                        style: normalStyle),
                                    if (item.additionalInfo.isNotEmpty)
                                      pw.Text(
                                        item.additionalInfo,
                                        style: pw.TextStyle(
                                          fontSize: 10,
                                          color: PdfColors.grey700,
                                          fontStyle: pw.FontStyle.italic,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  item.quantity.toString(),
                                  style: normalStyle,
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  currencyFormatter.format(item.unitPrice),
                                  style: normalStyle,
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  currencyFormatter
                                      .format(item.quantity * item.unitPrice),
                                  style: normalStyle,
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),

                  pw.SizedBox(height: 16),

                  // Totals section
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Row(
                            children: [
                              pw.Container(
                                width: 120,
                                child: pw.Text('Subtotal:', style: normalStyle),
                              ),
                              pw.Container(
                                width: 100,
                                child: pw.Text(
                                  currencyFormatter.format(invoice.subtotal),
                                  style: normalStyle,
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 4),
                          if (invoice.discountAmount > 0)
                            pw.Row(
                              children: [
                                pw.Container(
                                  width: 120,
                                  child: pw.Text(
                                    'Discount (${invoice.discountPercent}%):',
                                    style: normalStyle,
                                  ),
                                ),
                                pw.Container(
                                  width: 100,
                                  child: pw.Text(
                                    '- ${currencyFormatter.format(invoice.discountAmount)}',
                                    style: normalStyle,
                                    textAlign: pw.TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          if (invoice.taxAmount > 0)
                            pw.Row(
                              children: [
                                pw.Container(
                                  width: 120,
                                  child: pw.Text(
                                    'Tax (${invoice.taxRate}%):',
                                    style: normalStyle,
                                  ),
                                ),
                                pw.Container(
                                  width: 100,
                                  child: pw.Text(
                                    currencyFormatter.format(invoice.taxAmount),
                                    style: normalStyle,
                                    textAlign: pw.TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          pw.SizedBox(height: 8),
                          pw.Divider(color: PdfColors.grey),
                          pw.SizedBox(height: 8),
                          pw.Row(
                            children: [
                              pw.Container(
                                width: 120,
                                child: pw.Text(
                                  'Total:',
                                  style: pw.TextStyle(
                                    fontSize: 14,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                              pw.Container(
                                width: 100,
                                child: pw.Text(
                                  currencyFormatter.format(invoice.total),
                                  style: pw.TextStyle(
                                    fontSize: 14,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          if (invoice.amountPaid > 0)
                            pw.Row(
                              children: [
                                pw.Container(
                                  width: 120,
                                  child: pw.Text(
                                    'Amount Paid:',
                                    style: normalStyle,
                                  ),
                                ),
                                pw.Container(
                                  width: 100,
                                  child: pw.Text(
                                    currencyFormatter
                                        .format(invoice.amountPaid),
                                    style: normalStyle,
                                    textAlign: pw.TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          if (invoice.amountPaid > 0)
                            pw.Row(
                              children: [
                                pw.Container(
                                  width: 120,
                                  child: pw.Text(
                                    'Balance Due:',
                                    style: pw.TextStyle(
                                      fontSize: 14,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.red,
                                    ),
                                  ),
                                ),
                                pw.Container(
                                  width: 100,
                                  child: pw.Text(
                                    currencyFormatter.format(
                                        invoice.total - invoice.amountPaid),
                                    style: pw.TextStyle(
                                      fontSize: 14,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.red,
                                    ),
                                    textAlign: pw.TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 32),

                  // Notes and terms
                  if (invoice.notes.isNotEmpty)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Notes:',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey300),
                            borderRadius: const pw.BorderRadius.all(
                                pw.Radius.circular(4)),
                          ),
                          child: pw.Text(invoice.notes, style: normalStyle),
                        ),
                        pw.SizedBox(height: 16),
                      ],
                    ),

                  if (settings.invoiceSettings.termsAndConditions.isNotEmpty)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Terms & Conditions:',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          settings.invoiceSettings.termsAndConditions,
                          style: smallStyle,
                        ),
                      ],
                    ),

                  pw.Spacer(),

                  // Footer
                  pw.Divider(color: PdfColors.grey),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Invoice generated by Dishaan Invoice Xpert',
                        style: smallStyle,
                      ),
                      pw.Text(
                        'Page 1 of 1',
                        style: smallStyle,
                      ),
                    ],
                  ),
                ],
              ),

              // Watermark if needed
              if (addWatermark)
                pw.Positioned.fill(
                  child: pw.Center(
                    child: pw.Transform.rotate(
                      angle: -0.5,
                      child: pw.Text(
                        watermarkText,
                        style: pw.TextStyle(
                          color: watermarkColor,
                          fontSize: 100,
                          fontWeight: pw.FontWeight.bold,
                        ),
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

  /// Save PDF to a temporary file and return the path
  static Future<String> savePdfToTemp(
      Uint8List pdfBytes, String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(pdfBytes);
    return file.path;
  }

  /// Open the PDF file
  static Future<void> openPdfFile(String filePath) async {
    final url = 'file://$filePath';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not open PDF file at $filePath';
    }
  }

  /// Share PDF via email
  static Future<void> sharePdfViaEmail({
    required String filePath,
    required String recipientEmail,
    required String subject,
    required String body,
  }) async {
    final uriString =
        'mailto:$recipientEmail?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}&attachment=$filePath';

    try {
      if (await canLaunchUrlString(uriString)) {
        await launchUrlString(uriString);
      } else {
        throw 'Could not launch email client';
      }
    } catch (e) {
      print('Error sharing PDF via email: $e');
      throw 'Failed to share PDF via email: $e';
    }
  }
}
