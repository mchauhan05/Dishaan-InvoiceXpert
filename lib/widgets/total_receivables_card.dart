import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../providers/dashboard_provider.dart';

class TotalReceivablesCard extends StatefulWidget {
  const TotalReceivablesCard({Key? key}) : super(key: key);

  @override
  State<TotalReceivablesCard> createState() => _TotalReceivablesCardState();
}

class _TotalReceivablesCardState extends State<TotalReceivablesCard> with SingleTickerProviderStateMixin {
  int touchedIndex = -1;
  bool _showAsPieChart = true;
  bool _showAsTable = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _resetAnimation() {
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final receivablesData = dashboardProvider.receivablesData;

    // Calculate percentages
    final total = receivablesData.total;
    final currentPercent = receivablesData.current / total * 100;
    final overduePercent = receivablesData.overdue / total * 100;
    final days1to15Percent = receivablesData.days1to15 / total * 100;
    final days16to30Percent = receivablesData.days16to30 / total * 100;
    final days31to45Percent = receivablesData.days31to45 / total * 100;
    final daysAbove45Percent = receivablesData.daysAbove45 / total * 100;

    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Total Receivables',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: 'Money owed to your business by customers',
                      child: Icon(
                        Icons.info_outline,
                        color: AppColors.textGray,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // View toggle buttons
                    ToggleButtons(
                      isSelected: [_showAsPieChart, !_showAsPieChart && !_showAsTable, _showAsTable],
                      onPressed: (int index) {
                        setState(() {
                          if (index == 0) {
                            _showAsPieChart = true;
                            _showAsTable = false;
                          } else if (index == 1) {
                            _showAsPieChart = false;
                            _showAsTable = false;
                          } else {
                            _showAsPieChart = false;
                            _showAsTable = true;
                          }
                          _resetAnimation();
                        });
                      },
                      borderRadius: BorderRadius.circular(4),
                      constraints: const BoxConstraints(minHeight: 30, minWidth: 30),
                      borderColor: AppColors.borderGray,
                      selectedBorderColor: AppColors.primaryBlue,
                      selectedColor: AppColors.primaryBlue,
                      fillColor: Colors.white,
                      color: AppColors.textGray,
                      children: const [
                        Tooltip(
                          message: 'Pie Chart View',
                          child: Icon(Icons.pie_chart, size: 16),
                        ),
                        Tooltip(
                          message: 'Bar Chart View',
                          child: Icon(Icons.bar_chart, size: 16),
                        ),
                        Tooltip(
                          message: 'Table View',
                          child: Icon(Icons.table_rows, size: 16),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/invoices/create');
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('New Invoice'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Total amount
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Total Receivables: ${currencyFormat.format(receivablesData.total)}',
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Chart and breakdown
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _showAsTable
                ? _buildTableView(receivablesData, currencyFormat)
                : _showAsPieChart
                    ? _buildPieChartView(receivablesData)
                    : _buildBarChartView(receivablesData),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to invoice list with filter for overdue
                    Navigator.pushNamed(context, '/invoices');
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View All'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: BorderSide(color: AppColors.borderGray),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    // Send payment reminders
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sending payment reminders...'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.email_outlined, size: 16),
                  label: const Text('Send Reminders'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: BorderSide(color: AppColors.borderGray),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const Spacer(),
                Tooltip(
                  message: 'Export Receivables Report',
                  child: IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Exporting receivables report...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.download,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPieChartView(receivablesData) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Pie chart
          SizedBox(
            height: 180,
            width: 180,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: showingSections(receivablesData),
                    startDegreeOffset: 270 * (1 - _animation.value),
                  ),
                );
              }
            ),
          ),

          const SizedBox(width: 20),

          // Legend and breakdown
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem('Current', receivablesData.current / receivablesData.total * 100, AppColors.chartGreen, receivablesData.current, touchedIndex == 0),
                const SizedBox(height: 8),
                _buildLegendItem('1-15 days', receivablesData.days1to15 / receivablesData.total * 100, Colors.blue, receivablesData.days1to15, touchedIndex == 1),
                const SizedBox(height: 8),
                _buildLegendItem('16-30 days', receivablesData.days16to30 / receivablesData.total * 100, Colors.amber, receivablesData.days16to30, touchedIndex == 2),
                const SizedBox(height: 8),
                _buildLegendItem('31-45 days', receivablesData.days31to45 / receivablesData.total * 100, Colors.orange, receivablesData.days31to45, touchedIndex == 3),
                const SizedBox(height: 8),
                _buildLegendItem('Above 45 days', receivablesData.daysAbove45 / receivablesData.total * 100, AppColors.secondaryOrange, receivablesData.daysAbove45, touchedIndex == 4),
                const SizedBox(height: 8),
                _buildLegendItem('Overdue', receivablesData.overdue / receivablesData.total * 100, Colors.red, receivablesData.overdue, touchedIndex == 5),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartView(receivablesData) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    // Convert data into a format suitable for bar chart
    final barGroups = [
      _makeBarGroup(0, 'Current', receivablesData.current, AppColors.chartGreen),
      _makeBarGroup(1, '1-15', receivablesData.days1to15, Colors.blue),
      _makeBarGroup(2, '16-30', receivablesData.days16to30, Colors.amber),
      _makeBarGroup(3, '31-45', receivablesData.days31to45, Colors.orange),
      _makeBarGroup(4, '45+', receivablesData.daysAbove45, AppColors.secondaryOrange),
      _makeBarGroup(5, 'Overdue', receivablesData.overdue, Colors.red),
    ];

    final maxY = [
      receivablesData.current,
      receivablesData.days1to15,
      receivablesData.days16to30,
      receivablesData.days31to45,
      receivablesData.daysAbove45,
      receivablesData.overdue,
    ].reduce((a, b) => a > b ? a : b) * 1.2;

    return SizedBox(
      height: 250,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16, left: 8, right: 16),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return BarChart(
              BarChartData(
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey.shade800,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final String category = [
                        'Current', '1-15 days', '16-30 days',
                        '31-45 days', 'Above 45 days', 'Overdue'
                      ][groupIndex];

                      return BarTooltipItem(
                        '$category\n${currencyFormat.format(rod.toY)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  touchCallback: (FlTouchEvent event, barTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          barTouchResponse == null ||
                          barTouchResponse.spot == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                    });
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        const labels = ['Current', '1-15', '16-30', '31-45', '45+', 'Overdue'];
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 4,
                          child: Text(
                            labels[value.toInt()],
                            style: TextStyle(
                              color: touchedIndex == value.toInt()
                                  ? AppColors.primaryDark
                                  : AppColors.textGray,
                              fontWeight: touchedIndex == value.toInt()
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 4,
                          child: Text(
                            currencyFormat.format(value),
                            style: TextStyle(
                              color: AppColors.textGray,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: barGroups.map((group) {
                  final BarChartGroupData updatedGroup = BarChartGroupData(
                    x: group.x,
                    barRods: group.barRods.map((rod) {
                      return BarChartRodData(
                        toY: rod.toY * _animation.value,
                        color: rod.color,
                        width: rod.width,
                        borderRadius: rod.borderRadius,
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: AppColors.borderGray.withOpacity(0.2),
                        ),
                      );
                    }).toList(),
                    showingTooltipIndicators: group.showingTooltipIndicators,
                  );
                  return updatedGroup;
                }).toList(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.borderGray,
                      strokeWidth: 1.0,
                      dashArray: [5, 5],
                    );
                  },
                ),
                maxY: maxY,
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildTableView(receivablesData, NumberFormat currencyFormat) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(3),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(3),
        },
        border: TableBorder.all(
          color: AppColors.borderGray.withOpacity(0.5),
          width: 1,
          style: BorderStyle.solid,
        ),
        children: [
          // Table header
          TableRow(
            decoration: BoxDecoration(
              color: AppColors.backgroundGray.withOpacity(0.5),
            ),
            children: [
              _tableCell('Age', isHeader: true),
              _tableCell('Percentage', isHeader: true),
              _tableCell('Amount', isHeader: true),
            ],
          ),
          // Current
          _buildDataRow(
            'Current',
            receivablesData.current / receivablesData.total * 100,
            receivablesData.current,
            currencyFormat,
            AppColors.chartGreen
          ),
          // 1-15 days
          _buildDataRow(
            '1-15 days',
            receivablesData.days1to15 / receivablesData.total * 100,
            receivablesData.days1to15,
            currencyFormat,
            Colors.blue
          ),
          // 16-30 days
          _buildDataRow(
            '16-30 days',
            receivablesData.days16to30 / receivablesData.total * 100,
            receivablesData.days16to30,
            currencyFormat,
            Colors.amber
          ),
          // 31-45 days
          _buildDataRow(
            '31-45 days',
            receivablesData.days31to45 / receivablesData.total * 100,
            receivablesData.days31to45,
            currencyFormat,
            Colors.orange
          ),
          // Above 45 days
          _buildDataRow(
            'Above 45 days',
            receivablesData.daysAbove45 / receivablesData.total * 100,
            receivablesData.daysAbove45,
            currencyFormat,
            AppColors.secondaryOrange
          ),
          // Overdue
          _buildDataRow(
            'Overdue',
            receivablesData.overdue / receivablesData.total * 100,
            receivablesData.overdue,
            currencyFormat,
            Colors.red
          ),
          // Total
          TableRow(
            decoration: BoxDecoration(
              color: AppColors.backgroundGray.withOpacity(0.5),
            ),
            children: [
              _tableCell('Total', fontWeight: FontWeight.bold),
              _tableCell('100.0%', fontWeight: FontWeight.bold),
              _tableCell(currencyFormat.format(receivablesData.total), fontWeight: FontWeight.bold),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildDataRow(
    String label,
    double percent,
    double amount,
    NumberFormat formatter,
    Color indicatorColor
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
        ),
        _tableCell('${percent.toStringAsFixed(1)}%'),
        _tableCell(formatter.format(amount)),
      ],
    );
  }

  Widget _tableCell(String text, {bool isHeader = false, FontWeight? fontWeight}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: fontWeight ?? (isHeader ? FontWeight.bold : FontWeight.normal),
          fontSize: 13,
        ),
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, String title, double amount, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: amount,
          color: touchedIndex == x ? color.withOpacity(0.8) : color,
          width: 20,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
      showingTooltipIndicators: touchedIndex == x ? [0] : [],
    );
  }

  List<PieChartSectionData> showingSections(receivablesData) {
    return List.generate(6, (i) {
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 60.0 : 50.0;
      final fontSize = isTouched ? 20.0 : 16.0;
      final fontWeight = isTouched ? FontWeight.bold : FontWeight.normal;

      // Define the value for each section
      double value = 0;
      Color color = Colors.transparent;

      switch (i) {
        case 0:
          value = receivablesData.current;
          color = AppColors.chartGreen;
          break;
        case 1:
          value = receivablesData.days1to15;
          color = Colors.blue;
          break;
        case 2:
          value = receivablesData.days16to30;
          color = Colors.amber;
          break;
        case 3:
          value = receivablesData.days31to45;
          color = Colors.orange;
          break;
        case 4:
          value = receivablesData.daysAbove45;
          color = AppColors.secondaryOrange;
          break;
        case 5:
          value = receivablesData.overdue;
          color = Colors.red;
          break;
      }

      // Only create a visible section if the value is greater than 0
      if (value > 0) {
        return PieChartSectionData(
          color: color,
          value: value,
          title: '',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: Colors.white,
          ),
        );
      } else {
        return PieChartSectionData(
          color: Colors.transparent,
          value: 0,
          title: '',
          radius: 0,
        );
      }
    });
  }

  Widget _buildLegendItem(String label, double percent, Color color, double amount, bool isHighlighted) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: isHighlighted ? Border.all(color: Colors.black, width: 1) : null,
            boxShadow: isHighlighted ? [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? AppColors.primaryDark : AppColors.textGray,
            ),
          ),
        ),
        Text(
          '${percent.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 13,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            color: isHighlighted ? color : AppColors.textGray,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          currencyFormat.format(amount),
          style: TextStyle(
            fontSize: 13,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            color: isHighlighted ? AppColors.primaryDark : AppColors.textGray,
          ),
        ),
      ],
    );
  }
}
