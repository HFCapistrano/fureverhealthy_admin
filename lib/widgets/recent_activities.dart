import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:furever_healthy_admin/providers/dashboard_provider.dart';
import 'package:furever_healthy_admin/theme/app_theme.dart';

class RecentActivities extends StatelessWidget {
  const RecentActivities({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activities',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<DashboardProvider>(
                builder: (context, dashboardProvider, child) {
                  return ListView.builder(
                    itemCount: dashboardProvider.recentActivities.length,
                    itemBuilder: (context, index) {
                      final activity = dashboardProvider.recentActivities[index];
                      return _buildActivityItem(context, activity);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, Map<String, dynamic> activity) {
    final timeAgo = _getTimeAgo(activity['time'] as DateTime);
    
    IconData icon;
    Color iconColor;
    
    switch (activity['type']) {
      case 'appointment':
        icon = Icons.calendar_today;
        iconColor = AppTheme.primaryColor;
        break;
      case 'registration':
        icon = Icons.person_add;
        iconColor = AppTheme.secondaryColor;
        break;
      case 'payment':
        icon = Icons.payment;
        iconColor = AppTheme.successColor;
        break;
      case 'vet_join':
        icon = Icons.medical_services;
        iconColor = AppTheme.warningColor;
        break;
      default:
        icon = Icons.info;
        iconColor = AppTheme.textSecondary;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['message'],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      activity['user'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    if (activity['pet'] != null) ...[
                      const Text(' • '),
                      Text(
                        activity['pet'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  timeAgo,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
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
} 