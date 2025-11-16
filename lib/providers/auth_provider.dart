import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:furever_healthy_admin/services/database_service.dart';
import 'package:furever_healthy_admin/models/admin_user.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userToken;
  String? _userEmail;
  String? _userName;
  String? _userRole;
  Map<String, bool> _permissions = {};
  AdminUser? _adminUser;

  bool get isAuthenticated => _isAuthenticated;
  String? get userToken => _userToken;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get userRole => _userRole;
  Map<String, bool> get permissions => _permissions;
  AdminUser? get adminUser => _adminUser;
  
  bool get isSuperAdmin => _userRole == 'super-admin';
  
  bool hasPermission(String permission) {
    if (isSuperAdmin) return true;
    return _permissions[permission] ?? false;
  }
  
  bool canAccess(String module) {
    if (isSuperAdmin) return true;
    return _permissions.entries
        .any((entry) => entry.key.startsWith('$module.') && entry.value == true);
  }

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _userToken = prefs.getString('user_token');
    _userEmail = prefs.getString('user_email');
    _userName = prefs.getString('user_name');
    _userRole = prefs.getString('user_role');
    
    // Load permissions
    final permissionsJson = prefs.getString('user_permissions');
    if (permissionsJson != null && permissionsJson.isNotEmpty) {
      _permissions = {};
      for (final entry in permissionsJson.split(',')) {
        final parts = entry.split(':');
        if (parts.length == 2) {
          _permissions[parts[0]] = parts[1] == 'true';
        }
      }
    }
    
    _isAuthenticated = _userToken != null;
    
    // If authenticated, refresh admin user data from Firestore
    if (_isAuthenticated && _userEmail != null) {
      try {
        final adminDoc = await DatabaseService.getAdminUserByEmail(_userEmail!);
        if (adminDoc != null && adminDoc.exists) {
          final adminUser = AdminUser.fromMap(
            adminDoc.data() as Map<String, dynamic>,
            adminDoc.id,
          );
          _adminUser = adminUser;
          _permissions = Map<String, bool>.from(adminUser.permissions);
          _userRole = adminUser.role;
        }
      } catch (e) {
        print('Error loading admin user: $e');
      }
    }
    
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      // Verify admin password
      final isValidPassword = await DatabaseService.verifyAdminPassword(email, password);
      if (!isValidPassword) {
        return false;
      }
      
      // Fetch admin user from Firestore
      final adminDoc = await DatabaseService.getAdminUserByEmail(email);
      
      if (adminDoc == null) {
        // If admin doesn't exist, create a default super-admin for first login
        if (email == 'admin@pethealth.com') {
          await DatabaseService.grantAdminAccess(
            email: email,
            name: 'Super Admin',
            role: 'super-admin',
          );
          // Fetch again after creation
          final newAdminDoc = await DatabaseService.getAdminUserByEmail(email);
          if (newAdminDoc != null && newAdminDoc.exists) {
            final adminUser = AdminUser.fromMap(
              newAdminDoc.data() as Map<String, dynamic>,
              newAdminDoc.id,
            );
            await DatabaseService.updateAdminLastLogin(adminUser.id);
            _loadAdminUser(adminUser);
            return true;
          }
        }
        return false;
      }
      
      if (!adminDoc.exists) {
        return false;
      }
      
      final adminUser = AdminUser.fromMap(
        adminDoc.data() as Map<String, dynamic>,
        adminDoc.id,
      );
      
      // Update last login
      await DatabaseService.updateAdminLastLogin(adminUser.id);
      
      _loadAdminUser(adminUser);
      
      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }
  
  void _loadAdminUser(AdminUser adminUser) {
    _adminUser = adminUser;
    _userToken = 'token_${DateTime.now().millisecondsSinceEpoch}';
    _userEmail = adminUser.email;
    _userName = adminUser.name;
    _userRole = adminUser.role;
    _permissions = Map<String, bool>.from(adminUser.permissions);
    _isAuthenticated = true;

    // Save to local storage
    _saveAuthState();
    notifyListeners();
  }
  
  Future<void> _saveAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_token', _userToken!);
    await prefs.setString('user_email', _userEmail!);
    await prefs.setString('user_name', _userName!);
    await prefs.setString('user_role', _userRole!);
    
    // Save permissions as JSON string
    final permissionsJson = _permissions.entries
        .map((e) => '${e.key}:${e.value}')
        .join(',');
    await prefs.setString('user_permissions', permissionsJson);
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _userToken = null;
    _userEmail = null;
    _userName = null;
    _userRole = null;
    _permissions = {};
    _adminUser = null;

    // Clear local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_token');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_role');
    await prefs.remove('user_permissions');

    notifyListeners();
  }

  Future<void> updateUserProfile({String? name, String? email}) async {
    if (name != null) _userName = name;
    if (email != null) _userEmail = email;

    final prefs = await SharedPreferences.getInstance();
    if (name != null) await prefs.setString('user_name', name);
    if (email != null) await prefs.setString('user_email', email);

    notifyListeners();
  }
} 