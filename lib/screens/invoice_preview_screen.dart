import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../widgets/header.dart';
import '../widgets/sidebar.dart';
import '../models/invoice_models.dart';
import '../models/settings_model.dart';
import '../models/upi_payment_model.dart'; // Import UPI model
import '../providers/settings_provider.dart';
import '../providers/upi_payment_provider.dart'; // Import UPI provider
import '../utils/pdf_generator.dart';
import '../utils/upi_qr_generator.dart'; // Import UPI QR generator
import '../utils/translation_extension.dart'; // Import translation extension

class InvoicePreviewScreen extends StatefulWidget {
  final Invoice invoice;

  const InvoicePreviewScreen({
    Key? key,
    required this.invoice,
  }) : super(key: key);

  @override
  State<InvoicePreviewScreen> createState() => _InvoicePreviewScreenState();
}

class _InvoicePreviewScreenState extends State<InvoicePreviewScreen> {
  bool _isGeneratingPdf = false;
  String? _pdfFilePath;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final settings = settingsProvider.settings;
    final upiProvider = Provider.of<UpiPaymentProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: Row(
        children: [
          // Sidebar
          Sidebar(currentRoute: '/invoices'),

          // Main content
          Expanded(
            child: Column(
              children: [
                // Header
                const Header(),

                // Main content area with scrolling
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Breadcrumb and title
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Invoices',
                                style: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.chevron_right,
                              size: 14,
                              color: AppColors.textGray,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Preview Invoice #${widget.invoice.invoiceNumber}',
                              style: TextStyle(
                                color: AppColors.textGray,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Title and actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Invoice #${widget.invoice.invoiceNumber}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            Row(
                              children: [
                                // PDF buttons
                                _buildActionButton(
                                  icon: Icons.picture_as_pdf,
                                  label: 'Generate PDF',
                                  onPressed: () => _generatePdf(settings),
                                  isLoading: _isGeneratingPdf,
                                ),
                                const SizedBox(width: 8),
                                _buildActionButton(
                                  icon: Icons.email,
                                  label: 'Email Invoice',
                                  onPressed: _pdfFilePath != null
                                      ? () => _emailInvoice(settings)
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                _buildActionButton(
                                  icon: Icons.print,
                                  label: 'Print Invoice',
                                  onPressed: _pdfFilePath != null
                                      ? () => _printInvoice(settings)
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),

                        if (_errorMessage != null)
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.red.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _errorMessage = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),

                        if (_pdfFilePath != null)
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'PDF generated successfully!',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Saved at: $_pdfFilePath',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.green),
                                  onPressed: () {
                                    setState(() {
                                      _pdfFilePath = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Invoice preview
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Preview header
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                color: AppColors.primaryDark,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.visibility,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'PREVIEW',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(widget.invoice.status).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        widget.invoice.statusText.toUpperCase(),
                                        style: TextStyle(
                                          color: _getStatusColor(widget.invoice.status),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Invoice preview content
                              SizedBox(
                                height: 600,
                                child: PdfGenerator.getInvoicePreview(
                                  widget.invoice,
                                  settings,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Invoice information section
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderGray),
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Invoice Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoItem(
                                      'Invoice Number',
                                      widget.invoice.invoiceNumber,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildInfoItem(
                                      'Status',
                                      widget.invoice.statusText,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoItem(
                                      'Invoice Date',
                                      DateFormat('MMM dd, yyyy').format(widget.invoice.date),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildInfoItem(
                                      'Due Date',
                                      DateFormat('MMM dd, yyyy').format(widget.invoice.dueDate),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoItem(
                                      'Customer',
                                      widget.invoice.customer.name,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildInfoItem(
                                      'Payment Terms',
                                      widget.invoice.paymentTermsText,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoItem(
                                      'Subtotal',
                                      NumberFormat.currency(
                                        symbol: settings.currencySettings.currencySymbol,
                                      ).format(widget.invoice.subtotal),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildInfoItem(
                                      'Total',
                                      NumberFormat.currency(
                                        symbol: settings.currencySettings.currencySymbol,
                                      ).format(widget.invoice.total),
                                      isBold: true,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Payment options section
                        _buildPaymentOptions(upiProvider, settings),

                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptions(UpiPaymentProvider upiProvider, AppSettings settings) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('payment_options'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // UPI Payment option
            if (upiProvider.primaryUpiAccount != null)
              _buildUpiPaymentOption(upiProvider.primaryUpiAccount!)
            else
              _buildNoUpiAccountsMessage(),

            if (settings.bankDetails != null) ...[
              const Divider(height: 32),
              _buildBankTransferOption(settings.bankDetails!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUpiPaymentOption(UPIDetails upiAccount) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // UPI QR Code
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.all(8),
          child: UpiQrGenerator.generateInvoiceUpiQr(
            widget.invoice,
            upiId: upiAccount.upiId,
            payeeName: upiAccount.payeeName,
            merchantCode: upiAccount.merchantCode,
            size: 134,
          ),
        ),

        const SizedBox(width: 24),

        // UPI Payment instructions
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('pay_via_upi'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(context.tr('scan_qr_code_to_pay')),
              const SizedBox(height: 16),
              Text(
                '${context.tr('upi_id')}: ${upiAccount.upiId}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '${context.tr('amount')}: ${context.formatCurrency(widget.invoice.calculateTotal())}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // UPI App buttons
              Text(context.tr('pay_using')),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: UPIApps.popularApps.map((app) {
                  return ElevatedButton.icon(
                    icon: Icon(app.icon, size: 18),
                    label: Text(app.name),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onPressed: () async {
                      final upiUri = upiProvider.generateUpiPaymentLink(
                        widget.invoice,
                        account: upiAccount,
                      );
                      final launched = await upiProvider.launchUpiApp(app, upiUri);
                      if (!launched && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.tr('app_not_found'))),
                        );
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoUpiAccountsMessage() {
    return ListTile(
      leading: const Icon(Icons.info_outline, color: Colors.orange),
      title: Text(context.tr('no_upi_accounts_set_up')),
      subtitle: Text(context.tr('add_upi_account_to_enable_payments')),
      trailing: ElevatedButton(
        child: Text(context.tr('set_up_upi')),
        onPressed: () {
          Navigator.pushNamed(context, '/upi_settings');
        },
      ),
    );
  }

  Widget _buildBankTransferOption(BankDetails bankDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('bank_transfer'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Bank details
        Table(
          columnWidths: const {
            0: FixedColumnWidth(150),
            1: FlexColumnWidth(),
          },
          children: [
            TableRow(
              children: [
                Text('${context.tr('account_name')}:'),
                Text(
                  bankDetails.accountName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            TableRow(
              children: [
                Text('${context.tr('account_number')}:'),
                Text(
                  bankDetails.accountNumber,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            TableRow(
              children: [
                Text('${context.tr('bank_name')}:'),
                Text(
                  bankDetails.bankName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            TableRow(
              children: [
                Text('${context.tr('ifsc_code')}:'),
                Text(
                  bankDetails.ifscCode,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        textStyle: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textGray,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.sent:
        return Colors.blue;
      case InvoiceStatus.viewed:
        return Colors.purple;
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.partiallyPaid:
        return Colors.orange;
      case InvoiceStatus.overdue:
        return Colors.red;
      case InvoiceStatus.void:
        return Colors.blueGrey;
      case InvoiceStatus.deleted:
        return Colors.black45;
      default:
        return Colors.grey;
    }
  }

  Future<void> _generatePdf(AppSettings settings) async {
    setState(() {
      _isGeneratingPdf = true;
      _errorMessage = null;
    });

    try {
      final filePath = await PdfGenerator.saveInvoicePdf(widget.invoice, settings);
      setState(() {
        _pdfFilePath = filePath;
        _isGeneratingPdf = false;
      });

      // Show confirmation dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF generated and saved to: $filePath'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to generate PDF: ${e.toString()}';
        _isGeneratingPdf = false;
      });
    }
  }

  Future<void> _emailInvoice(AppSettings settings) async {
    try {
      final success = await PdfGenerator.emailInvoice(
        widget.invoice,
        settings,
        additionalMessage: 'Please review the attached invoice and process payment at your earliest convenience.',
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email client opened successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            _errorMessage = 'Failed to open email client';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to email invoice: ${e.toString()}';
      });
    }
  }

  Future<void> _printInvoice(AppSettings settings) async {
    try {
      final success = await PdfGenerator.printInvoice(widget.invoice, settings);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invoice sent to printer successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            _errorMessage = 'Failed to print invoice';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to print invoice: ${e.toString()}';
      });
    }
  }
}
