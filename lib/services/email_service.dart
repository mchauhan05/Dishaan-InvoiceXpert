import 'dart:async';

import 'package:url_launcher/url_launcher_string.dart';

import '../models/customer_model.dart';
import '../models/invoice_models.dart';
import '../models/settings_model.dart';
import '../utils/pdf_generator.dart';

/// A service class for handling email operations
/// This is a simple implementation using URL launcher
/// In a real-world app, this would use a proper email API service
class EmailService {
  // Email templates
  static const Map<String, String> _templates = {
    'invoice_new': '''
Dear {customer_name},

Please find attached your invoice {invoice_number} from {company_name} for {invoice_amount}.

This invoice is due on {due_date}.

{notes}

You can view the details of your invoice in the attached PDF.

Thank you for your business.

Regards,
{sender_name}
{company_name}
{company_email}
{company_phone}
''',

    'invoice_reminder': '''
Dear {customer_name},

This is a friendly reminder that invoice {invoice_number} for {invoice_amount} is due on {due_date}.

If you have already made the payment, please disregard this reminder.

If you have any questions about this invoice, please don't hesitate to contact us.

Thank you for your business.

Regards,
{sender_name}
{company_name}
{company_email}
{company_phone}
''',

    'invoice_overdue': '''
Dear {customer_name},

We would like to remind you that invoice {invoice_number} for {invoice_amount} is now overdue. The payment was due on {due_date}.

If you have already made the payment, please disregard this reminder.

If you have any questions or concerns about this invoice, please contact us as soon as possible.

Thank you for your attention to this matter.

Regards,
{sender_name}
{company_name}
{company_email}
{company_phone}
''',

    'payment_received': '''
Dear {customer_name},

Thank you for your payment of {payment_amount} for invoice {invoice_number}.

Your payment has been received and recorded.

We appreciate your business and look forward to working with you again.

Regards,
{sender_name}
{company_name}
{company_email}
{company_phone}
''',

    'welcome': '''
Dear {customer_name},

Welcome to {company_name}!

Thank you for choosing to work with us. We're excited to have you as a customer.

If you have any questions or need assistance, please don't hesitate to contact us.

Regards,
{sender_name}
{company_name}
{company_email}
{company_phone}
''',
  };

  /// Send a new invoice to a customer
  static Future<bool> sendInvoice({
    required Invoice invoice,
    required Customer customer,
    required AppSettings settings,
    String? additionalNotes,
    bool includeAttachment = true,
  }) async {
    try {
      // Generate PDF invoice
      final pdfBytes = await PdfGenerator.generateInvoicePdf(
        invoice,
        settings,
        addWatermark: invoice.status.toString().toLowerCase() != 'paid',
      );

      // Save PDF to temporary file
      final filePath = await PdfGenerator.savePdfToTemp(
        pdfBytes,
        'invoice_${invoice.invoiceNumber.replaceAll('/', '_')}.pdf',
      );

      // Prepare email content
      final String emailTemplate = _templates['invoice_new']!;
      final String subject = 'Invoice ${invoice.invoiceNumber} from ${settings.companyProfile.companyName}';
      final String body = _generateEmailContent(
        template: emailTemplate,
        invoice: invoice,
        customer: customer,
        settings: settings,
        additionalNotes: additionalNotes,
      );

      // Send email
      await PdfGenerator.sharePdfViaEmail(
        filePath: filePath,
        recipientEmail: customer.email,
        subject: subject,
        body: body,
      );

      return true;
    } catch (e) {
      print('Error sending invoice email: $e');
      return false;
    }
  }

  /// Send a payment reminder to a customer
  static Future<bool> sendPaymentReminder({
    required Invoice invoice,
    required Customer customer,
    required AppSettings settings,
    bool isOverdue = false,
  }) async {
    try {
      // Determine which template to use
      final String templateKey = isOverdue ? 'invoice_overdue' : 'invoice_reminder';
      final String emailTemplate = _templates[templateKey]!;

      // Prepare email content
      final String subject = isOverdue
          ? 'OVERDUE: Invoice ${invoice.invoiceNumber} from ${settings.companyProfile.companyName}'
          : 'Reminder: Invoice ${invoice.invoiceNumber} from ${settings.companyProfile.companyName}';
      final String body = _generateEmailContent(
        template: emailTemplate,
        invoice: invoice,
        customer: customer,
        settings: settings,
      );

      // Generate PDF invoice
      final pdfBytes = await PdfGenerator.generateInvoicePdf(
        invoice,
        settings,
        addWatermark: true,
        watermarkText: isOverdue ? 'OVERDUE' : 'REMINDER',
      );

      // Save PDF to temporary file
      final filePath = await PdfGenerator.savePdfToTemp(
        pdfBytes,
        'invoice_${invoice.invoiceNumber.replaceAll('/', '_')}.pdf',
      );

      // Send email
      await PdfGenerator.sharePdfViaEmail(
        filePath: filePath,
        recipientEmail: customer.email,
        subject: subject,
        body: body,
      );

      return true;
    } catch (e) {
      print('Error sending payment reminder email: $e');
      return false;
    }
  }

  /// Send a payment confirmation to a customer
  static Future<bool> sendPaymentConfirmation({
    required Invoice invoice,
    required Customer customer,
    required AppSettings settings,
    required double paymentAmount,
  }) async {
    try {
      // Prepare email content
      final String emailTemplate = _templates['payment_received']!;
      final String subject = 'Payment Received for Invoice ${invoice.invoiceNumber}';
      final String body = _generateEmailContent(
        template: emailTemplate,
        invoice: invoice,
        customer: customer,
        settings: settings,
        paymentAmount: paymentAmount,
      );

      // Launch email client
      final emailUri = _buildEmailUri(
        recipient: customer.email,
        subject: subject,
        body: body,
      );

      if (await canLaunchUrlString(emailUri)) {
        await launchUrlString(emailUri);
        return true;
      } else {
        throw 'Could not launch email client';
      }
    } catch (e) {
      print('Error sending payment confirmation email: $e');
      return false;
    }
  }

  /// Send a welcome email to a new customer
  static Future<bool> sendWelcomeEmail({
    required Customer customer,
    required AppSettings settings,
  }) async {
    try {
      // Prepare email content
      final String emailTemplate = _templates['welcome']!;
      final String subject = 'Welcome to ${settings.companyProfile.companyName}';
      final String body = _generateEmailContent(
        template: emailTemplate,
        customer: customer,
        settings: settings,
      );

      // Launch email client
      final emailUri = _buildEmailUri(
        recipient: customer.email,
        subject: subject,
        body: body,
      );

      if (await canLaunchUrlString(emailUri)) {
        await launchUrlString(emailUri);
        return true;
      } else {
        throw 'Could not launch email client';
      }
    } catch (e) {
      print('Error sending welcome email: $e');
      return false;
    }
  }

  /// Send a custom email to a customer
  static Future<bool> sendCustomEmail({
    required String recipient,
    required String subject,
    required String body,
    String? ccEmail,
    String? bccEmail,
  }) async {
    try {
      // Launch email client
      final emailUri = _buildEmailUri(
        recipient: recipient,
        subject: subject,
        body: body,
        cc: ccEmail,
        bcc: bccEmail,
      );

      if (await canLaunchUrlString(emailUri)) {
        await launchUrlString(emailUri);
        return true;
      } else {
        throw 'Could not launch email client';
      }
    } catch (e) {
      print('Error sending custom email: $e');
      return false;
    }
  }

  /// Generate email content using template and provided data
  static String _generateEmailContent({
    required String template,
    Invoice? invoice,
    required Customer customer,
    required AppSettings settings,
    String? additionalNotes,
    double? paymentAmount,
  }) {
    // Get the template
    String content = template;

    // Replace customer placeholders
    content = content.replaceAll('{customer_name}', customer.displayName);

    // Replace company placeholders
    content = content.replaceAll('{company_name}', settings.companyProfile.companyName);
    content = content.replaceAll('{company_email}', settings.companyProfile.email);
    content = content.replaceAll('{company_phone}', settings.companyProfile.phone);
    content = content.replaceAll('{sender_name}', settings.emailSettings.senderName);

    // Replace invoice placeholders if invoice is provided
    if (invoice != null) {
      content = content.replaceAll('{invoice_number}', invoice.invoiceNumber);
      content = content.replaceAll('{invoice_amount}', '\$${invoice.total.toStringAsFixed(2)}');
      content = content.replaceAll('{due_date}', _formatDate(invoice.dueDate));

      // Add notes if provided
      if (additionalNotes != null && additionalNotes.isNotEmpty) {
        content = content.replaceAll('{notes}', additionalNotes);
      } else if (invoice.notes.isNotEmpty) {
        content = content.replaceAll('{notes}', invoice.notes);
      } else {
        content = content.replaceAll('{notes}', '');
      }
    }

    // Replace payment placeholders if payment is provided
    if (paymentAmount != null) {
      content = content.replaceAll('{payment_amount}', '\$${paymentAmount.toStringAsFixed(2)}');
    }

    return content;
  }

  /// Build mailto URI for email
  static String _buildEmailUri({
    required String recipient,
    required String subject,
    required String body,
    String? cc,
    String? bcc,
  }) {
    String uri = 'mailto:$recipient?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';

    if (cc != null && cc.isNotEmpty) {
      uri += '&cc=${Uri.encodeComponent(cc)}';
    }

    if (bcc != null && bcc.isNotEmpty) {
      uri += '&bcc=${Uri.encodeComponent(bcc)}';
    }

    return uri;
  }

  /// Format date for display in emails
  static String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$month/$day/$year';
  }

  /// Check if email service is available
  static Future<bool> isEmailServiceAvailable() async {
    const testMailto = 'mailto:test@example.com?subject=Test&body=Test';
    return await canLaunchUrlString(testMailto);
  }
}
