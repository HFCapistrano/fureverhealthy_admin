import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:furever_healthy_admin/theme/app_theme.dart';
import 'package:furever_healthy_admin/widgets/sidebar.dart';
import 'package:furever_healthy_admin/services/database_service.dart';
import 'package:furever_healthy_admin/providers/auth_provider.dart';
import 'package:furever_healthy_admin/models/admin_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  String _selectedRole = 'admin';
  final Map<String, bool> _selectedPermissions = {
    'users.view': true,
    'users.edit': true,
    'users.delete': true,
    'vets.view': true,
    'vets.edit': true,
    'vets.delete': true,
    'feedbacks.view': true,
    'feedbacks.edit': true,
    'contents.view': true,
    'contents.edit': true,
    'contents.publish': true,
    'reports.view': true,
    'community.view': true,
    'community.moderate': true,
  };

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _showGrantAccessDialog() {
    // Reset form
    _emailController.clear();
    _nameController.clear();
    _usernameController.clear();
    _selectedRole = 'admin';
    _selectedPermissions.updateAll((key, value) => value = true);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          constraints: const BoxConstraints(maxWidth: 700),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_add, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Grant Admin Access',
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
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.alternate_email),
                    helperText: 'A unique username for this admin account',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role *',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'super-admin', child: Text('Super Admin')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                      // Super-admin has all permissions, disable permission selection
                      if (_selectedRole == 'super-admin') {
                        _selectedPermissions.updateAll((key, value) => value = true);
                      }
                    });
                  },
                ),
                if (_selectedRole == 'admin') ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Permissions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._buildPermissionCheckboxes(),
                ],
                const SizedBox(height: 24),
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
                        if (_emailController.text.isEmpty ||
                            _nameController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill in all required fields'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        try {
                          await DatabaseService.grantAdminAccess(
                            email: _emailController.text.trim(),
                            name: _nameController.text.trim(),
                            username: _usernameController.text.trim().isEmpty 
                                ? null 
                                : _usernameController.text.trim(),
                            role: _selectedRole,
                            permissions: _selectedRole == 'admin'
                                ? _selectedPermissions
                                : null,
                          );

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Admin access granted successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error granting access: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Grant Access'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPermissionCheckboxes() {
    final modules = {
      'Users': ['users.view', 'users.edit', 'users.delete'],
      'Vets': ['vets.view', 'vets.edit', 'vets.delete'],
      'Feedbacks': ['feedbacks.view', 'feedbacks.edit'],
      'Contents': ['contents.view', 'contents.edit', 'contents.publish'],
      'Reports': ['reports.view'],
      'Community': ['community.view', 'community.moderate'],
    };

    return modules.entries.map((module) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            module.key,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          ...module.value.map((permission) {
            return CheckboxListTile(
              title: Text(_getPermissionLabel(permission)),
              value: _selectedPermissions[permission] ?? false,
              onChanged: (value) {
                setState(() {
                  _selectedPermissions[permission] = value ?? false;
                });
              },
              dense: true,
              contentPadding: const EdgeInsets.only(left: 8),
            );
          }),
          const SizedBox(height: 8),
        ],
      );
    }).toList();
  }

  String _getPermissionLabel(String permission) {
    final labels = {
      'users.view': 'View Users',
      'users.edit': 'Edit Users',
      'users.delete': 'Delete Users',
      'vets.view': 'View Vets',
      'vets.edit': 'Edit Vets',
      'vets.delete': 'Delete Vets',
      'feedbacks.view': 'View Feedbacks',
      'feedbacks.edit': 'Edit Feedbacks',
      'contents.view': 'View Contents',
      'contents.edit': 'Edit Contents',
      'contents.publish': 'Publish Contents',
      'reports.view': 'View Reports',
      'community.view': 'View Community',
      'community.moderate': 'Moderate Community',
    };
    return labels[permission] ?? permission;
  }

  void _showEditPermissionsDialog(AdminUser adminUser) {
    _nameController.text = adminUser.name;
    _emailController.text = adminUser.email;
    _usernameController.text = adminUser.username ?? '';
    _selectedRole = adminUser.role;
    _selectedPermissions.clear();
    _selectedPermissions.addAll(adminUser.permissions);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          constraints: const BoxConstraints(maxWidth: 700),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Edit Admin Access',
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
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.alternate_email),
                    helperText: 'A unique username for this admin account',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'super-admin', child: Text('Super Admin')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                      if (_selectedRole == 'super-admin') {
                        _selectedPermissions.updateAll((key, value) => value = true);
                      }
                    });
                  },
                ),
                if (_selectedRole == 'admin') ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Permissions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._buildPermissionCheckboxes(),
                ],
                const SizedBox(height: 24),
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
                        try {
                          await DatabaseService.updateAdminRole(
                            adminUser.id,
                            _selectedRole,
                          );

                          if (_selectedRole == 'admin') {
                            await DatabaseService.updateAdminPermissions(
                              adminUser.id,
                              _selectedPermissions,
                            );
                          }

                          // Update name if changed
                          if (_nameController.text != adminUser.name) {
                            await DatabaseService.admins
                                .doc(adminUser.id)
                                .update({'name': _nameController.text.trim()});
                          }

                          // Update username if changed
                          final newUsername = _usernameController.text.trim().isEmpty 
                              ? null 
                              : _usernameController.text.trim();
                          if (newUsername != adminUser.username) {
                            await DatabaseService.updateAdminUsername(
                              adminUser.id,
                              newUsername,
                            );
                          }

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Admin access updated successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error updating access: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _revokeAccess(AdminUser adminUser) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Revoke Admin Access'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to revoke admin access for ${adminUser.name}?'),
            const SizedBox(height: 8),
            Text(
              'Email: ${adminUser.email}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
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
              try {
                await DatabaseService.revokeAdminAccess(adminUser.id);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Admin access revoked successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error revoking access: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Revoke Access'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Check if user is super-admin
    if (!authProvider.isSuperAdmin) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Row(
          children: [
            const Sidebar(),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Access Denied',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Only super-admins can access this page.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

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
                              'Admin Management',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage admin accounts, roles, and permissions',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showGrantAccessDialog,
                        icon: const Icon(Icons.person_add),
                        label: const Text('Grant Admin Access'),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Card(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: DatabaseService.getAdminsStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }

                          final docs = snapshot.data?.docs ?? [];
                          if (docs.isEmpty) {
                            return const Center(
                                child: Text('No admin accounts found'));
                          }

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 24,
                              columns: const [
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Username')),
                                DataColumn(label: Text('Email')),
                                DataColumn(label: Text('Role')),
                                DataColumn(label: Text('Permissions')),
                                DataColumn(label: Text('Last Login')),
                                DataColumn(label: Text('Created At')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: docs.map((doc) {
                                final data =
                                    doc.data() as Map<String, dynamic>;
                                final adminUser = AdminUser.fromMap(data, doc.id);

                                String lastLoginStr = 'Never';
                                if (adminUser.lastLogin != null) {
                                  lastLoginStr = adminUser.lastLogin!
                                      .toString()
                                      .substring(0, 16);
                                }

                                String createdAtStr = 'Unknown';
                                if (adminUser.createdAt != null) {
                                  createdAtStr = adminUser.createdAt!
                                      .toString()
                                      .substring(0, 16);
                                }

                                final permissionCount = adminUser.role ==
                                        'super-admin'
                                    ? 'All'
                                    : adminUser.permissions.values
                                            .where((v) => v == true)
                                            .length
                                        .toString();

                                return DataRow(
                                  cells: [
                                    DataCell(Text(adminUser.name)),
                                    DataCell(Text(adminUser.username ?? '—')),
                                    DataCell(Text(adminUser.email)),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: adminUser.role == 'super-admin'
                                              ? Colors.amber.withOpacity(0.1)
                                              : AppTheme.primaryColor
                                                  .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          adminUser.role == 'super-admin'
                                              ? 'Super Admin'
                                              : 'Admin',
                                          style: TextStyle(
                                            color: adminUser.role ==
                                                    'super-admin'
                                                ? Colors.amber.shade700
                                                : AppTheme.primaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(permissionCount)),
                                    DataCell(Text(lastLoginStr)),
                                    DataCell(Text(createdAtStr)),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () =>
                                                _showEditPermissionsDialog(
                                                    adminUser),
                                            icon: const Icon(Icons.edit,
                                                size: 16),
                                            tooltip: 'Edit',
                                          ),
                                          IconButton(
                                            onPressed: () =>
                                                _revokeAccess(adminUser),
                                            icon: const Icon(Icons.delete,
                                                size: 16),
                                            color: Colors.red,
                                            tooltip: 'Revoke Access',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
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

