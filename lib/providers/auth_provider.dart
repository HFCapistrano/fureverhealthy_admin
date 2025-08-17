import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userToken;
  String? _userEmail;
  String? _userName;
  String? _userRole;

  bool get isAuthenticated => _isAuthenticated;
  String? get userToken => _userToken;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get userRole => _userRole;

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _userToken = prefs.getString('user_token');
    _userEmail = prefs.getString('user_email');
    _userName = prefs.getString('user_name');
    _userRole = prefs.getString('user_role');
    _isAuthenticated = _userToken != null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock authentication - in real app, this would be an API call
      if (email == 'admin@pethealth.com' && password == 'admin123') {
        _userToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
        _userEmail = email;
        _userName = 'Admin User';
        _userRole = 'admin';
        _isAuthenticated = true;

        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_token', _userToken!);
        await prefs.setString('user_email', _userEmail!);
        await prefs.setString('user_name', _userName!);
        await prefs.setString('user_role', _userRole!);

        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _userToken = null;
    _userEmail = null;
    _userName = null;
    _userRole = null;

    // Clear local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_token');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_role');

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