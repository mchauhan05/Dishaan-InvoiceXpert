import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/dashboard_data.dart';

class DashboardProvider extends ChangeNotifier {
  // Mock data for receivables
  ReceivablesData _receivablesData = ReceivablesData(
    total: 372580.05,
    current: 0.00,
    overdue: 12.06,
    days1to15: 0.00,
    days16to30: 0.00,
    days31to45: 0.00,
    daysAbove45: 372567.99,
  );

  // Mock data for sales and expenses
  List<SalesExpenseData> _salesExpenseData = [
    SalesExpenseData(month: 'Jan', sales: 1200, expenses: 800),
    SalesExpenseData(month: 'Feb', sales: 1500, expenses: 600),
    SalesExpenseData(month: 'Mar', sales: 1800, expenses: 500),
    SalesExpenseData(month: 'Apr', sales: 1000, expenses: 700),
    SalesExpenseData(month: 'May', sales: 1200, expenses: 900),
    SalesExpenseData(month: 'Jun', sales: 900, expenses: 1200),
  ];

  // Mock data for projects
  List<ProjectData> _projectsData = [
    ProjectData(
      id: 'PRJ001',
      name: 'Sleek Rubber Computer',
      clientName: 'Ethan Clark',
      budgetHoursProgress: 0.7,
    ),
    ProjectData(
      id: 'PRJ002',
      name: 'Luxurious Granite Mouse',
      clientName: 'Sophia Hall',
      budgetHoursProgress: 0.4,
    ),
    ProjectData(
      id: 'PRJ003',
      name: 'Ergonomic Steel Keyboard',
      clientName: 'James Wilson',
      budgetHoursProgress: 0.9,
    ),
    ProjectData(
      id: 'PRJ004',
      name: 'Handcrafted Wooden Chair',
      clientName: 'Emma Davis',
      budgetHoursProgress: 0.2,
    ),
  ];

  // Mock data for sales summary
  List<SalesSummary> _salesSummaryData = [
    SalesSummary(period: 'Today', sales: 0.00, receipts: 0.00, due: 0.00),
    SalesSummary(period: 'This Week', sales: 10.00, receipts: 0.00, due: 10.00),
    SalesSummary(period: 'This Month', sales: 30.00, receipts: 0.00, due: 30.00),
    SalesSummary(period: 'This Quarter', sales: 120.00, receipts: 0.00, due: 120.00),
    SalesSummary(period: 'This Year', sales: 240.00, receipts: 0.00, due: 240.00),
  ];

  // Mock data for expenses
  List<ExpenseItem> _expensesData = [
    ExpenseItem(
      id: 'EXP001',
      category: 'Office Supplies',
      vendor: 'Staples',
      amount: 350.75,
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
    ExpenseItem(
      id: 'EXP002',
      category: 'Travel',
      vendor: 'Delta Airlines',
      amount: 520.30,
      date: DateTime.now().subtract(const Duration(days: 10)),
    ),
    ExpenseItem(
      id: 'EXP003',
      category: 'Software',
      vendor: 'Adobe',
      amount: 240.99,
      date: DateTime.now().subtract(const Duration(days: 15)),
    ),
    ExpenseItem(
      id: 'EXP004',
      category: 'Utilities',
      vendor: 'PG&E',
      amount: 189.45,
      date: DateTime.now().subtract(const Duration(days: 20)),
    ),
    ExpenseItem(
      id: 'EXP005',
      category: 'Rent',
      vendor: 'ABC Property Management',
      amount: 2500.00,
      date: DateTime.now().subtract(const Duration(days: 25)),
    ),
  ];

  // Mock data for invoices
  List<InvoiceItem> _invoicesData = [
    InvoiceItem(
      id: 'INV-001',
      customerName: 'Ethan Clark',
      status: 'Paid',
      amount: 1250.00,
      date: DateTime.now().subtract(const Duration(days: 30)),
      dueDate: DateTime.now().subtract(const Duration(days: 15)),
    ),
    InvoiceItem(
      id: 'INV-002',
      customerName: 'Sophia Hall',
      status: 'Overdue',
      amount: 780.50,
      date: DateTime.now().subtract(const Duration(days: 45)),
      dueDate: DateTime.now().subtract(const Duration(days: 15)),
    ),
    InvoiceItem(
      id: 'INV-003',
      customerName: 'James Wilson',
      status: 'Unpaid',
      amount: 2340.00,
      date: DateTime.now().subtract(const Duration(days: 10)),
      dueDate: DateTime.now().add(const Duration(days: 5)),
    ),
    InvoiceItem(
      id: 'INV-004',
      customerName: 'Emma Davis',
      status: 'Draft',
      amount: 1830.25,
      date: DateTime.now().subtract(const Duration(days: 5)),
      dueDate: DateTime.now().add(const Duration(days: 10)),
    ),
    InvoiceItem(
      id: 'INV-005',
      customerName: 'Oliver Brown',
      status: 'Paid',
      amount: 940.75,
      date: DateTime.now().subtract(const Duration(days: 60)),
      dueDate: DateTime.now().subtract(const Duration(days: 45)),
    ),
  ];

  // Mock data for customers
  List<Customer> _customersData = [
    Customer(
      id: 'CUST001',
      name: 'Ethan Clark',
      email: 'ethan.clark@example.com',
      phone: '(555) 123-4567',
      outstandingAmount: 0.00,
      totalInvoices: 5,
    ),
    Customer(
      id: 'CUST002',
      name: 'Sophia Hall',
      email: 'sophia.hall@example.com',
      phone: '(555) 234-5678',
      outstandingAmount: 780.50,
      totalInvoices: 3,
    ),
    Customer(
      id: 'CUST003',
      name: 'James Wilson',
      email: 'james.wilson@example.com',
      phone: '(555) 345-6789',
      outstandingAmount: 2340.00,
      totalInvoices: 2,
    ),
    Customer(
      id: 'CUST004',
      name: 'Emma Davis',
      email: 'emma.davis@example.com',
      phone: '(555) 456-7890',
      outstandingAmount: 1830.25,
      totalInvoices: 1,
    ),
    Customer(
      id: 'CUST005',
      name: 'Oliver Brown',
      email: 'oliver.brown@example.com',
      phone: '(555) 567-8901',
      outstandingAmount: 0.00,
      totalInvoices: 4,
    ),
  ];

  // Getters
  ReceivablesData get receivablesData => _receivablesData;
  List<SalesExpenseData> get salesExpenseData => _salesExpenseData;
  List<ProjectData> get projectsData => _projectsData;
  List<SalesSummary> get salesSummaryData => _salesSummaryData;
  List<ExpenseItem> get expensesData => _expensesData;
  List<InvoiceItem> get invoicesData => _invoicesData;
  List<Customer> get customersData => _customersData;

  // Get all expenses total
  double get totalExpenses {
    return _expensesData.fold(0, (sum, item) => sum + item.amount);
  }

  // Get formatted date for display
  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // Get top expenses
  List<ExpenseItem> get topExpenses {
    final sorted = List<ExpenseItem>.from(_expensesData);
    sorted.sort((a, b) => b.amount.compareTo(a.amount));
    return sorted.take(3).toList();
  }

  // Filter invoices by status
  List<InvoiceItem> getInvoicesByStatus(String status) {
    return _invoicesData.where((invoice) => invoice.status == status).toList();
  }

  // Filter customers with outstanding balances
  List<Customer> get customersWithOutstandingBalance {
    return _customersData.where((customer) => customer.outstandingAmount > 0).toList();
  }
}
