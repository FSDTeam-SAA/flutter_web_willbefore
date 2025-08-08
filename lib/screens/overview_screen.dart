import 'package:flutter/material.dart';
import '../widgets/stat_card.dart';
import '../widgets/chart_card.dart';
import '../data/dummy_data.dart';
import '../theme/app_theme.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  String _newUserFilter = 'Month';
  String _liveProductFilter = 'Day';
  String _revenueFilter = 'Year';

  @override
  Widget build(BuildContext context) {
    final stats = DummyData.dashboardStats;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.attach_money,
                  title: 'Total Revenue',
                  value: '\$${stats.totalRevenue.toStringAsFixed(0)}',
                  iconColor: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: StatCard(
                  icon: Icons.inventory,
                  title: 'Total Live Product',
                  value: '${stats.totalLiveProducts}',
                  iconColor: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: StatCard(
                  icon: Icons.people,
                  title: 'Total User',
                  value: '${stats.totalUsers}',
                  iconColor: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Charts Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ChartCard(
                  title: 'New User',
                  data: DummyData.newUserData,
                  chartType: ChartType.line,
                  selectedFilter: _newUserFilter,
                  onFilterChanged: (filter) {
                    setState(() {
                      _newUserFilter = filter;
                    });
                  },
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: ChartCard(
                  title: 'Live Product report',
                  data: DummyData.liveProductData,
                  chartType: ChartType.bar,
                  selectedFilter: _liveProductFilter,
                  onFilterChanged: (filter) {
                    setState(() {
                      _liveProductFilter = filter;
                    });
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Revenue Chart
          ChartCard(
            title: 'Revenue report',
            data: DummyData.revenueThisYear,
            chartType: ChartType.area,
            timeFilters: const ['Day', 'Week', 'Month', 'Year'],
            selectedFilter: _revenueFilter,
            onFilterChanged: (filter) {
              setState(() {
                _revenueFilter = filter;
              });
            },
          ),
        ],
      ),
    );
  }
}