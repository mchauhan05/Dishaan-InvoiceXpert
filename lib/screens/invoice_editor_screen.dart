import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/invoice_models.dart';
import '../providers/invoice_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/header.dart';
import '../routes/app_router.dart';

class InvoiceEditorScreen extends StatefulWidget {
  final bool isEditing;
  final String? invoiceId;

  const InvoiceEditorScreen({
    Key? key,
    required this.isEditing,
    this.invoiceId,
  }) : super(key: key);

  @override
  State<InvoiceEditorScreen> createState() => _InvoiceEditorScreenState();
}

class _InvoiceEditorScreenState extends State<InvoiceEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Initialize the invoice
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);

      if (widget.isEditing && widget.invoiceId != null) {
        // Load existing invoice for editing
        invoiceProvider.loadInvoiceForEditing(widget.invoiceId!);
      } else {
        // Create a new invoice
        invoiceProvider.initializeNewInvoice();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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

                // Invoice editor content
                Expanded(
                  child: Consumer<InvoiceProvider>(
                    builder: (context, invoiceProvider, child) {
                      final invoice = invoiceProvider.currentInvoice;

                      if (invoice == null) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title and action buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    widget.isEditing
                                        ? 'Edit Invoice #${invoice.invoiceNumber}'
                                        : 'Create New Invoice',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      // Cancel button
                                      OutlinedButton(
                                        onPressed: () {
                                          Navigator.pushNamed(context, AppRouter.invoices);
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: AppColors.borderGray),
                                        ),
                                        child: const Text('Cancel'),
                                      ),
                                      const SizedBox(width: 16),
                                      // Save button
                                      ElevatedButton(
                                        onPressed: () {
                                          if (_formKey.currentState!.validate()) {
                                            invoiceProvider.saveInvoice();
                                            Navigator.pushNamed(context, AppRouter.invoices);
                                          }
                                        },
                                        child: const Text('Save Invoice'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Invoice details and customer selection
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left column - Invoice details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Invoice number
                                        Text(
                                          'Invoice #: ${invoice.invoiceNumber}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        // Invoice date
                                        Row(
                                          children: [
                                            const Text('Invoice Date:'),
                                            const SizedBox(width: 8),
                                            TextButton(
                                              onPressed: () => _selectDate(
                                                context,
                                                invoice.date,
                                                (newDate) => invoiceProvider.updateInvoiceDate(newDate),
                                              ),
                                              child: Text(
                                                DateFormat('MMM dd, yyyy').format(invoice.date),
                                                style: TextStyle(
                                                  color: AppColors.primaryBlue,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Due date
                                        Row(
                                          children: [
                                            const Text('Due Date:'),
                                            const SizedBox(width: 8),
                                            TextButton(
                                              onPressed: () => _selectDate(
                                                context,
                                                invoice.dueDate,
                                                (newDate) => invoiceProvider.updateDueDate(newDate),
                                              ),
                                              child: Text(
                                                DateFormat('MMM dd, yyyy').format(invoice.dueDate),
                                                style: TextStyle(
                                                  color: AppColors.primaryBlue,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Payment terms
                                        Row(
                                          children: [
                                            const Text('Payment Terms:'),
                                            const SizedBox(width: 8),
                                            DropdownButton<PaymentTerms>(
                                              value: invoice.paymentTerms,
                                              items: PaymentTerms.values.map((term) {
                                                return DropdownMenuItem<PaymentTerms>(
                                                  value: term,
                                                  child: Text(
                                                    _getPaymentTermName(term),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                if (value != null) {
                                                  invoiceProvider.updatePaymentTerms(value);
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 24),

                                  // Right column - Customer details
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
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
                                                'Customer',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              // Change customer button
                                              TextButton(
                                                onPressed: () => _showCustomerSelection(context, invoiceProvider),
                                                child: const Text('Change'),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),

                                          // Display selected customer
                                          Text(
                                            invoice.customer.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(invoice.customer.email),
                                          const SizedBox(height: 4),
                                          Text(invoice.customer.phone),
                                          const SizedBox(height: 8),
                                          Text(invoice.customer.billingAddress),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Line items section
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.borderGray),
                                ),
                                child: Column(
                                  children: [
                                    // Items header
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryDark,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(3),
                                          topRight: Radius.circular(3),
                                        ),
                                      ),
                                      child: Row(
                                        children: const [
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
                                            child: Text(
                                              'QUANTITY',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
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
                                            child: Text(
                                              'AMOUNT',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                          SizedBox(width: 50),
                                        ],
                                      ),
                                    ),

                                    // Line items
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: invoice.items.length,
                                      separatorBuilder: (context, index) => const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final item = invoice.items[index];
                                        return _buildLineItem(context, item, index, invoiceProvider);
                                      },
                                    ),

                                    // Add item button
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: ElevatedButton.icon(
                                        onPressed: () => _showAddItemDialog(context, invoiceProvider),
                                        icon: const Icon(Icons.add),
                                        label: const Text('Add Item'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: AppColors.primaryBlue,
                                          side: BorderSide(color: AppColors.primaryBlue),
                                        ),
                                      ),
                                    ),

                                    // Totals
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.backgroundGray.withOpacity(0.3),
                                        border: Border(
                                          top: BorderSide(color: AppColors.borderGray),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Spacer(),
                                          // Totals column
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              // Subtotal
                                              Row(
                                                children: [
                                                  const Text(
                                                    'Subtotal:',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  SizedBox(
                                                    width: 100,
                                                    child: Text(
                                                      '\$${invoice.subtotal.toStringAsFixed(2)}',
                                                      textAlign: TextAlign.right,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),

                                              // Tax
                                              Row(
                                                children: [
                                                  const Text(
                                                    'Tax:',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  SizedBox(
                                                    width: 100,
                                                    child: Text(
                                                      '\$${invoice.totalTax.toStringAsFixed(2)}',
                                                      textAlign: TextAlign.right,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),

                                              // Total
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                color: AppColors.primaryDark,
                                                child: Row(
                                                  children: [
                                                    const Text(
                                                      'Total:',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    SizedBox(
                                                      width: 100,
                                                      child: Text(
                                                        '\$${invoice.total.toStringAsFixed(2)}',
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                        textAlign: TextAlign.right,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Notes and terms
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
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          initialValue: invoice.notes,
                                          decoration: const InputDecoration(
                                            hintText: 'Notes to customer',
                                          ),
                                          maxLines: 3,
                                          onChanged: (value) {
                                            // Update notes
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
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          initialValue: invoice.terms,
                                          decoration: const InputDecoration(
                                            hintText: 'Terms and conditions',
                                          ),
                                          maxLines: 3,
                                          onChanged: (value) {
                                            // Update terms
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
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineItem(BuildContext context, InvoiceItem item, int index, InvoiceProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                if (item.description.isNotEmpty)
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
            child: Text(
              item.quantity.toString(),
              textAlign: TextAlign.center,
            ),
          ),

          // Rate
          Expanded(
            child: Text(
              '\$${item.rate.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
            ),
          ),

          // Amount
          Expanded(
            child: Text(
              '\$${item.amount.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
            ),
          ),

          // Edit/delete buttons
          SizedBox(
            width: 50,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: AppColors.textGray,
                    size: 18,
                  ),
                  onPressed: () {
                    provider.removeItemFromInvoice(index);
                  },
                  tooltip: 'Remove item',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _selectDate(BuildContext context, DateTime initialDate, Function(DateTime) onDateSelected) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != initialDate) {
      onDateSelected(pickedDate);
    }
  }

  String _getPaymentTermName(PaymentTerms term) {
    switch (term) {
      case PaymentTerms.dueOnReceipt:
        return 'Due on Receipt';
      case PaymentTerms.net15:
        return 'Net 15';
      case PaymentTerms.net30:
        return 'Net 30';
      case PaymentTerms.net45:
        return 'Net 45';
      case PaymentTerms.net60:
        return 'Net 60';
      case PaymentTerms.custom:
        return 'Custom';
      default:
        return 'Unknown';
    }
  }

  void _showCustomerSelection(BuildContext context, InvoiceProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Customer'),
        content: SizedBox(
          width: 400,
          height: 300,
          child: ListView.builder(
            itemCount: provider.customers.length,
            itemBuilder: (context, index) {
              final customer = provider.customers[index];
              return ListTile(
                title: Text(customer.name),
                subtitle: Text(customer.email),
                onTap: () {
                  provider.updateCustomer(customer);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, InvoiceProvider provider) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController quantityController = TextEditingController(text: '1');
    final TextEditingController rateController = TextEditingController();
    double taxRate = 0.0;
    bool isTaxable = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Item'),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Preset items dropdown
                    DropdownButtonFormField<Map<String, dynamic>>(
                      decoration: const InputDecoration(
                        labelText: 'Select from catalog',
                      ),
                      items: [
                        const DropdownMenuItem<Map<String, dynamic>>(
                          value: null,
                          child: Text('Custom Item'),
                        ),
                        ...provider.itemCatalog.map((item) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: item,
                            child: Text(item['name']),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          nameController.text = value['name'];
                          descriptionController.text = value['description'];
                          rateController.text = value['rate'].toString();
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Item name
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Item Name',
                        hintText: 'Enter item name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter item name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Item description
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter item description',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Quantity and rate
                    Row(
                      children: [
                        // Quantity
                        Expanded(
                          child: TextFormField(
                            controller: quantityController,
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Rate
                        Expanded(
                          child: TextFormField(
                            controller: rateController,
                            decoration: const InputDecoration(
                              labelText: 'Rate',
                              prefixText: '\$',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tax options
                    Row(
                      children: [
                        Checkbox(
                          value: isTaxable,
                          onChanged: (value) {
                            setState(() {
                              isTaxable = value ?? false;
                            });
                          },
                        ),
                        const Text('Taxable'),
                        const SizedBox(width: 16),
                        if (isTaxable)
                          Expanded(
                            child: DropdownButtonFormField<double>(
                              decoration: const InputDecoration(
                                labelText: 'Tax Rate',
                              ),
                              value: taxRate,
                              items: provider.taxRates.map((rate) {
                                return DropdownMenuItem<double>(
                                  value: rate,
                                  child: Text('${rate.toStringAsFixed(1)}%'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  taxRate = value ?? 0.0;
                                });
                              },
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Create and add the item
                  final newItem = InvoiceItem(
                    id: 'ITEM${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text,
                    description: descriptionController.text,
                    quantity: double.tryParse(quantityController.text) ?? 1,
                    rate: double.tryParse(rateController.text) ?? 0,
                    tax: taxRate,
                    taxable: isTaxable,
                  );

                  provider.addItemToInvoice(newItem);
                  Navigator.pop(context);
                },
                child: const Text('Add Item'),
              ),
            ],
          );
        },
      ),
    );
  }
}
