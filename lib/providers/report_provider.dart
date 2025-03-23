import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../models/customer_model.dart';
import '../models/invoice_models.dart';
import '../models/report_model.dart';
import '../models/settings_model.dart';
import '../services/report_service.dart';

/// Provider class for report management
class ReportProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  // Current report being viewed
  Report? _currentReport;

  // List of saved reports
  List<Report> _savedReports = [];

  // Default report configurations
  final Map<ReportType, ReportConfig> _defaultConfigs = {
    ReportType.sales: ReportConfig(
      type: ReportType.sales,
      period: ReportPeriod.thisMonth,
      chartType: ChartType.bar,
      groupBy: ['month', 'status'],
    ),

    ReportType.customers: ReportConfig(
      type: ReportType.customers,
      period: ReportPeriod.thisYear,
      chartType: ChartType.pie,
      groupBy: ['segment'],
    ),

    ReportType.products: ReportConfig(
      type: ReportType.products,
      period: ReportPeriod.lastMonth,
      chartType: ChartType.bar,
      groupBy: ['category'],
    ),

    ReportType.taxes: ReportConfig(
      type: ReportType.taxes,
      period: ReportPeriod.lastQuarter,
      chartType: ChartType.pie,
      groupBy: ['jurisdiction'],
    ),
  };

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Report? get currentReport => _currentReport;
  List<Report> get savedReports => _savedReports;
  Map<ReportType, ReportConfig> get defaultConfigs => _defaultConfigs;

  // Constructor
  ReportProvider() {
    _loadSavedReports();
  }

  // Load saved reports from storage
  Future<void> _loadSavedReports() async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, you would load reports from a database or API
      // For this demo, we'll just create some sample reports

      // We'll load reports from storage later if we implement that functionality
      _savedReports = [];
      _error = null;
    } catch (e) {
      _error = 'Error loading saved reports: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Generate a sales report
  Future<Report?> generateSalesReport({
    required List<Invoice> invoices,
    List<Customer>? customers,
    ReportConfig? config,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Use provided config or default
      final reportConfig = config ?? _defaultConfigs[ReportType.sales]!;

      // Generate the report
      final report = await ReportService.generateSalesReport(
        config: reportConfig,
        invoices: invoices,
        customers: customers,
      );

      // Set as current report
      _currentReport = report;

      // Add to saved reports
      _savedReports.add(report);

      _isLoading = false;
      notifyListeners();

      return report;
    } catch (e) {
      _error = 'Error generating sales report: $e';
      print(_error);
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Generate a customer insights report
  Future<Report?> generateCustomerInsightsReport({
    required List<Customer> customers,
    required List<Invoice> invoices,
    ReportConfig? config,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Use provided config or default
      final reportConfig = config ?? _defaultConfigs[ReportType.customers]!;

      // Generate the report
      final report = await ReportService.generateCustomerInsightsReport(
        config: reportConfig,
        customers: customers,
        invoices: invoices,
      );

      // Set as current report
      _currentReport = report;

      // Add to saved reports
      _savedReports.add(report);

      _isLoading = false;
      notifyListeners();

      return report;
    } catch (e) {
      _error = 'Error generating customer insights report: $e';
      print(_error);
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Export current report
  Future<bool> exportCurrentReport(String format, AppSettings settings) async {
    if (_currentReport == null) {
      _error = 'No report selected for export';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String filePath;

      if (format.toLowerCase() == 'pdf') {
        // Generate PDF
        final pdfBytes = await ReportService.exportReportToPdf(_currentReport!, settings);

        // Save to temp file
        filePath = await ReportService.saveReportToTempFile(_currentReport!, 'pdf');
      } else if (format.toLowerCase() == 'csv') {
        // Save to temp file
        filePath = await ReportService.saveReportToTempFile(_currentReport!, 'csv');
      } else {
        throw Exception('Unsupported export format: $format');
      }

      // Open the file
      final url = 'file://$filePath';
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Could not open the exported file');
      }
    } catch (e) {
      _error = 'Error exporting report: $e';
      print(_error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Share current report via email
  Future<bool> shareReportViaEmail({
    required String recipientEmail,
    required String subject,
    required String body,
    required String format,
    required AppSettings settings,
  }) async {
    if (_currentReport == null) {
      _error = 'No report selected to share';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Save report to file
      final filePath = await ReportService.saveReportToTempFile(_currentReport!, format);

      // Create email URL
      final emailUrl = Uri(
        scheme: 'mailto',
        path: recipientEmail,
        query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}&attachment=$filePath',
      ).toString();

      // Launch email client
      if (await canLaunchUrlString(emailUrl)) {
        await launchUrlString(emailUrl);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Could not launch email client');
      }
    } catch (e) {
      _error = 'Error sharing report: $e';
      print(_error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // View a saved report
  void viewReport(String reportId) {
    try {
      final report = _savedReports.firstWhere((r) => r.id == reportId);
      _currentReport = report;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Report not found: $e';
      print(_error);
      notifyListeners();
    }
  }

  // Delete a saved report
  void deleteReport(String reportId) {
    _savedReports.removeWhere((r) => r.id == reportId);

    if (_currentReport?.id == reportId) {
      _currentReport = null;
    }

    notifyListeners();
  }

  // Format currency values for display
  String formatCurrency(double value, {String currencyCode = 'USD'}) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(value);
  }

  // Format date for display
  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // Get all report types with descriptions
  Map<ReportType, String> getReportTypes() {
    return {
      ReportType.sales: 'Sales Analysis',
      ReportType.customers: 'Customer Insights',
      ReportType.products: 'Product Performance',
      ReportType.taxes: 'Tax Summary',
      ReportType.expenses: 'Expense Analysis',
      ReportType.profit: 'Profit & Loss',
      ReportType.timeTracking: 'Time Tracking',
      ReportType.custom: 'Custom Report',
    };
  }

  // Get all report periods with descriptions
  Map<ReportPeriod, String> getReportPeriods() {
    return {
      ReportPeriod.today: 'Today',
      ReportPeriod.yesterday: 'Yesterday',
      ReportPeriod.thisWeek: 'This Week',
      ReportPeriod.lastWeek: 'Last Week',
      ReportPeriod.thisMonth: 'This Month',
      ReportPeriod.lastMonth: 'Last Month',
      ReportPeriod.thisQuarter: 'This Quarter',
      ReportPeriod.lastQuarter: 'Last Quarter',
      ReportPeriod.thisYear: 'This Year',
      ReportPeriod.lastYear: 'Last Year',
      ReportPeriod.custom: 'Custom Date Range',
    };
  }
}
