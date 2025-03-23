import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/indian_payment_provider.dart';
import '../utils/translation_extension.dart';
import '../widgets/app_layout.dart';

class IndianPaymentMethodsScreen extends StatefulWidget {
  const IndianPaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  _IndianPaymentMethodsScreenState createState() => _IndianPaymentMethodsScreenState();
}

class _IndianPaymentMethodsScreenState extends State<IndianPaymentMethodsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Form fields
  final _nameController = TextEditingController();
  late String _selectedPaymentType;
  Map<String, dynamic> _paymentDetails = {};
  bool _isEnabled = true;

  bool _isEditing = false;
  String? _currentMethodId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Set default payment type
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<IndianPaymentProvider>(context, listen: false);
      _selectedPaymentType = provider.paymentMethodTypes.first;
      _updateDetailsFields();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _updateDetailsFields() {
    // Reset payment details based on selected type
    setState(() {
      switch (_selectedPaymentType) {
        case 'Bank Transfer':
        case 'NEFT':
        case 'RTGS':
        case 'IMPS':
          _paymentDetails = {
            'accountName': '',
            'accountNumber': '',
            'ifscCode': '',
            'bankName': '',
            'branch': '',
          };
          break;
        case 'UPI':
          _paymentDetails = {
            'upiId': '',
            'qrCode': '',
          };
          break;
        case 'Cheque':
        case 'Demand Draft':
          _paymentDetails = {
            'payableTo': '',
            'instructions': '',
          };
          break;
        case 'Cash':
        default:
          _paymentDetails = {};
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Indian Payment Methods',
      body: Consumer<IndianPaymentProvider>(
        builder: (context, provider, child) {
          // Initialize selectedPaymentType if not set
          if (_selectedPaymentType == null && provider.paymentMethodTypes.isNotEmpty) {
            _selectedPaymentType = provider.paymentMethodTypes.first;
            _updateDetailsFields();
          }

          return Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'Payment Methods'),
                  Tab(text: _isEditing ? 'Edit Method' : 'Add Method'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPaymentMethodsTab(provider),
                    _buildAddEditMethodTab(provider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaymentMethodsTab(IndianPaymentProvider provider) {
    final methods = provider.paymentMethods;

    if (methods.isEmpty) {
      return Center(
        child: Text(
          'No payment methods configured. Add your first one!',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: methods.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final method = methods[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: CircleAvatar(
              child: _getPaymentTypeIcon(method.type),
            ),
            title: Text(method.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(method.type),
                Text(method.isEnabled ? 'Enabled' : 'Disabled',
                  style: TextStyle(
                    color: method.isEnabled ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editPaymentMethod(method),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deletePaymentMethod(method.id),
                ),
              ],
            ),
            onTap: () => _showPaymentMethodDetails(method),
          ),
        );
      },
    );
  }

  Widget _buildAddEditMethodTab(IndianPaymentProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditing ? 'Edit Payment Method' : 'Add Payment Method',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Name field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Payment Method Name',
                hintText: 'Enter a name for this payment method',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Payment Type dropdown
            DropdownButtonFormField<String>(
              value: _selectedPaymentType,
              items: provider.paymentMethodTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPaymentType = value!;
                  _updateDetailsFields();
                });
              },
              decoration: InputDecoration(
                labelText: 'Payment Type',
              ),
            ),
            const SizedBox(height: 16),

            // Enabled switch
            SwitchListTile(
              title: Text('Enabled'),
              subtitle: Text('Allow this payment method to be used'),
              value: _isEnabled,
              onChanged: (value) {
                setState(() {
                  _isEnabled = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // Dynamic Fields based on payment type
            if (_paymentDetails.isNotEmpty) ...[
              Text(
                'Payment Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              ..._buildDynamicFields(),
            ],

            const SizedBox(height: 24),

            // Submit button
            Center(
              child: ElevatedButton(
                onPressed: () => _submitPaymentMethod(provider),
                child: Text(_isEditing ? 'Update Payment Method' : 'Add Payment Method'),
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

  List<Widget> _buildDynamicFields() {
    final fields = <Widget>[];

    _paymentDetails.forEach((key, value) {
      String label = '';
      String hint = '';
      TextInputType keyboardType = TextInputType.text;

      // Set appropriate labels based on field key
      switch (key) {
        case 'accountName':
          label = 'Account Name';
          hint = 'Enter account holder name';
          break;
        case 'accountNumber':
          label = 'Account Number';
          hint = 'Enter account number';
          keyboardType = TextInputType.number;
          break;
        case 'ifscCode':
          label = 'IFSC Code';
          hint = 'Enter IFSC code';
          break;
        case 'bankName':
          label = 'Bank Name';
          hint = 'Enter bank name';
          break;
        case 'branch':
          label = 'Branch';
          hint = 'Enter branch location';
          break;
        case 'upiId':
          label = 'UPI ID';
          hint = 'Enter UPI ID (e.g., name@bank)';
          break;
        case 'qrCode':
          label = 'QR Code Path';
          hint = 'Path to QR code image (optional)';
          break;
        case 'payableTo':
          label = 'Payable To';
          hint = 'Enter payee name';
          break;
        case 'instructions':
          label = 'Instructions';
          hint = 'Enter payment instructions';
          break;
        default:
          label = key.replaceFirst(key[0], key[0].toUpperCase());
          hint = 'Enter $key';
      }

      // Create text field
      fields.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextFormField(
            initialValue: value.toString(),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
            ),
            keyboardType: keyboardType,
            onChanged: (newValue) {
              setState(() {
                _paymentDetails[key] = newValue;
              });
            },
          ),
        ),
      );
    });

    return fields;
  }

  Future<void> _submitPaymentMethod(IndianPaymentProvider provider) async {
    if (_formKey.currentState!.validate()) {
      try {
        if (_isEditing) {
          // Update existing method
          await provider.updatePaymentMethod(
            id: _currentMethodId!,
            name: _nameController.text,
            type: _selectedPaymentType,
            isEnabled: _isEnabled,
            details: _paymentDetails,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment method updated successfully')),
          );
        } else {
          // Add new method
          await provider.addPaymentMethod(
            name: _nameController.text,
            type: _selectedPaymentType,
            isEnabled: _isEnabled,
            details: _paymentDetails,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment method added successfully')),
          );
        }

        // Reset form and switch to list tab
        _resetForm();
        _tabController.animateTo(0);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _editPaymentMethod(IndianPaymentMethod method) {
    setState(() {
      _isEditing = true;
      _currentMethodId = method.id;

      _nameController.text = method.name;
      _selectedPaymentType = method.type;
      _isEnabled = method.isEnabled;
      _paymentDetails = Map.from(method.details);

      _tabController.animateTo(1);
    });
  }

  Future<void> _deletePaymentMethod(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this payment method?'),
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
      final provider = Provider.of<IndianPaymentProvider>(context, listen: false);
      await provider.deletePaymentMethod(id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment method deleted successfully')),
      );
    }
  }

  void _showPaymentMethodDetails(IndianPaymentMethod method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(method.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Type: ${method.type}'),
              Text('Status: ${method.isEnabled ? 'Enabled' : 'Disabled'}'),
              const SizedBox(height: 16),
              Text('Details:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...method.details.entries.map((entry) {
                String key = entry.key.replaceFirst(entry.key[0], entry.key[0].toUpperCase());
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('$key: ${entry.value}'),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _editPaymentMethod(method);
            },
            child: Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _isEditing = false;
      _currentMethodId = null;

      _nameController.clear();
      _isEnabled = true;

      final provider = Provider.of<IndianPaymentProvider>(context, listen: false);
      if (provider.paymentMethodTypes.isNotEmpty) {
        _selectedPaymentType = provider.paymentMethodTypes.first;
        _updateDetailsFields();
      }
    });
  }

  Widget _getPaymentTypeIcon(String type) {
    IconData iconData;

    switch (type) {
      case 'Bank Transfer':
      case 'NEFT':
      case 'RTGS':
      case 'IMPS':
        iconData = Icons.account_balance;
        break;
      case 'UPI':
        iconData = Icons.smartphone;
        break;
      case 'Cash':
        iconData = Icons.money;
        break;
      case 'Cheque':
      case 'Demand Draft':
        iconData = Icons.description;
        break;
      default:
        iconData = Icons.payment;
    }

    return Icon(iconData);
  }
}
