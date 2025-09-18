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
        .where('name', isLessThan: searchTerm + 'z')
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
}

