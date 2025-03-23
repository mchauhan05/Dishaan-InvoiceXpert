import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/eway_bill_provider.dart';
import '../providers/invoice_provider.dart';
import '../providers/indian_gst_provider.dart';
import '../utils/translation_extension.dart';
import '../widgets/app_layout.dart';

class EwayBillScreen extends StatefulWidget {
  const EwayBillScreen({Key? key}) : super(key: key);

  @override
  _EwayBillScreenState createState() => _EwayBillScreenState();
}

class _EwayBillScreenState extends State<EwayBillScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Form fields
  final _fromGstinController = TextEditingController();
  final _toGstinController = TextEditingController();
  final _transporterIdController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _documentNumberController = TextEditingController();

  late DateTime _validFrom;
  late DateTime _validUntil;
  String _selectedDocumentType = 'Invoice';

  List<EwayBillItem> _items = [];
  bool _isCreating = true;
  String? _currentBillId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _validFrom = DateTime.now();
    _validUntil = DateTime.now().add(const Duration(days: 1));

    // Initialize with data from providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<EwayBillProvider>(context, listen: false);
      final gstProvider = Provider.of<IndianGSTProvider>(context, listen: false);

      if (gstProvider.gstin.isNotEmpty) {
        _fromGstinController.text = gstProvider.gstin;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fromGstinController.dispose();
    _toGstinController.dispose();
    _transporterIdController.dispose();
    _vehicleNumberController.dispose();
    _documentNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'E-way Bill Management',
      body: Consumer<EwayBillProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'E-way Bills'),
                  Tab(text: 'Create E-way Bill'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildEwayBillListTab(provider),
                    _buildCreateEwayBillTab(provider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEwayBillListTab(EwayBillProvider provider) {
    final bills = provider.ewayBills;

    if (bills.isEmpty) {
      return Center(
        child: Text(
          'No E-way Bills found. Create your first one!',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: bills.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final bill = bills[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bill No: ${bill.billNumber}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Document: ${bill.documentType}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('From GSTIN: ${bill.fromGstin}'),
                Text('To GSTIN: ${bill.toGstin}'),
                const SizedBox(height: 8),
                Text('Vehicle: ${bill.vehicleNumber}'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('Valid: ${DateFormat('dd/MM/yyyy').format(bill.validFrom)}'),
                    Text(' to ${DateFormat('dd/MM/yyyy').format(bill.validUntil)}'),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Total Items: ${bill.items.length}'),
                Text('Total Value: ₹${bill.totalValue.toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      onPressed: () => _editEwayBill(bill),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                      onPressed: () => _deleteEwayBill(bill.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCreateEwayBillTab(EwayBillProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isCreating ? 'Create New E-way Bill' : 'Edit E-way Bill',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // From GSTIN
            TextFormField(
              controller: _fromGstinController,
              decoration: InputDecoration(
                labelText: 'From GSTIN',
                hintText: 'Enter sender GSTIN',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the GSTIN';
                }
                if (value.length != 15) {
                  return 'GSTIN must be 15 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // To GSTIN
            TextFormField(
              controller: _toGstinController,
              decoration: InputDecoration(
                labelText: 'To GSTIN',
                hintText: 'Enter recipient GSTIN',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the GSTIN';
                }
                if (value.length != 15) {
                  return 'GSTIN must be 15 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Transporter ID
            TextFormField(
              controller: _transporterIdController,
              decoration: InputDecoration(
                labelText: 'Transporter ID',
                hintText: 'Enter transporter ID',
              ),
            ),
            const SizedBox(height: 16),

            // Vehicle Number
            TextFormField(
              controller: _vehicleNumberController,
              decoration: InputDecoration(
                labelText: 'Vehicle Number',
                hintText: 'Enter vehicle registration number',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the vehicle number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Valid From Date
            Row(
              children: [
                Expanded(
                  child: Text('Valid From: ${DateFormat('dd/MM/yyyy').format(_validFrom)}'),
                ),
                TextButton(
                  onPressed: () => _selectDate(context, true),
                  child: Text('Select Date'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Valid Until Date
            Row(
              children: [
                Expanded(
                  child: Text('Valid Until: ${DateFormat('dd/MM/yyyy').format(_validUntil)}'),
                ),
                TextButton(
                  onPressed: () => _selectDate(context, false),
                  child: Text('Select Date'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Document Type
            DropdownButtonFormField<String>(
              value: _selectedDocumentType,
              items: provider.documentTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDocumentType = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Document Type',
              ),
            ),
            const SizedBox(height: 16),

            // Document Number
            TextFormField(
              controller: _documentNumberController,
              decoration: InputDecoration(
                labelText: 'Document Number',
                hintText: 'Enter invoice/document number',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the document number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Items Section
            Text(
              'Items in E-way Bill',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Add item button
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
              onPressed: () => _showAddItemDialog(provider),
            ),
            const SizedBox(height: 16),

            // Items list
            _items.isEmpty
                ? Text('No items added yet')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(item.productName),
                          subtitle: Text(
                            'Qty: ${item.quantity} ${item.unit} | HSN/SAC: ${item.taxableAmount} | Tax: ${item.taxRate}%',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _items.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),

            const SizedBox(height: 24),

            // Submit button
            Center(
              child: ElevatedButton(
                onPressed: _items.isEmpty
                    ? null
                    : () => _submitEwayBill(provider),
                child: Text(_isCreating ? 'Create E-way Bill' : 'Update E-way Bill'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final initialDate = isFromDate ? _validFrom : _validUntil;
    final firstDate = isFromDate ? DateTime.now() : _validFrom;
    final lastDate = isFromDate
        ? DateTime.now().add(const Duration(days: 30))
        : _validFrom.add(const Duration(days: 30));

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selectedDate != null) {
      setState(() {
        if (isFromDate) {
          _validFrom = selectedDate;
          if (_validUntil.isBefore(selectedDate)) {
            _validUntil = selectedDate.add(const Duration(days: 1));
          }
        } else {
          _validUntil = selectedDate;
        }
      });
    }
  }

  void _showAddItemDialog(EwayBillProvider provider) {
    final _productNameController = TextEditingController();
    final _quantityController = TextEditingController();
    final _unitController = TextEditingController(text: 'PCS');
    final _taxableAmountController = TextEditingController();
    final _taxRateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        double cgstAmount = 0;
        double sgstAmount = 0;
        double igstAmount = 0;

        return StatefulBuilder(
          builder: (context, setState) {
            // Calculate tax amounts when tax rate or taxable amount changes
            void calculateTax() {
              final taxableAmount = double.tryParse(_taxableAmountController.text) ?? 0;
              final taxRate = double.tryParse(_taxRateController.text) ?? 0;

              // For simplicity, assuming IGST for inter-state and CGST+SGST for intra-state
              if (_fromGstinController.text.substring(0, 2) == _toGstinController.text.substring(0, 2)) {
                // Same state - CGST & SGST
                cgstAmount = taxableAmount * (taxRate / 2) / 100;
                sgstAmount = taxableAmount * (taxRate / 2) / 100;
                igstAmount = 0;
              } else {
                // Different state - IGST
                cgstAmount = 0;
                sgstAmount = 0;
                igstAmount = taxableAmount * taxRate / 100;
              }

              setState(() {});
            }

            return AlertDialog(
              title: Text('Add Item'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _productNameController,
                      decoration: InputDecoration(
                        labelText: 'Product Name',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _quantityController,
                            decoration: InputDecoration(
                              labelText: 'Quantity',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: _unitController,
                            decoration: InputDecoration(
                              labelText: 'Unit',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _taxableAmountController,
                      decoration: InputDecoration(
                        labelText: 'Taxable Amount',
                        prefixText: '₹',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => calculateTax(),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _taxRateController,
                      decoration: InputDecoration(
                        labelText: 'Tax Rate (%)',
                        suffixText: '%',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => calculateTax(),
                    ),
                    const SizedBox(height: 16),
                    Text('Tax Amounts:'),
                    Text('CGST: ₹${cgstAmount.toStringAsFixed(2)}'),
                    Text('SGST: ₹${sgstAmount.toStringAsFixed(2)}'),
                    Text('IGST: ₹${igstAmount.toStringAsFixed(2)}'),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Validate fields
                    if (_productNameController.text.isEmpty ||
                        _quantityController.text.isEmpty ||
                        _unitController.text.isEmpty ||
                        _taxableAmountController.text.isEmpty ||
                        _taxRateController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill in all fields')),
                      );
                      return;
                    }

                    // Create a new item
                    final item = provider.createEwayBillItem(
                      productName: _productNameController.text,
                      quantity: double.parse(_quantityController.text),
                      unit: _unitController.text,
                      taxableAmount: double.parse(_taxableAmountController.text),
                      taxRate: double.parse(_taxRateController.text),
                      cgstAmount: cgstAmount,
                      sgstAmount: sgstAmount,
                      igstAmount: igstAmount,
                    );

                    // Add to the list
                    setState(() {
                      _items.add(item);
                    });

                    Navigator.pop(context);
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitEwayBill(EwayBillProvider provider) async {
    if (_formKey.currentState!.validate()) {
      // Calculate total amounts
      double totalValue = 0;
      double totalCgst = 0;
      double totalSgst = 0;
      double totalIgst = 0;

      for (var item in _items) {
        totalValue += item.taxableAmount;
        totalCgst += item.cgstAmount;
        totalSgst += item.sgstAmount;
        totalIgst += item.igstAmount;
      }

      try {
        if (_isCreating) {
          // Create new eway bill
          await provider.createEwayBill(
            fromGstin: _fromGstinController.text,
            toGstin: _toGstinController.text,
            transporterId: _transporterIdController.text,
            vehicleNumber: _vehicleNumberController.text,
            validFrom: _validFrom,
            validUntil: _validUntil,
            totalValue: totalValue,
            cgstAmount: totalCgst,
            sgstAmount: totalSgst,
            igstAmount: totalIgst,
            documentType: _selectedDocumentType,
            documentNumber: _documentNumberController.text,
            items: _items,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('E-way Bill created successfully')),
          );
        } else {
          // Update existing eway bill
          await provider.updateEwayBill(
            id: _currentBillId!,
            fromGstin: _fromGstinController.text,
            toGstin: _toGstinController.text,
            transporterId: _transporterIdController.text,
            vehicleNumber: _vehicleNumberController.text,
            validFrom: _validFrom,
            validUntil: _validUntil,
            totalValue: totalValue,
            cgstAmount: totalCgst,
            sgstAmount: totalSgst,
            igstAmount: totalIgst,
            documentType: _selectedDocumentType,
            documentNumber: _documentNumberController.text,
            items: _items,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('E-way Bill updated successfully')),
          );
        }

        // Reset form and switch to the list tab
        _resetForm();
        _tabController.animateTo(0);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _editEwayBill(EwayBill bill) {
    setState(() {
      _isCreating = false;
      _currentBillId = bill.id;

      _fromGstinController.text = bill.fromGstin;
      _toGstinController.text = bill.toGstin;
      _transporterIdController.text = bill.transporterId;
      _vehicleNumberController.text = bill.vehicleNumber;
      _validFrom = bill.validFrom;
      _validUntil = bill.validUntil;
      _selectedDocumentType = bill.documentType;
      _documentNumberController.text = bill.documentNumber;
      _items = List.from(bill.items);

      _tabController.animateTo(1);
    });
  }

  Future<void> _deleteEwayBill(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this E-way Bill?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final provider = Provider.of<EwayBillProvider>(context, listen: false);
      await provider.deleteEwayBill(id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('E-way Bill deleted successfully')),
      );
    }
  }

  void _resetForm() {
    setState(() {
      _isCreating = true;
      _currentBillId = null;

      _fromGstinController.clear();
      _toGstinController.clear();
      _transporterIdController.clear();
      _vehicleNumberController.clear();
      _validFrom = DateTime.now();
      _validUntil = DateTime.now().add(const Duration(days: 1));
      _selectedDocumentType = 'Invoice';
      _documentNumberController.clear();
      _items = [];

      // Initialize with default GSTIN if available
      final gstProvider = Provider.of<IndianGSTProvider>(context, listen: false);
      if (gstProvider.gstin.isNotEmpty) {
        _fromGstinController.text = gstProvider.gstin;
      }
    });
  }
}
