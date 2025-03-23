import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/branding_provider.dart';
import '../routes/app_router.dart';
import '../utils/translation_extension.dart';

class Sidebar extends StatelessWidget {
  final String currentRoute;

  const Sidebar({
    Key? key,
    required this.currentRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brandingProvider = Provider.of<BrandingProvider>(context);
    final brandColors = brandingProvider.brandingSettings.colors;

    return Container(
      width: 240,
      color: Color(int.parse(brandColors.primary.value.toRadixString(16), radix: 16)),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Logo and Invoice title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(Icons.description, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(text: 'Dishaan'),
                      TextSpan(
                        text: 'Invoice',
                        style: TextStyle(color: Color(int.parse(brandColors.secondary.value.toRadixString(16), radix: 16))),
                      ),
                      TextSpan(text: 'Xpert'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Navigation items
          _buildNavItem(
            context,
            'Dashboard',
            Icons.dashboard,
            currentRoute == AppRouter.dashboard,
            onTap: () {
              Navigator.pushNamed(context, AppRouter.dashboard);
            },
          ),
          _buildNavItem(
            context,
            'Customers',
            Icons.people,
            currentRoute == AppRouter.customers,
            onTap: () {
              Navigator.pushNamed(context, AppRouter.customers);
            },
          ),
          _buildNavItem(
            context,
            'Items',
            Icons.inventory,
            currentRoute == AppRouter.items,
            onTap: () {
              Navigator.pushNamed(context, AppRouter.items);
            },
          ),
          const Divider(color: Colors.white24, height: 32),
          _buildNavItem(
            context,
            'Quotes',
            Icons.request_quote,
            currentRoute == '/quotes',
            onTap: () {
              // No navigation for now
            },
          ),
          _buildNavItem(
            context,
            'Invoices',
            Icons.receipt,
            currentRoute == AppRouter.invoices,
            onTap: () {
              Navigator.pushNamed(context, AppRouter.invoices);
            },
          ),
          _buildNavItem(
            context,
            'Payments Received',
            Icons.payments,
            currentRoute == '/payments',
            onTap: () {
              // No navigation for now
            },
          ),
          _buildNavItem(
            context,
            'Recurring Invoices',
            Icons.loop,
            currentRoute == '/recurring',
            onTap: () {
              // No navigation for now
            },
          ),
          const Divider(color: Colors.white24, height: 32),
          _buildNavItem(
            context,
            'Expenses',
            Icons.shopping_bag,
            currentRoute == AppRouter.expenses,
            onTap: () {
              Navigator.pushNamed(context, AppRouter.expenses);
            },
          ),
          const Divider(color: Colors.white24, height: 32),
          _buildNavItem(
            context,
            'Time Tracking',
            Icons.timer,
            currentRoute == '/timetracking',
            onTap: () {
              // No navigation for now
            },
          ),
          _buildNavItem(
            context,
            'Reports',
            Icons.bar_chart,
            currentRoute == AppRouter.reports,
            onTap: () {
              Navigator.pushNamed(context, AppRouter.reports);
            },
          ),
          const Divider(color: Colors.white24, height: 32),
          _buildNavItem(
            context,
            'Settings',
            Icons.settings,
            currentRoute == AppRouter.settings,
            onTap: () {
              Navigator.pushNamed(context, AppRouter.settings);
            },
          ),
          _buildNavItem(
            context,
            'Indian GST',
            Icons.account_balance,
            currentRoute == AppRouter.indianGstSettings,
            onTap: () {
              Navigator.pushNamed(context, AppRouter.indianGstSettings);
            },
          ),
          // Add GST Return Filing option
          _buildNavItem(
            context,
            context.tr('gst_return_filing'),
            Icons.assignment_turned_in,
            currentRoute == AppRouter.gstReturnFiling,
            onTap: () {
              Navigator.pushNamed(context, AppRouter.gstReturnFiling);
            },
          ),
          // Add UPI Payment Settings option
          _buildNavItem(
            context,
            context.tr('upi_payment_settings'),
            Icons.payment,
            currentRoute == AppRouter.upiSettings,
            onTap: () {
              Navigator.pushNamed(context, AppRouter.upiSettings);
            },
          ),
          const Spacer(),

          // Upgrade banner
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upgrade Plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Get more features with Premium',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(int.parse(brandColors.secondary.value.toRadixString(16), radix: 16)),
                      ),
                      child: const Text('Upgrade Now'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String title,
    IconData icon,
    bool isSelected,
    {VoidCallback? onTap}
  ) {
    return Container(
      color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.white70,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        dense: true,
        onTap: onTap,
        selectedTileColor: Colors.white.withOpacity(0.1),
        selected: isSelected,
      ),
    );
  }
}
