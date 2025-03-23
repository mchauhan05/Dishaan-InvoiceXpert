import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../providers/dashboard_provider.dart';
import '../models/dashboard_data.dart';

class TopExpensesCard extends StatelessWidget {
  const TopExpensesCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final topExpenses = dashboardProvider.topExpenses;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Top Expenses',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.more_horiz,
                  color: AppColors.textGray,
                  size: 20,
                ),
              ],
            ),
          ),

          // Expense items
          ...topExpenses.map((expense) => _buildExpenseItem(context, expense)).toList(),

          // View all button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: TextButton(
                onPressed: () {
                  // Navigate to expenses screen
                  Navigator.pushNamed(context, '/expenses');
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All Expenses',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      color: AppColors.primaryBlue,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(BuildContext context, ExpenseItem expense) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.backgroundGray,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              _getCategoryIcon(expense.category),
              color: AppColors.textGray,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Expense details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.category,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expense.vendor,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),
          ),
          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${expense.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(expense.date),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'office supplies':
        return Icons.shopping_bag;
      case 'travel':
        return Icons.flight;
      case 'software':
        return Icons.computer;
      case 'utilities':
        return Icons.electrical_services;
      case 'rent':
        return Icons.home;
      case 'marketing':
        return Icons.campaign;
      default:
        return Icons.attach_money;
    }
  }
}
