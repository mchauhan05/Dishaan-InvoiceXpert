import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../routes/app_router.dart';
import '../widgets/header.dart';
import '../widgets/sidebar.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedReport = 'Sales Summary';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: Row(
        children: [
          // Sidebar
          Sidebar(currentRoute: AppRouter.reports),

          // Main content
          Expanded(
            child: Column(
              children: [
                // Header
                const Header(),

                // Reports content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reports',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Report selection
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.borderGray),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Available Reports',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  _buildReportCard('Sales Summary', Icons.bar_chart),
                                  _buildReportCard('Expense Summary', Icons.money_off),
                                  _buildReportCard('Profit & Loss', Icons.account_balance),
                                  _buildReportCard('Customer Sales', Icons.people),
                                  _buildReportCard('Tax Summary', Icons.receipt_long),
                                  _buildReportCard('Payments Collected', Icons.payments),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Message about analytics
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.analytics,
                                size: 64,
                                color: AppColors.primaryBlue.withOpacity(0.7),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Select a report type above to view detailed analytics',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textGray,
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildReportCard(String title, IconData icon) {
    final isSelected = _selectedReport == title;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedReport = title;
        });
      },
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.borderGray,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryBlue : AppColors.textGray,
              size: 24,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.primaryBlue : AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
