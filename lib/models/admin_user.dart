import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUser {
  final String id;
  final String email;
  final String name;
  final String? username; // Optional username
  final String role; // 'admin' or 'super-admin'
  final Map<String, bool> permissions; // Module-level permissions
  final DateTime? createdAt;
  final DateTime? lastLogin;

  AdminUser({
    required this.id,
    required this.email,
    required this.name,
    this.username,
    required this.role,
    required this.permissions,
    this.createdAt,
    this.lastLogin,
  });

  factory AdminUser.fromMap(Map<String, dynamic> map, String id) {
    return AdminUser(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      username: map['username'] as String?,
      role: map['role'] ?? 'admin',
      permissions: Map<String, bool>.from(map['permissions'] ?? {}),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      lastLogin: map['lastLogin'] != null
          ? (map['lastLogin'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'username': username,
      'role': role,
      'permissions': permissions,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
    };
  }

  bool hasPermission(String permission) {
    // Super-admin has all permissions
    if (role == 'super-admin') return true;
    
    // Check specific permission
    return permissions[permission] ?? false;
  }

  bool canAccess(String module) {
    // Super-admin can access all modules
    if (role == 'super-admin') return true;
    
    // Check if any permission for this module exists
    return permissions.entries
        .any((entry) => entry.key.startsWith('$module.') && entry.value == true);
  }
}

