import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_colors.dart';
import '../providers/dashboard_provider.dart';
import '../models/dashboard_data.dart';

class ProjectsCard extends StatefulWidget {
  const ProjectsCard({Key? key}) : super(key: key);

  @override
  State<ProjectsCard> createState() => _ProjectsCardState();
}

class _ProjectsCardState extends State<ProjectsCard> {
  int _selectedProjectIndex = -1;

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final projects = dashboardProvider.projectsData;

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
                      'Projects',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: 'Projects you\'re tracking and their progress',
                      child: Icon(
                        Icons.info_outline,
                        color: AppColors.textGray,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to projects list
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('New Project'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: BorderSide(color: AppColors.borderGray),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Unbilled stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundGray.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildUnbilledStat(
                    'Unbilled Hours',
                    '12:00',
                    Icons.access_time,
                  ),
                  _buildUnbilledStat(
                    'Unbilled Expenses',
                    '\$100.00',
                    Icons.receipt_long,
                  ),
                  _buildUnbilledStat(
                    'Upcoming Deadlines',
                    '2',
                    Icons.event,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Progress chart
          SizedBox(
            height: 200,
            child: _buildProjectsChart(projects),
          ),

          const Divider(height: 1, thickness: 1, color: AppColors.borderGray),

          // Project list
          ...projects.asMap().entries.map((entry) {
            final index = entry.key;
            final project = entry.value;
            return _buildProjectItem(project, index);
          }).toList(),

          // Show all projects button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: TextButton(
                onPressed: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Show All Projects',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      color: AppColors.primaryBlue,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsChart(List<ProjectData> projects) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceBetween,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blueGrey.shade800,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final project = projects[group.x.toInt()];
                return BarTooltipItem(
                  '${project.name}\n${(project.budgetHoursProgress * 100).toStringAsFixed(0)}% complete',
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
                  _selectedProjectIndex = -1;
                  return;
                }
                _selectedProjectIndex = barTouchResponse.spot!.touchedBarGroupIndex;
              });
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value >= projects.length) return const SizedBox();
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      projects[value.toInt()].name.split(' ')[0],
                      style: TextStyle(
                        color: AppColors.textGray,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
                reservedSize: 28,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          barGroups: projects.asMap().entries.map((entry) {
            final index = entry.key;
            final project = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: project.budgetHoursProgress,
                  color: _getProgressColor(project.budgetHoursProgress),
                  width: 16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 1,
                    color: AppColors.borderGray.withOpacity(0.2),
                  ),
                ),
              ],
              showingTooltipIndicators: _selectedProjectIndex == index ? [0] : [],
            );
          }).toList(),
          maxY: 1,
        ),
      ),
    );
  }

  Widget _buildUnbilledStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textGray,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProjectItem(ProjectData project, int index) {
    final bool isSelected = index == _selectedProjectIndex;
    final progressColor = _getProgressColor(project.budgetHoursProgress);

    return Material(
      color: isSelected ? AppColors.backgroundGray : Colors.white,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedProjectIndex = isSelected ? -1 : index;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project name with link icon
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.open_in_new,
                    color: AppColors.textGray,
                    size: 14,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Client name
              Text(
                project.clientName,
                style: TextStyle(
                  color: AppColors.textGray,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              // Budget hours
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Budget Hours',
                        style: TextStyle(
                          color: AppColors.textGray,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.info_outline,
                        color: AppColors.textGray,
                        size: 12,
                      ),
                    ],
                  ),
                  Text(
                    '${(project.budgetHoursProgress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: progressColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress bar
              Stack(
                children: [
                  // Background
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.borderGray.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Progress
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: 8,
                    width: MediaQuery.of(context).size.width * project.budgetHoursProgress * 0.5, // Approximate for card width
                    decoration: BoxDecoration(
                      color: progressColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.red;
    if (progress < 0.7) return AppColors.chartGreen;
    if (progress < 0.9) return Colors.orange;
    return AppColors.secondaryOrange;
  }
}
