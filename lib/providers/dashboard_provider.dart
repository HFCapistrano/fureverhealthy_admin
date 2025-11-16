import 'package:flutter/material.dart';
import 'package:furever_healthy_admin/services/database_service.dart';
import '../config/firebase_config.dart';

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
      
      // Calculate revenue from verified payments
      try {
        final firestore = FirebaseConfig.firestore;
        final paymentsSnap = await firestore.collection('payment')
            .where('status', whereIn: ['Verified', 'Approved']) // Support both for compatibility
            .get();
        double revenue = 0.0;
        for (final doc in paymentsSnap.docs) {
          final data = doc.data();
          final amount = data['amount'];
          if (amount is num) {
            revenue += amount.toDouble();
          }
        }
        _revenue = revenue;
      } catch (e) {
        debugPrint('Error calculating revenue: $e');
        _revenue = 0.0;
      }

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
      
      // Load recent activities
      await loadRecentActivities();

      notifyListeners();
    } catch (e) {
      // On error, keep previous values
      debugPrint('Dashboard load error: $e');
    }
  }

  Future<void> loadRecentActivities({int limit = 20}) async {
    try {
      final liveActivities = await DatabaseService.getRecentActivities(limit: limit);
      // If no live activities, use static examples
      if (liveActivities.isEmpty) {
        _recentActivities = _getStaticExampleActivities();
      } else {
        _recentActivities = liveActivities;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading recent activities: $e');
      // Use static examples on error
      _recentActivities = _getStaticExampleActivities();
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _getStaticExampleActivities() {
    final now = DateTime.now();
    return [
      {
        'type': 'payment_notice',
        'id': 'payment_1',
        'title': 'Payment Notice',
        'description': 'New payment submission pending verification',
        'timestamp': now.subtract(const Duration(minutes: 15)),
        'metadata': {
          'transactionId': 'TXN-2024-001234',
          'amount': 150.00,
          'userId': 'user_123',
          'vetId': 'vet_456',
        },
      },
      {
        'type': 'registration',
        'id': 'user_reg_1',
        'title': 'New User Registration',
        'description': 'John Doe registered as a new user',
        'timestamp': now.subtract(const Duration(hours: 1)),
        'metadata': {
          'userName': 'John Doe',
          'email': 'john.doe@example.com',
        },
      },
      {
        'type': 'vet_join',
        'id': 'vet_reg_1',
        'title': 'New Vet Registration',
        'description': 'Dr. Sarah Smith joined as a veterinarian',
        'timestamp': now.subtract(const Duration(hours: 2)),
        'metadata': {
          'vetName': 'Dr. Sarah Smith',
          'clinic': 'Happy Paws Clinic',
        },
      },
      {
        'type': 'appointment',
        'id': 'appt_1',
        'title': 'Appointment Scheduled',
        'description': 'New appointment scheduled with Dr. Sarah Smith',
        'timestamp': now.subtract(const Duration(hours: 3)),
        'metadata': {
          'appointmentId': 'APT-2024-001',
          'userId': 'user_123',
          'vetId': 'vet_456',
          'petName': 'Max',
        },
      },
      {
        'type': 'payment_notice',
        'id': 'payment_2',
        'title': 'Payment Notice',
        'description': 'New payment submission pending verification',
        'timestamp': now.subtract(const Duration(hours: 4)),
        'metadata': {
          'transactionId': 'TXN-2024-001235',
          'amount': 200.00,
          'userId': 'user_789',
          'vetId': 'vet_123',
        },
      },
      {
        'type': 'registration',
        'id': 'user_reg_2',
        'title': 'New User Registration',
        'description': 'Jane Wilson registered as a new user',
        'timestamp': now.subtract(const Duration(hours: 5)),
        'metadata': {
          'userName': 'Jane Wilson',
          'email': 'jane.wilson@example.com',
        },
      },
      {
        'type': 'appointment',
        'id': 'appt_2',
        'title': 'Appointment Completed',
        'description': 'Appointment completed with Dr. Michael Brown',
        'timestamp': now.subtract(const Duration(hours: 6)),
        'metadata': {
          'appointmentId': 'APT-2024-002',
          'userId': 'user_456',
          'vetId': 'vet_789',
          'petName': 'Luna',
        },
      },
      {
        'type': 'vet_join',
        'id': 'vet_reg_2',
        'title': 'New Vet Registration',
        'description': 'Dr. Michael Brown joined as a veterinarian',
        'timestamp': now.subtract(const Duration(hours: 8)),
        'metadata': {
          'vetName': 'Dr. Michael Brown',
          'clinic': 'Animal Care Center',
        },
      },
      {
        'type': 'payment_notice',
        'id': 'payment_3',
        'title': 'Payment Notice',
        'description': 'New payment submission pending verification',
        'timestamp': now.subtract(const Duration(hours: 10)),
        'metadata': {
          'transactionId': 'TXN-2024-001236',
          'amount': 175.50,
          'userId': 'user_321',
          'vetId': 'vet_654',
        },
      },
      {
        'type': 'appointment',
        'id': 'appt_3',
        'title': 'Appointment Scheduled',
        'description': 'New appointment scheduled with Dr. Emily Davis',
        'timestamp': now.subtract(const Duration(hours: 12)),
        'metadata': {
          'appointmentId': 'APT-2024-003',
          'userId': 'user_789',
          'vetId': 'vet_321',
          'petName': 'Bella',
        },
      },
      {
        'type': 'registration',
        'id': 'user_reg_3',
        'title': 'New User Registration',
        'description': 'Robert Taylor registered as a new user',
        'timestamp': now.subtract(const Duration(days: 1)),
        'metadata': {
          'userName': 'Robert Taylor',
          'email': 'robert.taylor@example.com',
        },
      },
      {
        'type': 'payment_notice',
        'id': 'payment_4',
        'title': 'Payment Notice',
        'description': 'New payment submission pending verification',
        'timestamp': now.subtract(const Duration(days: 1, hours: 2)),
        'metadata': {
          'transactionId': 'TXN-2024-001237',
          'amount': 300.00,
          'userId': 'user_654',
          'vetId': 'vet_987',
        },
      },
      {
        'type': 'appointment',
        'id': 'appt_4',
        'title': 'Appointment Completed',
        'description': 'Appointment completed with Dr. Sarah Smith',
        'timestamp': now.subtract(const Duration(days: 1, hours: 4)),
        'metadata': {
          'appointmentId': 'APT-2024-004',
          'userId': 'user_987',
          'vetId': 'vet_456',
          'petName': 'Charlie',
        },
      },
      {
        'type': 'vet_join',
        'id': 'vet_reg_3',
        'title': 'New Vet Registration',
        'description': 'Dr. Emily Davis joined as a veterinarian',
        'timestamp': now.subtract(const Duration(days: 2)),
        'metadata': {
          'vetName': 'Dr. Emily Davis',
          'clinic': 'Pet Wellness Clinic',
        },
      },
      {
        'type': 'payment_notice',
        'id': 'payment_5',
        'title': 'Payment Notice',
        'description': 'New payment submission pending verification',
        'timestamp': now.subtract(const Duration(days: 2, hours: 3)),
        'metadata': {
          'transactionId': 'TXN-2024-001238',
          'amount': 125.75,
          'userId': 'user_147',
          'vetId': 'vet_258',
        },
      },
    ];
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