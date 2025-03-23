import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../providers/gst_return_provider.dart';
import '../providers/gst_return_filing_provider.dart';
import '../providers/indian_gst_provider.dart';
import '../utils/translation_extension.dart';
import '../widgets/app_layout.dart';

class GstReturnReportsScreen extends StatefulWidget {
  const GstReturnReportsScreen({Key? key}) : super(key: key);

  @override
  _GstReturnReportsScreenState createState() => _GstReturnReportsScreenState();
}

class _GstReturnReportsScreenState extends State<GstReturnReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Filter variables
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 365));
  DateTime _endDate = DateTime.now();
  String _selectedReturnType = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'GST Return Reports',
      body: Column(
        children: [
          _buildFilterSection(),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Summary'),
              Tab(text: 'Tax Analysis'),
              Tab(text: 'Compliance Status'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSummaryTab(),
                _buildTaxAnalysisTab(),
                _buildComplianceStatusTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Consumer<GstReturnProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Reports',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Start Date'),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectDate(context, true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(DateFormat('dd/MM/yyyy').format(_startDate)),
                                const Icon(Icons.calendar_today, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('End Date'),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectDate(context, false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(DateFormat('dd/MM/yyyy').format(_endDate)),
                                const Icon(Icons.calendar_today, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Return Type'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedReturnType,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: ['All', ...provider.returnTypes]
                                .map((type) => DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(type),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedReturnType = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Apply filters and refresh data
                        setState(() {});
                      },
                      icon: const Icon(Icons.filter_alt),
                      label: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2017), // GST started in India in July 2017
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Ensure end date is not before start date
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Widget _buildSummaryTab() {
    return Consumer<GstReturnProvider>(
      builder: (context, provider, child) {
        // Filter returns based on selected criteria
        List<GstReturn> filteredReturns = provider.gstReturns
            .where((gstReturn) =>
              (gstReturn.filingDate.isAfter(_startDate) || gstReturn.filingDate.isAtSameMomentAs(_startDate)) &&
              (gstReturn.filingDate.isBefore(_endDate) || gstReturn.filingDate.isAtSameMomentAs(_endDate)) &&
              (_selectedReturnType == 'All' || gstReturn.returnType == _selectedReturnType)
            )
            .toList();

        // Calculate summary metrics
        double totalTaxableValue = 0;
        double totalCgst = 0;
        double totalSgst = 0;
        double totalIgst = 0;
        double totalCess = 0;

        for (var gstReturn in filteredReturns) {
          totalTaxableValue += gstReturn.totalTaxableValue;
          totalCgst += gstReturn.totalCgst;
          totalSgst += gstReturn.totalSgst;
          totalIgst += gstReturn.totalIgst;
          totalCess += gstReturn.totalCess;
        }

        final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary metrics cards
              Row(
                children: [
                  _buildMetricCard(
                    title: 'Total Returns Filed',
                    value: filteredReturns.length.toString(),
                    icon: Icons.receipt_long,
                    color: Colors.blue,
                  ),
                  _buildMetricCard(
                    title: 'Total Taxable Value',
                    value: currencyFormat.format(totalTaxableValue),
                    icon: Icons.money,
                    color: Colors.green,
                  ),
                  _buildMetricCard(
                    title: 'Total Tax',
                    value: currencyFormat.format(totalCgst + totalSgst + totalIgst + totalCess),
                    icon: Icons.account_balance,
                    color: Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tax breakdown card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tax Breakdown',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('CGST:'),
                                Text('SGST:'),
                                Text('IGST:'),
                                Text('CESS:'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(currencyFormat.format(totalCgst)),
                                Text(currencyFormat.format(totalSgst)),
                                Text(currencyFormat.format(totalIgst)),
                                Text(currencyFormat.format(totalCess)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            currencyFormat.format(totalCgst + totalSgst + totalIgst + totalCess),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Returns list
              Text(
                'Filed Returns',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              filteredReturns.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text('No returns found for the selected criteria.'),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: filteredReturns.length,
                      itemBuilder: (context, index) {
                        final gstReturn = filteredReturns[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(
                              '${gstReturn.returnType} - ${gstReturn.period}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Filing Date: ${DateFormat('dd/MM/yyyy').format(gstReturn.filingDate)}'),
                                Text('Total Tax: ${currencyFormat.format(gstReturn.totalTax)}'),
                                Text('Status: ${gstReturn.status}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.visibility),
                                  tooltip: 'View Details',
                                  onPressed: () => _showReturnDetails(gstReturn),
                                ),
                                IconButton(
                                  icon: Icon(Icons.download),
                                  tooltip: 'Download',
                                  onPressed: () => _downloadReturn(gstReturn),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.file_download),
                    label: Text('Export Report'),
                    onPressed: () => _exportReport(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: Icon(Icons.print),
                    label: Text('Print Report'),
                    onPressed: () => _printReport(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaxAnalysisTab() {
    return Consumer<GstReturnProvider>(
      builder: (context, provider, child) {
        // Filter returns based on selected criteria
        List<GstReturn> filteredReturns = provider.gstReturns
            .where((gstReturn) =>
              (gstReturn.filingDate.isAfter(_startDate) || gstReturn.filingDate.isAtSameMomentAs(_startDate)) &&
              (gstReturn.filingDate.isBefore(_endDate) || gstReturn.filingDate.isAtSameMomentAs(_endDate)) &&
              (_selectedReturnType == 'All' || gstReturn.returnType == _selectedReturnType)
            )
            .toList();

        // Prepare data for charts
        Map<String, double> taxTypeData = {
          'CGST': 0,
          'SGST': 0,
          'IGST': 0,
          'CESS': 0,
        };

        Map<String, double> periodData = {};

        for (var gstReturn in filteredReturns) {
          taxTypeData['CGST'] = (taxTypeData['CGST'] ?? 0) + gstReturn.totalCgst;
          taxTypeData['SGST'] = (taxTypeData['SGST'] ?? 0) + gstReturn.totalSgst;
          taxTypeData['IGST'] = (taxTypeData['IGST'] ?? 0) + gstReturn.totalIgst;
          taxTypeData['CESS'] = (taxTypeData['CESS'] ?? 0) + gstReturn.totalCess;

          periodData[gstReturn.period] = (periodData[gstReturn.period] ?? 0) + gstReturn.totalTax;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tax Distribution Pie Chart
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tax Distribution',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 300,
                        child: taxTypeData.values.every((value) => value == 0)
                            ? Center(child: Text('No tax data available for the selected period.'))
                            : PieChart(
                                PieChartData(
                                  sections: _createPieSections(taxTypeData),
                                  centerSpaceRadius: 40,
                                  sectionsSpace: 2,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      // Chart legend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegendItem('CGST', Colors.blue),
                          const SizedBox(width: 16),
                          _buildLegendItem('SGST', Colors.green),
                          const SizedBox(width: 16),
                          _buildLegendItem('IGST', Colors.orange),
                          const SizedBox(width: 16),
                          _buildLegendItem('CESS', Colors.purple),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Period-wise Bar Chart
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Period-wise Tax Liability',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 300,
                        child: periodData.isEmpty
                            ? Center(child: Text('No period data available.'))
                            : BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: periodData.values.fold(0, (max, value) => value > max ? value : max) * 1.2,
                                  barTouchData: BarTouchData(enabled: true),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          if (value < 0 || value >= periodData.length) return const SizedBox();
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(
                                              periodData.keys.elementAt(value.toInt()),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 60,
                                        getTitlesWidget: (value, meta) {
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: Text(
                                              '₹${value.toInt()}',
                                              style: const TextStyle(fontSize: 10),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: periodData.values.fold(0, (max, value) => value > max ? value : max) / 5,
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups: List.generate(
                                    periodData.length,
                                    (index) => BarChartGroupData(
                                      x: index,
                                      barRods: [
                                        BarChartRodData(
                                          toY: periodData.values.elementAt(index),
                                          color: Colors.blue,
                                          width: 20,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComplianceStatusTab() {
    return Consumer<GstReturnProvider>(
      builder: (context, provider, child) {
        // Filter returns based on selected criteria
        List<GstReturn> filteredReturns = provider.gstReturns
            .where((gstReturn) =>
              (gstReturn.filingDate.isAfter(_startDate) || gstReturn.filingDate.isAtSameMomentAs(_startDate)) &&
              (gstReturn.filingDate.isBefore(_endDate) || gstReturn.filingDate.isAtSameMomentAs(_endDate)) &&
              (_selectedReturnType == 'All' || gstReturn.returnType == _selectedReturnType)
            )
            .toList();

        // Calculate compliance metrics
        int totalReturns = filteredReturns.length;
        int filedReturns = filteredReturns.where((r) => r.status == 'Filed' || r.status == 'Verified').length;
        int pendingReturns = totalReturns - filedReturns;
        double complianceRate = totalReturns > 0 ? (filedReturns / totalReturns * 100) : 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Compliance metrics cards
              Row(
                children: [
                  _buildMetricCard(
                    title: 'Compliance Rate',
                    value: '${complianceRate.toStringAsFixed(2)}%',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                  _buildMetricCard(
                    title: 'Filed Returns',
                    value: filedReturns.toString(),
                    icon: Icons.assignment_turned_in,
                    color: Colors.blue,
                  ),
                  _buildMetricCard(
                    title: 'Pending Returns',
                    value: pendingReturns.toString(),
                    icon: Icons.assignment_late,
                    color: Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Compliance Status Chart
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Compliance Status',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 250,
                        child: totalReturns == 0
                            ? Center(child: Text('No returns data available for the selected period.'))
                            : PieChart(
                                PieChartData(
                                  sections: [
                                    PieChartSectionData(
                                      value: filedReturns.toDouble(),
                                      title: 'Filed\n${(filedReturns / totalReturns * 100).toStringAsFixed(0)}%',
                                      color: Colors.green,
                                      radius: 100,
                                      titleStyle: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      value: pendingReturns.toDouble(),
                                      title: 'Pending\n${(pendingReturns / totalReturns * 100).toStringAsFixed(0)}%',
                                      color: Colors.orange,
                                      radius: 100,
                                      titleStyle: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                  centerSpaceRadius: 0,
                                  sectionsSpace: 2,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      // Chart legend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegendItem('Filed Returns', Colors.green),
                          const SizedBox(width: 24),
                          _buildLegendItem('Pending Returns', Colors.orange),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Compliance Alerts
              Text(
                'Compliance Alerts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Overdue returns list
              if (pendingReturns == 0)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 16),
                        Text('All returns are filed. No compliance issues found.'),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: filteredReturns.where((r) => r.status == 'Draft').length,
                  itemBuilder: (context, index) {
                    final pendingReturn = filteredReturns.where((r) => r.status == 'Draft').toList()[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: Colors.red.shade50,
                      child: ListTile(
                        leading: Icon(Icons.warning, color: Colors.red),
                        title: Text(
                          '${pendingReturn.returnType} - ${pendingReturn.period}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Status: ${pendingReturn.status}'),
                        trailing: ElevatedButton(
                          child: Text('File Now'),
                          onPressed: () {
                            // Navigate to filing screen
                            Navigator.pushNamed(context, '/gst_return_filing');
                          },
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: .5,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  List<PieChartSectionData> _createPieSections(Map<String, double> data) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple];
    final total = data.values.fold(0.0, (sum, value) => sum + value);

    if (total == 0) return [];

    return data.entries.map((entry) {
      final index = data.keys.toList().indexOf(entry.key);
      final percentage = entry.value / total * 100;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
    }).toList();
  }

  void _showReturnDetails(GstReturn gstReturn) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${gstReturn.returnType} - ${gstReturn.period}'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('GSTIN: ${gstReturn.gstin}'),
                Text('Filing Date: ${DateFormat('dd/MM/yyyy').format(gstReturn.filingDate)}'),
                Text('Status: ${gstReturn.status}'),
                if (gstReturn.arnNumber.isNotEmpty)
                  Text('ARN Number: ${gstReturn.arnNumber}'),
                const Divider(height: 24),
                Text('Total Taxable Value: ₹${gstReturn.totalTaxableValue.toStringAsFixed(2)}'),
                Text('CGST: ₹${gstReturn.totalCgst.toStringAsFixed(2)}'),
                Text('SGST: ₹${gstReturn.totalSgst.toStringAsFixed(2)}'),
                Text('IGST: ₹${gstReturn.totalIgst.toStringAsFixed(2)}'),
                Text('CESS: ₹${gstReturn.totalCess.toStringAsFixed(2)}'),
                Text('Total Tax: ₹${gstReturn.totalTax.toStringAsFixed(2)}'),
                const Divider(height: 24),
                Text('Sections:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...gstReturn.sections.map((section) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('${section.name}: ₹${section.totalTaxableValue.toStringAsFixed(2)} (Tax: ₹${section.totalTax.toStringAsFixed(2)})'),
                )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => _downloadReturn(gstReturn),
            child: Text('Download'),
          ),
        ],
      ),
    );
  }

  void _downloadReturn(GstReturn gstReturn) {
    // In a real app, this would generate and download a PDF
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading ${gstReturn.returnType} - ${gstReturn.period}...')),
    );
  }

  void _exportReport() {
    // In a real app, this would export the report data to Excel/CSV
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting report to Excel...')),
    );
  }

  void _printReport() {
    // In a real app, this would print the report
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Preparing report for printing...')),
    );
  }
