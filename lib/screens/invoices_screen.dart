import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/dashboard_data.dart';
import '../providers/dashboard_provider.dart';
import '../routes/app_router.dart';
import '../widgets/header.dart';
import '../widgets/sidebar.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({Key? key}) : super(key: key);

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final invoices = dashboardProvider.invoicesData;

    // Filter invoices based on search query
    final filteredInvoices = _searchQuery.isEmpty
        ? invoices
        : invoices.where((invoice) =>
            invoice.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            invoice.id.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: Row(
        children: [
          // Sidebar
          Sidebar(currentRoute: AppRouter.invoices),

          // Main content
          Expanded(
            child: Column(
              children: [
                // Header
                const Header(),

                // Invoices header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Invoices',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRouter.createInvoice);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('New Invoice'),
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
                            hintText: 'Search invoices',
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
                              'Filter',
                              style: TextStyle(color: AppColors.textGray),
                            ),
                            icon: Icon(Icons.filter_list, color: AppColors.textGray),
                            items: const [
                              DropdownMenuItem(
                                value: 'all',
                                child: Text('All'),
                              ),
                              DropdownMenuItem(
                                value: 'paid',
                                child: Text('Paid'),
                              ),
                              DropdownMenuItem(
                                value: 'unpaid',
                                child: Text('Unpaid'),
                              ),
                              DropdownMenuItem(
                                value: 'overdue',
                                child: Text('Overdue'),
                              ),
                            ],
                            onChanged: (value) {
                              // Filter logic
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
                          tooltip: 'Export invoices',
                        ),
                      ),
                    ],
                  ),
                ),

                // Tabs
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'All'),
                      Tab(text: 'Unpaid'),
                      Tab(text: 'Overdue'),
                      Tab(text: 'Paid'),
                    ],
                    labelColor: AppColors.primaryBlue,
                    unselectedLabelColor: AppColors.textGray,
                    indicatorColor: AppColors.primaryBlue,
                    indicatorWeight: 2,
                  ),
                ),

                // Divider
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.borderGray,
                ),

                // Invoice list
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // All invoices
                      _buildInvoiceList(filteredInvoices),
                      // Unpaid invoices
                      _buildInvoiceList(filteredInvoices.where((i) => i.status == 'Unpaid').toList()),
                      // Overdue invoices
                      _buildInvoiceList(filteredInvoices.where((i) => i.status == 'Overdue').toList()),
                      // Paid invoices
                      _buildInvoiceList(filteredInvoices.where((i) => i.status == 'Paid').toList()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceList(List<InvoiceItem> invoices) {
    if (invoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: AppColors.textGray.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No invoices found',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a new invoice to get started',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGray,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: invoices.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 1,
          color: AppColors.borderGray,
        ),
        itemBuilder: (context, index) {
          final invoice = invoices[index];
          return _buildInvoiceItem(invoice);
        },
      ),
    );
  }

  Widget _buildInvoiceItem(InvoiceItem invoice) {
    Color statusColor;
    switch (invoice.status) {
      case 'Paid':
        statusColor = Colors.green;
        break;
      case 'Unpaid':
        statusColor = AppColors.primaryBlue;
        break;
      case 'Overdue':
        statusColor = AppColors.secondaryOrange;
        break;
      case 'Draft':
        statusColor = AppColors.textGray;
        break;
      default:
        statusColor = AppColors.textGray;
    }

    return InkWell(
      onTap: () {
        // Navigate to invoice details
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            // Invoice ID
            SizedBox(
              width: 100,
              child: Text(
                invoice.id,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Customer name
            Expanded(
              flex: 2,
              child: Text(
                invoice.customerName,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Date
            Expanded(
              child: Text(
                DateFormat('MMM dd, yyyy').format(invoice.date),
                style: TextStyle(
                  color: AppColors.textGray,
                ),
              ),
            ),
            // Due date
            Expanded(
              child: Text(
                DateFormat('MMM dd, yyyy').format(invoice.dueDate),
                style: TextStyle(
                  color: AppColors.textGray,
                ),
              ),
            ),
            // Amount
            SizedBox(
              width: 120,
              child: Text(
                '\$${invoice.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            // Status
            SizedBox(
              width: 100,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  invoice.status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
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

  void _showCreateInvoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Invoice'),
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
