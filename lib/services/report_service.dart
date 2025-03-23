import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/customer_model.dart';
import '../models/invoice_models.dart';
import '../models/product_model.dart';
import '../models/report_model.dart';
import '../models/settings_model.dart';
import '../utils/pdf_generator.dart';
import 'database_service.dart';

/// A service class for generating and exporting reports
class ReportService {
  /// Generate a sales report based on the given configuration
  static Future<Report> generateSalesReport({
    required ReportConfig config,
    required List<Invoice> invoices,
    List<Customer>? customers,
  }) async {
    final dateRange = config.getDateRange();
    final now = DateTime.now();

    // Filter invoices by date range
    final filteredInvoices = invoices.where((invoice) {
      return invoice.date.isAfter(dateRange.start) &&
          invoice.date.isBefore(dateRange.end.add(const Duration(days: 1)));
    }).toList();

    // Generate report ID
    final id = 'sales_${now.millisecondsSinceEpoch}';

    // Prepare title
    final title = 'Sales Report - ${config.getPeriodName()}';

    // Group data based on configuration
    List<ReportDataSeries> series = [];

    if (config.groupBy.contains('month')) {
      // Group by month
      final Map<String, double> monthlySales = {};

      for (final invoice in filteredInvoices) {
        final month = DateFormat('MMM yyyy').format(invoice.date);
        monthlySales[month] = (monthlySales[month] ?? 0) + invoice.total;
      }

      // Convert to data points
      final dataPoints = monthlySales.entries.map((entry) {
        return ReportDataPoint(
          label: entry.key,
          value: entry.value,
          metadata: {'month': entry.key},
        );
      }).toList();

      // Sort by date
      dataPoints.sort((a, b) {
        // Extract month and year
        final aMonth = a.label.split(' ')[0];
        final aYear = int.parse(a.label.split(' ')[1]);
        final bMonth = b.label.split(' ')[0];
        final bYear = int.parse(b.label.split(' ')[1]);

        // Compare year first
        if (aYear != bYear) {
          return aYear.compareTo(bYear);
        }

        // Then compare month
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
        return months.indexOf(aMonth).compareTo(months.indexOf(bMonth));
      });

      series.add(ReportDataSeries(
        name: 'Monthly Sales',
        data: dataPoints,
        color: Colors.blue,
      ));
    }

    if (config.groupBy.contains('status')) {
      // Group by invoice status
      final Map<String, double> statusSales = {};

      for (final invoice in filteredInvoices) {
        final status = invoice.status;
        statusSales[status] = (statusSales[status] ?? 0) + invoice.total;
      }

      // Convert to data points
      final dataPoints = statusSales.entries.map((entry) {
        return ReportDataPoint(
          label: entry.key,
          value: entry.value,
          metadata: {'status': entry.key},
          // Assign color based on status
          color: _getStatusColor(entry.key),
        );
      }).toList();

      series.add(ReportDataSeries(
        name: 'Sales by Status',
        data: dataPoints,
      ));
    }

    if (config.groupBy.contains('customer')) {
      // Group by customer
      final Map<String, double> customerSales = {};
      final Map<String, String> customerNames = {};

      for (final invoice in filteredInvoices) {
        final customerId = invoice.customer.id;
        final customerName = invoice.customer.name;
        customerSales[customerId] =
            (customerSales[customerId] ?? 0) + invoice.total;
        customerNames[customerId] = customerName;
      }

      // Convert to data points
      final dataPoints = customerSales.entries.map((entry) {
        return ReportDataPoint(
          label: customerNames[entry.key] ?? 'Unknown',
          value: entry.value,
          metadata: {
            'customerId': entry.key,
            'customerName': customerNames[entry.key]
          },
        );
      }).toList();

      // Sort by value (descending)
      dataPoints.sort((a, b) => b.value.compareTo(a.value));

      // Take top 10
      final topCustomers = dataPoints.take(10).toList();

      series.add(ReportDataSeries(
        name: 'Top Customers',
        data: topCustomers,
        color: Colors.green,
      ));
    }

    // Calculate summary
    final totalSales =
        filteredInvoices.fold(0.0, (sum, invoice) => sum + invoice.total);
    final averageSale =
        filteredInvoices.isEmpty ? 0.0 : totalSales / filteredInvoices.length;
    final paidInvoices = filteredInvoices
        .where((invoice) => invoice.status.toLowerCase() == 'paid')
        .toList();
    final paidAmount =
        paidInvoices.fold(0.0, (sum, invoice) => sum + invoice.total);
    final unpaidAmount = totalSales - paidAmount;

    final summary = {
      'totalSales': totalSales,
      'invoiceCount': filteredInvoices.length,
      'averageSale': averageSale,
      'paidAmount': paidAmount,
      'unpaidAmount': unpaidAmount,
      'paidPercentage':
          filteredInvoices.isEmpty ? 0.0 : (paidAmount / totalSales) * 100,
    };

    // Create and return the report
    return Report(
      id: id,
      title: title,
      config: config,
      series: series,
      generatedAt: now,
      summary: summary,
    );
  }

  /// Generate a customer insights report
  static Future<Report> generateCustomerInsightsReport({
    required ReportConfig config,
    required List<Customer> customers,
    required List<Invoice> invoices,
  }) async {
    final dateRange = config.getDateRange();
    final now = DateTime.now();

    // Generate report ID
    final id = 'customer_insights_${now.millisecondsSinceEpoch}';

    // Prepare title
    final title = 'Customer Insights - ${config.getPeriodName()}';

    // Filter invoices by date range
    final filteredInvoices = invoices.where((invoice) {
      return invoice.date.isAfter(dateRange.start) &&
          invoice.date.isBefore(dateRange.end.add(const Duration(days: 1)));
    }).toList();

    // Calculate customer insights
    final List<CustomerInsights> insights = [];
    final Map<String, List<Invoice>> customerInvoices = {};

    // Group invoices by customer
    for (final invoice in filteredInvoices) {
      final customerId = invoice.customer.id;
      customerInvoices[customerId] = customerInvoices[customerId] ?? [];
      customerInvoices[customerId]!.add(invoice);
    }

    // Calculate insights for each customer
    for (final customer in customers) {
      final customerInvoiceList = customerInvoices[customer.id] ?? [];

      if (customerInvoiceList.isNotEmpty) {
        // Sort invoices by date
        customerInvoiceList.sort((a, b) => a.date.compareTo(b.date));

        final firstPurchase = customerInvoiceList.first.date;
        final lastPurchase = customerInvoiceList.last.date;
        final totalSpent = customerInvoiceList.fold(
            0.0, (sum, invoice) => sum + invoice.total);
        final averageValue = totalSpent / customerInvoiceList.length;
        final daysSinceLastPurchase = now.difference(lastPurchase).inDays;

        // Calculate most purchased category (simplified)
        final Map<String, double> categoryAmounts = {};
        for (final invoice in customerInvoiceList) {
          for (final item in invoice.items) {
            final category = item.category ?? 'Uncategorized';
            categoryAmounts[category] = (categoryAmounts[category] ?? 0) +
                (item.quantity * item.unitPrice);
          }
        }

        String? mostPurchasedCategory;
        double? mostPurchasedAmount = 0;
        categoryAmounts.forEach((category, amount) {
          if (amount > (mostPurchasedAmount ?? 0)) {
            mostPurchasedCategory = category;
            mostPurchasedAmount = amount;
          }
        });

        final mostPurchasedPercentage =
            totalSpent > 0 && mostPurchasedAmount != null
                ? (mostPurchasedAmount! / totalSpent) * 100
                : null;

        // Determine customer segment (simple logic)
        String segment;
        if (totalSpent > 5000) {
          segment = 'VIP';
        } else if (totalSpent > 1000) {
          segment = 'Regular';
        } else if (daysSinceLastPurchase < 90) {
          segment = 'Active';
        } else {
          segment = 'Inactive';
        }

        insights.add(CustomerInsights(
          customerId: customer.id,
          customerName: customer.displayName,
          totalSpent: totalSpent,
          invoiceCount: customerInvoiceList.length,
          averageInvoiceValue: averageValue,
          firstPurchaseDate: firstPurchase,
          lastPurchaseDate: lastPurchase,
          lifetimeValue: totalSpent,
          // Simplified LTV
          daysSinceLastPurchase: daysSinceLastPurchase,
          mostPurchasedCategory: mostPurchasedCategory,
          mostPurchasedCategoryPercentage: mostPurchasedPercentage,
          segment: segment,
        ));
      }
    }

    // Sort insights by total spent (descending)
    insights.sort((a, b) => b.totalSpent.compareTo(a.totalSpent));

    // Create data series for the report
    List<ReportDataSeries> series = [];

    // Top customers by spending
    final topCustomerPoints = insights.take(10).map((insight) {
      return ReportDataPoint(
        label: insight.customerName,
        value: insight.totalSpent,
        metadata: {
          'customerId': insight.customerId,
          'segment': insight.segment
        },
      );
    }).toList();

    series.add(ReportDataSeries(
      name: 'Top Customers by Spending',
      data: topCustomerPoints,
      color: Colors.purple,
    ));

    // Customers by segment
    final Map<String, double> segmentTotals = {};
    final Map<String, int> segmentCounts = {};

    for (final insight in insights) {
      segmentTotals[insight.segment] =
          (segmentTotals[insight.segment] ?? 0) + insight.totalSpent;
      segmentCounts[insight.segment] =
          (segmentCounts[insight.segment] ?? 0) + 1;
    }

    final segmentPoints = segmentTotals.entries.map((entry) {
      return ReportDataPoint(
        label: entry.key,
        value: entry.value,
        metadata: {'count': segmentCounts[entry.key], 'segment': entry.key},
      );
    }).toList();

    series.add(ReportDataSeries(
      name: 'Sales by Customer Segment',
      data: segmentPoints,
      color: Colors.orange,
    ));

    // Calculate summary
    final totalCustomers = insights.length;
    final totalRevenue =
        insights.fold(0.0, (sum, insight) => sum + insight.totalSpent);
    final averageRevenue =
        totalCustomers > 0 ? totalRevenue / totalCustomers : 0;

    final summary = {
      'totalCustomers': totalCustomers,
      'activeCustomers': insights
          .where((insight) =>
              insight.segment == 'Active' ||
              insight.segment == 'VIP' ||
              insight.segment == 'Regular')
          .length,
      'inactiveCustomers':
          insights.where((insight) => insight.segment == 'Inactive').length,
      'totalRevenue': totalRevenue,
      'averageRevenuePerCustomer': averageRevenue,
      'topCustomer': insights.isNotEmpty ? insights.first.customerName : 'None',
      'topCustomerSpent': insights.isNotEmpty ? insights.first.totalSpent : 0,
    };

    // Store customer insights in metadata for detailed viewing
    final metadata = {
      'insights': insights.map((insight) => insight.toJson()).toList(),
    };

    // Create and return the report
    return Report(
      id: id,
      title: title,
      config: config,
      series: series,
      generatedAt: now,
      summary: summary,
      metadata: metadata,
    );
  }

  /// Export report to PDF
  static Future<Uint8List> exportReportToPdf(
      Report report, AppSettings settings) async {
    final pdf = pw.Document();
    final titleStyle =
        pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold);
    final headerStyle =
        pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold);
    final subheaderStyle =
        pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold);
    final bodyStyle = pw.TextStyle(fontSize: 10);
    final smallStyle = pw.TextStyle(fontSize: 8);

    // Currency formatting
    final currencyFormat = NumberFormat.currency(
      symbol: settings.currencySettings.currencySymbol,
      decimalDigits: settings.currencySettings.decimalPlaces,
    );

    // Date formatting
    final dateFormat = DateFormat('MMM dd, yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(settings.companyProfile.companyName,
                      style: headerStyle),
                  pw.Text('Generated: ${dateFormat.format(report.generatedAt)}',
                      style: bodyStyle),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Divider(),
              pw.SizedBox(height: 5),
              pw.Text(report.title, style: titleStyle),
              pw.SizedBox(height: 5),
              pw.Text('Period: ${report.config.getPeriodName()}',
                  style: bodyStyle),
              pw.SizedBox(height: 10),
            ],
          );
        },
        footer: (context) {
          return pw.Column(
            children: [
              pw.Divider(),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Dishaan Invoice Xpert', style: smallStyle),
                  pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
                      style: smallStyle),
                ],
              ),
            ],
          );
        },
        build: (pw.Context context) {
          final List<pw.Widget> widgets = [];

          // Add summary section
          widgets.add(
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Summary', style: subheaderStyle),
                  pw.SizedBox(height: 10),
                  ..._buildSummaryWidgets(report, currencyFormat),
                ],
              ),
            ),
          );

          widgets.add(pw.SizedBox(height: 20));

          // Add charts for each series (simplistic representation)
          for (final series in report.series) {
            widgets.add(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(series.name, style: subheaderStyle),
                  pw.SizedBox(height: 10),
                  _buildChartWidget(series, report.config.chartType),
                  pw.SizedBox(height: 20),
                ],
              ),
            );
          }

          return widgets;
        },
      ),
    );

    return pdf.save();
  }

  /// Export report to CSV
  static Future<String> exportReportToCsv(Report report) async {
    final List<List<dynamic>> rows = [];

    // Add header row
    final List<String> header = ['Series', 'Label', 'Value'];
    if (report.config.showComparison) {
      header.addAll(['Comparison Value', 'Change (%)']);
    }
    rows.add(header);

    // Add data rows
    for (final series in report.series) {
      for (final dataPoint in series.data) {
        final List<dynamic> row = [
          series.name,
          dataPoint.label,
          dataPoint.value,
        ];

        if (report.config.showComparison) {
          row.addAll([
            dataPoint.comparisonValue,
            dataPoint.percentageChange,
          ]);
        }

        rows.add(row);
      }
    }

    // Convert to CSV
    return const ListToCsvConverter().convert(rows);
  }

  /// Save report to temporary file
  static Future<String> saveReportToTempFile(
      Report report, String format) async {
    final tempDir = await getTemporaryDirectory();
    final fileName =
        '${report.title.replaceAll(' ', '_').toLowerCase()}_${report.id}.${format.toLowerCase()}';
    final filePath = '${tempDir.path}/$fileName';

    final file = File(filePath);

    if (format.toLowerCase() == 'csv') {
      final csvContent = await exportReportToCsv(report);
      await file.writeAsString(csvContent);
    } else if (format.toLowerCase() == 'pdf') {
      // We need settings for PDF export
      // This is a simple implementation - in a real app, you would get this from a provider
      final settings = await _getDefaultSettings();
      final pdfBytes = await exportReportToPdf(report, settings);
      await file.writeAsBytes(pdfBytes);
    } else if (format.toLowerCase() == 'json') {
      await file.writeAsString(report.serialize());
    } else {
      throw Exception('Unsupported export format: $format');
    }

    return filePath;
  }

  /// Helper method to get status color
  static Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'unpaid':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      case 'draft':
        return Colors.blueGrey;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  /// Helper method to build summary widgets for PDF
  static List<pw.Widget> _buildSummaryWidgets(
      Report report, NumberFormat currencyFormat) {
    final List<pw.Widget> widgets = [];

    if (report.config.type == ReportType.sales) {
      widgets.addAll([
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Total Sales:'),
            pw.Text(currencyFormat.format(report.summary['totalSales'] ?? 0)),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Number of Invoices:'),
            pw.Text('${report.summary['invoiceCount'] ?? 0}'),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Average Sale:'),
            pw.Text(currencyFormat.format(report.summary['averageSale'] ?? 0)),
          ],
        ),
      ]);
    } else if (report.config.type == ReportType.customers) {
      widgets.addAll([
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Total Customers:'),
            pw.Text('${report.summary['totalCustomers'] ?? 0}'),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Active Customers:'),
            pw.Text('${report.summary['activeCustomers'] ?? 0}'),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Total Revenue:'),
            pw.Text(currencyFormat.format(report.summary['totalRevenue'] ?? 0)),
          ],
        ),
      ]);
    }

    return widgets;
  }

  /// Helper method to build chart widget for PDF
  static pw.Widget _buildChartWidget(
      ReportDataSeries series, ChartType chartType) {
    // A simplified chart representation - in a real app you would use a proper chart library
    // This just creates a table of values
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black),
      children: [
        // Header row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text('Label',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text('Value',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        // Data rows
        ...series.data.map((dataPoint) {
          return pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(dataPoint.label),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(dataPoint.value.toStringAsFixed(2)),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  /// Helper method to get default settings
  static Future<AppSettings> _getDefaultSettings() async {
    // Create a basic set of settings
    return AppSettings(
      companyProfile: CompanyProfile(
        companyName: 'Dishaan Invoice Xpert',
        contactPerson: 'Admin User',
        email: 'admin@example.com',
        phone: '123-456-7890',
        address: '123 Business St',
        city: 'Business City',
        state: 'BS',
        zipCode: '12345',
        country: 'United States',
      ),
      taxSettings: TaxSettings(),
      emailSettings: EmailSettings(
        senderName: 'Dishaan Invoice',
        senderEmail: 'invoices@example.com',
      ),
      invoiceSettings: InvoiceSettings(),
      currencySettings: CurrencySettings(),
    );
  }
}
