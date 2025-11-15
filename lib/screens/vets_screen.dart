import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:furever_healthy_admin/theme/app_theme.dart';
import 'package:furever_healthy_admin/widgets/sidebar.dart';
import 'package:furever_healthy_admin/services/database_service.dart';
import 'package:furever_healthy_admin/providers/auth_provider.dart';
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
  
  // Bulk selection
  Set<String> _selectedVetIds = {};
  
  // Scroll controllers for proper scroll bar control
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _applyFilters(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    return docs.where((doc) {
      final data = doc.data();
      final name = (data['name'] ?? '').toString();
      final email = (data['email'] ?? '').toString();
      final clinic = (data['clinic'] ?? '').toString();
      final status = (data['status'] ?? '').toString();
      final specialization = (data['specialization'] ?? '').toString();
      final verified = (data['verified'] ?? false) == true;
      final userType = (data['userType'] ?? 'regular').toString();

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

  void _editVet(BuildContext context, String vetId, Map<String, dynamic> vetData) {
    final nameController = TextEditingController(text: vetData['name'] ?? '');
    final emailController = TextEditingController(text: vetData['email'] ?? '');
    final phoneController = TextEditingController(text: vetData['phone'] ?? '');
    final clinicController = TextEditingController(text: vetData['clinic'] ?? '');
    final specializationController = TextEditingController(text: vetData['specialization'] ?? '');
    final experienceController = TextEditingController(text: vetData['experience'] ?? '');
    final ratingController = TextEditingController(text: vetData['rating']?.toString() ?? '');
    final patientsController = TextEditingController(text: vetData['patients']?.toString() ?? '');
    final licenseController = TextEditingController(text: vetData['license'] ?? '');
    final educationController = TextEditingController(text: vetData['education'] ?? '');
    final bioController = TextEditingController(text: vetData['bio'] ?? '');
    
    String status = vetData['status'] ?? 'active';
    String userType = vetData['userType'] ?? 'regular';
    bool verified = vetData['verified'] ?? false;
    bool licenseVerified = vetData['licenseVerified'] ?? false;
    bool profileHidden = vetData['profileHidden'] ?? false;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Edit Veterinarian',
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
                    children: [
                      // First Row - Name and Email
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Second Row - Phone and Clinic
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.phone),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: clinicController,
                              decoration: const InputDecoration(
                                labelText: 'Clinic',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.business),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Third Row - Specialization and Experience
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: specializationController,
                              decoration: const InputDecoration(
                                labelText: 'Specialization',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.medical_services),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: experienceController,
                              decoration: const InputDecoration(
                                labelText: 'Experience',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.work),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Fourth Row - Rating and Patients
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: ratingController,
                              decoration: const InputDecoration(
                                labelText: 'Rating',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.star),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: patientsController,
                              decoration: const InputDecoration(
                                labelText: 'Patients',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.pets),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Additional Fields Row - License, Education
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: licenseController,
                              decoration: const InputDecoration(
                                labelText: 'License Number',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.badge),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: educationController,
                              decoration: const InputDecoration(
                                labelText: 'Education',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.school),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Bio Field
                      TextField(
                        controller: bioController,
                        decoration: const InputDecoration(
                          labelText: 'Biography',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      
                      // Fifth Row - Account Status (Read-only), Online Status, User Type
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.borderColor),
                                borderRadius: BorderRadius.circular(8),
                                color: AppTheme.surfaceColor,
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.account_circle, color: AppTheme.textSecondary),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Account Status: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    status == 'active' ? 'Active' : status == 'inactive' ? 'Inactive' : 'Dormant',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: status == 'active'
                                          ? AppTheme.successColor
                                          : status == 'inactive'
                                              ? AppTheme.errorColor
                                              : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.borderColor),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.circle, 
                                    color: (vetData['isOnline'] ?? false) ? Colors.green : Colors.grey, 
                                    size: 16
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Online Status'),
                                  const Spacer(),
                                  Text((vetData['isOnline'] ?? false) ? 'Online' : 'Offline'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // User Type Row
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: userType,
                              decoration: const InputDecoration(
                                labelText: 'User Type',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'regular', child: Text('Regular')),
                                DropdownMenuItem(value: 'premium', child: Text('Premium')),
                              ],
                              onChanged: (value) => userType = value!,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Verification Checkbox
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.borderColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_user, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            const Text('Verification Status'),
                            const Spacer(),
                            Checkbox(
                              value: verified,
                              onChanged: (value) => verified = value!,
                            ),
                            Text(verified ? 'Verified' : 'Unverified'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // License Verified and Hide Profile Row
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.borderColor),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.badge, color: AppTheme.primaryColor),
                                  const SizedBox(width: 8),
                                  const Text('License Verified'),
                                  const Spacer(),
                                  Checkbox(
                                    value: licenseVerified,
                                    onChanged: (value) => licenseVerified = value!,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.borderColor),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.visibility_off, color: AppTheme.primaryColor),
                                  const SizedBox(width: 8),
                                  const Text('Hide Profile'),
                                  const Spacer(),
                                  Checkbox(
                                    value: profileHidden,
                                    onChanged: (value) => profileHidden = value!,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      try {
                        await DatabaseService.updateVet(vetId, {
                          'name': nameController.text,
                          'email': emailController.text,
                          'phone': phoneController.text,
                          'clinic': clinicController.text,
                          'specialization': specializationController.text,
                          'experience': experienceController.text,
                          'rating': double.tryParse(ratingController.text) ?? 0.0,
                          'patients': int.tryParse(patientsController.text) ?? 0,
                          'license': licenseController.text,
                          'education': educationController.text,
                          'bio': bioController.text,
                          // Account status and online status are read-only and not updated here
                          'userType': userType,
                          'verified': verified,
                          'licenseVerified': licenseVerified,
                          'profileHidden': profileHidden,
                        });
                        if (mounted) {
                          Navigator.pop(context);
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(content: Text('Veterinarian updated successfully')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(content: Text('Error updating veterinarian: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Update'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteVet(BuildContext context, String vetId, String vetName) {
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Veterinarian'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to delete $vetName?'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Enter password to confirm',
                hintText: 'Type your password',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              if (passwordController.text.isEmpty) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Please enter your password')),
                );
                return;
              }
              
              try {
                await DatabaseService.deleteVet(vetId);
                if (mounted) {
                  Navigator.pop(context);
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Veterinarian deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Error deleting veterinarian: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _sendPasswordResetEmail(BuildContext context, String email, String vetName) {
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
            Text('Send password reset email to $vetName?'),
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
              'This action will send a password reset email to the veterinarian.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final adminEmail = authProvider.userEmail ?? '';
              final isPasswordValid = await DatabaseService.verifyAdminPassword(adminEmail, passwordController.text);
              if (!isPasswordValid) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Invalid admin password')),
                );
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
                  
                  if (success) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Password reset email sent to $vetName'),
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

  void _viewVetDetails(BuildContext context, String vetId, Map<String, dynamic> vetData) {
    context.go('/vets/$vetId');
  }

  // Old view vet details method removed - now navigates to detail screen

  Widget _buildFormSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }


  Widget _buildPatientCard(dynamic patient) {
    // Handle different patient data structures
    String patientName = 'Unknown Patient';
    String petName = 'Unknown Pet';
    String species = 'Unknown';
    String breed = 'Unknown';
    String age = 'Unknown';
    String lastVisit = 'Never';
    String status = 'Active';
    
    if (patient is Map<String, dynamic>) {
      patientName = patient['ownerName'] ?? patient['name'] ?? 'Unknown Patient';
      petName = patient['petName'] ?? patient['name'] ?? 'Unknown Pet';
      species = patient['species'] ?? 'Unknown';
      breed = patient['breed'] ?? 'Unknown';
      age = patient['age']?.toString() ?? 'Unknown';
      lastVisit = patient['lastVisit'] ?? 'Never';
      status = patient['status'] ?? 'Active';
    } else if (patient is String) {
      patientName = patient;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: const Icon(
                  Icons.pets,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Pet: $petName',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'Active' 
                      ? AppTheme.successColor.withOpacity(0.1)
                      : AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == 'Active' 
                        ? AppTheme.successColor 
                        : AppTheme.errorColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPatientDetail('Species', species),
              ),
              Expanded(
                child: _buildPatientDetail('Breed', breed),
              ),
              Expanded(
                child: _buildPatientDetail('Age', age),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildPatientDetail('Last Visit', lastVisit),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        // View patient details
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('View patient details functionality coming soon')),
                        );
                      },
                      icon: const Icon(Icons.visibility, size: 16),
                      tooltip: 'View Details',
                    ),
                    IconButton(
                      onPressed: () {
                        // Edit patient
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edit patient functionality coming soon')),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      tooltip: 'Edit',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _addVet(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final clinicController = TextEditingController();
    final specializationController = TextEditingController();
    final experienceController = TextEditingController();
    final ratingController = TextEditingController();
    final patientsController = TextEditingController();
    final licenseController = TextEditingController();
    final educationController = TextEditingController();
    final bioController = TextEditingController();
    
    String status = 'active';
    String userType = 'regular';
    bool verified = false;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 1000),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_add, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Add New Veterinarian',
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
                    children: [
                      // Personal Information
                      _buildFormSection('Personal Information', [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Full Name *',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email *',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.email),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: phoneController,
                                decoration: const InputDecoration(
                                  labelText: 'Phone',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.phone),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: licenseController,
                                decoration: const InputDecoration(
                                  labelText: 'License Number',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.badge),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]),
                      
                      const SizedBox(height: 24),
                      
                      // Professional Information
                      _buildFormSection('Professional Information', [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: specializationController,
                                decoration: const InputDecoration(
                                  labelText: 'Specialization *',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.medical_services),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: experienceController,
                                decoration: const InputDecoration(
                                  labelText: 'Years of Experience',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.work),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: clinicController,
                                decoration: const InputDecoration(
                                  labelText: 'Clinic/Hospital',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.business),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: educationController,
                                decoration: const InputDecoration(
                                  labelText: 'Education',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.school),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: ratingController,
                                decoration: const InputDecoration(
                                  labelText: 'Rating',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.star),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: patientsController,
                                decoration: const InputDecoration(
                                  labelText: 'Number of Patients',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.pets),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: bioController,
                          decoration: const InputDecoration(
                            labelText: 'Biography',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description),
                          ),
                          maxLines: 3,
                        ),
                      ]),
                      
                      const SizedBox(height: 24),
                      
                      // Account Information
                      _buildFormSection('Account Information', [
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: status,
                                decoration: const InputDecoration(
                                  labelText: 'Account Status',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.account_circle),
                                ),
                                items: const [
                                DropdownMenuItem(value: 'active', child: Text('Active')),
                                DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                                DropdownMenuItem(value: 'dormant', child: Text('Dormant')),
                                ],
                                onChanged: (value) => status = value!,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: userType,
                                decoration: const InputDecoration(
                                  labelText: 'User Type',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.category),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'regular', child: Text('Regular')),
                                  DropdownMenuItem(value: 'premium', child: Text('Premium')),
                                ],
                                onChanged: (value) => userType = value!,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.borderColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.verified_user, color: AppTheme.primaryColor),
                              const SizedBox(width: 8),
                              const Text('Verification Status'),
                              const Spacer(),
                              Checkbox(
                                value: verified,
                                onChanged: (value) => verified = value!,
                              ),
                              Text(verified ? 'Verified' : 'Unverified'),
                            ],
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      // Validate required fields
                      if (nameController.text.isEmpty || emailController.text.isEmpty || specializationController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill in all required fields (*)')),
                        );
                        return;
                      }
                      
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      try {
                        await DatabaseService.createVet({
                          'name': nameController.text,
                          'email': emailController.text,
                          'phone': phoneController.text,
                          'clinic': clinicController.text,
                          'specialization': specializationController.text,
                          'experience': experienceController.text,
                          'rating': double.tryParse(ratingController.text) ?? 0.0,
                          'patients': int.tryParse(patientsController.text) ?? 0,
                          'license': licenseController.text,
                          'education': educationController.text,
                          'bio': bioController.text,
                          'status': status,
                          'userType': userType,
                          'verified': verified,
                          'isOnline': false,
                          'createdAt': DateTime.now(),
                        });
                        if (mounted) {
                          Navigator.pop(context);
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(content: Text('Veterinarian added successfully')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(content: Text('Error adding veterinarian: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Veterinarian'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
                      Row(
                        children: [
                          if (_selectedVetIds.isNotEmpty) ...[
                            ElevatedButton.icon(
                              onPressed: () async {
                                final passwordController = TextEditingController();
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Row(
                                      children: [
                                        Icon(Icons.verified_user, color: AppTheme.primaryColor),
                                        SizedBox(width: 8),
                                        Text('Bulk Verify Vets'),
                                      ],
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Are you sure you want to verify ${_selectedVetIds.length} veterinarians?'),
                                        const SizedBox(height: 16),
                                        TextField(
                                          controller: passwordController,
                                          decoration: const InputDecoration(
                                            labelText: 'Enter your admin password to confirm',
                                            prefixIcon: Icon(Icons.lock),
                                          ),
                                          obscureText: true,
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
                                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                          final adminEmail = authProvider.userEmail ?? '';
                                          final isPasswordValid = await DatabaseService.verifyAdminPassword(adminEmail, passwordController.text);
                                          if (!isPasswordValid) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Invalid admin password'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            passwordController.clear();
                                            return;
                                          }
                                          
                                          try {
                                            await DatabaseService.bulkVerifyVets(_selectedVetIds.toList());
                                            if (mounted) {
                                              passwordController.dispose();
                                              Navigator.pop(context);
                                              setState(() {
                                                _selectedVetIds.clear();
                                              });
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('${_selectedVetIds.length} veterinarians verified successfully'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              passwordController.dispose();
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Error verifying vets: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        icon: const Icon(Icons.verified_user),
                                        label: const Text('Verify'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(Icons.verified_user),
                              label: Text('Verify (${_selectedVetIds.length})'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          ElevatedButton.icon(
                            onPressed: () => _addVet(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Vet'),
                          ),
                        ],
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
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Search
                                  SizedBox(
                                    width: 250,
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
                                  SizedBox(
                                    width: 150,
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
                                        DropdownMenuItem(value: 'dormant', child: Text('Dormant')),
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
                                  SizedBox(
                                    width: 180,
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
                                  SizedBox(
                                    width: 160,
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
                                  SizedBox(
                                    width: 150,
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
                                return SizedBox(
                                  height: 600, // Fixed height for proper scrolling
                                  child: Scrollbar(
                                    controller: _verticalScrollController,
                                    thumbVisibility: true,
                                    trackVisibility: true,
                                    child: SingleChildScrollView(
                                      controller: _verticalScrollController,
                                      scrollDirection: Axis.vertical,
                                      child: Scrollbar(
                                        controller: _horizontalScrollController,
                                        thumbVisibility: true,
                                        trackVisibility: true,
                                        child: SingleChildScrollView(
                                          controller: _horizontalScrollController,
                                          scrollDirection: Axis.horizontal,
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(minWidth: 1400),
                                            child: DataTable(
                                              columnSpacing: 24,
                                              columns: [
                                                DataColumn(
                                                  label: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                    child: Checkbox(
                                                      value: _selectedVetIds.length == filtered.length && filtered.isNotEmpty,
                                                      tristate: _selectedVetIds.isNotEmpty && _selectedVetIds.length < filtered.length,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          if (value == true) {
                                                            _selectedVetIds = Set.from(filtered.map((doc) => doc.id));
                                                          } else {
                                                            _selectedVetIds.clear();
                                                          }
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                const DataColumn(label: Text('View')),
                                                const DataColumn(label: Text('Veterinarian')),
                                                const DataColumn(label: Text('Contact')),
                                                const DataColumn(label: Text('Specialization')),
                                                const DataColumn(label: Text('Experience')),
                                                const DataColumn(label: Text('Clinic')),
                                                const DataColumn(label: Text('Account Status')),
                                                const DataColumn(label: Text('Online Status')),
                                                const DataColumn(label: Text('Verified')),
                                                const DataColumn(label: Text('User Type')),
                                                const DataColumn(label: Text('Rating')),
                                                const DataColumn(label: Text('Patients')),
                                                const DataColumn(label: Text('Actions')),
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
                                        final userType = (data['userType'] ?? 'regular').toString();
                                        final rating = (data['rating'] ?? '').toString();
                                        final patients = (data['patients'] ?? '').toString();

                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                child: Checkbox(
                                                  value: _selectedVetIds.contains(doc.id),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      if (value == true) {
                                                        _selectedVetIds.add(doc.id);
                                                      } else {
                                                        _selectedVetIds.remove(doc.id);
                                                      }
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              ElevatedButton(
                                                onPressed: () => _viewVetDetails(context, doc.id, data),
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  minimumSize: const Size(60, 32),
                                                ),
                                                child: const Text('View', style: TextStyle(fontSize: 12)),
                                              ),
                                            ),
                                            DataCell(
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 16,
                                                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                                    child: Text(
                                                      name.isNotEmpty ? name[0] : '?',
                                                      style: const TextStyle(
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
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(email),
                                                  Text(
                                                    phone,
                                                    style: const TextStyle(
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
                                                      : status == 'inactive'
                                                          ? AppTheme.errorColor.withOpacity(0.1)
                                                          : Colors.orange.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  status == 'active' ? 'Active' : status == 'inactive' ? 'Inactive' : 'Dormant',
                                                  style: TextStyle(
                                                    color: status == 'active'
                                                        ? AppTheme.successColor
                                                        : status == 'inactive'
                                                            ? AppTheme.errorColor
                                                            : Colors.orange,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: (data['isOnline'] ?? false) == true
                                                      ? Colors.green.withOpacity(0.1)
                                                      : Colors.grey.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 8,
                                                      height: 8,
                                                      decoration: BoxDecoration(
                                                        color: (data['isOnline'] ?? false) == true
                                                            ? Colors.green
                                                            : Colors.grey,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      (data['isOnline'] ?? false) == true ? 'Online' : 'Offline',
                                                      style: TextStyle(
                                                        color: (data['isOnline'] ?? false) == true
                                                            ? Colors.green
                                                            : Colors.grey,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
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
                                                    onPressed: () => _editVet(context, doc.id, data),
                                                    icon: const Icon(Icons.edit, size: 16),
                                                    tooltip: 'Edit',
                                                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                  IconButton(
                                                    onPressed: () => _sendPasswordResetEmail(context, email, name),
                                                    icon: const Icon(Icons.lock_reset, size: 16),
                                                    tooltip: 'Send Password Reset Email',
                                                    color: Colors.orange,
                                                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                  IconButton(
                                                    onPressed: () => _deleteVet(context, doc.id, name),
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
                                        ),
                                      ),
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