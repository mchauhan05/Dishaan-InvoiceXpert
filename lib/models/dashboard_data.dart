class ReceivablesData {
  final double total;
  final double current;
  final double overdue;
  final double days1to15;
  final double days16to30;
  final double days31to45;
  final double daysAbove45;

  ReceivablesData({
    required this.total,
    required this.current,
    required this.overdue,
    required this.days1to15,
    required this.days16to30,
    required this.days31to45,
    required this.daysAbove45,
  });
}

class SalesExpenseData {
  final String month;
  final double sales;
  final double expenses;

  SalesExpenseData({
    required this.month,
    required this.sales,
    required this.expenses,
  });
}

class ProjectData {
  final String id;
  final String name;
  final String clientName;
  final double budgetHoursProgress;
  final double budgetAmountProgress;

  ProjectData({
    required this.id,
    required this.name,
    required this.clientName,
    required this.budgetHoursProgress,
    this.budgetAmountProgress = 0.0,
  });
}

class SalesSummary {
  final String period;
  final double sales;
  final double receipts;
  final double due;

  SalesSummary({
    required this.period,
    required this.sales,
    required this.receipts,
    required this.due,
  });
}

class ExpenseItem {
  final String id;
  final String category;
  final String vendor;
  final double amount;
  final DateTime date;

  ExpenseItem({
    required this.id,
    required this.category,
    required this.vendor,
    required this.amount,
    required this.date,
  });
}

class InvoiceItem {
  final String id;
  final String customerName;
  final String status;
  final double amount;
  final DateTime date;
  final DateTime dueDate;

  InvoiceItem({
    required this.id,
    required this.customerName,
    required this.status,
    required this.amount,
    required this.date,
    required this.dueDate,
  });
}

class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final double outstandingAmount;
  final int totalInvoices;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.outstandingAmount,
    required this.totalInvoices,
  });
}
