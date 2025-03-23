import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../routes/app_router.dart';
import '../widgets/header.dart';
import '../widgets/sidebar.dart';

class ItemsScreen extends StatelessWidget {
  const ItemsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: Row(
        children: [
          // Sidebar
          Sidebar(currentRoute: AppRouter.items),

          // Main content
          Expanded(
            child: Column(
              children: [
                // Header
                const Header(),

                // Items content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Items',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Add item button
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add),
                          label: const Text('Add Item'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Basic message
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2,
                                size: 64,
                                color: AppColors.textGray.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Items feature coming soon',
                                style: TextStyle(
                                  fontSize: 18,
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
}
