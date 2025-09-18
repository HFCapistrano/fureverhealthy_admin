class AnalyticsData {
  final int totalUsers;
  final int premiumUsers;
  final int activeVets;
  final int premiumVets;
  final int totalAppointments;
  final double revenue;
  final double averageRating;
  final int petBreeds;
  final Map<String, double> petCategories;
  final List<Map<String, dynamic>> topBreeds;
  final Map<String, int> userGrowth;
  final Map<String, int> appointmentTrends;

  AnalyticsData({
    required this.totalUsers,
    required this.premiumUsers,
    required this.activeVets,
    required this.premiumVets,
    required this.totalAppointments,
    required this.revenue,
    required this.averageRating,
    required this.petBreeds,
    required this.petCategories,
    required this.topBreeds,
    required this.userGrowth,
    required this.appointmentTrends,
  });

  factory AnalyticsData.fromMap(Map<String, dynamic> map) {
    return AnalyticsData(
      totalUsers: map['totalUsers'] ?? 0,
      premiumUsers: map['premiumUsers'] ?? 0,
      activeVets: map['activeVets'] ?? 0,
      premiumVets: map['premiumVets'] ?? 0,
      totalAppointments: map['totalAppointments'] ?? 0,
      revenue: (map['revenue'] ?? 0).toDouble(),
      averageRating: (map['averageRating'] ?? 0).toDouble(),
      petBreeds: map['petBreeds'] ?? 0,
      petCategories: Map<String, double>.from(map['petCategories'] ?? {}),
      topBreeds: List<Map<String, dynamic>>.from(map['topBreeds'] ?? []),
      userGrowth: Map<String, int>.from(map['userGrowth'] ?? {}),
      appointmentTrends: Map<String, int>.from(map['appointmentTrends'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalUsers': totalUsers,
      'premiumUsers': premiumUsers,
      'activeVets': activeVets,
      'premiumVets': premiumVets,
      'totalAppointments': totalAppointments,
      'revenue': revenue,
      'averageRating': averageRating,
      'petBreeds': petBreeds,
      'petCategories': petCategories,
      'topBreeds': topBreeds,
      'userGrowth': userGrowth,
      'appointmentTrends': appointmentTrends,
    };
  }

  AnalyticsData copyWith({
    int? totalUsers,
    int? premiumUsers,
    int? activeVets,
    int? premiumVets,
    int? totalAppointments,
    double? revenue,
    double? averageRating,
    int? petBreeds,
    Map<String, double>? petCategories,
    List<Map<String, dynamic>>? topBreeds,
    Map<String, int>? userGrowth,
    Map<String, int>? appointmentTrends,
  }) {
    return AnalyticsData(
      totalUsers: totalUsers ?? this.totalUsers,
      premiumUsers: premiumUsers ?? this.premiumUsers,
      activeVets: activeVets ?? this.activeVets,
      premiumVets: premiumVets ?? this.premiumVets,
      totalAppointments: totalAppointments ?? this.totalAppointments,
      revenue: revenue ?? this.revenue,
      averageRating: averageRating ?? this.averageRating,
      petBreeds: petBreeds ?? this.petBreeds,
      petCategories: petCategories ?? this.petCategories,
      topBreeds: topBreeds ?? this.topBreeds,
      userGrowth: userGrowth ?? this.userGrowth,
      appointmentTrends: appointmentTrends ?? this.appointmentTrends,
    );
  }
}

