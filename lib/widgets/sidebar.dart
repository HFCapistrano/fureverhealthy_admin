import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:furever_healthy_admin/theme/app_theme.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  String? _hoveredRoute;

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          right: BorderSide(color: AppTheme.borderColor),
        ),
      ),
      child: Column(
        children: [
          // Logo Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.borderColor),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.pets,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'FureverHealthy',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          
          // Navigation Menu
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  route: '/dashboard',
                  isActive: currentLocation == '/dashboard',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.people,
                  title: 'Users',
                  route: '/users',
                  isActive: currentLocation == '/users',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.medical_services,
                  title: 'Vets',
                  route: '/vets',
                  isActive: currentLocation == '/vets',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.analytics,
                  title: 'Analytics',
                  route: '/analytics',
                  isActive: currentLocation == '/analytics',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.pets,
                  title: 'Pet Breeds',
                  route: '/pet-breeds',
                  isActive: currentLocation == '/pet-breeds',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.feedback,
                  title: 'Feedbacks',
                  route: '/feedbacks',
                  isActive: currentLocation == '/feedbacks',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.star,
                  title: 'Ratings',
                  route: '/ratings',
                  isActive: currentLocation == '/ratings',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.groups,
                  title: 'Community',
                  route: '/community',
                  isActive: currentLocation == '/community',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  route: '/settings',
                  isActive: currentLocation == '/settings',
                ),
              ],
            ),
          ),
          
          // User Info Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppTheme.borderColor),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin User',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'admin@pethealth.com',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required bool isActive,
  }) {
    final isHovered = _hoveredRoute == route;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredRoute = route),
        onExit: (_) => setState(() => _hoveredRoute = null),
        child: GestureDetector(
          onTap: () {
            print('Navigating to: $route');
            context.go(route);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isActive 
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : isHovered 
                      ? AppTheme.primaryColor.withOpacity(0.05)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isActive
                  ? Border.all(color: AppTheme.primaryColor.withOpacity(0.3))
                  : isHovered
                      ? Border.all(color: AppTheme.primaryColor.withOpacity(0.2))
                      : null,
              boxShadow: isHovered
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isActive 
                        ? AppTheme.primaryColor 
                        : isHovered 
                            ? AppTheme.primaryColor.withOpacity(0.8)
                            : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isActive 
                        ? AppTheme.primaryColor 
                        : isHovered 
                            ? AppTheme.primaryColor.withOpacity(0.8)
                            : AppTheme.textPrimary,
                    fontWeight: isActive || isHovered ? FontWeight.w600 : FontWeight.normal,
                  ) ?? const TextStyle(),
                  child: Text(title),
                ),
                if (isActive) ...[
                  const Spacer(),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
} 