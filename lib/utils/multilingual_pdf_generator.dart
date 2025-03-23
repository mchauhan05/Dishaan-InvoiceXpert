import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/invoice_models.dart';
import '../models/settings_model.dart';
import '../models/indian_invoice_model.dart';
import '../models/language_model.dart';
import '../utils/currency_utils.dart';
import '../utils/indian_pdf_generator.dart';

/// PDF Generator with multilingual support for invoices
class MultilingualPdfGenerator {
  /// Generate an invoice PDF with language-specific content
  static Future<Uint8List> generateMultilingualInvoice(
    Invoice invoice,
    AppSettings settings,
    GSTInvoiceDetails gstDetails,
    TranslationModel translations, {
    bool addWatermark = false,
    String watermarkText = 'UNPAID',
    PdfColor watermarkColor = const PdfColor(0.9, 0.1, 0.1, 0.3),
    RegionalNumberFormat? numberFormat,
  }) async {
    final pdf = pw.Document();

    // Default to Indian PDF Generator if no translations provided
    if (translations.translations.isEmpty) {
      return IndianPdfGenerator.generateGSTInvoicePdf(
        invoice,
        settings,
        gstDetails,
        addWatermark: addWatermark,
        watermarkText: watermarkText,
        watermarkColor: watermarkColor,
      );
    }

    // Load logo if it exists
    pw.MemoryImage? logoImage;
    try {
      if (settings.companyProfile.logoUrl != null &&
          settings.companyProfile.logoUrl!.isNotEmpty) {
        final logoBytes = await NetworkAssetBundle(Uri.parse(settings.companyProfile.logoUrl!)).load('');
        logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
      }
    } catch (e) {
      print('Error loading logo: $e');
    }

    // Format numbers using regional number format if provided
    final formatter = numberFormat ?? RegionalNumberFormat(
      languageCode: 'en',
      currencySymbol: '₹',
      useLakhCrore: true,
    );

    // Function to translate text
    String tr(String key) {
      return translations.translate(key);
    }

    // Build multilingual PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildMultilingualHeader(logoImage, invoice, settings, tr),
            pw.SizedBox(height: 24),
            _buildMultilingualBillingSection(invoice, tr),
            pw.SizedBox(height: 24),
            _buildMultilingualInvoiceTable(invoice, gstDetails, formatter, tr),
            pw.SizedBox(height: 16),
            _buildMultilingualGSTSummary(invoice, gstDetails, formatter, tr),
            pw.SizedBox(height: 16),
            _buildMultilingualFooter(invoice, settings, gstDetails, formatter, tr),
          ];
        },
        footer: (pw.Context context) {
          if (addWatermark) {
            return pw.Center(
              child: pw.Text(
                watermarkText,
                style: pw.TextStyle(
                  color: watermarkColor,
                  fontSize: 48,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            );
          } else {
            return pw.Container();
          }
        },
      ),
    );

    return pdf.save();
  }

  // Build header with company details
  static pw.Widget _buildMultilingualHeader(
    pw.MemoryImage? logo,
    Invoice invoice,
    AppSettings settings,
    String Function(String) tr,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            // Company details
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (logo != null)
                  pw.Container(
                    height: 72,
                    width: 72,
                    child: pw.Image(logo),
                  ),
                pw.SizedBox(height: 8),
                pw.Text(
                  settings.companyProfile.companyName,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(settings.companyProfile.address.line1),
                if (settings.companyProfile.address.line2 != null)
                  pw.Text(settings.companyProfile.address.line2!),
                pw.Text(
                  '${settings.companyProfile.address.city}, ${settings.companyProfile.address.state} ${settings.companyProfile.address.postalCode}',
                ),
                pw.SizedBox(height: 4),
                if (settings.companyProfile.gstin != null)
                  pw.Text('${tr('gstin')}: ${settings.companyProfile.gstin}'),
              ],
            ),

            // Invoice details
            pw.Container(
              width: 200,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    tr('tax_invoice'),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('${tr('invoice_number')}:'),
                      pw.Text(invoice.invoiceNumber),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('${tr('invoice_date')}:'),
                      pw.Text(DateFormat('dd/MM/yyyy').format(invoice.invoiceDate)),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('${tr('due_date')}:'),
                      pw.Text(DateFormat('dd/MM/yyyy').format(invoice.dueDate)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        pw.Divider(thickness: 1),
      ],
    );
  }

  // Build billing details section
  static pw.Widget _buildMultilingualBillingSection(
    Invoice invoice,
    String Function(String) tr,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Bill from
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                tr('bill_from'),
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(invoice.sellerInfo.name),
              pw.Text(invoice.sellerInfo.address.line1),
              if (invoice.sellerInfo.address.line2 != null)
                pw.Text(invoice.sellerInfo.address.line2!),
              pw.Text(
                '${invoice.sellerInfo.address.city}, ${invoice.sellerInfo.address.state} ${invoice.sellerInfo.address.postalCode}',
              ),
              if (invoice.sellerInfo.gstin != null)
                pw.Text('${tr('gstin')}: ${invoice.sellerInfo.gstin}'),
            ],
          ),
        ),

        // Bill to
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                tr('bill_to'),
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(invoice.customerInfo.name),
              pw.Text(invoice.customerInfo.address.line1),
              if (invoice.customerInfo.address.line2 != null)
                pw.Text(invoice.customerInfo.address.line2!),
              pw.Text(
                '${invoice.customerInfo.address.city}, ${invoice.customerInfo.address.state} ${invoice.customerInfo.address.postalCode}',
              ),
              if (invoice.customerInfo.gstin != null)
                pw.Text('${tr('gstin')}: ${invoice.customerInfo.gstin}'),
            ],
          ),
        ),
      ],
    );
  }

  // Build invoice items table
  static pw.Widget _buildMultilingualInvoiceTable(
    Invoice invoice,
    GSTInvoiceDetails gstDetails,
    RegionalNumberFormat formatter,
    String Function(String) tr,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        // Table header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _centeredTableCell(tr('item'), isHeader: true),
            if (gstDetails.showHsnCode)
              _centeredTableCell(tr('hsn_code'), isHeader: true),
            _centeredTableCell(tr('quantity'), isHeader: true),
            _centeredTableCell(tr('rate'), isHeader: true),
            if (gstDetails.detailedBreakup)
              _centeredTableCell(tr('taxable_amount'), isHeader: true),
            if (gstDetails.detailedBreakup && gstDetails.isIGST)
              _centeredTableCell('IGST (${gstDetails.igstRate}%)', isHeader: true),
            if (gstDetails.detailedBreakup && !gstDetails.isIGST) ...[
              _centeredTableCell('CGST (${gstDetails.cgstRate}%)', isHeader: true),
              _centeredTableCell('SGST (${gstDetails.sgstRate}%)', isHeader: true),
            ],
            _centeredTableCell(tr('amount'), isHeader: true),
          ],
        ),

        // Table rows (invoice items)
        ...invoice.items.map((item) {
          final amt = item.quantity * item.unitPrice;
          final taxAmount = amt * item.taxRate / 100;
          final totalAmount = amt + taxAmount;

          final hsnCode = item.additionalProperties?['hsn_code'] as String? ?? '';

          return pw.TableRow(
            children: [
              _paddedTableCell(item.description),
              if (gstDetails.showHsnCode)
                _centeredTableCell(hsnCode),
              _centeredTableCell('${item.quantity}'),
              _rightAlignedTableCell(formatter.formatCurrency(item.unitPrice)),
              if (gstDetails.detailedBreakup)
                _rightAlignedTableCell(formatter.formatCurrency(amt)),
              if (gstDetails.detailedBreakup && gstDetails.isIGST)
                _rightAlignedTableCell(formatter.formatCurrency(taxAmount)),
              if (gstDetails.detailedBreakup && !gstDetails.isIGST) ...[
                _rightAlignedTableCell(formatter.formatCurrency(taxAmount / 2)),
                _rightAlignedTableCell(formatter.formatCurrency(taxAmount / 2)),
              ],
              _rightAlignedTableCell(formatter.formatCurrency(totalAmount)),
            ],
          );
        }).toList(),
      ],
    );
  }

  // Build GST summary table
  static pw.Widget _buildMultilingualGSTSummary(
    Invoice invoice,
    GSTInvoiceDetails gstDetails,
    RegionalNumberFormat formatter,
    String Function(String) tr,
  ) {
    final subtotal = invoice.items.fold<double>(
      0, (sum, item) => sum + (item.quantity * item.unitPrice));

    final totalTax = invoice.items.fold<double>(
      0, (sum, item) => sum + (item.quantity * item.unitPrice * item.taxRate / 100));

    final total = subtotal + totalTax;

    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Container(
              width: 300,
              child: pw.Table(
                children: [
                  pw.TableRow(
                    children: [
                      _paddedTableCell(tr('subtotal')),
                      _rightAlignedTableCell(formatter.formatCurrency(subtotal)),
                    ],
                  ),
                  if (gstDetails.isIGST)
                    pw.TableRow(
                      children: [
                        _paddedTableCell('IGST (${gstDetails.igstRate}%)'),
                        _rightAlignedTableCell(formatter.formatCurrency(totalTax)),
                      ],
                    )
                  else ...[
                    pw.TableRow(
                      children: [
                        _paddedTableCell('CGST (${gstDetails.cgstRate}%)'),
                        _rightAlignedTableCell(formatter.formatCurrency(totalTax / 2)),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        _paddedTableCell('SGST (${gstDetails.sgstRate}%)'),
                        _rightAlignedTableCell(formatter.formatCurrency(totalTax / 2)),
                      ],
                    ),
                  ],
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _paddedTableCell(tr('total')),
                      _rightAlignedTableCell(formatter.formatCurrency(total)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Build invoice footer
  static pw.Widget _buildMultilingualFooter(
    Invoice invoice,
    AppSettings settings,
    GSTInvoiceDetails gstDetails,
    RegionalNumberFormat formatter,
    String Function(String) tr,
  ) {
    // Calculate total
    final subtotal = invoice.items.fold<double>(
      0, (sum, item) => sum + (item.quantity * item.unitPrice));

    final totalTax = invoice.items.fold<double>(
      0, (sum, item) => sum + (item.quantity * item.unitPrice * item.taxRate / 100));

    final total = subtotal + totalTax;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Amount in words
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('${tr('amount_in_words')}: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Expanded(
                child: pw.Text(CurrencyUtils.numberToWords(total, formatter.languageCode)),
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 16),

        // Bank details if available
        if (settings.bankDetails != null) ...[
          pw.Text(
            tr('bank_details'),
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('${tr('account_name')}: ${settings.bankDetails!.accountName}'),
                    pw.Text('${tr('account_number')}: ${settings.bankDetails!.accountNumber}'),
                    pw.Text('${tr('bank_name')}: ${settings.bankDetails!.bankName}'),
                    pw.Text('${tr('ifsc_code')}: ${settings.bankDetails!.ifscCode}'),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(tr('for_seller'), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 40),
                    pw.Text(tr('authorized_signatory')),
                  ],
                ),
              ),
            ],
          ),
        ],

        pw.SizedBox(height: 16),

        // Terms and conditions
        if (invoice.termsAndConditions != null) ...[
          pw.Text(
            tr('terms_and_conditions'),
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(invoice.termsAndConditions!),
        ],

        pw.SizedBox(height: 16),

        // Notes
        if (invoice.notes != null) ...[
          pw.Text(
            tr('notes'),
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(invoice.notes!),
        ],
      ],
    );
  }

  // Helper for centered table cell
  static pw.Widget _centeredTableCell(
    String text, {
    bool isHeader = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Center(
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontWeight: isHeader ? pw.FontWeight.bold : null,
          ),
        ),
      ),
    );
  }

  // Helper for right-aligned table cell
  static pw.Widget _rightAlignedTableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(text),
      ),
    );
  }

  // Helper for padded table cell
  static pw.Widget _paddedTableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text),
    );
  }
}
