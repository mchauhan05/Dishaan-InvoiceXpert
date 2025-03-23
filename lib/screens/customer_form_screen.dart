import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/customer_model.dart';
import '../providers/customer_provider.dart';
import '../routes/app_router.dart';
import '../widgets/header.dart';
import '../widgets/sidebar.dart';

class CustomerFormScreen extends StatefulWidget {
  final bool isEditing;
  final String? customerId;

  const CustomerFormScreen({
    Key? key,
    required this.isEditing,
    this.customerId,
  }) : super(key: key);

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _displayNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();

  // Billing address controllers
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _countryController = TextEditingController();

  // Contact controllers
  final _contactFirstNameController = TextEditingController();
  final _contactLastNameController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactJobTitleController = TextEditingController();

  // Additional fields
  final _taxNumberController = TextEditingController();
  final _notesController = TextEditingController();

  CustomerStatus _status = CustomerStatus.active;
  bool _useShippingAddress = false;

  @override
  void initState() {
    super.initState();

    // Initialize customer data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerProvider = Provider.of<CustomerProvider>(context, listen: false);

      if (widget.isEditing && widget.customerId != null) {
        // Load existing customer
        customerProvider.loadCustomerForEditing(widget.customerId!);
      } else {
        // Initialize new customer
        customerProvider.initNewCustomer();
      }

      // Populate form fields
      _populateFormFields(customerProvider);
    });
  }

  @override
  void dispose() {
    // Dispose all controllers
    _displayNameController.dispose();
    _companyNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();

    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();

    _contactFirstNameController.dispose();
    _contactLastNameController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _contactJobTitleController.dispose();

    _taxNumberController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  void _populateFormFields(CustomerProvider provider) {
    final customer = provider.currentCustomer;
    if (customer == null) return;

    // Basic info
    _displayNameController.text = customer.displayName;
    _companyNameController.text = customer.companyName;
    _emailController.text = customer.email;
    _phoneController.text = customer.phone;
    _websiteController.text = customer.website;

    // Billing address
    _streetController.text = customer.billingAddress.street;
    _cityController.text = customer.billingAddress.city;
    _stateController.text = customer.billingAddress.state;
    _zipCodeController.text = customer.billingAddress.zipCode;
    _countryController.text = customer.billingAddress.country;

    // Primary contact
    final primaryContact = customer.primaryContact;
    if (primaryContact != null) {
      _contactFirstNameController.text = primaryContact.firstName;
      _contactLastNameController.text = primaryContact.lastName;
      _contactEmailController.text = primaryContact.email;
      _contactPhoneController.text = primaryContact.phone;
      _contactJobTitleController.text = primaryContact.jobTitle ?? '';
    }

    // Additional fields
    _taxNumberController.text = customer.taxNumber ?? '';
    _notesController.text = customer.notes ?? '';

    // Status
    _status = customer.status;

    // Shipping address
    _useShippingAddress = customer.shippingAddress != null;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final customerProvider = Provider.of<CustomerProvider>(context);
    final customer = customerProvider.currentCustomer;

    if (customer == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
                            widget.isEditing ? 'Edit Customer' : 'Add New Customer',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Customer form container
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
                                // Customer Information
                                Text(
                                  'Customer Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Display Name
                                TextFormField(
                                  controller: _displayNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Display Name *',
                                    hintText: 'Enter customer display name',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a display name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Company Name
                                TextFormField(
                                  controller: _companyNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Company Name *',
                                    hintText: 'Enter company name',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a company name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Email & Phone in same row
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Email
                                    Expanded(
                                      child: TextFormField(
                                        controller: _emailController,
                                        decoration: const InputDecoration(
                                          labelText: 'Email Address *',
                                          hintText: 'Enter email address',
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter an email';
                                          }
                                          if (!value.contains('@') || !value.contains('.')) {
                                            return 'Please enter a valid email';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Phone
                                    Expanded(
                                      child: TextFormField(
                                        controller: _phoneController,
                                        decoration: const InputDecoration(
                                          labelText: 'Phone Number *',
                                          hintText: 'Enter phone number',
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a phone number';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Website
                                TextFormField(
                                  controller: _websiteController,
                                  decoration: const InputDecoration(
                                    labelText: 'Website',
                                    hintText: 'Enter website URL',
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Address Section
                                Text(
                                  'Billing Address',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Street
                                TextFormField(
                                  controller: _streetController,
                                  decoration: const InputDecoration(
                                    labelText: 'Street Address *',
                                    hintText: 'Enter street address',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a street address';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // City & State
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // City
                                    Expanded(
                                      child: TextFormField(
                                        controller: _cityController,
                                        decoration: const InputDecoration(
                                          labelText: 'City *',
                                          hintText: 'Enter city',
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a city';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // State
                                    Expanded(
                                      child: TextFormField(
                                        controller: _stateController,
                                        decoration: const InputDecoration(
                                          labelText: 'State/Province *',
                                          hintText: 'Enter state/province',
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a state';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Zip & Country
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Zip
                                    Expanded(
                                      child: TextFormField(
                                        controller: _zipCodeController,
                                        decoration: const InputDecoration(
                                          labelText: 'ZIP/Postal Code *',
                                          hintText: 'Enter ZIP/postal code',
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a ZIP code';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Country
                                    Expanded(
                                      child: TextFormField(
                                        controller: _countryController,
                                        decoration: const InputDecoration(
                                          labelText: 'Country *',
                                          hintText: 'Enter country',
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a country';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Shipping address option
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _useShippingAddress,
                                      onChanged: (value) {
                                        setState(() {
                                          _useShippingAddress = value ?? false;
                                        });
                                      },
                                    ),
                                    const Text('Add a different shipping address'),
                                  ],
                                ),

                                // Shipping address fields (conditionally displayed)
                                if (_useShippingAddress) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    'Shipping Address',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Shipping address fields would go here
                                  // (For brevity, not implementing the full shipping address form)
                                  const Text(
                                    'Shipping address fields would go here (not implemented in this example)',
                                    style: TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                ],

                                const SizedBox(height: 24),

                                // Primary Contact Section
                                Text(
                                  'Primary Contact',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // First & Last Name
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // First Name
                                    Expanded(
                                      child: TextFormField(
                                        controller: _contactFirstNameController,
                                        decoration: const InputDecoration(
                                          labelText: 'First Name *',
                                          hintText: 'Enter first name',
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a first name';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Last Name
                                    Expanded(
                                      child: TextFormField(
                                        controller: _contactLastNameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Last Name *',
                                          hintText: 'Enter last name',
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a last name';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Contact Email & Phone
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Email
                                    Expanded(
                                      child: TextFormField(
                                        controller: _contactEmailController,
                                        decoration: const InputDecoration(
                                          labelText: 'Email Address *',
                                          hintText: 'Enter contact email',
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter an email';
                                          }
                                          if (!value.contains('@') || !value.contains('.')) {
                                            return 'Please enter a valid email';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Phone
                                    Expanded(
                                      child: TextFormField(
                                        controller: _contactPhoneController,
                                        decoration: const InputDecoration(
                                          labelText: 'Phone Number *',
                                          hintText: 'Enter contact phone',
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a phone number';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Job Title
                                TextFormField(
                                  controller: _contactJobTitleController,
                                  decoration: const InputDecoration(
                                    labelText: 'Job Title',
                                    hintText: 'Enter job title',
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Additional Info Section
                                Text(
                                  'Additional Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Tax Number
                                TextFormField(
                                  controller: _taxNumberController,
                                  decoration: const InputDecoration(
                                    labelText: 'Tax Number',
                                    hintText: 'Enter tax registration number',
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Status
                                DropdownButtonFormField<CustomerStatus>(
                                  value: _status,
                                  decoration: const InputDecoration(
                                    labelText: 'Status',
                                  ),
                                  items: CustomerStatus.values.map((status) {
                                    String label;
                                    switch (status) {
                                      case CustomerStatus.active:
                                        label = 'Active';
                                        break;
                                      case CustomerStatus.inactive:
                                        label = 'Inactive';
                                        break;
                                      case CustomerStatus.blocked:
                                        label = 'Blocked';
                                        break;
                                      default:
                                        label = 'Unknown';
                                    }

                                    return DropdownMenuItem<CustomerStatus>(
                                      value: status,
                                      child: Text(label),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _status = value;
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Notes
                                TextFormField(
                                  controller: _notesController,
                                  decoration: const InputDecoration(
                                    labelText: 'Notes',
                                    hintText: 'Enter any additional notes',
                                  ),
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Form actions
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
                              // Save button
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _saveCustomer(customerProvider);
                                    Navigator.of(context).pushNamed(AppRouter.customers);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                child: const Text('Save Customer'),
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

  void _saveCustomer(CustomerProvider provider) {
    // Create billing address
    final billingAddress = Address(
      street: _streetController.text,
      city: _cityController.text,
      state: _stateController.text,
      zipCode: _zipCodeController.text,
      country: _countryController.text,
    );

    // Create primary contact
    final primaryContact = Contact(
      firstName: _contactFirstNameController.text,
      lastName: _contactLastNameController.text,
      email: _contactEmailController.text,
      phone: _contactPhoneController.text,
      jobTitle: _contactJobTitleController.text.isNotEmpty ? _contactJobTitleController.text : null,
      isPrimary: true,
    );

    // Save customer
    provider.saveCustomer(
      displayName: _displayNameController.text,
      companyName: _companyNameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      website: _websiteController.text,
      billingAddress: billingAddress,
      shippingAddress: _useShippingAddress ? billingAddress : null, // For simplicity, use billing as shipping
      contacts: [primaryContact],
      taxNumber: _taxNumberController.text.isNotEmpty ? _taxNumberController.text : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      status: _status,
    );
  }
}
