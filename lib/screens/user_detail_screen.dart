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
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              email,
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton.icon(
                                            onPressed: () => _sendPasswordResetEmail(context, email, name),
                                            icon: const Icon(Icons.lock_reset, size: 16),
                                            label: const Text('Send Reset Email'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              minimumSize: const Size(0, 36),
                                            ),
                                          ),
                                        ],
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
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Pets Information Section
                            _buildSection(
                              'Pets Information',
                              [
                                StreamBuilder<QuerySnapshot>(
                                  stream: DatabaseService.getPetsByUserId(widget.userId),
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

                            const SizedBox(height: 24),

                            // Strike History Section
                            _buildSection(
                              'Strike History',
                              [
                                FutureBuilder<List<Map<String, dynamic>>>(
                                  future: DatabaseService.getUserStrikeHistory(widget.userId),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(24.0),
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }
                                    if (snapshot.hasError) {
                                      return Center(
                                        child: Text('Error: ${snapshot.error}'),
                                      );
                                    }

                                    final strikes = snapshot.data ?? [];
                                    if (strikes.isEmpty) {
                                      return Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: AppTheme.surfaceColor,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: AppTheme.borderColor,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Text('No strike history found'),
                                        ),
                                      );
                                    }

                                    return Card(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: DataTable(
                                          columnSpacing: 24,
                                          columns: const [
                                            DataColumn(label: Text('Date')),
                                            DataColumn(label: Text('Action')),
                                            DataColumn(label: Text('Reason')),
                                            DataColumn(label: Text('Admin')),
                                          ],
                                          rows: strikes.map((strike) {
                                            final action = strike['action'] ?? 'unknown';
                                            final reason = strike['reason'] ?? 'No reason provided';
                                            final adminEmail = strike['adminEmail'] ?? 'Unknown';
                                            final createdAt = strike['createdAt'];
                                            
                                            String dateStr = 'Unknown';
                                            if (createdAt != null) {
                                              if (createdAt is Timestamp) {
                                                dateStr = createdAt.toDate().toString().substring(0, 16);
                                              } else {
                                                dateStr = createdAt.toString();
                                              }
                                            }
                                            
                                            Color actionColor = AppTheme.textSecondary;
                                            IconData actionIcon = Icons.info;
                                            if (action == 'warning') {
                                              actionColor = Colors.orange;
                                              actionIcon = Icons.warning;
                                            } else if (action == 'mute') {
                                              actionColor = Colors.blue;
                                              actionIcon = Icons.volume_off;
                                            } else if (action == 'suspension') {
                                              actionColor = Colors.red;
                                              actionIcon = Icons.block;
                                            }
                                            
                                            return DataRow(
                                              cells: [
                                                DataCell(Text(dateStr)),
                                                DataCell(
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(actionIcon, color: actionColor, size: 18),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        action.toUpperCase(),
                                                        style: TextStyle(
                                                          color: actionColor,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: 300,
                                                    child: Text(
                                                      reason,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                                DataCell(Text(adminEmail)),
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

  void _sendPasswordResetEmail(BuildContext context, String email, String userName) {
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock_reset, color: Colors.orange),
            SizedBox(width: 8),
            Text('Send Password Reset Email'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Send password reset email to $userName?'),
            const SizedBox(height: 8),
            Text(
              'Email: $email',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Enter your admin password to confirm',
                hintText: 'Type your admin password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            const Text(
              'This action will send a password reset email to the user.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              passwordController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              
              if (passwordController.text.isEmpty) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Please enter your admin password')),
                );
                return;
              }
              
              // Verify admin password
              final isPasswordValid = await DatabaseService.verifyAdminPassword(passwordController.text);
              if (!isPasswordValid) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Invalid admin password')),
                );
                passwordController.clear();
                return;
              }
              
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Sending password reset email...'),
                    ],
                  ),
                ),
              );
              
              try {
                final success = await DatabaseService.sendPasswordResetEmail(email);
                if (mounted) {
                  Navigator.pop(context); // Close loading dialog
                  Navigator.pop(context); // Close password dialog
                  passwordController.dispose();
                  
                  if (success) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Password reset email sent to $userName'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Failed to send password reset email'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context); // Close loading dialog
                  Navigator.pop(context); // Close password dialog
                  passwordController.dispose();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Error sending password reset email: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.send),
            label: const Text('Send Reset Email'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

