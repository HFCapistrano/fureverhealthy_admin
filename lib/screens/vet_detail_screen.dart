import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:furever_healthy_admin/theme/app_theme.dart';
import 'package:furever_healthy_admin/widgets/sidebar.dart';
import 'package:furever_healthy_admin/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VetDetailScreen extends StatefulWidget {
  final String vetId;
  
  const VetDetailScreen({
    super.key,
    required this.vetId,
  });

  @override
  State<VetDetailScreen> createState() => _VetDetailScreenState();
}

class _VetDetailScreenState extends State<VetDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: DatabaseService.vets.doc(widget.vetId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('Vet not found'));
                }

                final vetData = snapshot.data!.data() as Map<String, dynamic>;
                final name = vetData['name'] ?? 'Unknown';
                final email = vetData['email'] ?? '';
                final phone = vetData['phone'] ?? '';
                final clinic = vetData['clinic'] ?? '';
                final specialization = vetData['specialization'] ?? '';
                final experience = vetData['experience'] ?? '';
                final rating = vetData['rating'] ?? 0;
                final patients = vetData['patients'] ?? 0;
                final license = vetData['license'] ?? '';
                final education = vetData['education'] ?? '';
                final bio = vetData['bio'] ?? '';
                final status = vetData['status'] ?? 'active';
                final isOnline = vetData['isOnline'] ?? false;
                final verified = vetData['verified'] ?? false;
                final userType = vetData['userType'] ?? 'regular';

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
                            onPressed: () => context.go('/vets'),
                            icon: const Icon(Icons.arrow_back),
                            tooltip: 'Back to Vets',
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Veterinarian Details',
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
                                _buildInfoRow('Email', email),
                                _buildInfoRow('Phone', phone),
                                _buildInfoRow('License Number', license),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Professional Information Section
                            _buildSection(
                              'Professional Information',
                              [
                                _buildInfoRow('Specialization', specialization),
                                _buildInfoRow('Experience', experience),
                                _buildInfoRow('Clinic/Hospital', clinic),
                                _buildInfoRow('Education', education),
                                _buildInfoRow('Rating', rating.toString()),
                                _buildInfoRow('Number of Patients', patients.toString()),
                                if (bio.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Biography',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceColor,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppTheme.borderColor),
                                    ),
                                    child: Text(
                                      bio,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
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
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInfoCard(
                                        'Verification Status',
                                        verified ? 'Verified' : 'Unverified',
                                        verified ? AppTheme.successColor : AppTheme.errorColor,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildInfoCard(
                                        'User Type',
                                        userType.toUpperCase(),
                                        userType == 'premium' ? Colors.amber : AppTheme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Patients Information Section
                            _buildSection(
                              'Patients Information',
                              [
                                StreamBuilder<QuerySnapshot>(
                                  stream: DatabaseService.getPetsByVetId(widget.vetId),
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

                                    final pets = petsSnapshot.data?.docs ?? [];
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
                                          child: Text('No patients found'),
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
                                            final species =
                                                petData['species'] ?? 'Unknown';
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
                          'Species', petData['species'] ?? 'Unknown'),
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

