import 'package:flutter/material.dart';

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
    _loadMockData();
  }

  Future<void> _loadMockData() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock dashboard statistics
    _totalUsers = 1247;
    _totalVets = 89;
    _totalPets = 2156;
    _totalAppointments = 3421;
    _activeAppointments = 156;
    _completedAppointments = 3265;
    _revenue = 45678.90;

    // Mock user growth data (last 7 days)
    _userGrowth = [
      {'date': '2024-01-01', 'users': 1200},
      {'date': '2024-01-02', 'users': 1210},
      {'date': '2024-01-03', 'users': 1225},
      {'date': '2024-01-04', 'users': 1230},
      {'date': '2024-01-05', 'users': 1235},
      {'date': '2024-01-06', 'users': 1240},
      {'date': '2024-01-07', 'users': 1247},
    ];

    // Mock appointment trends (last 7 days)
    _appointmentTrends = [
      {'date': '2024-01-01', 'appointments': 45},
      {'date': '2024-01-02', 'appointments': 52},
      {'date': '2024-01-03', 'appointments': 48},
      {'date': '2024-01-04', 'appointments': 61},
      {'date': '2024-01-05', 'appointments': 58},
      {'date': '2024-01-06', 'appointments': 55},
      {'date': '2024-01-07', 'appointments': 62},
    ];

    // Mock revenue data (last 7 days)
    _revenueData = [
      {'date': '2024-01-01', 'revenue': 6500.0},
      {'date': '2024-01-02', 'revenue': 7200.0},
      {'date': '2024-01-03', 'revenue': 6800.0},
      {'date': '2024-01-04', 'revenue': 8100.0},
      {'date': '2024-01-05', 'revenue': 7800.0},
      {'date': '2024-01-06', 'revenue': 7400.0},
      {'date': '2024-01-07', 'revenue': 8500.0},
    ];

    // Mock top vets
    _topVets = [
      {
        'name': 'Dr. Sarah Johnson',
        'specialty': 'Cardiology',
        'rating': 4.9,
        'appointments': 156,
        'revenue': 12500.0,
      },
      {
        'name': 'Dr. Michael Chen',
        'specialty': 'Surgery',
        'rating': 4.8,
        'appointments': 142,
        'revenue': 11800.0,
      },
      {
        'name': 'Dr. Emily Davis',
        'specialty': 'Dermatology',
        'rating': 4.7,
        'appointments': 128,
        'revenue': 10200.0,
      },
      {
        'name': 'Dr. Robert Wilson',
        'specialty': 'Emergency',
        'rating': 4.6,
        'appointments': 115,
        'revenue': 9800.0,
      },
    ];

    // Mock recent activities
    _recentActivities = [
      {
        'type': 'appointment',
        'message': 'New appointment scheduled with Dr. Sarah Johnson',
        'time': DateTime.now().subtract(const Duration(minutes: 5)),
        'user': 'John Smith',
        'pet': 'Buddy (Golden Retriever)',
      },
      {
        'type': 'registration',
        'message': 'New user registered: Mary Johnson',
        'time': DateTime.now().subtract(const Duration(minutes: 15)),
        'user': 'Mary Johnson',
        'pet': null,
      },
      {
        'type': 'payment',
        'message': 'Payment received for appointment #3421',
        'time': DateTime.now().subtract(const Duration(minutes: 30)),
        'user': 'David Brown',
        'pet': 'Luna (Persian Cat)',
      },
      {
        'type': 'vet_join',
        'message': 'New vet joined: Dr. Lisa Anderson',
        'time': DateTime.now().subtract(const Duration(hours: 1)),
        'user': 'Dr. Lisa Anderson',
        'pet': null,
      },
      {
        'type': 'appointment',
        'message': 'Appointment completed with Dr. Michael Chen',
        'time': DateTime.now().subtract(const Duration(hours: 2)),
        'user': 'Sarah Wilson',
        'pet': 'Max (Labrador)',
      },
    ];

    notifyListeners();
  }

  Future<void> refreshData() async {
    await _loadMockData();
  }

  // Calculate growth percentage
  double get userGrowthPercentage {
    if (_userGrowth.length < 2) return 0.0;
    final current = _userGrowth.last['users'] as int;
    final previous = _userGrowth[_userGrowth.length - 2]['users'] as int;
    return ((current - previous) / previous * 100);
  }

  double get appointmentGrowthPercentage {
    if (_appointmentTrends.length < 2) return 0.0;
    final current = _appointmentTrends.last['appointments'] as int;
    final previous = _appointmentTrends[_appointmentTrends.length - 2]['appointments'] as int;
    return ((current - previous) / previous * 100);
  }

  double get revenueGrowthPercentage {
    if (_revenueData.length < 2) return 0.0;
    final current = _revenueData.last['revenue'] as double;
    final previous = _revenueData[_revenueData.length - 2]['revenue'] as double;
    return ((current - previous) / previous * 100);
  }
} 