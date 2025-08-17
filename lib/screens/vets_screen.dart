import 'package:flutter/material.dart';
import 'package:furever_healthy_admin/theme/app_theme.dart';
import 'package:furever_healthy_admin/widgets/sidebar.dart';

class VetsScreen extends StatefulWidget {
  const VetsScreen({super.key});

  @override
  State<VetsScreen> createState() => _VetsScreenState();
}

class _VetsScreenState extends State<VetsScreen> {
  final List<Map<String, dynamic>> _vets = [
    {
      'id': '1',
      'name': 'Dr. Sarah Wilson',
      'email': 'sarah.wilson@vetclinic.com',
      'phone': '+1 (555) 123-4567',
      'specialization': 'General Practice',
      'experience': '8 years',
      'clinic': 'Pawsome Care Clinic',
      'status': 'active',
      'verified': true,
      'userType': 'premium',
      'rating': 4.8,
      'patients': 156,
    },
    {
      'id': '2',
      'name': 'Dr. Michael Chen',
      'email': 'michael.chen@vetclinic.com',
      'phone': '+1 (555) 234-5678',
      'specialization': 'Surgery',
      'experience': '12 years',
      'clinic': 'Advanced Pet Surgery',
      'status': 'active',
      'verified': true,
      'userType': 'premium',
      'rating': 4.9,
      'patients': 89,
    },
    {
      'id': '3',
      'name': 'Dr. Emily Rodriguez',
      'email': 'emily.rodriguez@vetclinic.com',
      'phone': '+1 (555) 345-6789',
      'specialization': 'Dermatology',
      'experience': '6 years',
      'clinic': 'Skin & Coat Specialists',
      'status': 'active',
      'verified': false,
      'userType': 'regular',
      'rating': 4.7,
      'patients': 203,
    },
    {
      'id': '4',
      'name': 'Dr. David Thompson',
      'email': 'david.thompson@vetclinic.com',
      'phone': '+1 (555) 456-7890',
      'specialization': 'Emergency Care',
      'experience': '15 years',
      'clinic': 'Emergency Pet Hospital',
      'status': 'inactive',
      'verified': true,
      'userType': 'premium',
      'rating': 4.6,
      'patients': 312,
    },
    {
      'id': '5',
      'name': 'Dr. Lisa Park',
      'email': 'lisa.park@vetclinic.com',
      'phone': '+1 (555) 567-8901',
      'specialization': 'Cardiology',
      'experience': '10 years',
      'clinic': 'Heart Care for Pets',
      'status': 'active',
      'verified': false,
      'userType': 'regular',
      'rating': 4.9,
      'patients': 67,
    },
  ];

  String _searchQuery = '';
  String _statusFilter = 'all';
  String _specializationFilter = 'all';
  String _verificationFilter = 'all';
  String _userTypeFilter = 'all';

  List<Map<String, dynamic>> get _filteredVets {
    return _vets.where((vet) {
      final matchesSearch = vet['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          vet['email'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          vet['clinic'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == 'all' || vet['status'] == _statusFilter;
      final matchesSpecialization = _specializationFilter == 'all' || vet['specialization'] == _specializationFilter;
      final matchesVerification = _verificationFilter == 'all' || 
          (_verificationFilter == 'verified' && vet['verified'] == true) ||
          (_verificationFilter == 'unverified' && vet['verified'] == false);
      final matchesUserType = _userTypeFilter == 'all' || vet['userType'] == _userTypeFilter;
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
                          // Add new vet
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
                            child: SingleChildScrollView(
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
                                  rows: _filteredVets.map((vet) => DataRow(
                                    cells: [
                                      DataCell(
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 16,
                                              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                              child: Text(
                                                vet['name'][0],
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
                                                    vet['name'],
                                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                                  ),
                                                  Text(
                                                    'ID: ${vet['id']}',
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
                                            Text(vet['email']),
                                            Text(
                                              vet['phone'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(Text(vet['specialization'])),
                                      DataCell(Text(vet['experience'])),
                                      DataCell(Text(vet['clinic'])),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: vet['status'] == 'active'
                                                ? AppTheme.successColor.withOpacity(0.1)
                                                : AppTheme.errorColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            vet['status'],
                                            style: TextStyle(
                                              color: vet['status'] == 'active'
                                                  ? AppTheme.successColor
                                                  : AppTheme.errorColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          children: [
                                            Icon(
                                              vet['verified'] ? Icons.verified : Icons.verified_outlined,
                                              size: 16,
                                              color: vet['verified'] ? AppTheme.successColor : AppTheme.textSecondary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              vet['verified'] ? 'Verified' : 'Unverified',
                                              style: TextStyle(
                                                color: vet['verified'] ? AppTheme.successColor : AppTheme.textSecondary,
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
                                            color: vet['userType'] == 'premium'
                                                ? Colors.amber.withOpacity(0.1)
                                                : AppTheme.primaryColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            vet['userType'].toString().toUpperCase(),
                                            style: TextStyle(
                                              color: vet['userType'] == 'premium'
                                                  ? Colors.amber.shade700
                                                  : AppTheme.primaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              size: 16,
                                              color: Colors.amber,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(vet['rating'].toString()),
                                          ],
                                        ),
                                      ),
                                      DataCell(Text(vet['patients'].toString())),
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
                                              constraints: const BoxConstraints(
                                                minWidth: 24,
                                                minHeight: 24,
                                              ),
                                              padding: EdgeInsets.zero,
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                // Edit vet
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
                                                // Delete vet
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