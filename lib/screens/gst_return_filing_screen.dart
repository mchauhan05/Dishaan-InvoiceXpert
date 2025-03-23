import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/gst_return_filing_model.dart';
import '../providers/gst_return_filing_provider.dart';
import '../providers/invoice_provider.dart';
import '../utils/translation_extension.dart';
import '../widgets/app_layout.dart';

class GstReturnFilingScreen extends StatefulWidget {
  const GstReturnFilingScreen({Key? key}) : super(key: key);

  @override
  _GstReturnFilingScreenState createState() => _GstReturnFilingScreenState();
}

class _GstReturnFilingScreenState extends State<GstReturnFilingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<GstReturnFilingProvider>(context, listen: false);
      if (provider.returnCalendar == null) {
        provider.initialize();
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
      title: context.tr('gst_return_filing'),
      body: Consumer<GstReturnFilingProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
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
                    Tab(text: context.tr('return_calendar')),
                    Tab(text: 'GSTR-1'),
                    Tab(text: 'GSTR-3B'),
                  ],
                ),
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildReturnCalendarTab(provider),
                    _buildGSTR1Tab(provider),
                    _buildGSTR3BTab(provider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReturnCalendarTab(GstReturnFilingProvider provider) {
    final calendar = provider.returnCalendar;

    if (calendar == null) {
      return Center(
        child: Text(context.tr('no_return_calendar_available')),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upcoming returns section
          _buildCalendarSection(
            title: context.tr('upcoming_returns'),
            returns: calendar.upcomingReturns,
            emptyMessage: context.tr('no_upcoming_returns'),
          ),

          const SizedBox(height: 24),

          // Past returns section
          _buildCalendarSection(
            title: context.tr('past_returns'),
            returns: calendar.pastReturns,
            emptyMessage: context.tr('no_past_returns'),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection({
    required String title,
    required List<GSTReturnDue> returns,
    required String emptyMessage,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            if (returns.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    emptyMessage,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: returns.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final returnItem = returns[index];
                  return _buildReturnListTile(returnItem);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnListTile(GSTReturnDue returnItem) {
    String statusText;
    Widget? trailing;

    if (returnItem.status == 'FILED') {
      statusText = context.tr('filed_on', args: [DateFormat('d MMM').format(returnItem.dueDate)]);
    } else if (returnItem.status == 'LATE') {
      statusText = context.tr('filed_late');
    } else if (returnItem.isOverdue) {
      statusText = context.tr('overdue_by_days', args: ['${returnItem.daysUntilDue.abs()}']);
      trailing = ElevatedButton(
        onPressed: () => _showFilingDialog(returnItem),
        child: Text(context.tr('file_now')),
      );
    } else if (returnItem.isDueSoon) {
      statusText = context.tr('due_in_days', args: ['${returnItem.daysUntilDue}']);
      trailing = ElevatedButton(
        onPressed: () => _showFilingDialog(returnItem),
        child: Text(context.tr('file_now')),
      );
    } else {
      statusText = context.tr('due_on', args: [returnItem.formattedDueDate]);
      trailing = TextButton(
        onPressed: () => _showFilingDialog(returnItem),
        child: Text(context.tr('prepare')),
      );
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: returnItem.statusColor.withOpacity(0.1),
        child: Icon(returnItem.statusIcon, color: returnItem.statusColor),
      ),
      title: Text('${returnItem.returnType} - ${returnItem.taxPeriod}'),
      subtitle: Text(statusText),
      trailing: trailing,
      onTap: () {
        // Navigate to return details
        if (returnItem.returnType == 'GSTR-1') {
          _tabController.animateTo(1);
        } else if (returnItem.returnType == 'GSTR-3B') {
          _tabController.animateTo(2);
        }
      },
    );
  }

  void _showFilingDialog(GSTReturnDue returnItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('file_return', args: [returnItem.returnType])),
        content: Text(
          context.tr('file_return_confirmation', args: [
            returnItem.returnType,
            returnItem.taxPeriod,
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              // Mark return as filed
              final provider = Provider.of<GstReturnFilingProvider>(
                context,
                listen: false,
              );

              if (returnItem.returnType == 'GSTR-1') {
                provider.markGSTR1AsFiled(
                  returnItem.financialYear,
                  returnItem.taxPeriod,
                );
              } else if (returnItem.returnType == 'GSTR-3B') {
                provider.markGSTR3BAsFiled(
                  returnItem.financialYear,
                  returnItem.taxPeriod,
                );
              }

              Navigator.of(context).pop();
            },
            child: Text(context.tr('mark_as_filed')),
          ),
        ],
      ),
    );
  }

  Widget _buildGSTR1Tab(GstReturnFilingProvider provider) {
    final gstr1Returns = provider.gstr1Returns;

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
                    context.tr('gstr1_info'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(context.tr('gstr1_description')),
                ],
              ),
            ),
          ),

          // Generate GSTR-1 button
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('generate_gstr1'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text(context.tr('generate_for_current_month')),
                    onPressed: () => _generateGSTR1ForCurrentMonth(),
                  ),
                ],
              ),
            ),
          ),

          // GSTR-1 returns list
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('gstr1_returns'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (gstr1Returns.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          context.tr('no_gstr1_returns'),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: gstr1Returns.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final gstr1 = gstr1Returns[index];

                        return ListTile(
                          title: Text('${gstr1.taxPeriod} (${gstr1.financialYear})'),
                          subtitle: Text(
                            gstr1.status == 'PENDING'
                                ? context.tr('due_on', args: [gstr1.formattedDueDate])
                                : context.tr('filed_on', args: [gstr1.formattedFilingDate!]),
                          ),
                          trailing: gstr1.status == 'PENDING'
                              ? ElevatedButton(
                                  onPressed: () => _showGSTR1FilingOptions(gstr1),
                                  child: Text(context.tr('file')),
                                )
                              : const Icon(Icons.check_circle, color: Colors.green),
                          onTap: () => _showGSTR1Details(gstr1),
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

  void _generateGSTR1ForCurrentMonth() async {
    // Get invoice provider
    final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
    final gstReturnProvider = Provider.of<GstReturnFilingProvider>(context, listen: false);

    // Get current date
    final now = DateTime.now();

    // Get financial year and tax period
    final financialYear = gstReturnProvider.getFinancialYearForDate(now);
    final taxPeriod = gstReturnProvider.getTaxPeriodForDate(now);

    // Due date is usually 11th of next month
    final dueDate = DateTime(
      now.month < 12 ? now.year : now.year + 1,
      now.month < 12 ? now.month + 1 : 1,
      11,
    );

    // Generate GSTR-1
    final gstr1Return = await gstReturnProvider.generateGSTR1(
      invoiceProvider.invoices,
      financialYear,
      taxPeriod,
      dueDate,
    );

    // Show result
    if (gstr1Return != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('gstr1_generated_successfully'))),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('error_generating_gstr1'))),
      );
    }
  }

  void _showGSTR1FilingOptions(GSTR1Return gstr1) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: Text(context.tr('view_details')),
            onTap: () {
              Navigator.of(context).pop();
              _showGSTR1Details(gstr1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: Text(context.tr('mark_as_filed')),
            onTap: () {
              Navigator.of(context).pop();
              _showFilingDialog(GSTReturnDue(
                returnType: 'GSTR-1',
                financialYear: gstr1.financialYear,
                taxPeriod: gstr1.taxPeriod,
                dueDate: gstr1.dueDate,
                status: gstr1.status,
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_chart),
            title: Text(context.tr('generate_gstr3b')),
            onTap: () {
              Navigator.of(context).pop();
              _generateGSTR3BFromGSTR1(gstr1);
            },
          ),
        ],
      ),
    );
  }

  void _showGSTR1Details(GSTR1Return gstr1) {
    final totals = gstr1.calculateTotals();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('gstr1_details')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow(context.tr('tax_period'), gstr1.taxPeriod),
              _detailRow(context.tr('financial_year'), gstr1.financialYear),
              _detailRow(context.tr('due_date'), gstr1.formattedDueDate),
              _detailRow(context.tr('status'), gstr1.status),

              const Divider(height: 24),

              Text(
                context.tr('totals'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              _detailRow(
                context.tr('taxable_value'),
                context.formatCurrency(totals['taxable_value'] ?? 0),
              ),
              _detailRow(
                'CGST',
                context.formatCurrency(totals['cgst'] ?? 0),
              ),
              _detailRow(
                'SGST',
                context.formatCurrency(totals['sgst'] ?? 0),
              ),
              _detailRow(
                'IGST',
                context.formatCurrency(totals['igst'] ?? 0),
              ),
              _detailRow(
                context.tr('total'),
                context.formatCurrency(totals['total'] ?? 0),
                isBold: true,
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.tr('close')),
          ),
        ],
      ),
    );
  }

  void _generateGSTR3BFromGSTR1(GSTR1Return gstr1) async {
    final provider = Provider.of<GstReturnFilingProvider>(context, listen: false);

    // Calculate GSTR-3B data from GSTR-1
    final gstr3bData = provider.calculateGSTR3BData(gstr1);

    // Generate GSTR-3B
    final gstr3bReturn = await provider.generateGSTR3B(gstr1, gstr3bData);

    // Show result
    if (gstr3bReturn != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('gstr3b_generated_successfully'))),
      );
      // Switch to GSTR-3B tab
      _tabController.animateTo(2);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('error_generating_gstr3b'))),
      );
    }
  }

  Widget _buildGSTR3BTab(GstReturnFilingProvider provider) {
    final gstr3bReturns = provider.gstr3bReturns;

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
                    context.tr('gstr3b_info'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(context.tr('gstr3b_description')),
                ],
              ),
            ),
          ),

          // GSTR-3B returns list
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('gstr3b_returns'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (gstr3bReturns.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          context.tr('no_gstr3b_returns'),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: gstr3bReturns.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final gstr3b = gstr3bReturns[index];

                        return ListTile(
                          title: Text('${gstr3b.taxPeriod} (${gstr3b.financialYear})'),
                          subtitle: Text(
                            gstr3b.status == 'PENDING'
                                ? context.tr('due_on', args: [gstr3b.formattedDueDate])
                                : context.tr('filed_on', args: [gstr3b.formattedFilingDate!]),
                          ),
                          trailing: gstr3b.status == 'PENDING'
                              ? ElevatedButton(
                                  onPressed: () => _showGSTR3BFilingOptions(gstr3b),
                                  child: Text(context.tr('file')),
                                )
                              : const Icon(Icons.check_circle, color: Colors.green),
                          onTap: () => _showGSTR3BDetails(gstr3b),
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

  void _showGSTR3BFilingOptions(GSTR3BReturn gstr3b) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: Text(context.tr('view_details')),
            onTap: () {
              Navigator.of(context).pop();
              _showGSTR3BDetails(gstr3b);
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: Text(context.tr('mark_as_filed')),
            onTap: () {
              Navigator.of(context).pop();
              _showFilingDialog(GSTReturnDue(
                returnType: 'GSTR-3B',
                financialYear: gstr3b.financialYear,
                taxPeriod: gstr3b.taxPeriod,
                dueDate: gstr3b.dueDate,
                status: gstr3b.status,
              ));
            },
          ),
        ],
      ),
    );
  }

  void _showGSTR3BDetails(GSTR3BReturn gstr3b) {
    if (gstr3b.returnData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('no_return_data_available'))),
      );
      return;
    }

    final data = gstr3b.returnData!;
    final totalPayable = data.calculateTotalAmountPayable();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('gstr3b_details')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow(context.tr('tax_period'), gstr3b.taxPeriod),
              _detailRow(context.tr('financial_year'), gstr3b.financialYear),
              _detailRow(context.tr('due_date'), gstr3b.formattedDueDate),
              _detailRow(context.tr('status'), gstr3b.status),

              const Divider(height: 24),

              Text(
                context.tr('outward_supplies'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              _detailRow(
                context.tr('taxable_value'),
                context.formatCurrency(data.outwardSupplies.totalTaxableValue),
              ),
              _detailRow(
                context.tr('total_tax'),
                context.formatCurrency(data.outwardSupplies.totalTax),
              ),

              const Divider(height: 24),

              Text(
                context.tr('input_tax_credit'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              _detailRow(
                context.tr('total_itc'),
                context.formatCurrency(data.itcDetails.totalITC),
              ),

              const Divider(height: 24),

              _detailRow(
                context.tr('tax_payable'),
                context.formatCurrency(data.calculateTotalTaxPayable()),
              ),
              _detailRow(
                context.tr('interest'),
                context.formatCurrency(data.interestPayable),
              ),
              _detailRow(
                context.tr('late_fee'),
                context.formatCurrency(data.lateFee),
              ),
              _detailRow(
                context.tr('total_payment'),
                context.formatCurrency(totalPayable),
                isBold: true,
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.tr('close')),
          ),
        ],
      ),
    );
  }

  // Helper for details rows
  Widget _detailRow(String label, String value, {bool isBold = false}) {
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
          Expanded(child: Text(
            value,
            style: isBold ? const TextStyle(fontWeight: FontWeight.bold) : null,
          )),
        ],
      ),
    );
  }
}
