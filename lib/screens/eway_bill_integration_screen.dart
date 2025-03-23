import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/eway_bill_provider.dart';
import '../providers/indian_gst_provider.dart';
import '../utils/translation_extension.dart';
import '../widgets/app_layout.dart';

class EwayBillIntegrationScreen extends StatefulWidget {
  const EwayBillIntegrationScreen({Key? key}) : super(key: key);

  @override
  _EwayBillIntegrationScreenState createState() => _EwayBillIntegrationScreenState();
}

class _EwayBillIntegrationScreenState extends State<EwayBillIntegrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // GST Portal API credentials
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _apiSecretController = TextEditingController();

  bool _isConnected = false;
  bool _isTestMode = true;
  bool _autoUpload = false;
  bool _isLoading = false;

  // Mock API response data
  List<Map<String, dynamic>> _apiLogs = [];

  @override
  void initState() {
    super.initState();

    // Initialize with mock data for demonstration
    _apiLogs = [
      {
        'timestamp': DateTime.now().subtract(Duration(days: 2)),
        'status': 'success',
        'message': 'Successfully generated E-way Bill #EWB123456789',
        'details': 'Generated for Invoice #INV-2025-001',
      },
      {
        'timestamp': DateTime.now().subtract(Duration(days: 3)),
        'status': 'error',
        'message': 'Failed to generate E-way Bill',
        'details': 'Invalid GSTIN format for recipient',
      },
      {
        'timestamp': DateTime.now().subtract(Duration(days: 5)),
        'status': 'success',
        'message': 'Successfully updated E-way Bill #EWB123456123',
        'details': 'Vehicle number updated from KA01MJ8989 to KA01MJ9090',
      },
    ];
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _apiKeyController.dispose();
    _apiSecretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'E-way Bill Portal Integration',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConnectionStatusCard(),
            const SizedBox(height: 24),
            _buildConfigurationSection(),
            const SizedBox(height: 24),
            _buildApiLogsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _isConnected ? Colors.green.shade100 : Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isConnected ? Icons.link : Icons.link_off,
                size: 32,
                color: _isConnected ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isConnected ? 'Connected to GST Portal' : 'Not Connected to GST Portal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _isConnected ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isConnected
                        ? 'Your E-way Bills will be automatically synced with the GST Portal.'
                        : 'Configure your GST Portal API credentials to enable integration.',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            if (_isConnected)
              ElevatedButton.icon(
                onPressed: _disconnectFromPortal,
                icon: const Icon(Icons.logout),
                label: const Text('Disconnect'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () => _showConnectionDialog(),
                icon: const Icon(Icons.login),
                label: const Text('Connect'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigurationSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Integration Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<IndianGSTProvider>(
              builder: (context, gstProvider, child) {
                return Column(
                  children: [
                    ListTile(
                      title: Text('GSTIN'),
                      subtitle: Text(gstProvider.gstin.isNotEmpty
                          ? gstProvider.gstin
                          : 'No GSTIN configured'),
                      trailing: TextButton(
                        onPressed: () {
                          // Navigate to GST settings
                          Navigator.pushNamed(context, '/indian_gst_settings');
                        },
                        child: Text('Configure'),
                      ),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: Text('Test Mode'),
                      subtitle: Text(
                        'When enabled, E-way Bills will be generated in test environment',
                      ),
                      value: _isTestMode,
                      onChanged: _isConnected ? (value) {
                        setState(() {
                          _isTestMode = value;
                        });
                      } : null,
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: Text('Auto Upload'),
                      subtitle: Text(
                        'Automatically upload E-way Bills to GST Portal when created',
                      ),
                      value: _autoUpload,
                      onChanged: _isConnected ? (value) {
                        setState(() {
                          _autoUpload = value;
                        });
                      } : null,
                    ),
                    const Divider(),
                    ListTile(
                      title: Text('Bulk Upload E-way Bills'),
                      subtitle: Text(
                        'Upload multiple E-way Bills to the GST Portal at once',
                      ),
                      trailing: ElevatedButton(
                        onPressed: _isConnected ? () => _showBulkUploadDialog() : null,
                        child: Text('Bulk Upload'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiLogsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'API Integration Logs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _apiLogs.clear();
                    });
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('Clear Logs'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_apiLogs.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('No API logs available.'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _apiLogs.length,
                itemBuilder: (context, index) {
                  final log = _apiLogs[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: log['status'] == 'success'
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    child: ListTile(
                      leading: Icon(
                        log['status'] == 'success' ? Icons.check_circle : Icons.error,
                        color: log['status'] == 'success' ? Colors.green : Colors.red,
                      ),
                      title: Text(log['message']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Details: ${log['details']}'),
                          Text(
                            'Time: ${DateFormat('dd/MM/yyyy HH:mm').format(log['timestamp'])}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.info),
                        onPressed: () => _showLogDetails(log),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showConnectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Connect to GST Portal'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enter your GST Portal API credentials to enable E-way Bill integration.',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: 'Enter GST Portal username',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter GST Portal password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _apiKeyController,
                  decoration: InputDecoration(
                    labelText: 'API Key',
                    hintText: 'Enter API Key',
                    prefixIcon: Icon(Icons.key),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter API Key';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _apiSecretController,
                  decoration: InputDecoration(
                    labelText: 'API Secret',
                    hintText: 'Enter API Secret',
                    prefixIcon: Icon(Icons.security),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter API Secret';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context);
                _connectToPortal();
              }
            },
            child: Text('Connect'),
          ),
        ],
      ),
    );
  }

  void _showBulkUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Bulk Upload E-way Bills'),
            content: Consumer<EwayBillProvider>(
              builder: (context, provider, child) {
                final pendingBills = provider.ewayBills
                    .where((bill) => bill.billNumber.startsWith('EWB'))
                    .toList();

                return SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select E-way Bills to upload to GST Portal',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 16),
                      pendingBills.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text('No E-way Bills available for upload.'),
                            )
                          : SizedBox(
                              height: 300,
                              child: ListView.builder(
                                itemCount: pendingBills.length,
                                itemBuilder: (context, index) {
                                  final bill = pendingBills[index];
                                  return CheckboxListTile(
                                    title: Text(bill.billNumber),
                                    subtitle: Text(
                                      '${bill.documentType}: ${bill.documentNumber} (${DateFormat('dd/MM/yyyy').format(bill.validFrom)})',
                                    ),
                                    value: true, // For demo, all are selected
                                    onChanged: (value) {
                                      // In a real app, this would handle selection
                                    },
                                  );
                                },
                              ),
                            ),
                      if (_isLoading)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: LinearProgressIndicator(),
                        ),
                    ],
                  ),
                );
              }
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        setState(() {
                          _isLoading = true;
                        });

                        // Simulate API call
                        Future.delayed(const Duration(seconds: 2), () {
                          setState(() {
                            _isLoading = false;
                          });

                          Navigator.pop(context);

                          // Add success log entry
                          _addApiLog(
                            status: 'success',
                            message: 'Successfully uploaded 3 E-way Bills to GST Portal',
                            details: 'Uploaded bill numbers: EWB123456789, EWB123456123, EWB123456456',
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('E-way Bills uploaded successfully')),
                          );
                        });
                      },
                child: Text('Upload'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLogDetails(Map<String, dynamic> log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(log['status'] == 'success' ? 'Success Log' : 'Error Log'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${log['status']}'),
            const SizedBox(height: 8),
            Text('Message: ${log['message']}'),
            const SizedBox(height: 8),
            Text('Details: ${log['details']}'),
            const SizedBox(height: 8),
            Text(
              'Timestamp: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(log['timestamp'])}',
            ),
            const SizedBox(height: 16),
            if (log['status'] == 'error')
              Text(
                'Resolution: Please check your GST portal credentials and try again. Ensure that the GSTIN format is correct and the invoice details are valid.',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _connectToPortal() {
    setState(() {
      _isLoading = true;
    });

    // Simulate API connection
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _isConnected = true;
      });

      // Add success log entry
      _addApiLog(
        status: 'success',
        message: 'Successfully connected to GST Portal',
        details: 'Connection established with username: ${_usernameController.text}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connected to GST Portal successfully')),
      );
    });
  }

  void _disconnectFromPortal() {
    setState(() {
      _isConnected = false;
      _autoUpload = false;
    });

    // Add log entry
    _addApiLog(
      status: 'success',
      message: 'Disconnected from GST Portal',
      details: 'User initiated disconnect',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Disconnected from GST Portal')),
    );
  }

  void _addApiLog({
    required String status,
    required String message,
    required String details,
  }) {
    setState(() {
      _apiLogs.insert(0, {
        'timestamp': DateTime.now(),
        'status': status,
        'message': message,
        'details': details,
      });
    });
  }
}
