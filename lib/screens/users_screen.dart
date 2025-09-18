import 'package:flutter/material.dart';
import 'package:furever_healthy_admin/theme/app_theme.dart';
import 'package:furever_healthy_admin/widgets/sidebar.dart';
import 'package:furever_healthy_admin/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all';

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _applyFilters(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    return docs.where((doc) {
      final data = doc.data();
      final name = (data['name'] ?? '').toString();
      final email = (data['email'] ?? '').toString();
      final status = (data['status'] ?? '').toString();
      final matchesSearch = name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == 'all' || status == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceColor,
                    border: Border(
                      bottom: BorderSide(color: AppTheme.borderColor),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Users',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage pet owners and their accounts',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Add new user (optional: open a dialog)
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add User'),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Filters and Search
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Search
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    onChanged: (value) {
                                      setState(() {
                                        _searchQuery = value;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      hintText: 'Search users...',
                                      prefixIcon: Icon(Icons.search),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                // Status Filter
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _statusFilter,
                                    decoration: const InputDecoration(
                                      labelText: 'Status',
                                      border: InputBorder.none,
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'all', child: Text('All')),
                                      DropdownMenuItem(value: 'active', child: Text('Active')),
                                      DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _statusFilter = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Users Table
                        Expanded(
                          child: Card(
                            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                              stream: DatabaseService.users.orderBy('name').withConverter<Map<String, dynamic>>(
                                fromFirestore: (snap, _) => snap.data() ?? <String, dynamic>{},
                                toFirestore: (value, _) => value,
                              ).snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return Center(child: Text('Error: ${snapshot.error}'));
                                }
                                final docs = snapshot.data?.docs ?? [];
                                final filtered = _applyFilters(docs);
                                if (filtered.isEmpty) {
                                  return const Center(child: Text('No users found'));
                                }
                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(minWidth: 1200),
                                    child: DataTable(
                                      columnSpacing: 24,
                                      columns: const [
                                        DataColumn(label: Text('Name')),
                                        DataColumn(label: Text('Email')),
                                        DataColumn(label: Text('Phone')),
                                        DataColumn(label: Text('Pets')),
                                        DataColumn(label: Text('Join Date')),
                                        DataColumn(label: Text('Status')),
                                        DataColumn(label: Text('Last Active')),
                                        DataColumn(label: Text('Actions')),
                                      ],
                                      rows: filtered.map((doc) {
                                        final data = doc.data();
                                        final name = (data['name'] ?? '').toString();
                                        final email = (data['email'] ?? '').toString();
                                        final phone = (data['phone'] ?? '').toString();
                                        final pets = (data['pets'] ?? 0).toString();
                                        final joinDate = data['joinDate'] is Timestamp
                                            ? (data['joinDate'] as Timestamp).toDate().toIso8601String().split('T').first
                                            : (data['joinDate'] ?? '').toString();
                                        final status = (data['status'] ?? '').toString();
                                        final lastActive = data['lastActive'] is Timestamp
                                            ? (data['lastActive'] as Timestamp).toDate().toIso8601String().split('T').first
                                            : (data['lastActive'] ?? '').toString();
                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 16,
                                                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                                    child: Text(
                                                      name.isNotEmpty ? name[0] : '?',
                                                      style: TextStyle(
                                                        color: AppTheme.primaryColor,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      name,
                                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            DataCell(Text(email)),
                                            DataCell(Text(phone)),
                                            DataCell(Text(pets)),
                                            DataCell(Text(joinDate)),
                                            DataCell(
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: status == 'active'
                                                      ? AppTheme.successColor.withOpacity(0.1)
                                                      : AppTheme.errorColor.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  status,
                                                  style: TextStyle(
                                                    color: status == 'active'
                                                        ? AppTheme.successColor
                                                        : AppTheme.errorColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(Text(lastActive)),
                                            DataCell(
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      // View user details
                                                    },
                                                    icon: const Icon(Icons.visibility, size: 16),
                                                    tooltip: 'View',
                                                    constraints: const BoxConstraints(
                                                      minWidth: 24,
                                                      minHeight: 24,
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      // Edit user
                                                    },
                                                    icon: const Icon(Icons.edit, size: 16),
                                                    tooltip: 'Edit',
                                                    constraints: const BoxConstraints(
                                                      minWidth: 24,
                                                      minHeight: 24,
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      // Delete user
                                                    },
                                                    icon: const Icon(Icons.delete, size: 16),
                                                    tooltip: 'Delete',
                                                    constraints: const BoxConstraints(
                                                      minWidth: 24,
                                                      minHeight: 24,
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 