import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/invoice_models.dart';
import '../providers/invoice_provider.dart';
import '../routes/app_router.dart';
import '../widgets/header.dart';
import '../widgets/sidebar.dart';

class BasicInvoiceForm extends StatefulWidget {
  const BasicInvoiceForm({Key? key}) : super(key: key);

  @override
  State<BasicInvoiceForm> createState() => _BasicInvoiceFormState();
}

class _BasicInvoiceFormState extends State<BasicInvoiceForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize a new invoice
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InvoiceProvider>(context, listen: false).initializeNewInvoice();
    });
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final invoice = invoiceProvider.currentInvoice;

    if (invoice == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: Row(
        children: [
          // Sidebar
          Sidebar(currentRoute: AppRouter.createInvoice),

          // Main content
          Expanded(
            child: Column(
              children: [
                // Header
                const Header(),

                // Form content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Page title
                          Text(
                            'Create New Invoice',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Invoice form
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
                                // Invoice details section
                                Text(
                                  'Invoice Details',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Invoice number
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: invoice.invoiceNumber,
                                        decoration: const InputDecoration(
                                          labelText: 'Invoice Number',
                                        ),
                                        readOnly: true, // Auto-generated, not editable
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Invoice date
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: invoiceProvider.formatDate(invoice.date),
                                        decoration: InputDecoration(
                                          labelText: 'Invoice Date',
                                          suffixIcon: Icon(
                                            Icons.calendar_today,
                                            color: AppColors.textGray,
                                            size: 20,
                                          ),
                                        ),
                                        readOnly: true,
                                        onTap: () {
                                          _selectDate(context, invoice.date, (newDate) {
                                            invoiceProvider.updateInvoiceDate(newDate);
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Due date
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: invoiceProvider.formatDate(invoice.dueDate),
                                        decoration: InputDecoration(
                                          labelText: 'Due Date',
                                          suffixIcon: Icon(
                                            Icons.calendar_today,
                                            color: AppColors.textGray,
                                            size: 20,
                                          ),
                                        ),
                                        readOnly: true,
                                        onTap: () {
                                          _selectDate(context, invoice.dueDate, (newDate) {
                                            invoiceProvider.updateDueDate(newDate);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Customer section
                                Text(
                                  'Customer Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Customer dropdown
                                DropdownButtonFormField<String>(
                                  value: invoice.customer.id,
                                  decoration: const InputDecoration(
                                    labelText: 'Select Customer',
                                  ),
                                  items: invoiceProvider.customers.map((customer) {
                                    return DropdownMenuItem<String>(
                                      value: customer.id,
                                      child: Text(customer.name),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      final selectedCustomer = invoiceProvider.customers
                                          .firstWhere((customer) => customer.id == value);
                                      invoiceProvider.updateCustomer(selectedCustomer);
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Customer details
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundGray,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        invoice.customer.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        invoice.customer.email,
                                        style: TextStyle(
                                          color: AppColors.textGray,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        invoice.customer.phone,
                                        style: TextStyle(
                                          color: AppColors.textGray,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Billing Address: ${invoice.customer.billingAddress}',
                                        style: TextStyle(
                                          color: AppColors.textGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Add items section header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Invoice Items',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        _showAddItemDialog(context, invoiceProvider);
                                      },
                                      icon: const Icon(Icons.add, size: 18),
                                      label: const Text('Add Item'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Item table headers
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryDark,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      topRight: Radius.circular(4),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'ITEM',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          'QTY',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          'RATE',
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
                                          'AMOUNT',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                      SizedBox(width: 48), // For action buttons
                                    ],
                                  ),
                                ),

                                // Item list
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.borderGray),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(4),
                                      bottomRight: Radius.circular(4),
                                    ),
                                  ),
                                  child: invoice.items.isEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Center(
                                            child: Text(
                                              'No items added yet. Click "Add Item" to add invoice items.',
                                              style: TextStyle(
                                                color: AppColors.textGray,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                        )
                                      : ListView.separated(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: invoice.items.length,
                                          separatorBuilder: (context, index) => Divider(
                                            height: 1,
                                            color: AppColors.borderGray,
                                          ),
                                          itemBuilder: (context, index) {
                                            final item = invoice.items[index];
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 8,
                                                horizontal: 16,
                                              ),
                                              child: Row(
                                                children: [
                                                  // Item details
                                                  Expanded(
                                                    flex: 3,
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          item.name,
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          item.description,
                                                          style: TextStyle(
                                                            color: AppColors.textGray,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Quantity
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      item.quantity.toString(),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                  // Rate
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      '\$${item.rate.toStringAsFixed(2)}',
                                                      textAlign: TextAlign.right,
                                                    ),
                                                  ),
                                                  // Amount
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      '\$${item.amount.toStringAsFixed(2)}',
                                                      textAlign: TextAlign.right,
                                                    ),
                                                  ),
                                                  // Actions
                                                  SizedBox(
                                                    width: 48,
                                                    child: IconButton(
                                                      icon: Icon(
                                                        Icons.delete_outline,
                                                        color: AppColors.textGray,
                                                      ),
                                                      onPressed: () {
                                                        invoiceProvider.removeItemFromInvoice(index);
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                ),
                                const SizedBox(height: 24),

                                // Invoice totals
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundGray,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(child: Container()),
                                      // Totals column
                                      SizedBox(
                                        width: 300,
                                        child: Column(
                                          children: [
                                            _buildTotalRow('Subtotal', '\$${invoice.subtotal.toStringAsFixed(2)}'),
                                            const SizedBox(height: 8),
                                            _buildTotalRow('Tax', '\$${invoice.totalTax.toStringAsFixed(2)}'),
                                            const SizedBox(height: 8),
                                            const Divider(height: 1),
                                            const SizedBox(height: 8),
                                            _buildTotalRow(
                                              'Total',
                                              '\$${invoice.total.toStringAsFixed(2)}',
                                              isBold: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Notes and Terms
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Notes
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Notes',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            initialValue: invoice.notes,
                                            decoration: const InputDecoration(
                                              hintText: 'Enter notes for customer',
                                            ),
                                            maxLines: 3,
                                            onChanged: (value) {
                                              // Save notes
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Terms
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Terms & Conditions',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            initialValue: invoice.terms,
                                            decoration: const InputDecoration(
                                              hintText: 'Enter terms and conditions',
                                            ),
                                            maxLines: 3,
                                            onChanged: (value) {
                                              // Save terms
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Action buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Cancel button
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.borderGray),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: AppColors.textGray),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Save as draft button
                              OutlinedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    invoiceProvider.saveInvoice();
                                    Navigator.of(context).pushNamed(AppRouter.invoices);
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.primaryBlue),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                child: Text(
                                  'Save as Draft',
                                  style: TextStyle(color: AppColors.primaryBlue),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Save and send button
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    invoiceProvider.saveInvoice();
                                    Navigator.of(context).pushNamed(AppRouter.invoices);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                child: const Text('Save and Send'),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildTotalRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Date picker helper
  Future<void> _selectDate(
    BuildContext context,
    DateTime initialDate,
    Function(DateTime) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != initialDate) {
      onDateSelected(picked);
    }
  }

  // Dialog to add a new item
  void _showAddItemDialog(BuildContext context, InvoiceProvider invoiceProvider) {
    final catalog = invoiceProvider.itemCatalog;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Item'),
          content: SizedBox(
            width: 600,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Select an item from the catalog or create a custom item:'),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: catalog.length,
                    itemBuilder: (context, index) {
                      final item = catalog[index];
                      return ListTile(
                        title: Text(item['name']),
                        subtitle: Text(item['description']),
                        trailing: Text('\$${item['rate']}'),
                        onTap: () {
                          final newItem = InvoiceItem(
                            id: 'ITEM${DateTime.now().millisecondsSinceEpoch}',
                            name: item['name'],
                            description: item['description'],
                            quantity: 1,
                            rate: item['rate'],
                          );
                          invoiceProvider.addItemToInvoice(newItem);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
