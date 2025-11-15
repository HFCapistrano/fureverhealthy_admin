import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:furever_healthy_admin/theme/app_theme.dart';
import 'package:furever_healthy_admin/widgets/sidebar.dart';
import 'package:furever_healthy_admin/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetailScreen extends StatefulWidget {
  final String userId;
  
  const UserDetailScreen({
    super.key,
    required this.userId,
  });

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: DatabaseService.users.doc(widget.userId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('User not found'));
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final name = userData['name'] ?? 'Unknown';
                final email = userData['email'] ?? '';
                final phone = userData['phone'] ?? '';
                final address = userData['address'] ?? '';
                final status = userData['status'] ?? 'active';
                final isOnline = userData['isOnline'] ?? false;
                final isMuted = userData['muted'] ?? false;
                final joinDate = userData['joinDate'];
                final lastActive = userData['lastActive'];

                String joinDateStr = 'Unknown';
                if (joinDate != null) {
                  if (joinDate is Timestamp) {
                    joinDateStr = joinDate.toDate().toString().substring(0, 16);
                  } else {
                    joinDateStr = joinDate.toString();
                  }
                }

                String lastActiveStr = 'Unknown';
                if (lastActive != null) {
                  if (lastActive is Timestamp) {
                    lastActiveStr = lastActive.toDate().toString().substring(0, 16);
                  } else {
                    lastActiveStr = lastActive.toString();
                  }
                }

                return Column(
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
                          IconButton(
                            onPressed: () => context.go('/users'),
                            icon: const Icon(Icons.arrow_back),
                            tooltip: 'Back to Users',
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'User Details',
                                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  name,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Personal Information Section
                            _buildSection(
                              'Personal Information',
                              [
                                _buildInfoRow('Name', name),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 150,
                                      child: Text(
                                        'Email',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        email,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                                _buildInfoRow('Phone', phone),
                                _buildInfoRow('Address', address),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Account Information Section
                            _buildSection(
                              'Account Information',
                              [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInfoCard(
                                        'Account Status',
                                        status == 'active'
                                            ? 'Active'
                                            : status == 'inactive'
                                                ? 'Inactive'
                                                : 'Dormant',
                                        status == 'active'
                                            ? AppTheme.successColor
                                            : status == 'inactive'
                                                ? AppTheme.errorColor
                                                : Colors.orange,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildInfoCard(
                                        'Online Status',
                                        isOnline ? 'Online' : 'Offline',
                                        isOnline ? Colors.green : Colors.grey,
                                      ),
                                    ),
                                    if (isMuted) ...[
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildInfoCard(
                                          'Moderation Status',
                                          'Muted',
                                          Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow('Join Date', joinDateStr),
                                _buildInfoRow('Last Active', lastActiveStr),
                                if (userData['userType'] != null) ...[
                                  const SizedBox(height: 16),
                                  _buildInfoRow('User Type', (userData['userType'] ?? 'regular').toString().toUpperCase()),
                                ],
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Pets Information Section
                            _buildSection(
                              'Pets Information',
                              [
                                FutureBuilder<List<QueryDocumentSnapshot>>(
                                  future: DatabaseService.getPetsByUserIdAsync(widget.userId),
                                  builder: (context, petsSnapshot) {
                                    if (petsSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: Padding(
                                        padding: EdgeInsets.all(24.0),
                                        child: CircularProgressIndicator(),
                                      ));
                                    }
                                    if (petsSnapshot.hasError) {
                                      return Center(
                                          child: Text(
                                              'Error: ${petsSnapshot.error}'));
                                    }

                                    final pets = petsSnapshot.data ?? [];
                                    if (pets.isEmpty) {
                                      return Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: AppTheme.surfaceColor,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                              color: AppTheme.borderColor),
                                        ),
                                        child: const Center(
                                          child: Text('No pets found'),
                                        ),
                                      );
                                    }

                                    return Card(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: DataTable(
                                          columnSpacing: 24,
                                          columns: const [
                                            DataColumn(label: Text('View')),
                                            DataColumn(label: Text('Name')),
                                            DataColumn(label: Text('Species')),
                                            DataColumn(label: Text('Breed')),
                                            DataColumn(label: Text('Age')),
                                            DataColumn(label: Text('Gender')),
                                            DataColumn(label: Text('Weight')),
                                            DataColumn(label: Text('Status')),
                                          ],
                                          rows: pets.map((petDoc) {
                                            final petData = petDoc.data()
                                                as Map<String, dynamic>;
                                            final petName =
                                                petData['name'] ?? 'Unknown';
                                            // Check for species field variations
                                            final species = petData['species'] ?? 
                                                petData['speciesType'] ?? 
                                                (petData['medicalConcerns'] != null && petData['medicalConcerns'] is Map
                                                    ? (petData['medicalConcerns'] as Map)['speciesType'] ?? 'Unknown'
                                                    : 'Unknown');
                                            final breed =
                                                petData['breedName'] ?? petData['breed'] ?? 'Unknown';
                                            // Calculate age from birthDate if available
                                            String age = 'Unknown';
                                            if (petData['birthDate'] != null && petData['birthDate'].toString().isNotEmpty) {
                                              try {
                                                final birthDate = petData['birthDate'];
                                                if (birthDate is Timestamp) {
                                                  final years = DateTime.now().difference(birthDate.toDate()).inDays ~/ 365;
                                                  age = '$years years';
                                                }
                                              } catch (e) {
                                                age = petData['age'] ?? petData['ageYears'] ?? 'Unknown';
                                              }
                                            } else {
                                              age = petData['age'] ?? petData['ageYears'] ?? 'Unknown';
                                            }
                                            final gender =
                                                petData['sex'] ?? petData['gender'] ?? 'Unknown';
                                            final weight =
                                                petData['weightKG'] != null && petData['weightKG'].toString().isNotEmpty
                                                    ? '${petData['weightKG']} kg'
                                                    : (petData['weight'] != null && petData['weight'].toString().isNotEmpty
                                                        ? '${petData['weight']} kg'
                                                        : 'Unknown');
                                            final petStatus =
                                                petData['status'] ?? 'Active';

                                            return DataRow(
                                              cells: [
                                                DataCell(
                                                  ElevatedButton(
                                                    onPressed: () =>
                                                        _viewPetDetails(
                                                            context,
                                                            petDoc.id,
                                                            petData),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 6),
                                                      minimumSize:
                                                          const Size(60, 32),
                                                    ),
                                                    child: const Text('View',
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                  ),
                                                ),
                                                DataCell(Text(petName)),
                                                DataCell(Text(species)),
                                                DataCell(Text(breed)),
                                                DataCell(Text(
                                                    age.toString())),
                                                DataCell(Text(gender)),
                                                DataCell(Text(
                                                    weight.toString())),
                                                DataCell(
                                                  Container(
                                                    padding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                                horizontal: 8,
                                                                vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: petStatus ==
                                                              'Active'
                                                          ? AppTheme
                                                              .successColor
                                                              .withOpacity(
                                                                  0.1)
                                                          : AppTheme
                                                              .errorColor
                                                              .withOpacity(
                                                                  0.1),
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(4),
                                                    ),
                                                    child: Text(
                                                      petStatus,
                                                      style: TextStyle(
                                                        color: petStatus ==
                                                                'Active'
                                                            ? AppTheme
                                                                .successColor
                                                            : AppTheme
                                                                .errorColor,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 12,
                                                      ),
                                                    ),
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
                              ],
                            ),

                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(8),
        color: AppTheme.surfaceColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  void _viewPetDetails(
      BuildContext context, String petId, Map<String, dynamic> petData) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.pets, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Pet Details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPetDetailRow('Name', petData['name'] ?? 'Unknown'),
                      _buildPetDetailRow(
                          'Species', 
                          petData['species'] ?? 
                          petData['speciesType'] ?? 
                          (petData['medicalConcerns'] != null && petData['medicalConcerns'] is Map
                              ? (petData['medicalConcerns'] as Map)['speciesType'] ?? 'Unknown'
                              : 'Unknown')),
                      _buildPetDetailRow('Breed', 
                          petData['breedName'] ?? petData['breed'] ?? 'Unknown'),
                      if (petData['birthDate'] != null && petData['birthDate'].toString().isNotEmpty)
                        _buildPetDetailRow('Birth Date',
                            _formatTimestamp(petData['birthDate']))
                      else
                        _buildPetDetailRow('Age',
                            (petData['age'] ?? petData['ageYears'] ?? 'Unknown')
                                .toString()),
                      _buildPetDetailRow('Gender', 
                          petData['sex'] ?? petData['gender'] ?? 'Unknown'),
                      _buildPetDetailRow('Weight',
                          petData['weightKG'] != null && petData['weightKG'].toString().isNotEmpty
                              ? '${petData['weightKG']} kg'
                              : (petData['weight'] != null && petData['weight'].toString().isNotEmpty
                                  ? '${petData['weight']} kg'
                                  : 'Unknown')),
                      _buildPetDetailRow('Neutered', 
                          petData['neutured'] != null 
                              ? (petData['neutured'] == true ? 'Yes' : 'No')
                              : 'Unknown'),
                      _buildPetDetailRow('Status', 
                          petData['status'] ?? 'Active'),
                      if (petData['petID'] != null && petData['petID'].toString().isNotEmpty)
                        _buildPetDetailRow('Pet ID', petData['petID']),
                      if (petData['notes'] != null && petData['notes'].toString().isNotEmpty)
                        _buildPetDetailRow('Notes', petData['notes']),
                      if (petData['vaccinations'] != null && petData['vaccinations'].toString().isNotEmpty)
                        _buildPetDetailRow(
                            'Vaccinations', petData['vaccinations']),
                      if (petData['addedAt'] != null && petData['addedAt'].toString().isNotEmpty)
                        _buildPetDetailRow('Added At',
                            _formatTimestamp(petData['addedAt'])),
                      if (petData['updatedAt'] != null && petData['updatedAt'].toString().isNotEmpty)
                        _buildPetDetailRow('Updated At',
                            _formatTimestamp(petData['updatedAt'])),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    if (timestamp is Timestamp) {
      return timestamp.toDate().toString().substring(0, 16);
    }
    return timestamp.toString();
  }

}

