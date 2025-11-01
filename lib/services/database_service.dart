import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/firebase_config.dart';

class DatabaseService {
  static final FirebaseFirestore _firestore = FirebaseConfig.firestore;

  // Users Collection
  static CollectionReference get users => _firestore.collection('users');
  
  // Vets Collection
  static CollectionReference get vets => _firestore.collection('vets');
  
  // Appointments Collection
  static CollectionReference get appointments => _firestore.collection('appointments');
  
  // Pets Collection
  static CollectionReference get pets => _firestore.collection('pets');
  
  // Pet Breeds Collection
  static CollectionReference get petBreeds => _firestore.collection('petBreeds');
  
  // Analytics Collection
  static CollectionReference get analytics => _firestore.collection('analytics');
  
  // Feedbacks Collection
  static CollectionReference get feedbacks => _firestore.collection('feedbacks');
  
  // Ratings Collection
  static CollectionReference get ratings => _firestore.collection('ratings');
  
  // Community Collection
  static CollectionReference get community => _firestore.collection('community');
  
  // Pet Infos Collection
  static CollectionReference get petInfos => _firestore.collection('petInfos');

  // User Management
  static Future<DocumentSnapshot> getUser(String userId) async {
    return await users.doc(userId).get();
  }

  static Future<void> createUser(Map<String, dynamic> userData) async {
    await users.add(userData);
  }

  static Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    await users.doc(userId).update(userData);
  }

  static Future<void> deleteUser(String userId) async {
    await users.doc(userId).delete();
  }

  static Stream<QuerySnapshot> getUsersStream() {
    return users.snapshots();
  }

  // Vet Management
  static Future<DocumentSnapshot> getVet(String vetId) async {
    return await vets.doc(vetId).get();
  }

  static Future<void> createVet(Map<String, dynamic> vetData) async {
    await vets.add(vetData);
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

  static Future<bool> verifyAdminPassword(String password) async {
    try {
      // In a real implementation, this would verify against Firebase Auth
      // For now, we'll use a simple check against the admin password
      return password == 'admin123';
    } catch (e) {
      print('Error verifying admin password: $e');
      return false;
    }
  }

  // Feedback Management
  static Future<void> deleteFeedback(String feedbackId) async {
    await feedbacks.doc(feedbackId).delete();
  }

  static Stream<QuerySnapshot> getFeedbacksStream() {
    return feedbacks.orderBy('createdAt', descending: true).snapshots();
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
    return community.orderBy('createdAt', descending: true).snapshots();
  }

  // Pet Info Management
  static Stream<QuerySnapshot> getPetsByUserId(String userId) {
    return petInfos.where('ownerID', isEqualTo: userId).snapshots();
  }

  static Stream<QuerySnapshot> getPetsByVetId(String vetId) {
    // Check if pets are linked to vets via ownerID or a separate vetId field
    // For now, assuming vets also use ownerID or checking both fields
    return petInfos.where('vetId', isEqualTo: vetId).snapshots();
  }

  static Future<DocumentSnapshot> getPetInfo(String petId) async {
    return await petInfos.doc(petId).get();
  }
}

