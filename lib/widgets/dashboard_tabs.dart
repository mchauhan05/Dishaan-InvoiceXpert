import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class DashboardTabs extends StatefulWidget {
  const DashboardTabs({Key? key}) : super(key: key);

  @override
  State<DashboardTabs> createState() => _DashboardTabsState();
}

class _DashboardTabsState extends State<DashboardTabs> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.borderGray,
                width: 1,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            tabs: [
              _buildTab('Dashboard', 0),
              _buildTab('Announcements', 1),
              _buildTab('Recent Updates', 2),
            ],
            indicatorColor: AppColors.primaryBlue,
            indicatorWeight: 2,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Dashboard content is in the parent widget
              Container(),

              // Announcements
              _buildAnnouncementsTab(),

              // Recent Updates
              _buildRecentUpdatesTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: isSelected
            ? const Border(
                bottom: BorderSide(
                  color: AppColors.primaryBlue,
                  width: 2,
                ),
              )
            : null,
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.primaryBlue : AppColors.textGray,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.campaign,
            size: 64,
            color: AppColors.textGray.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No announcements at this time',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentUpdatesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.update,
            size: 64,
            color: AppColors.textGray.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No recent updates',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textGray,
            ),
          ),
        ],
      ),
    );
  }
}
