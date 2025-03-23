import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/dashboard_data.dart';
import '../providers/dashboard_provider.dart';
import '../routes/app_router.dart';
import '../widgets/header.dart';
import '../widgets/sidebar.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({Key? key}) : super(key: key);

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final customers = dashboardProvider.customersData;

    // Filter customers based on search query
    final filteredCustomers = _searchQuery.isEmpty
        ? customers
        : customers.where((customer) =>
            customer.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            customer.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            customer.phone.contains(_searchQuery)
          ).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: Row(
        children: [
          // Sidebar
          Sidebar(currentRoute: AppRouter.customers),

          // Main content
          Expanded(
            child: Column(
              children: [
                // Header
                const Header(),

                // Customers header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Customers',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Show a dialog for creating a new customer
                          _showCreateCustomerDialog(context);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('New Customer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search and filters
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      // Search box
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search customers',
                            prefixIcon: Icon(Icons.search, color: AppColors.textGray),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(color: AppColors.borderGray),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Filter dropdown
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.borderGray),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: Text(
                              'All Customers',
                              style: TextStyle(color: AppColors.textGray),
                            ),
                            icon: Icon(Icons.filter_list, color: AppColors.textGray),
                            items: const [
                              DropdownMenuItem(
                                value: 'all',
                                child: Text('All Customers'),
                              ),
                              DropdownMenuItem(
                                value: 'outstanding',
                                child: Text('With Outstanding Balance'),
                              ),
                              DropdownMenuItem(
                                value: 'zero',
                                child: Text('With Zero Balance'),
                              ),
                            ],
                            onChanged: (value) {
                              // Filter logic would go here
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Export button
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.borderGray),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.download, color: AppColors.textGray),
                          onPressed: () {
                            // Export logic
                          },
                          tooltip: 'Export customers',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Table header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: Text(
                            'ID',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'NAME',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'EMAIL',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'PHONE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'OUTSTANDING',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'INVOICES',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 40),
                      ],
                    ),
                  ),
                ),

                // Customer list
                Expanded(
                  child: filteredCustomers.isEmpty
                      ? _buildEmptyState()
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(4),
                                bottomRight: Radius.circular(4),
                              ),
                              border: Border.all(color: AppColors.borderGray),
                            ),
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: filteredCustomers.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                thickness: 1,
                                color: AppColors.borderGray,
                              ),
                              itemBuilder: (context, index) {
                                final customer = filteredCustomers[index];
                                return _buildCustomerItem(customer);
                              },
                            ),
                          ),
                        ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppColors.textGray.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No customers found',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a new customer to get started',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerItem(Customer customer) {
    return InkWell(
      onTap: () {
        // Navigate to customer details
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            // ID
            SizedBox(
              width: 40,
              child: Text(
                customer.id.substring(4), // Just showing the numeric part
                style: TextStyle(
                  color: AppColors.textGray,
                  fontSize: 12,
                ),
              ),
            ),
            // Customer name
            Expanded(
              flex: 3,
              child: Text(
                customer.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Email
            Expanded(
              flex: 3,
              child: Text(
                customer.email,
                style: TextStyle(
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            // Phone
            Expanded(
              flex: 2,
              child: Text(
                customer.phone,
                style: TextStyle(
                  color: AppColors.textGray,
                ),
              ),
            ),
            // Outstanding amount
            Expanded(
              flex: 2,
              child: Text(
                '\$${customer.outstandingAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: customer.outstandingAmount > 0 ? FontWeight.w500 : FontWeight.normal,
                  color: customer.outstandingAmount > 0 ? AppColors.secondaryOrange : AppColors.textGray,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            // Invoices count
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundGray,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    customer.totalInvoices.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            // Options
            SizedBox(
              width: 40,
              child: IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: AppColors.textGray,
                ),
                onPressed: () {
                  // Show options menu
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateCustomerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Customer'),
        content: const Text('This feature is not implemented yet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
