import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:furever_healthy_admin/providers/auth_provider.dart';

class PermissionGate extends StatelessWidget {
  final String permission;
  final Widget child;
  final Widget? fallback;

  const PermissionGate({
    super.key,
    required this.permission,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    
    if (authProvider.hasPermission(permission)) {
      return child;
    }
    
    return fallback ?? const SizedBox.shrink();
  }
}

