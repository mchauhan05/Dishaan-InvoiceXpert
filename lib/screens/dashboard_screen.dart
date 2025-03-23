import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../providers/dashboard_provider.dart';
import '../routes/app_router.dart';
import '../widgets/dashboard_tabs.dart';
import '../widgets/header.dart';
import '../widgets/projects_card.dart';
import '../widgets/sales_expenses_card.dart';
import '../widgets/sales_receipts_table.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_expenses_card.dart';
import '../widgets/total_receivables_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the provider
    final dashboardProvider = Provider.of<DashboardProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: Row(
        children: [
          // Sidebar
          Sidebar(currentRoute: AppRouter.dashboard),

          // Main content
          Expanded(
            child: Column(
              children: [
                // Header
                const Header(),

                // Main content area with scrolling
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome section
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.borderGray),
                                ),
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    'D',
                                    style: TextStyle(
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello, Demo User',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                  Text(
                                    'Demo Org',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textGray,
                                    ),
                                  ),
                                ],
                              ),
                              // Refresh button
                              const Spacer(),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // We'll implement refresh later
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Refreshing dashboard data...'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text('Refresh'),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: AppColors.primaryDark,
                                  backgroundColor: Colors.white,
                                  side: BorderSide(color: AppColors.borderGray),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Tabs
                        const DashboardTabs(),

                        // Dashboard content
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left column (60%)
                              Expanded(
                                flex: 6,
                                child: Column(
                                  children: const [
                                    TotalReceivablesCard(),
                                    SalesExpensesCard(),
                                    SalesReceiptsTable(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              // Right column (40%)
                              Expanded(
                                flex: 4,
                                child: Column(
                                  children: const [
                                    ProjectsCard(),
                                    TopExpensesCard(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Advanced billing banner
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.borderGray),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Need a solution for advanced billing needs?',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Check out our end-to-end billing software built for fast growing businesses.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Row(
                                    children: [
                                      Text(
                                        'Learn More',
                                        style: TextStyle(
                                          color: AppColors.primaryBlue,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
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
                              ],
                            ),
                          ),
                        ),

                        // Footer
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '© 2025, Zoho Corporation Pvt. Ltd. All Rights Reserved.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textGray,
                                ),
                              ),
                              // Contact support button
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.borderGray),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.email_outlined,
                                      color: AppColors.primaryBlue,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Contact Support',
                                      style: TextStyle(
                                        color: AppColors.primaryDark,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
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
}
