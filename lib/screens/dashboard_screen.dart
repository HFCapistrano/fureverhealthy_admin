import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:furever_healthy_admin/providers/auth_provider.dart';
import 'package:furever_healthy_admin/providers/dashboard_provider.dart';
import 'package:furever_healthy_admin/theme/app_theme.dart';
import 'package:furever_healthy_admin/widgets/sidebar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Row(
        children: [
          // Sidebar
          const Sidebar(),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceColor,
                    border: Border(
                      bottom: BorderSide(color: AppTheme.borderColor),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dashboard',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Welcome back, ${context.watch<AuthProvider>().userName ?? 'Admin'}!',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              print('Test button clicked - navigating to users');
                              context.go('/users');
                            },
                            child: const Text('Test Users'),
                          ),
                          const SizedBox(width: 16),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'logout') {
                                context.read<AuthProvider>().logout();
                                context.go('/login');
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'logout',
                                child: Row(
                                  children: [
                                    Icon(Icons.logout),
                                    SizedBox(width: 8),
                                    Text('Logout'),
                                  ],
                                ),
                              ),
                            ],
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Dashboard Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Debug Info
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Consumer<DashboardProvider>(
                            builder: (context, dashboardProvider, child) {
                              return Text(
                                'Dashboard loaded successfully! Total Users: ${dashboardProvider.totalUsers}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              );
                            },
                          ),
                        ),
                        
                        // Simple Stats
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quick Stats',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Consumer<DashboardProvider>(
                                  builder: (context, dashboardProvider, child) {
                                    return Row(
                                      children: [
                                        Expanded(
                                          child: _buildSimpleStat(
                                            'Total Users',
                                            dashboardProvider.totalUsers.toString(),
                                            Icons.people,
                                            AppTheme.primaryColor,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildSimpleStat(
                                            'Total Vets',
                                            dashboardProvider.totalVets.toString(),
                                            Icons.medical_services,
                                            AppTheme.secondaryColor,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildSimpleStat(
                                            'Total Pets',
                                            dashboardProvider.totalPets.toString(),
                                            Icons.pets,
                                            AppTheme.warningColor,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildSimpleStat(
                                            'Revenue',
                                            '\$${dashboardProvider.revenue.toStringAsFixed(0)}',
                                            Icons.attach_money,
                                            AppTheme.successColor,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Timeline View for Recent Activities
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Recent Activities Timeline',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Consumer<DashboardProvider>(
                                  builder: (context, dashboardProvider, child) {
                                    final activities = dashboardProvider.recentActivities;
                                    if (activities.isEmpty) {
                                      return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(24.0),
                                          child: Text('No recent activities'),
                                        ),
                                      );
                                    }
                                    return _buildTimelineView(context, activities);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineView(BuildContext context, List<Map<String, dynamic>> activities) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      separatorBuilder: (context, index) => const SizedBox(height: 0),
      itemBuilder: (context, index) {
        final activity = activities[index];
        final isLast = index == activities.length - 1;
        return _buildTimelineItem(context, activity, isLast);
      },
    );
  }

  Widget _buildTimelineItem(BuildContext context, Map<String, dynamic> activity, bool isLast) {
    final timestamp = activity['timestamp'];
    DateTime activityTime;
    
    if (timestamp is DateTime) {
      activityTime = timestamp;
    } else if (timestamp != null) {
      try {
        activityTime = DateTime.parse(timestamp.toString());
      } catch (e) {
        activityTime = DateTime.now();
      }
    } else {
      activityTime = DateTime.now();
    }

    final timeAgo = _getTimeAgo(activityTime);
    final type = activity['type'] ?? 'info';
    final title = activity['title'] ?? 'Activity';
    final description = activity['description'] ?? '';
    final metadata = activity['metadata'] as Map<String, dynamic>? ?? {};

    IconData icon;
    Color iconColor;
    
    switch (type) {
      case 'payment_notice':
        icon = Icons.payment;
        iconColor = AppTheme.successColor;
        break;
      case 'registration':
        icon = Icons.person_add;
        iconColor = AppTheme.primaryColor;
        break;
      case 'vet_join':
        icon = Icons.medical_services;
        iconColor = AppTheme.secondaryColor;
        break;
      case 'appointment':
        icon = Icons.calendar_today;
        iconColor = AppTheme.warningColor;
        break;
      default:
        icon = Icons.info;
        iconColor = AppTheme.textSecondary;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline line and dot
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: iconColor, width: 2),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: AppTheme.borderColor,
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Activity content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (metadata.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (metadata['transactionId'] != null)
                          _buildMetadataRow('Transaction ID', metadata['transactionId'].toString()),
                        if (metadata['amount'] != null)
                          _buildMetadataRow('Amount', '\$${metadata['amount']}'),
                        if (metadata['userName'] != null)
                          _buildMetadataRow('User', metadata['userName'].toString()),
                        if (metadata['vetName'] != null)
                          _buildMetadataRow('Vet', metadata['vetName'].toString()),
                        if (metadata['petName'] != null)
                          _buildMetadataRow('Pet', metadata['petName'].toString()),
                        if (metadata['appointmentId'] != null)
                          _buildMetadataRow('Appointment ID', metadata['appointmentId'].toString()),
                        if (metadata['clinic'] != null)
                          _buildMetadataRow('Clinic', metadata['clinic'].toString()),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Widget _buildSimpleStat(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
} 