import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/upi_payment_model.dart';
import '../providers/upi_payment_provider.dart';
import '../utils/translation_extension.dart';
import '../widgets/app_layout.dart';

class UpiSettingsScreen extends StatefulWidget {
  const UpiSettingsScreen({Key? key}) : super(key: key);

  @override
  _UpiSettingsScreenState createState() => _UpiSettingsScreenState();
}

class _UpiSettingsScreenState extends State<UpiSettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize UPI provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final upiProvider = Provider.of<UpiPaymentProvider>(context, listen: false);
      if (upiProvider.upiAccounts.isEmpty) {
        upiProvider.initialize();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: context.tr('upi_payment_settings'),
      body: Consumer<UpiPaymentProvider>(
        builder: (context, upiProvider, _) {
          if (upiProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tab bar
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: context.tr('upi_accounts')),
                    Tab(text: context.tr('payment_history')),
                  ],
                ),
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUpiAccountsTab(upiProvider),
                    _buildPaymentHistoryTab(upiProvider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUpiAccountsTab(UpiPaymentProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('upi_payments_info'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('upi_payments_description'),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          // UPI Accounts
          Card(
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
                        context.tr('your_upi_accounts'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: Text(context.tr('add_account')),
                        onPressed: () {
                          _showAddUpiAccountDialog(context, provider);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // List of UPI accounts
                  if (provider.upiAccounts.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              context.tr('no_upi_accounts'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.upiAccounts.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final account = provider.upiAccounts[index];
                        final isPrimary = account.primary;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isPrimary ? Theme.of(context).primaryColor : Colors.grey.shade200,
                            child: const Icon(Icons.account_balance_wallet),
                          ),
                          title: Text(account.upiId),
                          subtitle: Text(account.payeeName),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isPrimary)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    context.tr('primary'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                tooltip: context.tr('copy_upi_id'),
                                onPressed: () async {
                                  final success = await provider.copyUpiIdToClipboard(account.upiId);
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(context.tr('upi_id_copied'))),
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () {
                                  _showUpiAccountOptions(context, provider, account);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),

          // Popular UPI Apps
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('popular_upi_apps'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: UPIApps.popularApps.map((app) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            child: Icon(app.icon),
                          ),
                          const SizedBox(height: 8),
                          Text(app.name),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryTab(UpiPaymentProvider provider) {
    final recentPayments = provider.recentPayments;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('recent_payments'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // List of recent payments
                  if (recentPayments.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.payment_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              context.tr('no_payment_history'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentPayments.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final payment = recentPayments[index];

                        // Determine status color
                        Color statusColor;
                        IconData statusIcon;

                        if (payment.isSuccessful) {
                          statusColor = Colors.green;
                          statusIcon = Icons.check_circle;
                        } else if (payment.isPending) {
                          statusColor = Colors.orange;
                          statusIcon = Icons.access_time;
                        } else {
                          statusColor = Colors.red;
                          statusIcon = Icons.cancel;
                        }

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: statusColor.withOpacity(0.1),
                            child: Icon(statusIcon, color: statusColor),
                          ),
                          title: Text(payment.referenceId),
                          subtitle: Text(
                            '${context.formatCurrency(payment.amount)} • ${payment.timestamp.day}/${payment.timestamp.month}/${payment.timestamp.year}',
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              payment.status,
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          onTap: () {
                            _showPaymentDetails(context, payment);
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog to add a new UPI account
  void _showAddUpiAccountDialog(BuildContext context, UpiPaymentProvider provider) {
    final formKey = GlobalKey<FormState>();
    String upiId = '';
    String payeeName = '';
    String? merchantCode;
    bool isPrimary = provider.upiAccounts.isEmpty; // First account is primary by default

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('add_upi_account')),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: context.tr('upi_id'),
                    hintText: 'name@upi',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr('upi_id_required');
                    }
                    if (!value.contains('@')) {
                      return context.tr('invalid_upi_id');
                    }
                    return null;
                  },
                  onSaved: (value) {
                    upiId = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: context.tr('payee_name'),
                    hintText: context.tr('your_name_or_business'),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr('payee_name_required');
                    }
                    return null;
                  },
                  onSaved: (value) {
                    payeeName = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: context.tr('merchant_code'),
                    hintText: context.tr('optional'),
                  ),
                  onSaved: (value) {
                    merchantCode = value!.isEmpty ? null : value;
                  },
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: Text(context.tr('set_as_primary')),
                  subtitle: Text(context.tr('primary_account_description')),
                  value: isPrimary,
                  onChanged: (value) {
                    setState(() {
                      isPrimary = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                provider.addUpiAccount(UPIDetails(
                  upiId: upiId,
                  payeeName: payeeName,
                  merchantCode: merchantCode,
                  primary: isPrimary,
                ));
                Navigator.of(context).pop();
              }
            },
            child: Text(context.tr('add')),
          ),
        ],
      ),
    );
  }

  // Show options for a UPI account
  void _showUpiAccountOptions(BuildContext context, UpiPaymentProvider provider, UPIDetails account) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: Text(context.tr('edit')),
            onTap: () {
              Navigator.of(context).pop();
              _showEditUpiAccountDialog(context, provider, account);
            },
          ),
          if (!account.primary)
            ListTile(
              leading: const Icon(Icons.star),
              title: Text(context.tr('set_as_primary')),
              onTap: () {
                provider.setPrimaryUpiAccount(account.upiId);
                Navigator.of(context).pop();
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: Text(
              context.tr('delete'),
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.of(context).pop();
              _showDeleteConfirmation(context, provider, account);
            },
          ),
        ],
      ),
    );
  }

  // Dialog to edit a UPI account
  void _showEditUpiAccountDialog(BuildContext context, UpiPaymentProvider provider, UPIDetails account) {
    final formKey = GlobalKey<FormState>();
    String upiId = account.upiId;
    String payeeName = account.payeeName;
    String? merchantCode = account.merchantCode;
    bool isPrimary = account.primary;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('edit_upi_account')),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: upiId,
                  decoration: InputDecoration(
                    labelText: context.tr('upi_id'),
                    hintText: 'name@upi',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr('upi_id_required');
                    }
                    if (!value.contains('@')) {
                      return context.tr('invalid_upi_id');
                    }
                    return null;
                  },
                  onSaved: (value) {
                    upiId = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: payeeName,
                  decoration: InputDecoration(
                    labelText: context.tr('payee_name'),
                    hintText: context.tr('your_name_or_business'),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr('payee_name_required');
                    }
                    return null;
                  },
                  onSaved: (value) {
                    payeeName = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: merchantCode,
                  decoration: InputDecoration(
                    labelText: context.tr('merchant_code'),
                    hintText: context.tr('optional'),
                  ),
                  onSaved: (value) {
                    merchantCode = value!.isEmpty ? null : value;
                  },
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: Text(context.tr('set_as_primary')),
                  subtitle: Text(context.tr('primary_account_description')),
                  value: isPrimary,
                  onChanged: (value) {
                    setState(() {
                      isPrimary = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                provider.updateUpiAccount(
                  account.upiId,
                  UPIDetails(
                    upiId: upiId,
                    payeeName: payeeName,
                    merchantCode: merchantCode,
                    primary: isPrimary,
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );
  }

  // Confirmation dialog for deleting a UPI account
  void _showDeleteConfirmation(BuildContext context, UpiPaymentProvider provider, UPIDetails account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('confirm_delete')),
        content: Text(
          context.tr('delete_upi_account_confirmation', args: [account.upiId]),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              provider.removeUpiAccount(account.upiId);
              Navigator.of(context).pop();
            },
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );
  }

  // Show payment details
  void _showPaymentDetails(BuildContext context, UPIPaymentStatus payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('payment_details')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow(context.tr('transaction_id'), payment.transactionId),
            _detailRow(context.tr('reference_id'), payment.referenceId),
            _detailRow(context.tr('amount'), context.formatCurrency(payment.amount)),
            _detailRow(context.tr('status'), payment.status),
            _detailRow(
              context.tr('date_time'),
              '${payment.timestamp.day}/${payment.timestamp.month}/${payment.timestamp.year} ${payment.timestamp.hour}:${payment.timestamp.minute}',
            ),
            if (payment.responseCode != null)
              _detailRow(context.tr('response_code'), payment.responseCode!),
            if (payment.responseMessage != null)
              _detailRow(context.tr('response_message'), payment.responseMessage!),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(context.tr('close')),
          ),
        ],
      ),
    );
  }

  // Helper for payment details
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text('$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
