import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:furever_healthy_admin/theme/app_theme.dart';
import 'package:furever_healthy_admin/widgets/sidebar.dart';
import 'package:furever_healthy_admin/services/database_service.dart';
import 'package:furever_healthy_admin/providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Security Settings
  bool _sessionTimeout = true;
  int _sessionTimeoutMinutes = 30;
  bool _requireStrongPasswords = true;
  int _maxLoginAttempts = 5;
  
  // System Settings
  bool _autoBackup = true;
  int _backupFrequency = 7; // days
  bool _maintenanceMode = false;
  
  // Data Management
  bool _dataRetentionEnabled = true;
  int _dataRetentionDays = 365;
  bool _anonymizeOldData = false;

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
                    border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin Settings',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'System configuration and administrative controls',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _saveSettings,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Changes'),
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
                        
                        // Security Settings
                        _buildSettingsSection(
                          'Security Settings',
                          Icons.security,
                          [
                            // Change Password
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Change Admin Password',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Update your admin account password',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => _showChangePasswordDialog(context),
                                    icon: const Icon(Icons.lock_outline),
                                    label: const Text('Change Password'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                            _buildSwitchSetting(
                              'Session Timeout',
                              'Automatically log out after inactivity',
                              _sessionTimeout,
                              (value) => setState(() => _sessionTimeout = value),
                            ),
                            if (_sessionTimeout)
                              _buildSliderSetting(
                                'Session Timeout ($_sessionTimeoutMinutes minutes)',
                                'Minutes of inactivity before auto-logout',
                                _sessionTimeoutMinutes.toDouble(),
                                5.0,
                                120.0,
                                (value) => setState(() => _sessionTimeoutMinutes = value.round()),
                              ),
                            _buildSwitchSetting(
                              'Require Strong Passwords',
                              'Enforce strong password requirements for all users',
                              _requireStrongPasswords,
                              (value) => setState(() => _requireStrongPasswords = value),
                            ),
                            _buildSliderSetting(
                              'Max Login Attempts ($_maxLoginAttempts)',
                              'Maximum failed login attempts before account lockout',
                              _maxLoginAttempts.toDouble(),
                              3.0,
                              10.0,
                              (value) => setState(() => _maxLoginAttempts = value.round()),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Data Management
                        _buildSettingsSection(
                          'Data Management',
                          Icons.storage,
                          [
                            _buildSwitchSetting(
                              'Data Retention',
                              'Automatically manage old data',
                              _dataRetentionEnabled,
                              (value) => setState(() => _dataRetentionEnabled = value),
                            ),
                            if (_dataRetentionEnabled)
                              _buildSliderSetting(
                                'Data Retention ($_dataRetentionDays days)',
                                'How long to keep user data before cleanup',
                                _dataRetentionDays.toDouble(),
                                30.0,
                                1095.0,
                                (value) => setState(() => _dataRetentionDays = value.round()),
                              ),
                            _buildSwitchSetting(
                              'Anonymize Old Data',
                              'Anonymize personal data before deletion',
                              _anonymizeOldData,
                              (value) => setState(() => _anonymizeOldData = value),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // System Settings
                        _buildSettingsSection(
                          'System Settings',
                          Icons.computer,
                          [
                            _buildSwitchSetting(
                              'Auto Backup',
                              'Automatically backup system data',
                              _autoBackup,
                              (value) => setState(() => _autoBackup = value),
                            ),
                            if (_autoBackup)
                              _buildDropdownSetting(
                                'Backup Frequency',
                                'How often to backup data',
                                '$_backupFrequency days',
                                ['1 day', '3 days', '7 days', '14 days', '30 days'],
                                (value) {
                                  setState(() {
                                    _backupFrequency = int.parse(value!.split(' ')[0]);
                                  });
                                },
                              ),
                            _buildSwitchSetting(
                              'Maintenance Mode',
                              'Enable maintenance mode for system updates',
                              _maintenanceMode,
                              (value) => setState(() => _maintenanceMode = value),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Danger Zone
                        _buildSettingsSection(
                          'Danger Zone',
                          Icons.warning,
                          [
                            _buildDangerButton(
                              'Clear System Cache',
                              'Remove all cached system data',
                              Icons.delete_sweep,
                              () => _showPasswordConfirmDialog(
                                'Clear System Cache',
                                'This will remove all cached system data. This action cannot be undone.',
                                () => _clearCache(),
                              ),
                            ),
                            _buildDangerButton(
                              'Reset Admin Settings',
                              'Reset all admin settings to default',
                              Icons.restore,
                              () => _showPasswordConfirmDialog(
                                'Reset Admin Settings',
                                'This will reset all admin settings to default values. This action cannot be undone.',
                                () => _resetSettings(),
                              ),
                            ),
                            _buildDangerButton(
                              'System Maintenance',
                              'Put system into maintenance mode',
                              Icons.build,
                              () => _showPasswordConfirmDialog(
                                'System Maintenance',
                                'This will put the system into maintenance mode. Users will not be able to access the system.',
                                () => _enableMaintenanceMode(),
                              ),
                            ),
                            _buildDangerButton(
                              'Force Logout All Users',
                              'Logout all active user sessions',
                              Icons.logout,
                              () => _showPasswordConfirmDialog(
                                'Force Logout All Users',
                                'This will logout all active user sessions immediately. Users will need to log in again.',
                                () => _forceLogoutAllUsers(),
                              ),
                            ),
                          ],
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

  Widget _buildSettingsSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchSetting(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSetting(String title, String subtitle, String value, List<String> options, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSetting(String title, String subtitle, double value, double min, double max, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) / 5).round(),
            activeColor: AppTheme.primaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDangerButton(String title, String subtitle, IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.red, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.red, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _showPasswordConfirmDialog(String title, String message, VoidCallback onConfirm) {
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Enter your admin password to confirm',
                hintText: 'Type your admin password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              autofocus: true,
            ),
            const SizedBox(height: 8),
            const Text(
              'This is a dangerous action. Please confirm your identity.',
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
                  const SnackBar(
                    content: Text('Please enter your admin password'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              // Verify admin password
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final adminEmail = authProvider.userEmail ?? '';
              final isPasswordValid = await DatabaseService.verifyAdminPassword(adminEmail, passwordController.text);
              if (!isPasswordValid) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Invalid admin password'),
                    backgroundColor: Colors.red,
                  ),
                );
                passwordController.clear();
                return;
              }
              
              // Password verified, close dialog and execute action
              passwordController.dispose();
              if (mounted) {
                Navigator.pop(context);
                onConfirm();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.check_circle),
            label: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cache cleared successfully'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _resetSettings() {
    setState(() {
      _sessionTimeout = true;
      _sessionTimeoutMinutes = 30;
      _requireStrongPasswords = true;
      _maxLoginAttempts = 5;
      _autoBackup = true;
      _backupFrequency = 7;
      _maintenanceMode = false;
      _dataRetentionEnabled = true;
      _dataRetentionDays = 365;
      _anonymizeOldData = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Admin settings reset to default'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _enableMaintenanceMode() {
    setState(() {
      _maintenanceMode = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('System maintenance mode enabled'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _forceLogoutAllUsers() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All user sessions have been terminated'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lock, color: AppTheme.primaryColor),
                      SizedBox(width: 8),
                      Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: currentPasswordController,
                    obscureText: obscureCurrentPassword,
                    decoration: InputDecoration(
                      labelText: 'Current Password *',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureCurrentPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            obscureCurrentPassword = !obscureCurrentPassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPasswordController,
                    obscureText: obscureNewPassword,
                    decoration: InputDecoration(
                      labelText: 'New Password *',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            obscureNewPassword = !obscureNewPassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                      helperText: 'Must be at least 8 characters long',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password *',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            obscureConfirmPassword = !obscureConfirmPassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          currentPasswordController.dispose();
                          newPasswordController.dispose();
                          confirmPasswordController.dispose();
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final scaffoldMessenger = ScaffoldMessenger.of(context);

                          if (currentPasswordController.text.isEmpty ||
                              newPasswordController.text.isEmpty ||
                              confirmPasswordController.text.isEmpty) {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('Please fill in all fields'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (newPasswordController.text.length < 8) {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('New password must be at least 8 characters long'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (newPasswordController.text != confirmPasswordController.text) {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('New passwords do not match'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (newPasswordController.text == currentPasswordController.text) {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('New password must be different from current password'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          try {
                            final authProvider = Provider.of<AuthProvider>(context, listen: false);
                            final adminEmail = authProvider.userEmail ?? '';
                            if (adminEmail.isEmpty) {
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Unable to identify admin account'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            
                            final success = await DatabaseService.changeAdminPassword(
                              adminEmail,
                              currentPasswordController.text,
                              newPasswordController.text,
                            );

                            if (mounted) {
                              currentPasswordController.dispose();
                              newPasswordController.dispose();
                              confirmPasswordController.dispose();
                              Navigator.pop(context);

                              if (success) {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Password changed successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Invalid current password'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text('Error changing password: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Change Password'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}