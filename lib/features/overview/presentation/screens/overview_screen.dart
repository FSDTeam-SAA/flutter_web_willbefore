import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_willbefore/core/constants/app_colors.dart';
import 'package:flutx_core/flutx_core.dart';
import '../../../../core/services/stripe_service.dart';
import '../../../../data/dummy_data.dart'; // For fallback data only
import '../../../../models/dashboard_models.dart';
import '../../../product/presentation/providers/products_providers.dart';
import '../../../userProfile/presentation/provider/all_user_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/chart_card.dart';

class OverviewScreen extends ConsumerStatefulWidget {
  const OverviewScreen({super.key});

  @override
  ConsumerState<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends ConsumerState<OverviewScreen> {
  String _newUserFilter = 'Month';
  String _liveProductFilter = 'Day';
  String _revenueFilter = 'Year';
  String _chargeFilter = 'All'; // New filter for charges

  double _totalRevenue = 0.0;
  bool _isLoadingRevenue = false;
  bool _isLoadingCharges = false;
  List<ChartData> _revenueData = [];
  List<ChartData> _liveProductData = [];
  List<ChartData> _newUserData = [];
  List<dynamic> _charges = [];

  @override
  void initState() {
    super.initState();
    // Initialize Stripe
    StripeService.init();
    // Delay provider modifications until after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productsProvider.notifier).fetchProducts();
      _fetchRevenueData();
      _fetchLiveProductData();
      _fetchNewUserData();
      _fetchCharges();
    });
  }

  // Calculate timestamps based on filter
  Map<String, int> _getTimeRange(String filter) {
    final now = DateTime.now();
    int intervalStart;
    int intervalEnd;

    switch (filter) {
      case 'Day':
        intervalStart = now.subtract(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000;
        intervalEnd = now.millisecondsSinceEpoch ~/ 1000;
        break;
      case 'Week':
        intervalStart = now.subtract(const Duration(days: 7)).millisecondsSinceEpoch ~/ 1000;
        intervalEnd = now.millisecondsSinceEpoch ~/ 1000;
        break;
      case 'Month':
        intervalStart = now.subtract(const Duration(days: 30)).millisecondsSinceEpoch ~/ 1000;
        intervalEnd = now.millisecondsSinceEpoch ~/ 1000;
        break;
      case 'Year':
      default:
        intervalStart = now.subtract(const Duration(days: 365)).millisecondsSinceEpoch ~/ 1000;
        intervalEnd = now.millisecondsSinceEpoch ~/ 1000;
        break;
    }

    return {'interval_start': intervalStart, 'interval_end': intervalEnd};
  }

  // Fetch revenue data from Stripe charges
  Future<void> _fetchRevenueData() async {
    setState(() {
      _isLoadingRevenue = true;
    });

    try {
      final timeRange = _getTimeRange(_revenueFilter);
      final charges = await StripeService.fetchCharges(
        limit: 100, // Adjust as needed for pagination
        status: 'succeeded', // Only successful charges contribute to revenue
        created: {
          'gte': timeRange['interval_start']!,
          'lte': timeRange['interval_end']!,
        },
      );

      double total = 0.0;
      final List<ChartData> chartData = [];

      for (var charge in charges ?? []) {
        if (charge['status'] == 'succeeded') {
          final amount = (charge['amount'] as int) / 100.0; // Convert cents to dollars
          total += amount;

          final timestamp = charge['created'] as int;
          final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
          String label;

          switch (_revenueFilter) {
            case 'Day':
              label = '${date.hour}:00';
              break;
            case 'Week':
              label = date.day.toString();
              break;
            case 'Month':
              label = date.day.toString();
              break;
            case 'Year':
            default:
              label = date.month.toString();
              break;
          }
          chartData.add(ChartData(label: label, value: amount));
        }
      }

      setState(() {
        _totalRevenue = total;
        _revenueData = _aggregateChartData(chartData, _revenueFilter);
        _isLoadingRevenue = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingRevenue = false;
      });
      DPrint.error("Error fetching revenue data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching revenue data: $e')),
      );
    }
  }

  // Fetch charges from Stripe
  Future<void> _fetchCharges() async {
    setState(() {
      _isLoadingCharges = true;
    });

    try {
      final charges = await StripeService.fetchCharges(
        limit: 10,
        status: _chargeFilter == 'All' ? null : _chargeFilter.toLowerCase(),
      );
      setState(() {
        _charges = charges ?? [];
        _isLoadingCharges = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCharges = false;
      });
      DPrint.error("Error fetching charges: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching charges: $e')),
      );
    }
  }

  // Aggregate chart data for display
  List<ChartData> _aggregateChartData(List<ChartData> data, String filter) {
    final Map<String, double> aggregated = {};
    for (var item in data) {
      aggregated.update(
        item.label,
        (value) => value + item.value,
        ifAbsent: () => item.value,
      );
    }

    final result = aggregated.entries
        .map((entry) => ChartData(label: entry.key, value: entry.value))
        .toList();

    // Sort by label (assuming numeric for simplicity)
    result.sort((a, b) => int.parse(a.label).compareTo(int.parse(b.label)));
    return result.take(12).toList(); // Limit to reasonable number of points
  }

  // Fetch live product data from Firestore
  void _fetchLiveProductData() {
    final products = ref.read(productsProvider).products;
    final List<ChartData> chartData = [];

    final timeRange = _getTimeRange(_liveProductFilter);
    final startDate = DateTime.fromMillisecondsSinceEpoch(
      timeRange['interval_start']! * 1000,
    );

    final Map<String, int> productCounts = {};
    for (var product in products.where((p) => p.isActive)) {
      if (product.createdAt.isAfter(startDate)) {
        String label;
        switch (_liveProductFilter) {
          case 'Day':
            label = product.createdAt.hour.toString();
            break;
          case 'Week':
            label = product.createdAt.day.toString();
            break;
          case 'Month':
            label = product.createdAt.day.toString();
            break;
          case 'Year':
          default:
            label = product.createdAt.month.toString();
            break;
        }
        productCounts.update(label, (value) => value + 1, ifAbsent: () => 1);
      }
    }

    chartData.addAll(
      productCounts.entries.map(
        (entry) => ChartData(label: entry.key, value: entry.value.toDouble()),
      ),
    );

    chartData.sort((a, b) => int.parse(a.label).compareTo(int.parse(b.label)));
    setState(() {
      _liveProductData = chartData.take(12).toList();
    });
  }

  // Fetch new user data from Firestore
  void _fetchNewUserData() {
    final users = ref.read(userProvider).users;
    final List<ChartData> chartData = [];

    final timeRange = _getTimeRange(_newUserFilter);
    final startDate = DateTime.fromMillisecondsSinceEpoch(
      timeRange['interval_start']! * 1000,
    );

    final Map<String, int> userCounts = {};
    for (var user in users.where((u) => u.role != 'admin')) {
      if (user.createdAt.isAfter(startDate)) {
        String label;
        switch (_newUserFilter) {
          case 'Day':
            label = user.createdAt.hour.toString();
            break;
          case 'Week':
            label = user.createdAt.day.toString();
            break;
          case 'Month':
            label = user.createdAt.day.toString();
            break;
          case 'Year':
          default:
            label = user.createdAt.month.toString();
            break;
        }
        userCounts.update(label, (value) => value + 1, ifAbsent: () => 1);
      }
    }

    chartData.addAll(
      userCounts.entries.map(
        (entry) => ChartData(label: entry.key, value: entry.value.toDouble()),
      ),
    );

    chartData.sort((a, b) => int.parse(a.label).compareTo(int.parse(b.label)));
    setState(() {
      _newUserData = chartData.take(12).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);
    final userState = ref.watch(userProvider);

    double totalRevenue = _isLoadingRevenue ? 0.0 : _totalRevenue;
    int totalLiveProducts = 0;
    int totalUsers = userState.users.where((u) => u.role != 'admin').length;

    if (productsState.products.isNotEmpty) {
      totalLiveProducts = productsState.products.where((p) => p.isActive).length;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.attach_money,
                  title: 'Total Revenue',
                  value: _isLoadingRevenue
                      ? 'Loading...'
                      : '\$${totalRevenue.toStringAsFixed(2)}', // Display with 2 decimal places
                  iconColor: AppColors.primaryLaurel,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: StatCard(
                  icon: Icons.inventory,
                  title: 'Total Live Product',
                  value: '$totalLiveProducts',
                  iconColor: AppColors.primaryLaurel,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: StatCard(
                  icon: Icons.people,
                  title: 'Total User',
                  value: userState.isLoading ? 'Loading...' : '$totalUsers',
                  iconColor: AppColors.primaryLaurel,
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
                  data: _newUserData.isEmpty
                      ? DummyData.newUserData
                      : _newUserData,
                  chartType: ChartType.line,
                  selectedFilter: _newUserFilter,
                  onFilterChanged: (filter) {
                    setState(() {
                      _newUserFilter = filter;
                      _fetchNewUserData();
                    });
                  },
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: ChartCard(
                  title: 'Live Product report',
                  data: _liveProductData.isEmpty
                      ? DummyData.liveProductData
                      : _liveProductData,
                  chartType: ChartType.bar,
                  selectedFilter: _liveProductFilter,
                  onFilterChanged: (filter) {
                    setState(() {
                      _liveProductFilter = filter;
                      _fetchLiveProductData();
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
            data: _isLoadingRevenue ? DummyData.revenueThisYear : _revenueData,
            chartType: ChartType.area,
            timeFilters: const ['Day', 'Week', 'Month', 'Year'],
            selectedFilter: _revenueFilter,
            onFilterChanged: (filter) {
              setState(() {
                _revenueFilter = filter;
                _fetchRevenueData();
              });
            },
          ),

          const SizedBox(height: 32),

          // Charges Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Charges',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: _chargeFilter,
                items: ['All', 'Succeeded', 'Pending', 'Failed']
                    .map((filter) => DropdownMenuItem(
                          value: filter,
                          child: Text(filter),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _chargeFilter = value;
                      _fetchCharges();
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          _isLoadingCharges
              ? Center(child: CircularProgressIndicator())
              : _charges.isEmpty
                  ? Center(child: Text('No charges found'))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _charges.length,
                      itemBuilder: (context, index) {
                        final charge = _charges[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text('Amount: \$${charge['amount'] / 100}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Status: ${charge['status']}'),
                                Text('Date: ${DateTime.fromMillisecondsSinceEpoch(charge['created'] * 1000).toString()}'),
                                if (charge['metadata']['shippo_address_id'] != null)
                                  Text('Shippo Address ID: ${charge['metadata']['shippo_address_id']}'),
                                if (charge['metadata']['order_items'] != null)
                                  Text('Items: ${charge['metadata']['order_items']}'),
                              ],
                            ),
                            trailing: Icon(
                              charge['status'] == 'succeeded'
                                  ? Icons.check_circle
                                  : charge['status'] == 'pending'
                                      ? Icons.hourglass_empty
                                      : Icons.error,
                              color: charge['status'] == 'succeeded'
                                  ? Colors.green
                                  : charge['status'] == 'pending'
                                      ? Colors.orange
                                      : Colors.red,
                            ),
                          ),
                        );
                      },
                    ),
        ],
      ),
    );
  }
}