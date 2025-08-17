import 'package:flutter/material.dart';
import 'package:furever_healthy_admin/theme/app_theme.dart';
import 'package:furever_healthy_admin/widgets/sidebar.dart';

class PetBreedsScreen extends StatefulWidget {
  const PetBreedsScreen({super.key});

  @override
  State<PetBreedsScreen> createState() => _PetBreedsScreenState();
}

class _PetBreedsScreenState extends State<PetBreedsScreen> {
  final List<Map<String, dynamic>> _breeds = [
    {
      'id': '1',
      'name': 'Golden Retriever',
      'category': 'Dog',
      'size': 'Large',
      'temperament': 'Friendly, Intelligent, Devoted',
      'lifeExpectancy': '10-12 years',
      'popularity': 'Very Popular',
      'status': 'active',
      'imageUrl': 'https://example.com/golden-retriever.jpg',
      'description': 'Known for their friendly and tolerant attitudes.',
    },
    {
      'id': '2',
      'name': 'Persian Cat',
      'category': 'Cat',
      'size': 'Medium',
      'temperament': 'Quiet, Gentle, Affectionate',
      'lifeExpectancy': '12-16 years',
      'popularity': 'Popular',
      'status': 'active',
      'imageUrl': 'https://example.com/persian-cat.jpg',
      'description': 'Known for their long, luxurious coats and sweet personalities.',
    },
    {
      'id': '3',
      'name': 'Maine Coon',
      'category': 'Cat',
      'size': 'Large',
      'temperament': 'Gentle, Intelligent, Playful',
      'lifeExpectancy': '12-15 years',
      'popularity': 'Very Popular',
      'status': 'active',
      'imageUrl': 'https://example.com/maine-coon.jpg',
      'description': 'One of the largest domesticated cat breeds.',
    },
    {
      'id': '4',
      'name': 'Labrador Retriever',
      'category': 'Dog',
      'size': 'Large',
      'temperament': 'Friendly, Active, Outgoing',
      'lifeExpectancy': '10-12 years',
      'popularity': 'Very Popular',
      'status': 'active',
      'imageUrl': 'https://example.com/labrador.jpg',
      'description': 'America\'s most popular dog breed.',
    },
    {
      'id': '5',
      'name': 'Siamese Cat',
      'category': 'Cat',
      'size': 'Medium',
      'temperament': 'Vocal, Social, Intelligent',
      'lifeExpectancy': '15-20 years',
      'popularity': 'Popular',
      'status': 'active',
      'imageUrl': 'https://example.com/siamese.jpg',
      'description': 'Known for their distinctive color points and vocal nature.',
    },
    {
      'id': '6',
      'name': 'German Shepherd',
      'category': 'Dog',
      'size': 'Large',
      'temperament': 'Loyal, Courageous, Intelligent',
      'lifeExpectancy': '7-10 years',
      'popularity': 'Very Popular',
      'status': 'inactive',
      'imageUrl': 'https://example.com/german-shepherd.jpg',
      'description': 'Excellent working dogs and family companions.',
    },
  ];

  String _searchQuery = '';
  String _categoryFilter = 'all';
  String _sizeFilter = 'all';
  String _statusFilter = 'all';

  List<Map<String, dynamic>> get _filteredBreeds {
    return _breeds.where((breed) {
      final matchesSearch = breed['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          breed['description'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _categoryFilter == 'all' || breed['category'] == _categoryFilter;
      final matchesSize = _sizeFilter == 'all' || breed['size'] == _sizeFilter;
      final matchesStatus = _statusFilter == 'all' || breed['status'] == _statusFilter;
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
                          // Add new breed
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
                            child: SingleChildScrollView(
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
                                  rows: _filteredBreeds.map((breed) => DataRow(
                                    cells: [
                                      DataCell(
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                              child: Icon(
                                                breed['category'] == 'Dog' ? Icons.pets : Icons.pets_outlined,
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
                                                    breed['name'],
                                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                                  ),
                                                  Text(
                                                    'ID: ${breed['id']}',
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
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: breed['category'] == 'Dog'
                                                ? Colors.blue.withOpacity(0.1)
                                                : Colors.orange.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            breed['category'],
                                            style: TextStyle(
                                              color: breed['category'] == 'Dog'
                                                  ? Colors.blue.shade700
                                                  : Colors.orange.shade700,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(breed['size'])),
                                      DataCell(
                                        SizedBox(
                                          width: 200,
                                          child: Text(
                                            breed['temperament'],
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(breed['lifeExpectancy'])),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: breed['popularity'] == 'Very Popular'
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.amber.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            breed['popularity'],
                                            style: TextStyle(
                                              color: breed['popularity'] == 'Very Popular'
                                                  ? Colors.green.shade700
                                                  : Colors.amber.shade700,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: breed['status'] == 'active'
                                                ? AppTheme.successColor.withOpacity(0.1)
                                                : AppTheme.errorColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            breed['status'],
                                            style: TextStyle(
                                              color: breed['status'] == 'active'
                                                  ? AppTheme.successColor
                                                  : AppTheme.errorColor,
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
                                              constraints: const BoxConstraints(
                                                minWidth: 24,
                                                minHeight: 24,
                                              ),
                                              padding: EdgeInsets.zero,
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                // Edit breed
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
                                                // Delete breed
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