import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/branding_model.dart';
import '../providers/indian_gst_provider.dart';
import '../providers/tax_provider.dart';
import '../providers/branding_provider.dart';
import '../models/indian_invoice_model.dart';
import '../widgets/sidebar.dart';
import '../widgets/header.dart';
import '../constants/app_colors.dart';

class IndianGSTSettingsScreen extends StatefulWidget {
  const IndianGSTSettingsScreen({Key? key}) : super(key: key);

  @override
  State<IndianGSTSettingsScreen> createState() => _IndianGSTSettingsScreenState();
}

class _IndianGSTSettingsScreenState extends State<IndianGSTSettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _gstinController = TextEditingController();
  String? _selectedHSNCode;
  final _hsnDescriptionController = TextEditingController();
  final _hsnRateController = TextEditingController();
  bool _isInterState = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _gstinController.dispose();
    _hsnDescriptionController.dispose();
    _hsnRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final indianGSTProvider = Provider.of<IndianGSTProvider>(context);
    final taxProvider = Provider.of<TaxProvider>(context);
    final brandingProvider = Provider.of<BrandingProvider>(context);
    final brandingSettings = brandingProvider.brandingSettings;
    final brandColors = brandingSettings.colors;

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar
          Sidebar(currentRoute: '/indian_gst_settings'),

          // Main content
          Expanded(
            child: Column(
              children: [
                // Header
                const Header(),

                // Settings content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Indian GST Settings',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(int.parse(brandColors.primary.value.toRadixString(16), radix: 16)),
                          ),
                        ),
                      ),

                      // Tabs
                      Container(
                        color: Colors.white,
                        child: TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'Business GSTIN'),
                            Tab(text: 'HSN/SAC Codes'),
                            Tab(text: 'Invoice Templates'),
                          ],
                          labelColor: Color(int.parse(brandColors.primary.value.toRadixString(16), radix: 16)),
                          unselectedLabelColor: AppColors.textGray,
                          indicatorColor: Color(int.parse(brandColors.primary.value.toRadixString(16), radix: 16)),
                        ),
                      ),

                      // Tab content
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // GSTIN tab
                            _buildGSTINTab(indianGSTProvider, brandColors),

                            // HSN/SAC Codes tab
                            _buildHSNTab(indianGSTProvider, brandColors),

                            // Invoice Templates tab
                            _buildTemplateTab(brandingProvider, taxProvider, brandColors),
                          ],
                        ),
                      ),
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

  Widget _buildGSTINTab(IndianGSTProvider indianGSTProvider, BrandColors brandColors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Business GSTIN Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(int.parse(brandColors.primary.value.toRadixString(16), radix: 16)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _gstinController,
                      decoration: const InputDecoration(
                        labelText: 'Company GSTIN',
                        hintText: 'Enter your 15-digit GSTIN',
                        helperText: 'Format: 22AAAAA0000A1Z5',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your GSTIN';
                        }
                        if (!indianGSTProvider.validateGSTIN(value)) {
                          return 'Please enter a valid GSTIN';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Checkbox(
                          value: _isInterState,
                          onChanged: (value) {
                            setState(() {
                              _isInterState = value ?? false;
                            });
                          },
                          activeColor: Color(int.parse(brandColors.primary.value.toRadixString(16), radix: 16)),
                        ),
                        const Text('Default to interstate transactions (IGST)'),
                      ],
                    ),

                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Save GSTIN
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('GSTIN information saved')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(int.parse(brandColors.primary.value.toRadixString(16), radix: 16)),
                      ),
                      child: const Text('Save GSTIN Information'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GSTIN Verification',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(int.parse(brandColors.primary.value.toRadixString(16), radix: 16)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'This feature allows you to verify a GSTIN with the GST portal to ensure it is valid and retrieve business details.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Verify GSTIN',
                      hintText: 'Enter GSTIN to verify',
                    ),
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () {
                      // In a real app, this would connect to the GST verification API
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('GSTIN verification feature coming soon')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(int.parse(brandColors.secondary.value.toRadixString(16), radix: 16)),
                    ),
                    child: const Text('Verify GSTIN'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHSNTab(IndianGSTProvider indianGSTProvider, BrandColors brandColors) {
    final hsnCodes = indianGSTProvider.hsnCodes;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add/Edit HSN Code',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(int.parse(brandColors.primary.value.toRadixString(16), radix: 16)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'HSN/SAC Code',
                        hintText: 'Enter the code (e.g., 8471)',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedHSNCode = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _hsnDescriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter description',
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _hsnRateController,
                      decoration: const InputDecoration(
                        labelText: 'GST Rate (%)',
                        hintText: 'e.g., 18',
                      ),
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: () {
                        if (_selectedHSNCode != null &&
                            _selectedHSNCode!.isNotEmpty &&
                            _hsnDescriptionController.text.isNotEmpty &&
                            _hsnRateController.text.isNotEmpty) {

                          final double? rate = double.tryParse(_hsnRateController.text);
                          if (rate != null) {
                            indianGSTProvider.addHSNCode(
                              HSNCode(
                                code: _selectedHSNCode!,
                                description: _hsnDescriptionController.text,
                                gstRate: rate,
                              ),
                            );

                            // Clear the fields
                            setState(() {
                              _selectedHSNCode = null;
                              _hsnDescriptionController.clear();
                              _hsnRateController.clear();
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('HSN code added/updated')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(int.parse(brandColors.primary.value.toRadixString(16), radix: 16)),
                      ),
                      child: const Text('Save HSN/SAC Code'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available HSN/SAC Codes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(int.parse(brandColors.primary.value.toRadixString(16), radix: 16)),
                        ),
                      ),

                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          // Implement search functionality
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(3),
                        2: FlexColumnWidth(1),
                      },
                      border: TableBorder.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: Color(int.parse(brandColors.primary.value.toRadixString(16), radix: 16)),
                          ),
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Code',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Description',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Rate (%)',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        ...hsnCodes.map((code) => TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(code.code),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(code.description),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(code.gstRate.toString()),
                            ),
                          ],
                        )).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateTab(BrandingProvider brandingProvider, TaxProvider taxProvider, BrandColors brandColors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Indian GST Invoice Theme',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(int.parse(brandColors.primary.value.toRadixString(16), radix: 16)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Apply the Indian GST-compliant invoice theme with colors inspired by the Indian flag.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () {
                      brandingProvider.applyIndianTheme();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Indian theme applied successfully')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(int.parse(brandColors.primary.value.toRadixString(16), radix: 16)),
                    ),
                    child: const Text('Apply Indian Theme'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GST Invoice Configuration',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(int.parse(brandColors.primary.value.toRadixString(16), radix: 16)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  CheckboxListTile(
                    title: const Text('Show HSN/SAC codes in invoices'),
                    value: true,
                    onChanged: (value) {},
                    activeColor: Color(int.parse(brandColors.primary.value.toRadixString(16), radix: 16)),
                  ),

                  CheckboxListTile(
                    title: const Text('Show GST breakdown (CGST/SGST/IGST)'),
                    value: true,
                    onChanged: (value) {},
                    activeColor: Color(int.parse(brandColors.primary.value.toRadixString(16), radix: 16)),
                  ),

                  CheckboxListTile(
                    title: const Text('Include amount in words (Indian format)'),
                    value: true,
                    onChanged: (value) {},
                    activeColor: Color(int.parse(brandColors.primary.value.toRadixString(16), radix: 16)),
                  ),

                  CheckboxListTile(
                    title: const Text('Show declaration statement'),
                    value: true,
                    onChanged: (value) {},
                    activeColor: Color(int.parse(brandColors.primary.value.toRadixString(16), radix: 16)),
                  ),

                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('GST invoice settings saved')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(int.parse(brandColors.primary.value.toRadixString(16), radix: 16)),
                    ),
                    child: const Text('Save Invoice Settings'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
