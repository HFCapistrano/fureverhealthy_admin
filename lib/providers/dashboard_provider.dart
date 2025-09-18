import 'package:flutter/material.dart';
import 'package:furever_healthy_admin/services/database_service.dart';

class DashboardProvider extends ChangeNotifier {
  // Dashboard Statistics
  int _totalUsers = 0;
  int _totalVets = 0;
  int _totalPets = 0;
  int _totalAppointments = 0;
  int _activeAppointments = 0;
  int _completedAppointments = 0;
  double _revenue = 0.0;
  
  // Analytics Data
  List<Map<String, dynamic>> _userGrowth = [];
  List<Map<String, dynamic>> _appointmentTrends = [];
  List<Map<String, dynamic>> _revenueData = [];
  List<Map<String, dynamic>> _topVets = [];
  List<Map<String, dynamic>> _recentActivities = [];

  // Getters
  int get totalUsers => _totalUsers;
  int get totalVets => _totalVets;
  int get totalPets => _totalPets;
  int get totalAppointments => _totalAppointments;
  int get activeAppointments => _activeAppointments;
  int get completedAppointments => _completedAppointments;
  double get revenue => _revenue;
  
  List<Map<String, dynamic>> get userGrowth => _userGrowth;
  List<Map<String, dynamic>> get appointmentTrends => _appointmentTrends;
  List<Map<String, dynamic>> get revenueData => _revenueData;
  List<Map<String, dynamic>> get topVets => _topVets;
  List<Map<String, dynamic>> get recentActivities => _recentActivities;

  DashboardProvider() {
    loadLiveData();
  }

  Future<void> loadLiveData() async {
    try {
      // Fetch counts in parallel
      final results = await Future.wait([
        DatabaseService.getUserCount(),
        DatabaseService.getVetCount(),
        DatabaseService.getPetCount(),
        DatabaseService.getAppointmentCount(),
      ]);

      _totalUsers = results[0];
      _totalVets = results[1];
      _totalPets = results[2];
      _totalAppointments = results[3];

      // Placeholders until we wire real sources
      _activeAppointments = 0;
      _completedAppointments = _totalAppointments;
      _revenue = 0.0;

      // Simple placeholder series to avoid empty UI
      final today = DateTime.now();
      _userGrowth = List.generate(7, (i) {
        final d = today.subtract(Duration(days: 6 - i));
        return {'date': d.toIso8601String().split('T').first, 'users': _totalUsers};
      });
      _appointmentTrends = List.generate(7, (i) {
        final d = today.subtract(Duration(days: 6 - i));
        return {'date': d.toIso8601String().split('T').first, 'appointments': 0};
      });
      _revenueData = List.generate(7, (i) {
        final d = today.subtract(Duration(days: 6 - i));
        return {'date': d.toIso8601String().split('T').first, 'revenue': 0.0};
      });
      _topVets = [];
      _recentActivities = [];

      notifyListeners();
    } catch (e) {
      // On error, keep previous values
      debugPrint('Dashboard load error: $e');
    }
  }

  Future<void> refreshData() async {
    await loadLiveData();
  }

  // Calculate growth percentage
  double get userGrowthPercentage {
    if (_userGrowth.length < 2) return 0.0;
    final current = _userGrowth.last['users'] as int;
    final previous = _userGrowth[_userGrowth.length - 2]['users'] as int;
    return ((current - previous) / (previous == 0 ? 1 : previous) * 100);
  }

  double get appointmentGrowthPercentage {
    if (_appointmentTrends.length < 2) return 0.0;
    final current = _appointmentTrends.last['appointments'] as int;
    final previous = _appointmentTrends[_appointmentTrends.length - 2]['appointments'] as int;
    return ((current - previous) / (previous == 0 ? 1 : previous) * 100);
  }

  double get revenueGrowthPercentage {
    if (_revenueData.length < 2) return 0.0;
    final current = _revenueData.last['revenue'] as double;
    final previous = _revenueData[_revenueData.length - 2]['revenue'] as double;
    return ((current - previous) / (previous == 0 ? 1 : previous) * 100);
  }
} 