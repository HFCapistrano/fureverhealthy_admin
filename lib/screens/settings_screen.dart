import 'package:flutter/material.dart';
import 'package:furever_healthy_admin/theme/app_theme.dart';
import 'package:furever_healthy_admin/widgets/sidebar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Admin Settings
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = false;
  String _language = 'English';
  
  // Security Settings
  bool _twoFactorAuth = false;
  bool _sessionTimeout = true;
  int _sessionTimeoutMinutes = 30;
  bool _requireStrongPasswords = true;
  int _maxLoginAttempts = 5;
  
  // System Settings
  bool _autoBackup = true;
  int _backupFrequency = 7; // days
  bool _maintenanceMode = false;
  bool _systemMonitoring = true;
  bool _autoUpdates = true;
  
  // Notification Settings
  bool _userRegistrationNotifications = true;
  bool _vetRegistrationNotifications = true;
  bool _appointmentNotifications = true;
  bool _systemAlerts = true;
  bool _securityAlerts = true;
  bool _performanceAlerts = true;
  
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
                        // General Settings
                        _buildSettingsSection(
                          'General Settings',
                          Icons.admin_panel_settings,
                          [
                            _buildSwitchSetting(
                              'Enable Notifications',
                              'Receive system notifications',
                              _notificationsEnabled,
                              (value) => setState(() => _notificationsEnabled = value),
                            ),
                            _buildDropdownSetting(
                              'Language',
                              'Select your preferred language',
                              _language,
                              ['English', 'Spanish', 'French', 'German', 'Italian'],
                              (value) => setState(() => _language = value!),
                            ),
                            _buildSwitchSetting(
                              'System Monitoring',
                              'Monitor system performance and health',
                              _systemMonitoring,
                              (value) => setState(() => _systemMonitoring = value),
                            ),
                            _buildSwitchSetting(
                              'Auto Updates',
                              'Automatically update system components',
                              _autoUpdates,
                              (value) => setState(() => _autoUpdates = value),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Notification Settings
                        _buildSettingsSection(
                          'Notification Settings',
                          Icons.notifications,
                          [
                            _buildSwitchSetting(
                              'Email Notifications',
                              'Receive notifications via email',
                              _emailNotifications,
                              (value) => setState(() => _emailNotifications = value),
                            ),
                            _buildSwitchSetting(
                              'Push Notifications',
                              'Receive push notifications',
                              _pushNotifications,
                              (value) => setState(() => _pushNotifications = value),
                            ),
                            _buildSwitchSetting(
                              'User Registration',
                              'Notify when new users register',
                              _userRegistrationNotifications,
                              (value) => setState(() => _userRegistrationNotifications = value),
                            ),
                            _buildSwitchSetting(
                              'Vet Registration',
                              'Notify when new vets register',
                              _vetRegistrationNotifications,
                              (value) => setState(() => _vetRegistrationNotifications = value),
                            ),
                            _buildSwitchSetting(
                              'Appointments',
                              'Notify about appointment updates',
                              _appointmentNotifications,
                              (value) => setState(() => _appointmentNotifications = value),
                            ),
                            _buildSwitchSetting(
                              'System Alerts',
                              'Receive system alerts and updates',
                              _systemAlerts,
                              (value) => setState(() => _systemAlerts = value),
                            ),
                            _buildSwitchSetting(
                              'Security Alerts',
                              'Notify about security events and breaches',
                              _securityAlerts,
                              (value) => setState(() => _securityAlerts = value),
                            ),
                            _buildSwitchSetting(
                              'Performance Alerts',
                              'Notify about system performance issues',
                              _performanceAlerts,
                              (value) => setState(() => _performanceAlerts = value),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Security Settings
                        _buildSettingsSection(
                          'Security Settings',
                          Icons.security,
                          [
                            _buildSwitchSetting(
                              'Two-Factor Authentication',
                              'Add an extra layer of security',
                              _twoFactorAuth,
                              (value) => setState(() => _twoFactorAuth = value),
                            ),
                            _buildSwitchSetting(
                              'Session Timeout',
                              'Automatically log out after inactivity',
                              _sessionTimeout,
                              (value) => setState(() => _sessionTimeout = value),
                            ),
                            if (_sessionTimeout)
                              _buildSliderSetting(
                                'Session Timeout (${_sessionTimeoutMinutes} minutes)',
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
                              'Max Login Attempts (${_maxLoginAttempts})',
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
                                'Data Retention (${_dataRetentionDays} days)',
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
                            _buildSwitchSetting(
                              'System Monitoring',
                              'Monitor system performance and health',
                              _systemMonitoring,
                              (value) => setState(() => _systemMonitoring = value),
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
                              () => _showConfirmDialog(
                                'Clear System Cache',
                                'This will remove all cached system data. Are you sure?',
                                () => _clearCache(),
                              ),
                            ),
                            _buildDangerButton(
                              'Reset Admin Settings',
                              'Reset all admin settings to default',
                              Icons.restore,
                              () => _showConfirmDialog(
                                'Reset Admin Settings',
                                'This will reset all admin settings to default values. Are you sure?',
                                () => _resetSettings(),
                              ),
                            ),
                            _buildDangerButton(
                              'System Maintenance',
                              'Put system into maintenance mode',
                              Icons.build,
                              () => _showConfirmDialog(
                                'System Maintenance',
                                'This will put the system into maintenance mode. Users will not be able to access the system.',
                                () => _enableMaintenanceMode(),
                              ),
                            ),
                            _buildDangerButton(
                              'Force Logout All Users',
                              'Logout all active user sessions',
                              Icons.logout,
                              () => _showConfirmDialog(
                                'Force Logout All Users',
                                'This will logout all active user sessions. Are you sure?',
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

  void _showConfirmDialog(String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm'),
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
      _notificationsEnabled = true;
      _emailNotifications = true;
      _pushNotifications = false;
      _language = 'English';
      _twoFactorAuth = false;
      _sessionTimeout = true;
      _sessionTimeoutMinutes = 30;
      _requireStrongPasswords = true;
      _maxLoginAttempts = 5;
      _autoBackup = true;
      _backupFrequency = 7;
      _maintenanceMode = false;
      _systemMonitoring = true;
      _autoUpdates = true;
      _userRegistrationNotifications = true;
      _vetRegistrationNotifications = true;
      _appointmentNotifications = true;
      _systemAlerts = true;
      _securityAlerts = true;
      _performanceAlerts = true;
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
}