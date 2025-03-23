import 'package:flutter/material.dart';
import '../widgets/header.dart';
import '../widgets/sidebar.dart';
import '../constants/app_colors.dart';
import '../routes/app_router.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final String currentRoute;
  final String? pageTitle;

  const AppLayout({
    Key? key,
    required this.child,
    required this.currentRoute,
    this.pageTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: Row(
        children: [
          // Sidebar with current route
          Sidebar(currentRoute: currentRoute),

          // Main content
          Expanded(
            child: Column(
              children: [
                // Header
                const Header(),

                // Page title if provided
                if (pageTitle != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.borderGray,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      pageTitle!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),

                // Main content
                Expanded(
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
      // Floating action button for creating a new item
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    // Only show FAB on certain screens
    if (currentRoute == AppRouter.dashboard) {
      return null;
    }

    String label = '';
    IconData icon = Icons.add;
    VoidCallback onPressed = () {};

    switch (currentRoute) {
      case AppRouter.invoices:
        label = 'New Invoice';
        onPressed = () {
          // Navigate to create invoice page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create new invoice')),
          );
        };
        break;
      case AppRouter.customers:
        label = 'New Customer';
        onPressed = () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create new customer')),
          );
        };
        break;
      case AppRouter.expenses:
        label = 'New Expense';
        onPressed = () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create new expense')),
          );
        };
        break;
      case AppRouter.items:
        label = 'New Item';
        onPressed = () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create new item')),
          );
        };
        break;
      default:
        return null;
    }

    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: AppColors.primaryBlue,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
