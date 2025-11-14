import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:furever_healthy_admin/theme/app_theme.dart';
import 'package:furever_healthy_admin/widgets/sidebar.dart';
import 'package:furever_healthy_admin/providers/analytics_provider.dart';
import 'package:furever_healthy_admin/models/analytics_data.dart';
import 'package:furever_healthy_admin/services/database_service.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'Last 30 Days';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoadingReports = false;
  Map<String, dynamic> _reportData = {};

  @override
  void initState() {
    super.initState();
    // Load analytics data from Firebase when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().loadAnalyticsData();
      _loadReports();
    });
  }

  Future<void> _loadReports() async {
    setState(() => _isLoadingReports = true);
    try {
      final results = await Future.wait([
        DatabaseService.getActiveUsersCount(startDate: _startDate, endDate: _endDate),
        DatabaseService.getActiveVetsCount(startDate: _startDate, endDate: _endDate),
        DatabaseService.getAppointmentFunnel(startDate: _startDate, endDate: _endDate),
        DatabaseService.getCancellationReasons(startDate: _startDate, endDate: _endDate),
        DatabaseService.getTopFeedbackCategories(startDate: _startDate, endDate: _endDate),
      ]);

      setState(() {
        _reportData = {
          'activeUsers': results[0] as int,
          'activeVets': results[1] as int,
          'appointmentFunnel': results[2] as Map<String, dynamic>,
          'cancellationReasons': results[3] as Map<String, int>,
          'topFeedbackCategories': results[4] as Map<String, int>,
        };
        _isLoadingReports = false;
      });
    } catch (e) {
      setState(() => _isLoadingReports = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading reports: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadReports();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceColor,
                    border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Analytics',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Detailed analytics and insights',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.end,
                          children: [
                            Consumer<AnalyticsProvider>(
                              builder: (context, provider, child) {
                                if (provider.isLoading) {
                                  return const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  );
                                }
                                return IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () => provider.refreshData(),
                                  tooltip: 'Refresh Data',
                                );
                              },
                            ),
                            DropdownButton<String>(
                              value: _selectedPeriod,
                              items: const [
                                DropdownMenuItem(value: 'Last 7 Days', child: Text('Last 7 Days')),
                                DropdownMenuItem(value: 'Last 30 Days', child: Text('Last 30 Days')),
                                DropdownMenuItem(value: 'Last 90 Days', child: Text('Last 90 Days')),
                                DropdownMenuItem(value: 'Last Year', child: Text('Last Year')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedPeriod = value!;
                                });
                              },
                            ),
                            ElevatedButton.icon(
                              onPressed: _selectDateRange,
                              icon: const Icon(Icons.date_range),
                              label: Text(
                                _startDate != null && _endDate != null
                                    ? '${DateFormat('MMM d').format(_startDate!)} - ${DateFormat('MMM d').format(_endDate!)}'
                                    : 'Select Date Range',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: Consumer<AnalyticsProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading && provider.analyticsData == null) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (provider.error != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading analytics data',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                provider.error!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => provider.refreshData(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      final analyticsData = provider.analyticsData;
                      if (analyticsData == null) {
                        return const Center(
                          child: Text('No analytics data available'),
                        );
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Key Metrics Row 1
                            Row(
                              children: [
                                Flexible(
                                  child: _buildMetricCard(
                                    title: 'Total Users',
                                    value: '${analyticsData.totalUsers}',
                                    change: '+12.5%',
                                    isPositive: true,
                                    icon: Icons.people,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Flexible(
                                  child: _buildMetricCard(
                                    title: 'Premium Users',
                                    value: '${analyticsData.premiumUsers}',
                                    change: '+18.2%',
                                    isPositive: true,
                                    icon: Icons.star,
                                    color: Colors.amber,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Flexible(
                                  child: _buildMetricCard(
                                    title: 'Active Vets',
                                    value: '${analyticsData.activeVets}',
                                    change: '+8.2%',
                                    isPositive: true,
                                    icon: Icons.medical_services,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Flexible(
                                  child: _buildMetricCard(
                                    title: 'Premium Vets',
                                    value: '${analyticsData.premiumVets}',
                                    change: '+15.7%',
                                    isPositive: true,
                                    icon: Icons.verified,
                                    color: Colors.purple,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Key Metrics Row 2
                            Row(
                              children: [
                                Flexible(
                                  child: _buildMetricCard(
                                    title: 'Total Appointments',
                                    value: '${analyticsData.totalAppointments}',
                                    change: '+15.3%',
                                    isPositive: true,
                                    icon: Icons.calendar_today,
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Flexible(
                                  child: _buildMetricCard(
                                    title: 'Revenue',
                                    value: '\$${analyticsData.revenue.toStringAsFixed(0)}',
                                    change: '+22.1%',
                                    isPositive: true,
                                    icon: Icons.attach_money,
                                    color: Colors.teal,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Flexible(
                                  child: _buildMetricCard(
                                    title: 'Avg. Rating',
                                    value: analyticsData.averageRating.toStringAsFixed(1),
                                    change: '+0.2',
                                    isPositive: true,
                                    icon: Icons.star_rate,
                                    color: Colors.indigo,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Flexible(
                                  child: _buildMetricCard(
                                    title: 'Pet Breeds',
                                    value: '${analyticsData.petBreeds}',
                                    change: '+5.2%',
                                    isPositive: true,
                                    icon: Icons.pets,
                                    color: Colors.pink,
                                  ),
                                ),
                              ],
                            ),
                                
                                const SizedBox(height: 24),
                                
                                // Charts Row
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: _buildChartCard(
                                        title: 'User Growth Trend',
                                        child: _buildUserGrowthChart(analyticsData.userGrowth),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildChartCard(
                                        title: 'Pet Categories Distribution',
                                        child: _buildPetCategoriesChart(analyticsData.petCategories),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Bottom Row
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: _buildChartCard(
                                        title: 'Appointment Trends',
                                        child: _buildAppointmentTrendsChart(analyticsData.appointmentTrends),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildChartCard(
                                        title: 'Top Breeds',
                                        child: _buildTopBreedsList(analyticsData.topBreeds),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Additional Insights Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildChartCard(
                                        title: 'Premium vs Regular Users',
                                        child: _buildPremiumComparisonChart(analyticsData),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildChartCard(
                                        title: 'Vet Verification Status',
                                        child: _buildVetVerificationChart(analyticsData),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 48),
                                
                                // Divider
                                const Divider(thickness: 2),
                                
                                const SizedBox(height: 48),
                                
                                // Reports & KPIs Section Header
                                Text(
                                  'Reports & KPIs',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
                                // KPI Cards
                                if (_isLoadingReports)
                                  const Center(child: Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: CircularProgressIndicator(),
                                  ))
                                else
                                  Row(
                                    children: [
                                      Flexible(
                                        child: _buildKPICard(
                                          'Active Users',
                                          '${_reportData['activeUsers'] ?? 0}',
                                          Icons.people,
                                          AppTheme.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Flexible(
                                        child: _buildKPICard(
                                          'Active Vets',
                                          '${_reportData['activeVets'] ?? 0}',
                                          Icons.medical_services,
                                          AppTheme.successColor,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Flexible(
                                        child: _buildKPICard(
                                          'Scheduled',
                                          '${(_reportData['appointmentFunnel'] as Map?)?['scheduled'] ?? 0}',
                                          Icons.calendar_today,
                                          Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Flexible(
                                        child: _buildKPICard(
                                          'Completed',
                                          '${(_reportData['appointmentFunnel'] as Map?)?['completed'] ?? 0}',
                                          Icons.check_circle,
                                          Colors.green,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Flexible(
                                        child: _buildKPICard(
                                          'Cancelled',
                                          '${(_reportData['appointmentFunnel'] as Map?)?['cancelled'] ?? 0}',
                                          Icons.cancel,
                                          Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),

                                const SizedBox(height: 24),

                                // Appointment Funnel
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.timeline, color: AppTheme.primaryColor),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Appointment Funnel',
                                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        _buildFunnelVisualization(
                                          _reportData['appointmentFunnel'] as Map<String, dynamic>? ?? {},
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Top Feedback Categories and Cancellation Reasons
                                Row(
                                  children: [
                                    // Top Feedback Categories
                                    Expanded(
                                      child: Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(24),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(Icons.feedback, color: AppTheme.primaryColor),
                                                  const SizedBox(width: 8),
                                                  Flexible(
                                                    child: Text(
                                                      'Top Feedback Categories',
                                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 24),
                                              _buildCategoryList(
                                                _reportData['topFeedbackCategories'] as Map<String, int>? ?? {},
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Cancellation Reasons
                                    Expanded(
                                      child: Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(24),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(Icons.cancel, color: Colors.red),
                                                  const SizedBox(width: 8),
                                                  Flexible(
                                                    child: Text(
                                                      'Cancellation Reasons',
                                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 24),
                                              _buildReasonList(
                                                _reportData['cancellationReasons'] as Map<String, int>? ?? {},
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                        height: 1.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFunnelVisualization(Map<String, dynamic> funnel) {
    final total = funnel['total'] ?? 1;
    final scheduled = (funnel['scheduled'] ?? 0) as int;
    final completed = (funnel['completed'] ?? 0) as int;
    final cancelled = (funnel['cancelled'] ?? 0) as int;

    return Column(
      children: [
        _buildFunnelBar('Scheduled', scheduled, total, Colors.blue),
        const SizedBox(height: 8),
        _buildFunnelBar('Completed', completed, total, Colors.green),
        const SizedBox(height: 8),
        _buildFunnelBar('Cancelled', cancelled, total, Colors.red),
      ],
    );
  }

  Widget _buildFunnelBar(String label, int value, int total, Color color) {
    final percentage = total > 0 ? (value / total * 100) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              '$value (${percentage.toStringAsFixed(1)}%)',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: total > 0 ? value / total : 0,
            minHeight: 24,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList(Map<String, int> categories) {
    if (categories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No feedback categories found'),
        ),
      );
    }

    final entries = categories.entries.toList();
    final maxCount = entries.isNotEmpty ? entries.first.value : 1;

    return Column(
      children: entries.take(5).map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: entry.value / maxCount,
                    minHeight: 20,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text(
                  '${entry.value}',
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReasonList(Map<String, int> reasons) {
    if (reasons.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No cancellation reasons found'),
        ),
      );
    }

    final entries = reasons.entries.toList();
    final maxCount = entries.isNotEmpty ? entries.first.value : 1;

    return Column(
      children: entries.take(5).map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  entry.key.isEmpty ? 'Not specified' : entry.key,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: entry.value / maxCount,
                    minHeight: 20,
                    backgroundColor: Colors.red.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text(
                  '${entry.value}',
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      change,
                      style: TextStyle(
                        color: isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildUserGrowthChart(Map<String, int> userGrowth) {
    // Calculate trend from userGrowth data
    final entries = userGrowth.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    bool? isPositive;
    double changePercent = 0.0;
    String changeText = 'No data';
    bool hasData = false;
    int totalUsers = 0;
    int recentUsers = 0;
    
    if (entries.isNotEmpty) {
      // Get total and recent counts
      recentUsers = entries.last.value;
      totalUsers = recentUsers;
      
      // Try to calculate trend if we have at least 2 entries
      if (entries.length >= 2) {
        final recent = entries.last.value;
        final previous = entries[entries.length - 2].value;
        
        if (previous > 0) {
          changePercent = ((recent - previous) / previous * 100);
          isPositive = changePercent >= 0;
          changeText = '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(1)}%';
          hasData = true;
        } else if (recent > 0) {
          // If previous was 0 but recent has data, show positive growth
          changeText = '+100%';
          isPositive = true;
          hasData = true;
        }
      } else if (recentUsers > 0) {
        // If we only have one data point with users, show it
        changeText = '$recentUsers users';
        hasData = true;
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (hasData && isPositive != null) ...[
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isPositive ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                changeText,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: hasData 
                    ? (isPositive != null ? (isPositive ? Colors.green : Colors.red) : AppTheme.primaryColor)
                    : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          if (hasData && isPositive != null) ...[
            const SizedBox(height: 8),
            Text(
              isPositive ? 'User growth increased' : 'User growth decreased',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
          if (entries.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Total Users: $totalUsers',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last 30 days: ${entries.where((e) => e.value > 0).length} days with activity',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPetCategoriesChart(Map<String, double> petCategories) {
    return Column(
      children: petCategories.entries.map((entry) {
        final label = entry.key;
        final percentage = entry.value;
        return _buildPieChartSegment(label, percentage, _getColorForCategory(label));
      }).toList(),
    );
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Dogs':
        return Colors.blue;
      case 'Cats':
        return Colors.orange;
      case 'Birds':
        return Colors.purple;
      case 'Fish':
        return Colors.teal;
      case 'Reptiles':
        return Colors.indigo;
      case 'Other':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  Widget _buildPieChartSegment(String label, double percentage, Color color) {
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
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Text(
          '$percentage%',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentTrendsChart(Map<String, int> appointmentTrends) {
    // Calculate trend from appointmentTrends data
    final entries = appointmentTrends.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    bool? isPositive;
    double changePercent = 0.0;
    String changeText = 'No data';
    bool hasData = false;
    int totalAppointments = 0;
    int recentAppointments = 0;
    
    if (entries.isNotEmpty) {
      // Calculate total appointments in the period
      totalAppointments = entries.fold(0, (sum, entry) => sum + entry.value);
      recentAppointments = entries.last.value;
      
      // Try to calculate trend if we have at least 2 entries
      if (entries.length >= 2) {
        final recent = entries.last.value;
        final previous = entries[entries.length - 2].value;
        
        if (previous > 0) {
          changePercent = ((recent - previous) / previous * 100);
          isPositive = changePercent >= 0;
          changeText = '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(1)}%';
          hasData = true;
        } else if (recent > 0) {
          // If previous was 0 but recent has data, show positive growth
          changeText = '+100%';
          isPositive = true;
          hasData = true;
        } else if (totalAppointments > 0) {
          // Show total if we have appointments but can't calculate trend
          changeText = '$totalAppointments total';
          hasData = true;
        }
      } else if (totalAppointments > 0) {
        // If we have appointments but only one data point, show total
        changeText = '$totalAppointments appointments';
        hasData = true;
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (hasData && isPositive != null) ...[
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isPositive ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                changeText,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: hasData 
                    ? (isPositive != null ? (isPositive ? Colors.green : Colors.red) : AppTheme.primaryColor)
                    : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          if (hasData && isPositive != null) ...[
            const SizedBox(height: 8),
            Text(
              isPositive ? 'Appointments increased' : 'Appointments decreased',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
          if (entries.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Total (30 days): $totalAppointments',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Today: $recentAppointments',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Active days: ${entries.where((e) => e.value > 0).length}',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTopBreedsList(List<Map<String, dynamic>> topBreeds) {
    return Column(
      children: topBreeds.map((breed) {
        final name = breed['name'] as String;
        final count = breed['count'] as int;
        final percentage = breed['percentage'] as double;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Text(
                '$count',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${percentage.toStringAsFixed(1)}%)',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPremiumComparisonChart(AnalyticsData analyticsData) {
    final totalUsers = analyticsData.totalUsers;
    final premiumUsers = analyticsData.premiumUsers;
    final totalVets = analyticsData.activeVets;
    final premiumVets = analyticsData.premiumVets;

    return Column(
      children: [
        _buildComparisonBar('Premium Users', premiumUsers, totalUsers, Colors.amber),
        const SizedBox(height: 12),
        _buildComparisonBar('Regular Users', totalUsers - premiumUsers, totalUsers, Colors.blue),
        const SizedBox(height: 12),
        _buildComparisonBar('Premium Vets', premiumVets, totalVets, Colors.purple),
        const SizedBox(height: 12),
        _buildComparisonBar('Regular Vets', totalVets - premiumVets, totalVets, Colors.green),
      ],
    );
  }

  Widget _buildComparisonBar(String label, int value, int total, Color color) {
    final percentage = (value / total * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            Text(
              '$value ($percentage%)',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.borderColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value / total,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVetVerificationChart(AnalyticsData analyticsData) {
    final totalVets = analyticsData.activeVets;
    // For now, we'll assume 85% of vets are verified (this should come from Firebase data)
    final verifiedVets = (totalVets * 0.85).round();
    final unverifiedVets = totalVets - verifiedVets;

          return Column(
        children: [
          _buildPieChartSegment('Verified Vets', verifiedVets.toDouble(), Colors.green),
          const SizedBox(height: 8),
          _buildPieChartSegment('Unverified Vets', unverifiedVets.toDouble(), Colors.orange),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${(verifiedVets / totalVets * 100).toStringAsFixed(1)}% Verified',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$verifiedVets out of $totalVets vets',
                      style: TextStyle(
                        color: Colors.green.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
