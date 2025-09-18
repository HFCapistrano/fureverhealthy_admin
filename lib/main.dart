import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:furever_healthy_admin/providers/auth_provider.dart';
import 'package:furever_healthy_admin/providers/dashboard_provider.dart';
import 'package:furever_healthy_admin/providers/analytics_provider.dart';
import 'package:furever_healthy_admin/routes/app_router.dart';
import 'package:furever_healthy_admin/theme/app_theme.dart';
import 'package:furever_healthy_admin/config/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await FirebaseConfig.initialize();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Failed to initialize Firebase: $e');
  }
  
  runApp(const PetHealthAdminApp());
}

class PetHealthAdminApp extends StatelessWidget {
  const PetHealthAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
      ],
      child: MaterialApp.router(
        title: 'FureverHealthy Admin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
} 