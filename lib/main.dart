import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:furever_healthy_admin/providers/auth_provider.dart';
import 'package:furever_healthy_admin/providers/dashboard_provider.dart';
import 'package:furever_healthy_admin/routes/app_router.dart';
import 'package:furever_healthy_admin/theme/app_theme.dart';

void main() {
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