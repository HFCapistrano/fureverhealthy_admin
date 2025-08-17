import 'package:flutter/material.dart';
import 'package:furever_healthy_admin/theme/app_theme.dart';
import 'package:furever_healthy_admin/widgets/sidebar.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final List<Map<String, dynamic>> _users = [
    {
      'id': '1',
      'name': 'John Smith',
      'email': 'john.smith@email.com',
      'phone': '+1 (555) 123-4567',
      'pets': 2,
      'joinDate': '2024-01-15',
      'status': 'active',
      'lastActive': '2024-01-20',
    },
    {
      'id': '2',
      'name': 'Sarah Johnson',
      'email': 'sarah.j@email.com',
      'phone': '+1 (555) 234-5678',
      'pets': 1,
      'joinDate': '2024-01-10',
      'status': 'active',
      'lastActive': '2024-01-19',
    },
    {
      'id': '3',
      'name': 'Michael Brown',
      'email': 'michael.b@email.com',
      'phone': '+1 (555) 345-6789',
      'pets': 3,
      'joinDate': '2024-01-05',
      'status': 'inactive',
      'lastActive': '2024-01-12',
    },
    {
      'id': '4',
      'name': 'Emily Davis',
      'email': 'emily.d@email.com',
      'phone': '+1 (555) 456-7890',
      'pets': 1,
      'joinDate': '2024-01-18',
      'status': 'active',
      'lastActive': '2024-01-20',
    },
    {
      'id': '5',
      'name': 'David Wilson',
      'email': 'david.w@email.com',
      'phone': '+1 (555) 567-8901',
      'pets': 2,
      'joinDate': '2024-01-12',
      'status': 'active',
      'lastActive': '2024-01-18',
    },
  ];

  String _searchQuery = '';
  String _statusFilter = 'all';

  List<Map<String, dynamic>> get _filteredUsers {
    return _users.where((user) {
      final matchesSearch = user['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user['email'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == 'all' || user['status'] == _statusFilter;
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
                          // Add new user
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
                            child: SingleChildScrollView(
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
                                  rows: _filteredUsers.map((user) => DataRow(
                                    cells: [
                                      DataCell(
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 16,
                                              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                              child: Text(
                                                user['name'][0],
                                                style: TextStyle(
                                                  color: AppTheme.primaryColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                user['name'],
                                                style: const TextStyle(fontWeight: FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(Text(user['email'])),
                                      DataCell(Text(user['phone'])),
                                      DataCell(Text(user['pets'].toString())),
                                      DataCell(Text(user['joinDate'])),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: user['status'] == 'active'
                                                ? AppTheme.successColor.withOpacity(0.1)
                                                : AppTheme.errorColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            user['status'],
                                            style: TextStyle(
                                              color: user['status'] == 'active'
                                                  ? AppTheme.successColor
                                                  : AppTheme.errorColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(user['lastActive'])),
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
                                  )).toList(),
                                ),
                              ),
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