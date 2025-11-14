import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/firebase_config.dart';
import '../models/analytics_data.dart';
import '../services/database_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  AnalyticsData? _analyticsData;
  bool _isLoading = false;
  String? _error;

  AnalyticsData? get analyticsData => _analyticsData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize with default data
  AnalyticsProvider() {
    _initializeDefaultData();
  }

  void _initializeDefaultData() {
    _analyticsData = AnalyticsData(
      totalUsers: 0,
      premiumUsers: 0,
      activeVets: 0,
      premiumVets: 0,
      totalAppointments: 0,
      revenue: 0.0,
      averageRating: 0.0,
      petBreeds: 0,
      petCategories: {
        'Dogs': 0,
        'Cats': 0,
      },
      topBreeds: const [],
      userGrowth: const {},
      appointmentTrends: const {},
    );
  }

  Future<void> loadAnalyticsData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Attempt to load persisted analytics doc (optional)
      final persisted = await DatabaseService.getAnalyticsData();

      // Compute live metrics from Firestore
      final firestore = FirebaseConfig.firestore;

      // Run independent queries in parallel
      final results = await Future.wait([
        DatabaseService.getUserCount(),
        DatabaseService.getVetCount(),
        DatabaseService.getAppointmentCount(),
        DatabaseService.getPetCount(),
        firestore.collection('vets').get(), // for avg rating, premiumVets
        firestore.collection('pets').get(), // for dog/cat split
        firestore.collection('petBreeds').get(), // for top breeds and count
        firestore.collection('appointments').get(), // for appointment trends
      ]);

      final totalUsers = results[0] as int;
      final totalVets = results[1] as int;
      final totalAppointments = results[2] as int;
      // final totalPets = results[3] as int; // available if needed later
      final vetsSnap = results[4] as QuerySnapshot;
      final petsSnap = results[5] as QuerySnapshot;
      final breedsSnap = results[6] as QuerySnapshot;
      final appointmentsSnap = results[7] as QuerySnapshot;

      // premium users (optional flag isPremium on users). If not present, 0.
      int premiumUsers = 0;
      try {
        final prem = await firestore.collection('users').where('isPremium', isEqualTo: true).get();
        premiumUsers = prem.docs.length;
      } catch (_) {}

      // premium vets and avg rating
      int premiumVets = 0;
      double ratingSum = 0.0;
      int ratingCount = 0;
      for (final d in vetsSnap.docs) {
        final data = d.data() as Map<String, dynamic>;
        if ((data['userType'] ?? '') == 'premium') premiumVets++;
        final r = data['rating'];
        if (r is num) {
          ratingSum += r.toDouble();
          ratingCount++;
        }
      }
      final averageRating = ratingCount == 0 ? 0.0 : (ratingSum / ratingCount);

      // pet categories split (Dogs/Cats only)
      int dogCount = 0;
      int catCount = 0;
      for (final d in petsSnap.docs) {
        final data = d.data() as Map<String, dynamic>;
        final species = (data['species'] ?? '').toString();
        if (species == 'Dog') dogCount++;
        if (species == 'Cat') catCount++;
      }
      final totalSpecies = (dogCount + catCount);
      final petCategories = <String, double>{
        'Dogs': totalSpecies == 0 ? 0.0 : (dogCount / totalSpecies * 100).toDouble(),
        'Cats': totalSpecies == 0 ? 0.0 : (catCount / totalSpecies * 100).toDouble(),
      };

      // top breeds (from petBreeds or from pets usage). Here: from petBreeds popularity if present
      final List<Map<String, dynamic>> topBreeds = breedsSnap.docs.take(5).map((d) {
        final data = d.data() as Map<String, dynamic>;
        return {
          'name': data['name'] ?? 'Unknown',
          'count': 0, // unknown without usage aggregation
          'percentage': 0.0,
        };
      }).toList();

      // Calculate appointment trends from actual appointments
      final Map<String, int> appointmentTrends = {};
      final now = DateTime.now();
      
      // Group appointments by date (last 30 days)
      for (int i = 29; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        appointmentTrends[dateKey] = 0;
      }
      
      // Count appointments per day
      int appointmentsWithoutDate = 0;
      for (final doc in appointmentsSnap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Try multiple possible date fields
        dynamic dateValue = data['createdAt'] ?? data['date'] ?? data['appointmentDate'] ?? data['created'];
        
        DateTime appointmentDate = now; // Default to today
        bool hasValidDate = false;
        
        if (dateValue != null) {
          if (dateValue is Timestamp) {
            appointmentDate = dateValue.toDate();
            hasValidDate = true;
          } else if (dateValue is DateTime) {
            appointmentDate = dateValue;
            hasValidDate = true;
          }
        }
        
        // If no valid date found, use today's date as fallback (so appointment is still counted)
        if (!hasValidDate) {
          appointmentsWithoutDate++;
        }
        
        final dateKey = '${appointmentDate.year}-${appointmentDate.month.toString().padLeft(2, '0')}-${appointmentDate.day.toString().padLeft(2, '0')}';
        
        // Count the appointment for its date (or today if no date)
        if (appointmentTrends.containsKey(dateKey)) {
          appointmentTrends[dateKey] = (appointmentTrends[dateKey] ?? 0) + 1;
        } else {
          // If outside the 30-day window, add it to today's count to ensure it's visible
          final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
          if (appointmentTrends.containsKey(todayKey)) {
            appointmentTrends[todayKey] = (appointmentTrends[todayKey] ?? 0) + 1;
          }
        }
      }
      
      // Debug: log if we found appointments without dates
      if (appointmentsWithoutDate > 0) {
        debugPrint('Found $appointmentsWithoutDate appointments without date fields');
      }
      
      // Sort and ensure we have a continuous 30-day range ending today
      final sortedKeys = appointmentTrends.keys.toList()..sort();
      if (sortedKeys.isNotEmpty) {
        // Get the most recent 30 days
        final last30Days = <String, int>{};
        final today = now;
        for (int i = 29; i >= 0; i--) {
          final date = today.subtract(Duration(days: i));
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          last30Days[dateKey] = appointmentTrends[dateKey] ?? 0;
        }
        appointmentTrends.clear();
        appointmentTrends.addAll(last30Days);
      }

      // Calculate user growth trends (last 30 days)
      final Map<String, int> userGrowth = {};
      final usersSnap = await firestore.collection('users').get();
      
      for (int i = 29; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        userGrowth[dateKey] = 0;
      }
      
      // Count users per day based on joinDate
      for (final doc in usersSnap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final joinDate = data['joinDate'];
        if (joinDate != null) {
          DateTime userDate;
          if (joinDate is Timestamp) {
            userDate = joinDate.toDate();
          } else if (joinDate is DateTime) {
            userDate = joinDate;
          } else {
            continue;
          }
          
          final dateKey = '${userDate.year}-${userDate.month.toString().padLeft(2, '0')}-${userDate.day.toString().padLeft(2, '0')}';
          if (userGrowth.containsKey(dateKey)) {
            userGrowth[dateKey] = (userGrowth[dateKey] ?? 0) + 1;
          }
        }
      }
      
      // Calculate cumulative user growth
      int cumulativeUsers = 0;
      final userGrowthKeys = userGrowth.keys.toList()..sort();
      for (final key in userGrowthKeys) {
        cumulativeUsers += userGrowth[key] ?? 0;
        userGrowth[key] = cumulativeUsers;
      }
      
      // If no users found, at least show the total users count on today's date
      if (cumulativeUsers == 0 && totalUsers > 0) {
        final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        userGrowth[todayKey] = totalUsers;
      }

      // Build analytics data, preferring persisted values for charts if available
      final persistedMap = persisted;
      _analyticsData = AnalyticsData(
        totalUsers: totalUsers,
        premiumUsers: premiumUsers,
        activeVets: totalVets,
        premiumVets: premiumVets,
        totalAppointments: totalAppointments,
        revenue: (persistedMap['revenue'] ?? 0).toDouble(),
        averageRating: averageRating,
        petBreeds: breedsSnap.docs.length,
        petCategories: petCategories,
        topBreeds: persistedMap['topBreeds'] is List ? List<Map<String, dynamic>>.from(persistedMap['topBreeds']) : topBreeds,
        userGrowth: userGrowth.isNotEmpty 
            ? userGrowth
            : (persistedMap['userGrowth'] is Map<String, dynamic>
                ? Map<String, int>.from((persistedMap['userGrowth'] as Map).map((k, v) => MapEntry(k.toString(), (v as num).toInt())))
                : <String, int>{}),
        appointmentTrends: appointmentTrends.isNotEmpty
            ? appointmentTrends
            : (persistedMap['appointmentTrends'] is Map<String, dynamic>
                ? Map<String, int>.from((persistedMap['appointmentTrends'] as Map).map((k, v) => MapEntry(k.toString(), (v as num).toInt())))
                : <String, int>{}),
      );
    } catch (e) {
      _error = 'Failed to load analytics data: $e';
      debugPrint('Error loading analytics data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveAnalyticsData() async {
    if (_analyticsData == null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await DatabaseService.updateAnalyticsData(_analyticsData!.toMap());
      
    } catch (e) {
      _error = 'Failed to save analytics data: $e';
      debugPrint('Error saving analytics data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    await loadAnalyticsData();
  }

  // Update specific metrics
  void updateTotalUsers(int count) {
    if (_analyticsData != null) {
      _analyticsData = _analyticsData!.copyWith(totalUsers: count);
      notifyListeners();
    }
  }

  void updatePremiumUsers(int count) {
    if (_analyticsData != null) {
      _analyticsData = _analyticsData!.copyWith(premiumUsers: count);
      notifyListeners();
    }
  }

  void updateActiveVets(int count) {
    if (_analyticsData != null) {
      _analyticsData = _analyticsData!.copyWith(activeVets: count);
      notifyListeners();
    }
  }

  void updatePremiumVets(int count) {
    if (_analyticsData != null) {
      _analyticsData = _analyticsData!.copyWith(premiumVets: count);
      notifyListeners();
    }
  }

  void updateTotalAppointments(int count) {
    if (_analyticsData != null) {
      _analyticsData = _analyticsData!.copyWith(totalAppointments: count);
      notifyListeners();
    }
  }

  void updateRevenue(double amount) {
    if (_analyticsData != null) {
      _analyticsData = _analyticsData!.copyWith(revenue: amount);
      notifyListeners();
    }
  }

  void updateAverageRating(double rating) {
    if (_analyticsData != null) {
      _analyticsData = _analyticsData!.copyWith(averageRating: rating);
      notifyListeners();
    }
  }

  void updatePetBreeds(int count) {
    if (_analyticsData != null) {
      _analyticsData = _analyticsData!.copyWith(petBreeds: count);
      notifyListeners();
    }
  }

  void updatePetCategories(Map<String, double> categories) {
    if (_analyticsData != null) {
      _analyticsData = _analyticsData!.copyWith(petCategories: categories);
      notifyListeners();
    }
  }

  void updateTopBreeds(List<Map<String, dynamic>> breeds) {
    if (_analyticsData != null) {
      _analyticsData = _analyticsData!.copyWith(topBreeds: breeds);
      notifyListeners();
    }
  }

  void updateUserGrowth(Map<String, int> growth) {
    if (_analyticsData != null) {
      _analyticsData = _analyticsData!.copyWith(userGrowth: growth);
      notifyListeners();
    }
  }

  void updateAppointmentTrends(Map<String, int> trends) {
    if (_analyticsData != null) {
      _analyticsData = _analyticsData!.copyWith(appointmentTrends: trends);
      notifyListeners();
    }
  }

  // Calculate percentages
  double get premiumUserPercentage {
    if (_analyticsData?.totalUsers == 0) return 0;
    return (_analyticsData?.premiumUsers ?? 0) / (_analyticsData?.totalUsers ?? 1) * 100;
  }

  double get premiumVetPercentage {
    if (_analyticsData?.activeVets == 0) return 0;
    return (_analyticsData?.premiumVets ?? 0) / (_analyticsData?.activeVets ?? 1) * 100;
  }

  double get verifiedVetPercentage {
    if (_analyticsData?.activeVets == 0) return 0;
    // Placeholder: using premium vets as proxy if verified not tracked
    return (_analyticsData?.premiumVets ?? 0) / (_analyticsData?.activeVets ?? 1) * 100;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

