import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../config/firebase_config.dart';

class DatabaseService {
  static final FirebaseFirestore _firestore = FirebaseConfig.firestore;

  // Users Collection
  static CollectionReference get users => _firestore.collection('users');
  
  // Vets Collection
  static CollectionReference get vets => _firestore.collection('vets');
  
  // Appointments Collection
  static CollectionReference get appointments => _firestore.collection('appointments');
  
  // User Appointments Collection
  static CollectionReference get userAppointments => _firestore.collection('user_appointments');
  
  // Pets Collection
  static CollectionReference get pets => _firestore.collection('pets');
  
  // Pet Breeds Collection
  static CollectionReference get petBreeds => _firestore.collection('petBreeds');
  
  // Analytics Collection
  static CollectionReference get analytics => _firestore.collection('analytics');
  
  // Feedbacks Collection (system feedbacks)
  static CollectionReference get feedbacks => _firestore.collection('feedbacks');
  
  // Feedback Collection (user feedbacks to vets - singular)
  static CollectionReference get feedback => _firestore.collection('feedback');
  
  // Ratings Collection
  static CollectionReference get ratings => _firestore.collection('ratings');
  
  // Community Collection
  static CollectionReference get community => _firestore.collection('community');
  
  // Pet Infos Collection
  static CollectionReference get petInfos => _firestore.collection('petInfos');
  
  // Admins Collection
  static CollectionReference get admins => _firestore.collection('admins');

  // Notifications Collection
  static CollectionReference get notifications => _firestore.collection('notifications');

  // System Config Collection
  static CollectionReference get systemConfig => _firestore.collection('systemConfig');

  // Contents Collection
  static CollectionReference get contents => _firestore.collection('contents');

  // Payments Collection
  static CollectionReference get payments => _firestore.collection('payment');

  // User Management
  static Future<DocumentSnapshot> getUser(String userId) async {
    return await users.doc(userId).get();
  }

  static Future<void> createUser(Map<String, dynamic> userData) async {
    // Set default userType to 'regular' if not provided
    final dataWithDefaults = Map<String, dynamic>.from(userData);
    if (!dataWithDefaults.containsKey('userType')) {
      dataWithDefaults['userType'] = 'regular';
    }
    await users.add(dataWithDefaults);
  }

  static Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    await users.doc(userId).update(userData);
  }

  static Future<void> deleteUser(String userId) async {
    await users.doc(userId).delete();
  }

  static Future<void> softDeleteUser(String userId) async {
    await users.doc(userId).update({
      'deleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> suspendUser(String userId) async {
    await users.doc(userId).update({
      'status': 'suspended',
      'suspendedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> unsuspendUser(String userId) async {
    await users.doc(userId).update({
      'status': 'active',
      'suspendedAt': FieldValue.delete(),
    });
  }

  static Stream<QuerySnapshot> getUsersStream({bool includeDeleted = false}) {
    if (includeDeleted) {
      return users.snapshots();
    }
    // Filter out soft-deleted users - check both where the field is not equal to true and where it doesn't exist
    // For better performance, we'll just return all and filter in the client
    return users.snapshots();
  }

  // Vet Management
  static Future<DocumentSnapshot> getVet(String vetId) async {
    return await vets.doc(vetId).get();
  }

  static Future<void> createVet(Map<String, dynamic> vetData) async {
    // Set default userType to 'regular' if not provided
    final dataWithDefaults = Map<String, dynamic>.from(vetData);
    if (!dataWithDefaults.containsKey('userType')) {
      dataWithDefaults['userType'] = 'regular';
    }
    await vets.add(dataWithDefaults);
  }

  static Future<void> updateVet(String vetId, Map<String, dynamic> vetData) async {
    await vets.doc(vetId).update(vetData);
  }

  static Future<void> deleteVet(String vetId) async {
    await vets.doc(vetId).delete();
  }

  static Stream<QuerySnapshot> getVetsStream() {
    return vets.snapshots();
  }

  static Future<void> bulkVerifyVets(List<String> vetIds) async {
    final batch = _firestore.batch();
    for (final vetId in vetIds) {
      batch.update(vets.doc(vetId), {
        'licenseVerified': true,
        'verified': true,
      });
    }
    await batch.commit();
  }

  static Future<void> updateVetVisibility(String vetId, bool hidden) async {
    await vets.doc(vetId).update({
      'profileHidden': hidden,
    });
  }

  static Future<String> exportVetsToCSV(List<Map<String, dynamic>> vets) async {
    final csv = StringBuffer();
    
    // Header
    csv.writeln('Name,Email,Phone,Clinic,Specialization,License,License Verified,Verified,Hidden,Created At');
    
    // Data rows
    for (final vet in vets) {
      final name = (vet['name'] ?? '').toString().replaceAll(',', ';');
      final email = (vet['email'] ?? '').toString().replaceAll(',', ';');
      final phone = (vet['phone'] ?? '').toString().replaceAll(',', ';');
      final clinic = (vet['clinic'] ?? '').toString().replaceAll(',', ';');
      final specialization = (vet['specialization'] ?? '').toString().replaceAll(',', ';');
      final license = (vet['license'] ?? '').toString().replaceAll(',', ';');
      final licenseVerified = (vet['licenseVerified'] ?? false) ? 'Yes' : 'No';
      final verified = (vet['verified'] ?? false) ? 'Yes' : 'No';
      final hidden = (vet['profileHidden'] ?? false) ? 'Yes' : 'No';
      final createdAt = vet['createdAt'] != null
          ? (vet['createdAt'] as Timestamp).toDate().toIso8601String()
          : '';
      
      csv.writeln('$name,$email,$phone,$clinic,$specialization,$license,$licenseVerified,$verified,$hidden,$createdAt');
    }
    
    return csv.toString();
  }

  // Appointment Management
  static Future<DocumentSnapshot> getAppointment(String appointmentId) async {
    return await appointments.doc(appointmentId).get();
  }

  static Future<void> createAppointment(Map<String, dynamic> appointmentData) async {
    await appointments.add(appointmentData);
  }

  static Future<void> updateAppointment(String appointmentId, Map<String, dynamic> appointmentData) async {
    await appointments.doc(appointmentId).update(appointmentData);
  }

  static Future<void> deleteAppointment(String appointmentId) async {
    await appointments.doc(appointmentId).delete();
  }

  static Stream<QuerySnapshot> getAppointmentsStream() {
    return appointments.snapshots();
  }

  // Analytics Data
  static Future<Map<String, dynamic>> getAnalyticsData() async {
    final doc = await analytics.doc('dashboard').get();
    return doc.data() as Map<String, dynamic>? ?? {};
  }

  static Future<void> updateAnalyticsData(Map<String, dynamic> data) async {
    await analytics.doc('dashboard').set(data, SetOptions(merge: true));
  }

  // Pet Breeds
  static Future<List<Map<String, dynamic>>> getPetBreeds() async {
    final snapshot = await petBreeds.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  static Future<void> addPetBreed(Map<String, dynamic> breedData) async {
    await petBreeds.add(breedData);
  }

  // Search and Filter Methods
  static Future<QuerySnapshot> searchUsers(String searchTerm) async {
    return await users
        .where('name', isGreaterThanOrEqualTo: searchTerm)
        .where('name', isLessThan: '${searchTerm}z')
        .get();
  }

  static Future<QuerySnapshot> getUsersByRole(String role) async {
    return await users.where('role', isEqualTo: role).get();
  }

  static Future<QuerySnapshot> getVetsByStatus(String status) async {
    return await vets.where('verificationStatus', isEqualTo: status).get();
  }

  // Statistics and Counts
  static Future<int> getUserCount() async {
    final snapshot = await users.get();
    return snapshot.docs.length;
  }

  static Future<int> getVetCount() async {
    final snapshot = await vets.get();
    return snapshot.docs.length;
  }

  static Future<int> getAppointmentCount() async {
    final snapshot = await appointments.get();
    return snapshot.docs.length;
  }

  static Future<int> getPremiumUserCount() async {
    final snapshot = await users.where('isPremium', isEqualTo: true).get();
    return snapshot.docs.length;
  }

  static Future<int> getVerifiedVetCount() async {
    final snapshot = await vets.where('verificationStatus', isEqualTo: 'verified').get();
    return snapshot.docs.length;
  }

  static Future<int> getPetCount() async {
    final snapshot = await pets.get();
    return snapshot.docs.length;
  }

  // Password Reset Methods
  static Future<bool> sendPasswordResetEmail(String email) async {
    try {
      // In a real implementation, this would integrate with Firebase Auth
      // For now, we'll simulate the email sending process
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      // Log the password reset request (in real app, this would be handled by Firebase Auth)
      print('Password reset email sent to: $email');
      
      return true;
    } catch (e) {
      print('Error sending password reset email: $e');
      return false;
    }
  }

  static Future<bool> verifyAdminPassword(String email, String password) async {
    try {
      // Get admin document by email
      final adminDoc = await getAdminUserByEmail(email);
      
      if (adminDoc == null || !adminDoc.exists) {
        // If admin doesn't exist, only allow default password for admin@pethealth.com
        if (email == 'admin@pethealth.com') {
          return password == 'admin123';
        }
        return false;
      }
      
      final adminData = adminDoc.data() as Map<String, dynamic>?;
      if (adminData == null) {
        return false;
      }
      
      final storedPassword = adminData['password'] as String?;
      
      // If password is set in admin document, check against it first
      if (storedPassword != null && storedPassword.isNotEmpty) {
        return storedPassword == password;
      }
      
      // If no stored password, use default "admin123" for all accounts
      return password == 'admin123';
    } catch (e) {
      print('Error verifying admin password: $e');
      return false;
    }
  }

  static Future<bool> changeAdminPassword(String email, String currentPassword, String newPassword) async {
    try {
      // Verify current password first
      final isValid = await verifyAdminPassword(email, currentPassword);
      if (!isValid) {
        return false;
      }

      // Validate new password strength
      if (newPassword.length < 8) {
        throw Exception('Password must be at least 8 characters long');
      }

      // Get admin document
      final adminDoc = await getAdminUserByEmail(email);
      if (adminDoc == null || !adminDoc.exists) {
        throw Exception('Admin account not found');
      }

      // Store password in the admin's document
      await admins.doc(adminDoc.id).update({
        'password': newPassword,
        'passwordUpdatedAt': FieldValue.serverTimestamp(),
      });

      // Log the password change
      await logConfigChange(
        adminDoc.id,
        email,
        'adminPassword',
        '*****',
        '*****',
      );

      return true;
    } catch (e) {
      print('Error changing admin password: $e');
      return false;
    }
  }

  // Feedback Management
  static Future<void> deleteFeedback(String feedbackId) async {
    await feedbacks.doc(feedbackId).delete();
  }

  static Stream<QuerySnapshot> getFeedbacksStream() {
    // Note: Firestore doesn't support multiple orderBy with different directions easily
    // So we'll order by createdAt and sort pinned items in the client
    return feedbacks.orderBy('createdAt', descending: true).snapshots();
  }

  static Future<void> updateFeedbackCategory(String feedbackId, String category) async {
    await feedbacks.doc(feedbackId).update({
      'category': category,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateFeedbackSeverity(String feedbackId, String severity) async {
    await feedbacks.doc(feedbackId).update({
      'severity': severity,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> assignFeedback(String feedbackId, String? assignedTo) async {
    await feedbacks.doc(feedbackId).update({
      'assignedTo': assignedTo,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> changeFeedbackStatus(String feedbackId, String status) async {
    await feedbacks.doc(feedbackId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> pinFeedback(String feedbackId, bool isPinned) async {
    await feedbacks.doc(feedbackId).update({
      'isPinned': isPinned,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Rating Management
  static Future<void> deleteRating(String ratingId) async {
    await ratings.doc(ratingId).delete();
  }

  static Stream<QuerySnapshot> getRatingsStream() {
    return ratings.orderBy('createdAt', descending: true).snapshots();
  }

  // Community Management
  static Future<void> deleteCommunityPost(String postId) async {
    await community.doc(postId).delete();
  }

  static Stream<QuerySnapshot> getCommunityPostsStream() {
    // Try community_posts collection first, fallback to community
    try {
      return _firestore.collection('community_posts').orderBy('timestamp', descending: true).snapshots();
    } catch (e) {
      return community.orderBy('timestamp', descending: true).snapshots();
    }
  }

  static Future<List<Map<String, dynamic>>> getPostComments(String postId) async {
    try {
      // Try community_posts collection first
      // Try to order by createdAt first
      QuerySnapshot? commentsSnap;
      try {
        commentsSnap = await _firestore
            .collection('community_posts')
            .doc(postId)
            .collection('comments')
            .orderBy('createdAt', descending: true)
            .get();
      } catch (e) {
        // If ordering fails (e.g., missing index), fetch without ordering
        debugPrint('Note: Cannot order by createdAt, fetching without order: $e');
        commentsSnap = await _firestore
            .collection('community_posts')
            .doc(postId)
            .collection('comments')
            .get();
      }
      
      final comments = commentsSnap.docs.map<Map<String, dynamic>>((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return {
          'id': doc.id,
          'commentId': doc.id,
          ...data,
        };
      }).toList();
      
      // Sort manually if we couldn't order by createdAt
      comments.sort((a, b) {
        final aTime = a['createdAt'];
        final bTime = b['createdAt'];
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        
        DateTime aDate;
        DateTime bDate;
        
        if (aTime is Timestamp) {
          aDate = aTime.toDate();
        } else if (aTime is String) {
          try {
            aDate = DateTime.parse(aTime);
          } catch (e) {
            return 1;
          }
        } else {
          return 1;
        }
        
        if (bTime is Timestamp) {
          bDate = bTime.toDate();
        } else if (bTime is String) {
          try {
            bDate = DateTime.parse(bTime);
          } catch (e) {
            return -1;
          }
        } else {
          return -1;
        }
        
        return bDate.compareTo(aDate);
      });
      
      return comments;
    } catch (e) {
      debugPrint('Error fetching comments from community_posts: $e');
      // Fallback to community collection
      try {
        QuerySnapshot? commentsSnap;
        try {
          commentsSnap = await community
              .doc(postId)
              .collection('comments')
              .orderBy('createdAt', descending: true)
              .get();
        } catch (e2) {
          // If ordering fails, fetch without ordering
          debugPrint('Note: Cannot order by createdAt in fallback: $e2');
          commentsSnap = await community
              .doc(postId)
              .collection('comments')
              .get();
        }
        
        final comments = commentsSnap.docs.map<Map<String, dynamic>>((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          return {
            'id': doc.id,
            'commentId': doc.id,
            ...data,
          };
        }).toList();
        
        // Sort manually if needed
        comments.sort((a, b) {
          final aTime = a['createdAt'];
          final bTime = b['createdAt'];
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          
          DateTime aDate;
          DateTime bDate;
          
          if (aTime is Timestamp) {
            aDate = aTime.toDate();
          } else if (aTime is String) {
            try {
              aDate = DateTime.parse(aTime);
            } catch (e) {
              return 1;
            }
          } else {
            return 1;
          }
          
          if (bTime is Timestamp) {
            bDate = bTime.toDate();
          } else if (bTime is String) {
            try {
              bDate = DateTime.parse(bTime);
            } catch (e) {
              return -1;
            }
          } else {
            return -1;
          }
          
          return bDate.compareTo(aDate);
        });
        
        return comments;
      } catch (e2) {
        debugPrint('Error fetching comments: $e2');
        return [];
      }
    }
  }

  // Feedback to Vets Management
  static Stream<QuerySnapshot> getFeedbackToVetsStream() {
    return feedback.orderBy('date', descending: true).snapshots();
  }

  static Future<void> deleteFeedbackToVet(String feedbackId) async {
    await feedback.doc(feedbackId).delete();
  }

  static Future<void> hideFeedbackToVet(String feedbackId, bool isHidden) async {
    await feedback.doc(feedbackId).update({
      'isHidden': isHidden,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Community Moderation
  static Future<void> muteUser(String userId, String reason) async {
    await users.doc(userId).update({
      'muted': true,
      'mutedAt': FieldValue.serverTimestamp(),
      'muteReason': reason,
    });
  }

  static Future<void> unmuteUser(String userId) async {
    await users.doc(userId).update({
      'muted': false,
      'mutedAt': FieldValue.delete(),
      'muteReason': FieldValue.delete(),
    });
  }

  static Future<void> escalateToSuspension(String userId, String reason) async {
    await users.doc(userId).update({
      'status': 'suspended',
      'suspendedAt': FieldValue.serverTimestamp(),
      'suspensionReason': reason,
    });
  }

  static Future<void> addStrike(String userId, String reason, String action, String adminId, String adminEmail) async {
    await users.doc(userId).collection('strikes').add({
      'reason': reason,
      'action': action, // 'warning', 'mute', 'suspension'
      'adminId': adminId,
      'adminEmail': adminEmail,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<List<Map<String, dynamic>>> getUserStrikeHistory(String userId) async {
    final snapshot = await users.doc(userId).collection('strikes').orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // Pet Info Management
  static Stream<QuerySnapshot> getPetsByUserId(String userId) {
    // Use userId field (primary field name in database)
    return petInfos.where('userId', isEqualTo: userId).snapshots();
  }

  static Future<List<QueryDocumentSnapshot>> getPetsByUserIdAsync(String userId) async {
    // Get pets with userId field (primary)
    final petsByUserId = await petInfos.where('userId', isEqualTo: userId).get();
    
    // Also check ownerID field as fallback for legacy data
    final petsByOwnerID = await petInfos.where('ownerID', isEqualTo: userId).get();
    
    // Combine and deduplicate
    final allPets = <String, QueryDocumentSnapshot>{};
    for (final pet in petsByUserId.docs) {
      allPets[pet.id] = pet;
    }
    for (final pet in petsByOwnerID.docs) {
      allPets[pet.id] = pet;
    }
    
    return allPets.values.toList();
  }

  static Future<List<QueryDocumentSnapshot>> getPetsByVetIdAsync(String vetId) async {
    // Get pets linked directly via vetId field
    final directPets = await petInfos.where('vetId', isEqualTo: vetId).get();
    
    // Also get pets through user_appointments (primary collection)
    final userAppointments = await DatabaseService.userAppointments
        .where('vetId', isEqualTo: vetId)
        .get();
    
    // Also check regular appointments collection as fallback
    final appointments = await DatabaseService.appointments
        .where('vetId', isEqualTo: vetId)
        .get();
    
    final petIdsFromAppointments = <String>{};
    
    // Process user_appointments
    for (final appointment in userAppointments.docs) {
      final data = appointment.data() as Map<String, dynamic>;
      final petId = data['petId']?.toString();
      if (petId != null && petId.isNotEmpty) {
        petIdsFromAppointments.add(petId);
      }
    }
    
    // Process regular appointments
    for (final appointment in appointments.docs) {
      final data = appointment.data() as Map<String, dynamic>;
      final petId = data['petId']?.toString();
      if (petId != null && petId.isNotEmpty) {
        petIdsFromAppointments.add(petId);
      }
    }
    
    // Get pet documents from appointment petIds
    final petsFromAppointments = <QueryDocumentSnapshot>[];
    if (petIdsFromAppointments.isNotEmpty) {
      // Firestore 'in' queries are limited to 10 items, so we need to batch
      final petIdsList = petIdsFromAppointments.toList();
      for (var i = 0; i < petIdsList.length; i += 10) {
        final batch = petIdsList.skip(i).take(10).toList();
        final batchPets = await petInfos.where(FieldPath.documentId, whereIn: batch).get();
        petsFromAppointments.addAll(batchPets.docs);
      }
    }
    
    // Combine and deduplicate
    final allPets = <String, QueryDocumentSnapshot>{};
    for (final pet in directPets.docs) {
      allPets[pet.id] = pet;
    }
    for (final pet in petsFromAppointments) {
      allPets[pet.id] = pet;
    }
    
    return allPets.values.toList();
  }

  static Stream<QuerySnapshot> getPetsByVetId(String vetId) {
    // For stream, we'll use the direct vetId query
    // Note: This won't include pets from appointments, but streams can't easily combine multiple queries
    // For complete data, use getPetsByVetIdAsync in a FutureBuilder
    return petInfos.where('vetId', isEqualTo: vetId).snapshots();
  }

  static Future<DocumentSnapshot> getPetInfo(String petId) async {
    return await petInfos.doc(petId).get();
  }

  // Admin Management
  static Future<DocumentSnapshot?> getAdminUser(String adminId) async {
    try {
      return await admins.doc(adminId).get();
    } catch (e) {
      print('Error getting admin user: $e');
      return null;
    }
  }

  static Future<DocumentSnapshot?> getAdminUserByEmail(String email) async {
    try {
      final snapshot = await admins.where('email', isEqualTo: email).limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first;
      }
      return null;
    } catch (e) {
      print('Error getting admin user by email: $e');
      return null;
    }
  }

  static Future<void> grantAdminAccess({
    required String email,
    required String name,
    String? username,
    required String role,
    Map<String, bool>? permissions,
  }) async {
    try {
      final defaultPermissions = permissions ?? {
        'users.view': true,
        'users.edit': true,
        'users.delete': true,
        'vets.view': true,
        'vets.edit': true,
        'vets.delete': true,
        'feedbacks.view': true,
        'feedbacks.edit': true,
        'contents.view': true,
        'contents.edit': true,
        'contents.publish': true,
        'reports.view': true,
        'community.view': true,
        'community.moderate': true,
      };
      
      // Generate initial password - use "admin123" for all accounts
      // Users can change it later through settings
      const initialPassword = 'admin123';
      
      await admins.add({
        'email': email,
        'name': name,
        'username': username,
        'role': role,
        'permissions': defaultPermissions,
        'password': initialPassword,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': null,
      });
    } catch (e) {
      print('Error granting admin access: $e');
      rethrow;
    }
  }

  static Future<void> revokeAdminAccess(String adminId) async {
    try {
      await admins.doc(adminId).delete();
    } catch (e) {
      print('Error revoking admin access: $e');
      rethrow;
    }
  }

  static Future<void> updateAdminRole(String adminId, String role) async {
    try {
      await admins.doc(adminId).update({
        'role': role,
      });
    } catch (e) {
      print('Error updating admin role: $e');
      rethrow;
    }
  }

  static Future<void> updateAdminPermissions(String adminId, Map<String, bool> permissions) async {
    try {
      await admins.doc(adminId).update({
        'permissions': permissions,
      });
    } catch (e) {
      print('Error updating admin permissions: $e');
      rethrow;
    }
  }

  static Future<void> updateAdminUsername(String adminId, String? username) async {
    try {
      await admins.doc(adminId).update({
        'username': username,
      });
    } catch (e) {
      print('Error updating admin username: $e');
      rethrow;
    }
  }

  static Future<void> updateAdminLastLogin(String adminId) async {
    try {
      await admins.doc(adminId).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating admin last login: $e');
      // Don't rethrow - this is not critical
    }
  }

  static Stream<QuerySnapshot> getAdminsStream() {
    return admins.orderBy('createdAt', descending: true).snapshots();
  }

  // Reports and Analytics
  static Future<int> getActiveUsersCount({DateTime? startDate, DateTime? endDate}) async {
    // Build query without deleted filter to avoid composite index requirement
    Query query = users;
    if (startDate != null) {
      query = query.where('joinDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('joinDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }
    final snapshot = await query.get();
    
    // Filter deleted users in memory
    int count = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final deleted = data['deleted'] ?? false;
      if (!deleted) {
        count++;
      }
    }
    return count;
  }

  static Future<int> getActiveVetsCount({DateTime? startDate, DateTime? endDate}) async {
    var query = vets.where('verificationStatus', isEqualTo: 'verified');
    if (startDate != null) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }
    final snapshot = await query.get();
    return snapshot.docs.length;
  }

  static Future<Map<String, dynamic>> getAppointmentFunnel({DateTime? startDate, DateTime? endDate}) async {
    Query query = appointments;
    if (startDate != null) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }
    final snapshot = await query.get();
    
    int scheduled = 0;
    int completed = 0;
    int cancelled = 0;
    
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = (data['status'] ?? '').toString().toLowerCase();
      if (status == 'scheduled' || status == 'confirmed') {
        scheduled++;
      } else if (status == 'completed' || status == 'done') {
        completed++;
      } else if (status == 'cancelled' || status == 'canceled') {
        cancelled++;
      }
    }
    
    return {
      'scheduled': scheduled,
      'completed': completed,
      'cancelled': cancelled,
      'total': snapshot.docs.length,
    };
  }

  static Future<int> getContentReach({DateTime? startDate, DateTime? endDate}) async {
    // For now, return a placeholder. In a real app, track content views
    return 0;
  }

  static Future<Map<String, int>> getTopFeedbackCategories({DateTime? startDate, DateTime? endDate}) async {
    Query query = feedbacks;
    if (startDate != null) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }
    final snapshot = await query.get();
    
    final categories = <String, int>{};
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final category = (data['category'] ?? 'other').toString();
      categories[category] = (categories[category] ?? 0) + 1;
    }
    
    // Sort by count descending
    final sortedCategories = Map.fromEntries(
      categories.entries.toList()..sort((a, b) => b.value.compareTo(a.value))
    );
    
    return sortedCategories;
  }

  static Future<String> exportReportsToCSV(Map<String, dynamic> reportData) async {
    final csv = StringBuffer();
    csv.writeln('Report Generated,${DateTime.now().toIso8601String()}');
    csv.writeln('');
    csv.writeln('KPIs');
    csv.writeln('Metric,Value');
    csv.writeln('Active Users,${reportData['activeUsers'] ?? 0}');
    csv.writeln('Active Vets,${reportData['activeVets'] ?? 0}');
    csv.writeln('Scheduled Appointments,${reportData['appointmentFunnel']?['scheduled'] ?? 0}');
    csv.writeln('Completed Appointments,${reportData['appointmentFunnel']?['completed'] ?? 0}');
    csv.writeln('Cancelled Appointments,${reportData['appointmentFunnel']?['cancelled'] ?? 0}');
    csv.writeln('');
    csv.writeln('Top Feedback Categories');
    csv.writeln('Category,Count');
    final categories = reportData['topFeedbackCategories'] as Map<String, int>? ?? {};
    categories.forEach((category, count) {
      csv.writeln('$category,$count');
    });
    csv.writeln('');
    csv.writeln('Cancellation Reasons');
    csv.writeln('Reason,Count');
    final reasons = reportData['cancellationReasons'] as Map<String, int>? ?? {};
    reasons.forEach((reason, count) {
      csv.writeln('$reason,$count');
    });
    return csv.toString();
  }

  // Notification Management
  static Future<void> createNotification(Map<String, dynamic> notificationData) async {
    await notifications.add(notificationData);
  }

  static Future<void> scheduleNotification(String notificationId, DateTime scheduledDate) async {
    await notifications.doc(notificationId).update({
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'status': 'scheduled',
    });
  }

  static Stream<QuerySnapshot> getScheduledNotifications() {
    return notifications
        .where('status', isEqualTo: 'scheduled')
        .orderBy('scheduledDate', descending: false)
        .snapshots();
  }

  // System Configuration
  static Future<Map<String, dynamic>> getSystemConfig() async {
    final doc = await systemConfig.doc('settings').get();
    return doc.data() as Map<String, dynamic>? ?? {};
  }

  static Future<void> updateSystemConfig(Map<String, dynamic> config) async {
    await systemConfig.doc('settings').set(config, SetOptions(merge: true));
  }

  static Future<void> logConfigChange(String adminId, String adminEmail, String setting, dynamic oldValue, dynamic newValue) async {
    await systemConfig.doc('changeLog').collection('changes').add({
      'adminId': adminId,
      'adminEmail': adminEmail,
      'setting': setting,
      'oldValue': oldValue,
      'newValue': newValue,
      'changedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<List<Map<String, dynamic>>> getConfigHistory({int? limit}) async {
    Query query = systemConfig.doc('changeLog').collection('changes').orderBy('changedAt', descending: true);
    if (limit != null) {
      query = query.limit(limit);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // Content Management
  static Future<DocumentSnapshot> getContent(String contentId) async {
    return await contents.doc(contentId).get();
  }

  static Future<void> createContent(Map<String, dynamic> contentData) async {
    await contents.add(contentData);
  }

  static Future<void> updateContent(String contentId, Map<String, dynamic> contentData) async {
    await contents.doc(contentId).update(contentData);
  }

  static Future<void> deleteContent(String contentId) async {
    await contents.doc(contentId).delete();
  }

  static Future<void> updateContentStatus(String contentId, String status) async {
    await contents.doc(contentId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Recent Activities - Only registrations and payments
  static Future<List<Map<String, dynamic>>> getRecentActivities({int limit = 20}) async {
    final activities = <Map<String, dynamic>>[];
    
    // Get recent user registrations
    try {
      final usersSnap = await users
          .orderBy('createdAt', descending: true)
          .limit(limit ~/ 3)
          .get();
      for (final doc in usersSnap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        activities.add({
          'type': 'registration',
          'id': doc.id,
          'title': 'New User Registration',
          'description': '${data['name'] ?? 'User'} registered as a new user',
          'timestamp': data['createdAt'],
          'metadata': {
            'userName': data['name'] ?? 'Unknown',
            'email': data['email'] ?? '',
          },
        });
      }
    } catch (e) {
      debugPrint('Error fetching user registrations: $e');
    }
    
    // Get recent vet registrations
    try {
      final vetsSnap = await vets
          .orderBy('createdAt', descending: true)
          .limit(limit ~/ 3)
          .get();
      for (final doc in vetsSnap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        activities.add({
          'type': 'vet_join',
          'id': doc.id,
          'title': 'New Vet Registration',
          'description': '${data['name'] ?? 'Veterinarian'} joined as a veterinarian',
          'timestamp': data['createdAt'],
          'metadata': {
            'vetName': data['name'] ?? 'Unknown',
            'clinic': data['clinic'] ?? '',
          },
        });
      }
    } catch (e) {
      debugPrint('Error fetching vet registrations: $e');
    }
    
    // Get recent payment notices (Pending payments)
    try {
      final paymentsSnap = await payments
          .where('status', isEqualTo: 'Pending')
          .orderBy('submissionTime', descending: true)
          .limit(limit ~/ 3)
          .get();
      for (final doc in paymentsSnap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        activities.add({
          'type': 'payment_notice',
          'id': doc.id,
          'title': 'Payment Notice',
          'description': 'New payment submission pending verification',
          'timestamp': data['submissionTime'] ?? data['createdAt'],
          'metadata': {
            'transactionId': data['transactionId'] ?? '',
            'amount': data['amount'] ?? 0,
            'userId': data['userId'] ?? '',
            'vetId': data['vetId'] ?? '',
          },
        });
      }
    } catch (e) {
      debugPrint('Error fetching payments: $e');
    }
    
    // Sort all activities by timestamp (most recent first)
    activities.sort((a, b) {
      final aTime = a['timestamp'];
      final bTime = b['timestamp'];
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      
      DateTime aDate;
      DateTime bDate;
      
      if (aTime is Timestamp) {
        aDate = aTime.toDate();
      } else if (aTime is String) {
        try {
          aDate = DateTime.parse(aTime);
        } catch (e) {
          return 1;
        }
      } else {
        return 1;
      }
      
      if (bTime is Timestamp) {
        bDate = bTime.toDate();
      } else if (bTime is String) {
        try {
          bDate = DateTime.parse(bTime);
        } catch (e) {
          return -1;
        }
      } else {
        return -1;
      }
      
      return bDate.compareTo(aDate);
    });
    
    return activities.take(limit).toList();
  }

  // Realtime stream for recent activities
  static Stream<List<Map<String, dynamic>>> getRecentActivitiesStream({int limit = 20}) {
    // Poll every 5 seconds for updates
    return Stream.periodic(const Duration(seconds: 5))
        .asyncMap((_) => getRecentActivities(limit: limit));
  }

  static Stream<QuerySnapshot> getContentsStream([String? sortBy]) {
    Query query = contents;
    if (sortBy != null) {
      if (sortBy == 'title') {
        query = query.orderBy('title', descending: false);
      } else if (sortBy == 'createdAt') {
        query = query.orderBy('createdAt', descending: true);
      } else {
        query = query.orderBy('updatedAt', descending: true);
      }
    } else {
      query = query.orderBy('updatedAt', descending: true);
    }
    return query.snapshots();
  }

  // Payment Management
  static Stream<QuerySnapshot> getPaymentsStream() {
    // Use submissionTime for ordering, fallback to createdAt if submissionTime doesn't exist
    return payments.orderBy('submissionTime', descending: true).snapshots();
  }

  static Future<void> updatePaymentStatus(String paymentId, String status, {String? adminId}) async {
    final updateData = <String, dynamic>{
      'status': status, // Status should be "Pending", "Verified", or "Rejected"
    };
    
    if (adminId != null) {
      updateData['adminVerifiedBy'] = adminId;
    }
    
    await payments.doc(paymentId).update(updateData);
  }

  static Future<DocumentSnapshot> getPayment(String paymentId) async {
    return await payments.doc(paymentId).get();
  }
}

