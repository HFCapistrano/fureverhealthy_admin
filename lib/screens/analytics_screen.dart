import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:furever_healthy_admin/theme/app_theme.dart';
import 'package:furever_healthy_admin/widgets/sidebar.dart';
import 'package:furever_healthy_admin/providers/analytics_provider.dart';
import 'package:furever_healthy_admin/models/analytics_data.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'Last 30 Days';

  @override
  void initState() {
    super.initState();
    // Load analytics data from Firebase when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().loadAnalyticsData();
    });
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
                      Row(
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
                          const SizedBox(width: 16),
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
                        ],
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
                                Expanded(
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
                                Expanded(
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
                                Expanded(
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
                                Expanded(
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
                                Expanded(
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
                                Expanded(
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
                                Expanded(
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
                                Expanded(
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

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Container(
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
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
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
            SizedBox(
              height: 200,
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserGrowthChart(Map<String, int> userGrowth) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        size: const Size(double.infinity, 200),
        painter: LineChartPainter(),
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
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        size: const Size(double.infinity, 200),
        painter: BarChartPainter(),
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
                style: TextStyle(
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
              Icon(Icons.verified, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${(verifiedVets / totalVets * 100).toStringAsFixed(1)}% Verified',
                      style: TextStyle(
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

class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.2, size.height * 0.6),
      Offset(size.width * 0.4, size.height * 0.7),
      Offset(size.width * 0.6, size.height * 0.4),
      Offset(size.width * 0.8, size.height * 0.3),
      Offset(size.width, size.height * 0.2),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 5, pointPaint);
    }

    // Draw grid lines
    final gridPaint = Paint()
      ..color = AppTheme.borderColor
      ..strokeWidth = 1;

    for (int i = 1; i < 5; i++) {
      final y = size.height * (i / 5);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.fill;

    final barWidth = size.width / 7;
    final maxHeight = size.height * 0.8;
    final heights = [0.6, 0.8, 0.5, 0.9, 0.7, 0.4, 0.6];

    for (int i = 0; i < heights.length; i++) {
      final barHeight = maxHeight * heights[i];
      final rect = Rect.fromLTWH(
        i * barWidth + barWidth * 0.1,
        size.height - barHeight,
        barWidth * 0.8,
        barHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        paint,
      );
    }

    // Draw grid lines
    final gridPaint = Paint()
      ..color = AppTheme.borderColor
      ..strokeWidth = 1;

    for (int i = 1; i < 5; i++) {
      final y = size.height * (i / 5);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 