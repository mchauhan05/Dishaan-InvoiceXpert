import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../routes/app_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textGray),
            onPressed: () {},
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
          // Search bar
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.backgroundGray,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.borderGray),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.textGray, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search ( / )',
                        hintStyle: TextStyle(
                          color: AppColors.textGray,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Organization info
          Text(
            'Dishaan Organization',
            style: TextStyle(
              color: AppColors.textGray,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 16),
          // Demo org dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.borderGray),
            ),
            child: Row(
              children: [
                Text(
                  'Invoice Xpert',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, color: AppColors.primaryDark),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Add new button (Create dropdown)
          PopupMenuButton<String>(
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(color: AppColors.borderGray),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'invoice',
                child: Text('New Invoice'),
              ),
              const PopupMenuItem(
                value: 'customer',
                child: Text('New Customer'),
              ),
              const PopupMenuItem(
                value: 'product',
                child: Text('New Item'),
              ),
              const PopupMenuItem(
                value: 'expense',
                child: Text('New Expense'),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'invoice':
                  Navigator.pushNamed(context, AppRouter.createInvoice);
                  break;
                case 'customer':
                  Navigator.pushNamed(context, AppRouter.createCustomer);
                  break;
                default:
                  break;
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          // Notifications
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.textGray),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
          // Settings
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.textGray),
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.settings);
            },
            tooltip: 'Settings',
          ),
          // User avatar
          PopupMenuButton<String>(
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(color: AppColors.borderGray),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 16),
                    const SizedBox(width: 8),
                    Text('Profile: ${user?.fullName ?? "Demo User"}'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 16),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 16),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              switch (value) {
                case 'profile':
                  Navigator.pushNamed(context, AppRouter.settings);
                  break;
                case 'settings':
                  Navigator.pushNamed(context, AppRouter.settings);
                  break;
                case 'logout':
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, AppRouter.login);
                  }
                  break;
                default:
                  break;
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.backgroundGray,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderGray),
              ),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user?.initials ?? 'D',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
