import 'package:flutter/material.dart';
import 'package:furever_healthy_admin/theme/app_theme.dart';
import 'package:furever_healthy_admin/widgets/sidebar.dart';
import 'package:furever_healthy_admin/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PetBreedsScreen extends StatefulWidget {
  const PetBreedsScreen({super.key});

  @override
  State<PetBreedsScreen> createState() => _PetBreedsScreenState();
}

class _PetBreedsScreenState extends State<PetBreedsScreen> {
  String _searchQuery = '';
  String _categoryFilter = 'all';
  String _sizeFilter = 'all';
  String _statusFilter = 'all';

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _applyFilters(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    return docs.where((doc) {
      final data = doc.data();
      final name = (data['name'] ?? '').toString();
      final desc = (data['description'] ?? '').toString();
      final category = (data['category'] ?? '').toString();
      final size = (data['size'] ?? '').toString();
      final status = (data['status'] ?? '').toString();
      final matchesSearch = name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          desc.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _categoryFilter == 'all' || category == _categoryFilter;
      final matchesSize = _sizeFilter == 'all' || size == _sizeFilter;
      final matchesStatus = _statusFilter == 'all' || status == _statusFilter;
      return matchesSearch && matchesCategory && matchesSize && matchesStatus;
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
                              'Pet Breeds',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage pet breeds and categories',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Add new breed (optional)
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Breed'),
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
                                      hintText: 'Search breeds...',
                                      prefixIcon: Icon(Icons.search),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                // Category Filter
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _categoryFilter,
                                    decoration: const InputDecoration(
                                      labelText: 'Category',
                                      border: InputBorder.none,
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'all', child: Text('All')),
                                      DropdownMenuItem(value: 'Dog', child: Text('Dogs')),
                                      DropdownMenuItem(value: 'Cat', child: Text('Cats')),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _categoryFilter = value!;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                // Size Filter
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _sizeFilter,
                                    decoration: const InputDecoration(
                                      labelText: 'Size',
                                      border: InputBorder.none,
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'all', child: Text('All')),
                                      DropdownMenuItem(value: 'Small', child: Text('Small')),
                                      DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                                      DropdownMenuItem(value: 'Large', child: Text('Large')),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _sizeFilter = value!;
                                      });
                                    },
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
                        
                        // Breeds Table
                        Expanded(
                          child: Card(
                            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                              stream: DatabaseService.petBreeds.orderBy('name').withConverter<Map<String, dynamic>>(
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
                                  return const Center(child: Text('No breeds found'));
                                }
                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(minWidth: 1200),
                                    child: DataTable(
                                      columnSpacing: 24,
                                      columns: const [
                                        DataColumn(label: Text('Breed')),
                                        DataColumn(label: Text('Category')),
                                        DataColumn(label: Text('Size')),
                                        DataColumn(label: Text('Temperament')),
                                        DataColumn(label: Text('Life Expectancy')),
                                        DataColumn(label: Text('Popularity')),
                                        DataColumn(label: Text('Status')),
                                        DataColumn(label: Text('Actions')),
                                      ],
                                      rows: filtered.map((doc) {
                                        final data = doc.data();
                                        final id = doc.id;
                                        final name = (data['name'] ?? '').toString();
                                        final category = (data['category'] ?? '').toString();
                                        final size = (data['size'] ?? '').toString();
                                        final temperament = (data['temperament'] ?? '').toString();
                                        final lifeExpectancy = (data['lifeExpectancy'] ?? '').toString();
                                        final popularity = (data['popularity'] ?? '').toString();
                                        final status = (data['status'] ?? '').toString();

                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 20,
                                                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                                    child: Icon(
                                                      category == 'Dog' ? Icons.pets : Icons.pets_outlined,
                                                      color: AppTheme.primaryColor,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
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
                                                          style: const TextStyle(
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
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: category == 'Dog' ? Colors.blue.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  category,
                                                  style: TextStyle(
                                                    color: category == 'Dog' ? Colors.blue.shade700 : Colors.orange.shade700,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(Text(size)),
                                            DataCell(
                                              SizedBox(
                                                width: 200,
                                                child: Text(
                                                  temperament,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            DataCell(Text(lifeExpectancy)),
                                            DataCell(
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: popularity == 'Very Popular' ? Colors.green.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  popularity,
                                                  style: TextStyle(
                                                    color: popularity == 'Very Popular' ? Colors.green.shade700 : Colors.amber.shade700,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: status == 'active' ? AppTheme.successColor.withOpacity(0.1) : AppTheme.errorColor.withOpacity(0.1),
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
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      // View breed details
                                                    },
                                                    icon: const Icon(Icons.visibility, size: 16),
                                                    tooltip: 'View',
                                                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      // Edit breed
                                                    },
                                                    icon: const Icon(Icons.edit, size: 16),
                                                    tooltip: 'Edit',
                                                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      // Delete breed
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