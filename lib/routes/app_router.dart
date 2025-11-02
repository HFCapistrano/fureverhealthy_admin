import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:furever_healthy_admin/providers/auth_provider.dart';
import 'package:furever_healthy_admin/screens/login_screen.dart';
import 'package:furever_healthy_admin/screens/dashboard_screen.dart';
import 'package:furever_healthy_admin/screens/users_screen.dart';
import 'package:furever_healthy_admin/screens/vets_screen.dart';
import 'package:furever_healthy_admin/screens/analytics_screen.dart';
import 'package:furever_healthy_admin/screens/pet_breeds_screen.dart';
import 'package:furever_healthy_admin/screens/settings_screen.dart';
import 'package:furever_healthy_admin/screens/feedbacks_screen.dart';
import 'package:furever_healthy_admin/screens/community_screen.dart';
import 'package:furever_healthy_admin/screens/user_detail_screen.dart';
import 'package:furever_healthy_admin/screens/vet_detail_screen.dart';
import 'package:furever_healthy_admin/screens/admin_management_screen.dart';
import 'package:furever_healthy_admin/screens/contents_screen.dart';
import 'package:furever_healthy_admin/screens/content_editor_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // If user is not authenticated and trying to access protected routes
      if (!authProvider.isAuthenticated && state.matchedLocation != '/login') {
        return '/login';
      }
      
      // If user is authenticated and on login page, redirect to dashboard
      if (authProvider.isAuthenticated && state.matchedLocation == '/login') {
        return '/dashboard';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        redirect: (context, state) => '/dashboard',
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/users',
        name: 'users',
        builder: (context, state) => const UsersScreen(),
      ),
      GoRoute(
        path: '/vets',
        name: 'vets',
        builder: (context, state) => const VetsScreen(),
      ),
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/pet-breeds',
        name: 'pet-breeds',
        builder: (context, state) => const PetBreedsScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/feedbacks',
        name: 'feedbacks',
        builder: (context, state) => const FeedbacksScreen(),
      ),
      GoRoute(
        path: '/community',
        name: 'community',
        builder: (context, state) => const CommunityScreen(),
      ),
      GoRoute(
        path: '/users/:userId',
        name: 'user-detail',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return UserDetailScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/vets/:vetId',
        name: 'vet-detail',
        builder: (context, state) {
          final vetId = state.pathParameters['vetId']!;
          return VetDetailScreen(vetId: vetId);
        },
      ),
      GoRoute(
        path: '/admin-management',
        name: 'admin-management',
        builder: (context, state) => const AdminManagementScreen(),
      ),
      GoRoute(
        path: '/contents',
        name: 'contents',
        builder: (context, state) => const ContentsScreen(),
      ),
      GoRoute(
        path: '/contents/new',
        name: 'content-new',
        builder: (context, state) => const ContentEditorScreen(),
      ),
      GoRoute(
        path: '/contents/:contentId/edit',
        name: 'content-edit',
        builder: (context, state) {
          final contentId = state.pathParameters['contentId']!;
          return ContentEditorScreen(contentId: contentId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
} 