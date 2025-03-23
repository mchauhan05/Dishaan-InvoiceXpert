import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/customer_model.dart';
import '../providers/customer_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/header.dart';
import '../routes/app_router.dart';

class CustomerDetailScreen extends StatelessWidget {
  final String customerId;

  const CustomerDetailScreen({
    Key? key,
    required this.customerId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final customerProvider = Provider.of<CustomerProvider>(context);

    // Load customer data if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (customerProvider.currentCustomer?.id != customerId) {
        customerProvider.loadCustomerForEditing(customerId);
      }
    });

    final customer = customerProvider.currentCustomer;

    if (customer == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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

                // Detail content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button and title
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Customer Details',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const Spacer(),
                            // Edit button
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                  AppRouter.editCustomer,
                                  arguments: customer.id,
                                );
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primaryBlue,
                                side: BorderSide(color: AppColors.primaryBlue),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Actions button
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _showDeleteConfirmation(context, customer);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem<String>(
                                  value: 'create_invoice',
                                  child: Text('Create Invoice'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'send_statement',
                                  child: Text('Send Statement'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.borderGray),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    const Text('Actions'),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Customer overview
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.borderGray),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                children: [
                                  // Customer avatar
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        customer.displayName.isNotEmpty
                                            ? customer.displayName[0].toUpperCase()
                                            : 'C',
                                        style: TextStyle(
                                          color: AppColors.primaryBlue,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Customer details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          customer.displayName,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          customer.companyName,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: AppColors.textGray,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Status badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: customer.statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      customer.statusText,
                                      style: TextStyle(
                                        color: customer.statusColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),

                              // Financial overview
                              Row(
                                children: [
                                  _buildStatCard(
                                    'Outstanding Amount',
                                    customerProvider.formatCurrency(customer.outstandingAmount),
                                    color: customer.outstandingAmount > 0
                                        ? AppColors.secondaryOrange
                                        : Colors.green,
                                  ),
                                  const SizedBox(width: 16),
                                  _buildStatCard(
                                    'Total Invoices',
                                    customer.totalInvoices.toString(),
                                    color: AppColors.primaryBlue,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Contact info section
                              const Text(
                                'Contact Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Contact details in columns
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Column 1
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildContactItem('Email', customer.email, Icons.email),
                                        const SizedBox(height: 16),
                                        _buildContactItem('Phone', customer.phone, Icons.phone),
                                      ],
                                    ),
                                  ),
                                  // Column 2
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildContactItem('Website', customer.website, Icons.language),
                                        const SizedBox(height: 16),
                                        if (customer.taxNumber != null)
                                          _buildContactItem('Tax Number', customer.taxNumber!, Icons.receipt),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Address section
                              const Text(
                                'Address',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Address details in columns
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Billing address
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Billing Address',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(customer.billingAddress.formattedAddress),
                                      ],
                                    ),
                                  ),
                                  // Shipping address if exists
                                  if (customer.shippingAddress != null)
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Shipping Address',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(customer.shippingAddress!.formattedAddress),
                                        ],
                                      ),
                                    ),
                                ],
                              ),

                              // Additional contacts if any
                              if (customer.contacts.length > 1) ...[
                                const SizedBox(height: 24),
                                const Text(
                                  'Additional Contacts',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...customer.contacts
                                    .where((contact) => !contact.isPrimary)
                                    .map((contact) => Padding(
                                          padding: const EdgeInsets.only(bottom: 16),
                                          child: _buildAdditionalContact(contact),
                                        )),
                              ],

                              // Notes if exists
                              if (customer.notes != null && customer.notes!.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                const Text(
                                  'Notes',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundGray,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(customer.notes!),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Recent transactions section (placeholder)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.borderGray),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Recent Transactions',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      // Navigate to transactions
                                    },
                                    icon: const Icon(Icons.visibility),
                                    label: const Text('View All'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Placeholder for recent transactions
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.receipt_long,
                                        size: 48,
                                        color: AppColors.textGray.withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No recent transactions',
                                        style: TextStyle(
                                          color: AppColors.textGray,
                                          fontSize: 16,
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, {required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.textGray,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textGray,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalContact(Contact contact) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Contact avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                contact.firstName.isNotEmpty ? contact.firstName[0].toUpperCase() : 'C',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Contact details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (contact.jobTitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    contact.jobTitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textGray,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  contact.email,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contact.phone,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Customer'),
          content: Text(
            'Are you sure you want to delete ${customer.displayName}? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
              onPressed: () {
                final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
                customerProvider.deleteCustomer(customer.id);

                // Pop twice to go back to customers list
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
