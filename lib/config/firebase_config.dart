import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseConfig {
  static FirebaseFirestore? _firestore;
  static FirebaseAuth? _auth;
  static FirebaseStorage? _storage;

  static FirebaseFirestore get firestore {
    _firestore ??= FirebaseFirestore.instance;
    return _firestore!;
  }

  static FirebaseAuth get auth {
    _auth ??= FirebaseAuth.instance;
    return _auth!;
  }

  static FirebaseStorage get storage {
    _storage ??= FirebaseStorage.instance;
    return _storage!;
  }

  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyB0BPUNYKl3JzJxT2SQBQkQ8b3ioWhHsoc",
        authDomain: "fureverhealthy-admin.firebaseapp.com",
        projectId: "fureverhealthy-admin",
        storageBucket: "fureverhealthy-admin.appspot.com",
        messagingSenderId: "154419208249",
        appId: "1:154419208249:web:e54a4e161e9d1150e5ede8",
        measurementId: "G-ETJBL1ZC0K",
      ),
    );
  }
}

