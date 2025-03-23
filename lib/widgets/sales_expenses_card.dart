import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/dashboard_data.dart';
import '../providers/dashboard_provider.dart';

class SalesExpensesCard extends StatefulWidget {
  const SalesExpensesCard({Key? key}) : super(key: key);

  @override
  State<SalesExpensesCard> createState() => _SalesExpensesCardState();
}

class _SalesExpensesCardState extends State<SalesExpensesCard> with SingleTickerProviderStateMixin {
  int touchedGroupIndex = -1;
  String selectedTimeRange = 'This Fiscal Year';
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _showAsList = false;

  final List<String> timeRanges = [
    'This Month',
    'Last 3 Months',
    'Last 6 Months',
    'This Fiscal Year',
    'Last Year',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
    final salesExpenseData = dashboardProvider.salesExpenseData;

    // Calculate totals
    final totalSales = salesExpenseData.fold<double>(
      0, (sum, item) => sum + item.sales);
    final totalExpenses = salesExpenseData.fold<double>(
      0, (sum, item) => sum + item.expenses);
    final totalProfit = totalSales - totalExpenses;
    final profitMargin = totalSales > 0 ? (totalProfit / totalSales) * 100 : 0;
    final totalReceipts = totalSales * 0.42; // Just for demo, typically this would be from real data

    // Currency formatter
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final percentFormat = NumberFormat.decimalPercentPattern(decimalDigits: 1);

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
                      'Sales and Expenses',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Tooltip(
                      message: 'Compare your sales and expenses over time',
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
                    // Toggle between chart and list view
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showAsList = !_showAsList;
                          if (!_showAsList) {
                            _resetAnimation();
                          }
                        });
                      },
                      icon: Icon(
                        _showAsList ? Icons.bar_chart : Icons.list,
                        color: AppColors.textGray,
                        size: 20,
                      ),
                      tooltip: _showAsList ? 'Show as chart' : 'Show as list',
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    // Time range selector
                    PopupMenuButton<String>(
                      initialValue: selectedTimeRange,
                      onSelected: (String value) {
                        setState(() {
                          selectedTimeRange = value;
                          _resetAnimation();
                        });
                      },
                      itemBuilder: (BuildContext context) {
                        return timeRanges.map((String value) {
                          return PopupMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.borderGray),
                        ),
                        child: Row(
                          children: [
                            Text(
                              selectedTimeRange,
                              style: TextStyle(
                                color: AppColors.textGray,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.textGray,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Chart or List View
          _showAsList
              ? _buildListView(salesExpenseData, currencyFormat)
              : AspectRatio(
                  aspectRatio: 1.8,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 24,
                      left: 16,
                      top: 8,
                      bottom: 12,
                    ),
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return BarChart(
                          BarChartData(
                            maxY: _getMaxY(salesExpenseData),
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                tooltipBgColor: Colors.blueGrey.shade800,
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  String label;
                                  switch (rodIndex) {
                                    case 0:
                                      label = 'Sales: ${currencyFormat.format(rod.toY)}';
                                      break;
                                    case 1:
                                      label = 'Expenses: ${currencyFormat.format(rod.toY)}';
                                      break;
                                    case 2:
                                      label = 'Profit: ${currencyFormat.format(rod.toY)}';
                                      break;
                                    default:
                                      label = '';
                                  }
                                  return BarTooltipItem(
                                    label,
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
                                    touchedGroupIndex = -1;
                                    return;
                                  }
                                  touchedGroupIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                                });
                              },
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      space: 16,
                                      child: Text(
                                        salesExpenseData[value.toInt()].month,
                                        style: TextStyle(
                                          color: AppColors.textGray,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  },
                                  reservedSize: 28,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 60,
                                  interval: _getInterval(salesExpenseData),
                                  getTitlesWidget: (value, meta) {
                                    return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      space: 0,
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
                            barGroups: List.generate(salesExpenseData.length, (index) {
                              return _makeGroupData(
                                index,
                                salesExpenseData[index].sales * _animation.value,
                                salesExpenseData[index].expenses * _animation.value,
                                (salesExpenseData[index].sales - salesExpenseData[index].expenses) * _animation.value,
                                isTouched: index == touchedGroupIndex,
                              );
                            }),
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
                          ),
                        );
                      },
                    ),
                  ),
                ),

          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(AppColors.chartGreen, 'Sales'),
                const SizedBox(width: 24),
                _buildLegendItem(AppColors.chartOrange, 'Expenses'),
                const SizedBox(width: 24),
                _buildLegendItem(AppColors.chartBlue, 'Profit'),
              ],
            ),
          ),

          const Divider(color: AppColors.borderGray, height: 24),

          // Stats
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStat('Total Sales', currencyFormat.format(totalSales), AppColors.chartGreen),
                _buildStat('Total Profit', currencyFormat.format(totalProfit), AppColors.chartBlue),
                _buildStat('Profit Margin', '${percentFormat.format(profitMargin / 100)}', AppColors.chartBlue),
                _buildStat('Total Expenses', currencyFormat.format(totalExpenses), AppColors.chartOrange),
              ],
            ),
          ),

          // Note
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '* Sales value displayed is inclusive of tax and credits. Profit margin calculated as (Sales - Expenses) / Sales.',
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildListView(List<SalesExpenseData> data, NumberFormat formatter) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Month',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Sales',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.chartGreen,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Expenses',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.chartOrange,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Profit',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.chartBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // List items
          ...data.map((item) {
            final profit = item.sales - item.expenses;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(item.month),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      formatter.format(item.sales),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      formatter.format(item.expenses),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      formatter.format(profit),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: profit >= 0 ? AppColors.chartBlue : Colors.red,
                        fontWeight: profit >= 0 ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textGray,
          ),
        ),
      ],
    );
  }

  Widget _buildStat(String label, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textGray,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  BarChartGroupData _makeGroupData(
    int x,
    double sales,
    double expenses,
    double profit, {
    bool isTouched = false,
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: sales,
          color: isTouched ? AppColors.chartGreen.withOpacity(0.8) : AppColors.chartGreen,
          width: 10,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: _getMaxY(Provider.of<DashboardProvider>(context, listen: false).salesExpenseData),
            color: AppColors.borderGray.withOpacity(0.2),
          ),
        ),
        BarChartRodData(
          toY: expenses,
          color: isTouched ? AppColors.chartOrange.withOpacity(0.8) : AppColors.chartOrange,
          width: 10,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: _getMaxY(Provider.of<DashboardProvider>(context, listen: false).salesExpenseData),
            color: AppColors.borderGray.withOpacity(0.2),
          ),
        ),
        BarChartRodData(
          toY: profit,
          color: isTouched ? AppColors.chartBlue.withOpacity(0.8) : AppColors.chartBlue,
          width: 10,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: _getMaxY(Provider.of<DashboardProvider>(context, listen: false).salesExpenseData),
            color: AppColors.borderGray.withOpacity(0.2),
          ),
        ),
      ],
      showingTooltipIndicators: isTouched ? [0, 1, 2] : [],
    );
  }

  double _getMaxY(List<SalesExpenseData> data) {
    double maxSales = 0;
    double maxExpenses = 0;

    for (var item in data) {
      if (item.sales > maxSales) maxSales = item.sales;
      if (item.expenses > maxExpenses) maxExpenses = item.expenses;
    }

    // Make sure we have enough room for the profit bar too
    final maxProfit = data.map((e) => e.sales - e.expenses).reduce((a, b) => a > b ? a : b);
    final absoluteMax = [maxSales, maxExpenses, maxProfit].reduce((a, b) => a > b ? a : b);

    return absoluteMax * 1.2;
  }

  double _getInterval(List<SalesExpenseData> data) {
    final maxY = _getMaxY(data);
    if (maxY <= 1000) return 200;
    if (maxY <= 5000) return 1000;
    if (maxY <= 10000) return 2000;
    return 5000;
  }
}
