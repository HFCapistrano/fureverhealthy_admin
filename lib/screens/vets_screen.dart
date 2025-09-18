import 'package:flutter/material.dart';
import 'package:furever_healthy_admin/theme/app_theme.dart';
import 'package:furever_healthy_admin/widgets/sidebar.dart';
import 'package:furever_healthy_admin/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VetsScreen extends StatefulWidget {
  const VetsScreen({super.key});

  @override
  State<VetsScreen> createState() => _VetsScreenState();
}

class _VetsScreenState extends State<VetsScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all';
  String _specializationFilter = 'all';
  String _verificationFilter = 'all';
  String _userTypeFilter = 'all';

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _applyFilters(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    return docs.where((doc) {
      final data = doc.data();
      final name = (data['name'] ?? '').toString();
      final email = (data['email'] ?? '').toString();
      final clinic = (data['clinic'] ?? '').toString();
      final status = (data['status'] ?? '').toString();
      final specialization = (data['specialization'] ?? '').toString();
      final verified = (data['verified'] ?? false) == true;
      final userType = (data['userType'] ?? '').toString();

      final matchesSearch = name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          clinic.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == 'all' || status == _statusFilter;
      final matchesSpecialization = _specializationFilter == 'all' || specialization == _specializationFilter;
      final matchesVerification = _verificationFilter == 'all' ||
          (_verificationFilter == 'verified' && verified) ||
          (_verificationFilter == 'unverified' && !verified);
      final matchesUserType = _userTypeFilter == 'all' || userType == _userTypeFilter;

      return matchesSearch && matchesStatus && matchesSpecialization && matchesVerification && matchesUserType;
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
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceColor,
                    border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Veterinarians',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage veterinary professionals',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Add new vet (optional)
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Vet'),
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
                                      hintText: 'Search vets, clinics...',
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
                                const SizedBox(width: 16),
                                
                                // Specialization Filter
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _specializationFilter,
                                    decoration: const InputDecoration(
                                      labelText: 'Specialization',
                                      border: InputBorder.none,
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'all', child: Text('All')),
                                      DropdownMenuItem(value: 'General Practice', child: Text('General Practice')),
                                      DropdownMenuItem(value: 'Surgery', child: Text('Surgery')),
                                      DropdownMenuItem(value: 'Dermatology', child: Text('Dermatology')),
                                      DropdownMenuItem(value: 'Emergency Care', child: Text('Emergency Care')),
                                      DropdownMenuItem(value: 'Cardiology', child: Text('Cardiology')),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _specializationFilter = value!;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                // Verification Filter
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _verificationFilter,
                                    decoration: const InputDecoration(
                                      labelText: 'Verification',
                                      border: InputBorder.none,
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'all', child: Text('All')),
                                      DropdownMenuItem(value: 'verified', child: Text('Verified')),
                                      DropdownMenuItem(value: 'unverified', child: Text('Unverified')),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _verificationFilter = value!;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                // User Type Filter
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _userTypeFilter,
                                    decoration: const InputDecoration(
                                      labelText: 'User Type',
                                      border: InputBorder.none,
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'all', child: Text('All')),
                                      DropdownMenuItem(value: 'premium', child: Text('Premium')),
                                      DropdownMenuItem(value: 'regular', child: Text('Regular')),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _userTypeFilter = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Vets Table
                        Expanded(
                          child: Card(
                            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                              stream: DatabaseService.vets.orderBy('name').withConverter<Map<String, dynamic>>(
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
                                  return const Center(child: Text('No vets found'));
                                }
                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(minWidth: 1400),
                                    child: DataTable(
                                      columnSpacing: 24,
                                      columns: const [
                                        DataColumn(label: Text('Veterinarian')),
                                        DataColumn(label: Text('Contact')),
                                        DataColumn(label: Text('Specialization')),
                                        DataColumn(label: Text('Experience')),
                                        DataColumn(label: Text('Clinic')),
                                        DataColumn(label: Text('Status')),
                                        DataColumn(label: Text('Verified')),
                                        DataColumn(label: Text('User Type')),
                                        DataColumn(label: Text('Rating')),
                                        DataColumn(label: Text('Patients')),
                                        DataColumn(label: Text('Actions')),
                                      ],
                                      rows: filtered.map((doc) {
                                        final data = doc.data();
                                        final name = (data['name'] ?? '').toString();
                                        final id = doc.id;
                                        final email = (data['email'] ?? '').toString();
                                        final phone = (data['phone'] ?? '').toString();
                                        final specialization = (data['specialization'] ?? '').toString();
                                        final experience = (data['experience'] ?? '').toString();
                                        final clinic = (data['clinic'] ?? '').toString();
                                        final status = (data['status'] ?? '').toString();
                                        final verified = (data['verified'] ?? false) == true;
                                        final userType = (data['userType'] ?? '').toString();
                                        final rating = (data['rating'] ?? '').toString();
                                        final patients = (data['patients'] ?? '').toString();

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
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          name,
                                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                                        ),
                                                        Text(
                                                          'ID: $id',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: AppTheme.textSecondary,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            DataCell(
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(email),
                                                  Text(
                                                    phone,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: AppTheme.textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            DataCell(Text(specialization)),
                                            DataCell(Text(experience)),
                                            DataCell(Text(clinic)),
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
                                                    color: status == 'active' ? AppTheme.successColor : AppTheme.errorColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Row(
                                                children: [
                                                  Icon(
                                                    verified ? Icons.verified : Icons.verified_outlined,
                                                    size: 16,
                                                    color: verified ? AppTheme.successColor : AppTheme.textSecondary,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    verified ? 'Verified' : 'Unverified',
                                                    style: TextStyle(
                                                      color: verified ? AppTheme.successColor : AppTheme.textSecondary,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            DataCell(
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: userType == 'premium'
                                                      ? Colors.amber.withOpacity(0.1)
                                                      : AppTheme.primaryColor.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  userType.toUpperCase(),
                                                  style: TextStyle(
                                                    color: userType == 'premium' ? Colors.amber.shade700 : AppTheme.primaryColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.star,
                                                    size: 16,
                                                    color: Colors.amber,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(rating.toString()),
                                                ],
                                              ),
                                            ),
                                            DataCell(Text(patients.toString())),
                                            DataCell(
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      // View vet details
                                                    },
                                                    icon: const Icon(Icons.visibility, size: 16),
                                                    tooltip: 'View',
                                                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      // Edit vet
                                                    },
                                                    icon: const Icon(Icons.edit, size: 16),
                                                    tooltip: 'Edit',
                                                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      // Delete vet
                                                    },
                                                    icon: const Icon(Icons.delete, size: 16),
                                                    tooltip: 'Delete',
                                                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
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