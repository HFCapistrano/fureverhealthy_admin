import 'package:flutter/material.dart';
import 'package:furever_healthy_admin/theme/app_theme.dart';
import 'package:furever_healthy_admin/widgets/sidebar.dart';
import 'package:furever_healthy_admin/services/database_service.dart';
import 'package:furever_healthy_admin/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
  
  // Notification Management
  int? _notificationThrottlePerDay = 50;
  int? _notificationThrottlePerHour = 10;
  
  // Performance/Privacy
  bool? _featureA = true;
  bool? _featureB = true;
  bool? _featureC = false;
  int? _attachmentSizeLimitMB = 10;

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
                            // Change Password
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Change Admin Password',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
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
                            _buildSwitchSetting(
                              'System Monitoring',
                              'Monitor system performance and health',
                              _systemMonitoring,
                              (value) => setState(() => _systemMonitoring = value),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Notification Management
                        _buildSettingsSection(
                          'Notification Management',
                          Icons.notifications_active,
                          [
                            ElevatedButton.icon(
                              onPressed: () => _showNotificationComposer(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Compose Announcement'),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => _showBreedTipsComposer(context),
                              icon: const Icon(Icons.tips_and_updates),
                              label: const Text('Compose Breed-Specific Tips'),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => _showMaintenanceNoticeComposer(context),
                              icon: const Icon(Icons.build),
                              label: const Text('Create Maintenance Notice'),
                            ),
                            const SizedBox(height: 24),
                            _buildSliderSetting(
                              'Max Notifications per Day',
                              'Limit notifications sent per day',
                              (_notificationThrottlePerDay ?? 50).toDouble(),
                              10.0,
                              200.0,
                              (value) => setState(() => _notificationThrottlePerDay = value.round()),
                            ),
                            _buildSliderSetting(
                              'Max Notifications per Hour',
                              'Limit notifications sent per hour',
                              (_notificationThrottlePerHour ?? 10).toDouble(),
                              1.0,
                              50.0,
                              (value) => setState(() => _notificationThrottlePerHour = value.round()),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Performance/Privacy Settings
                        _buildSettingsSection(
                          'Performance/Privacy Settings',
                          Icons.settings_applications,
                          [
                            _buildSwitchSetting(
                              'Enable Feature A',
                              'Toggle specific feature',
                              _featureA ?? false,
                              (value) => setState(() => _featureA = value),
                            ),
                            _buildSwitchSetting(
                              'Enable Feature B',
                              'Toggle specific feature',
                              _featureB ?? false,
                              (value) => setState(() => _featureB = value),
                            ),
                            _buildSwitchSetting(
                              'Enable Feature C',
                              'Toggle specific feature',
                              _featureC ?? false,
                              (value) => setState(() => _featureC = value),
                            ),
                            const SizedBox(height: 16),
                            _buildSliderSetting(
                              'Data Retention ($_dataRetentionDays days)',
                              'How long to keep data before cleanup',
                              _dataRetentionDays.toDouble(),
                              30.0,
                              1095.0,
                              (value) => setState(() => _dataRetentionDays = value.round()),
                            ),
                            _buildSliderSetting(
                              'Attachment Size Limit (${_attachmentSizeLimitMB ?? 10} MB)',
                              'Maximum size for file attachments',
                              (_attachmentSizeLimitMB ?? 10).toDouble(),
                              1.0,
                              100.0,
                              (value) => setState(() => _attachmentSizeLimitMB = value.round()),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => _viewChangeLog(context),
                              icon: const Icon(Icons.history),
                              label: const Text('View Change Log'),
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
              final isPasswordValid = await DatabaseService.verifyAdminPassword(passwordController.text);
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
      _notificationsEnabled = true;
      _emailNotifications = true;
      _pushNotifications = false;
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

  void _showNotificationComposer(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String targetAudience = 'all';
    DateTime? scheduledDate;
    bool sendNow = true;

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
                const Row(
                  children: [
                    Icon(Icons.notifications, color: AppTheme.primaryColor),
                    SizedBox(width: 8),
                    Text(
                      'Compose Announcement',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: targetAudience,
                  decoration: const InputDecoration(
                    labelText: 'Target Audience',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Users')),
                    DropdownMenuItem(value: 'premium', child: Text('Premium Users')),
                  ],
                  onChanged: (value) => targetAudience = value!,
                ),
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setDialogState) => CheckboxListTile(
                    title: const Text('Send Now'),
                    value: sendNow,
                    onChanged: (value) => setDialogState(() => sendNow = value ?? true),
                  ),
                ),
                StatefulBuilder(
                  builder: (context, setDialogState) {
                    return sendNow
                        ? const SizedBox.shrink()
                        : Column(
                            children: [
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (date != null) {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    if (time != null) {
                                      setDialogState(() {
                                        scheduledDate = DateTime(
                                          date.year,
                                          date.month,
                                          date.day,
                                          time.hour,
                                          time.minute,
                                        );
                                      });
                                    }
                                  }
                                },
                                icon: const Icon(Icons.calendar_today),
                                label: Text(
                                  scheduledDate != null
                                      ? DateFormat('MMM d, yyyy h:mm a').format(scheduledDate!)
                                      : 'Schedule Date & Time',
                                ),
                              ),
                            ],
                          );
                  },
                ),
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
                        if (titleController.text.isEmpty || contentController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill in all required fields'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        try {
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          await DatabaseService.createNotification({
                            'title': titleController.text,
                            'content': contentController.text,
                            'type': 'announcement',
                            'targetAudience': targetAudience,
                            'status': sendNow ? 'sent' : 'scheduled',
                            'scheduledDate': scheduledDate != null
                                ? Timestamp.fromDate(scheduledDate!)
                                : null,
                            'createdBy': authProvider.userEmail ?? 'admin',
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Announcement created successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error creating announcement: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Send'),
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

  void _showBreedTipsComposer(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedBreed = '';

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
                const Row(
                  children: [
                    Icon(Icons.tips_and_updates, color: AppTheme.primaryColor),
                    SizedBox(width: 8),
                    Text(
                      'Compose Breed-Specific Tips',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content/Tips *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Breed Key (optional)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => selectedBreed = value,
                ),
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
                        if (titleController.text.isEmpty || contentController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill in all required fields'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        try {
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          await DatabaseService.createNotification({
                            'title': titleController.text,
                            'content': contentController.text,
                            'type': 'breed_tips',
                            'breedKey': selectedBreed,
                            'status': 'sent',
                            'createdBy': authProvider.userEmail ?? 'admin',
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Breed tips created successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error creating breed tips: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Send'),
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

  void _showMaintenanceNoticeComposer(BuildContext context) {
    final titleController = TextEditingController(text: 'System Maintenance');
    final contentController = TextEditingController();
    DateTime? maintenanceStart;
    DateTime? maintenanceEnd;

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
                const Row(
                  children: [
                    Icon(Icons.build, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'Create Maintenance Notice',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Maintenance Details *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() {
                                maintenanceStart = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          }
                        },
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          maintenanceStart != null
                              ? 'Start: ${DateFormat('MMM d, h:mm a').format(maintenanceStart!)}'
                              : 'Start Time',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() {
                                maintenanceEnd = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          }
                        },
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          maintenanceEnd != null
                              ? 'End: ${DateFormat('MMM d, h:mm a').format(maintenanceEnd!)}'
                              : 'End Time',
                        ),
                      ),
                    ),
                  ],
                ),
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
                        if (contentController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill in maintenance details'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        try {
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          await DatabaseService.createNotification({
                            'title': titleController.text,
                            'content': contentController.text,
                            'type': 'maintenance',
                            'maintenanceStart': maintenanceStart != null
                                ? Timestamp.fromDate(maintenanceStart!)
                                : null,
                            'maintenanceEnd': maintenanceEnd != null
                                ? Timestamp.fromDate(maintenanceEnd!)
                                : null,
                            'status': 'sent',
                            'createdBy': authProvider.userEmail ?? 'admin',
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Maintenance notice created successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error creating maintenance notice: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Send'),
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

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool _obscureCurrentPassword = true;
    bool _obscureNewPassword = true;
    bool _obscureConfirmPassword = true;

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
                    obscureText: _obscureCurrentPassword,
                    decoration: InputDecoration(
                      labelText: 'Current Password *',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCurrentPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            _obscureCurrentPassword = !_obscureCurrentPassword;
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
                    obscureText: _obscureNewPassword,
                    decoration: InputDecoration(
                      labelText: 'New Password *',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            _obscureNewPassword = !_obscureNewPassword;
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
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password *',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
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
                            final success = await DatabaseService.changeAdminPassword(
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

  void _viewChangeLog(BuildContext context) async {
    try {
      final history = await DatabaseService.getConfigHistory(limit: 50);
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            constraints: const BoxConstraints(maxWidth: 900),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  children: [
                    Icon(Icons.history, color: AppTheme.primaryColor),
                    SizedBox(width: 8),
                    Text(
                      'Change Log',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: history.isEmpty
                      ? const Center(child: Text('No changes recorded'))
                      : ListView.builder(
                          itemCount: history.length,
                          itemBuilder: (context, index) {
                            final change = history[index];
                            final changedAt = change['changedAt'] is Timestamp
                                ? (change['changedAt'] as Timestamp).toDate()
                                : DateTime.now();

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(Icons.edit, color: AppTheme.primaryColor),
                                title: Text(
                                  '${change['setting'] ?? 'Unknown'}',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Changed by: ${change['adminEmail'] ?? 'Unknown'}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'From: ${change['oldValue'] ?? 'N/A'} → To: ${change['newValue'] ?? 'N/A'}',
                                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  DateFormat('MMM d, yyyy\nh:mm a').format(changedAt),
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading change log: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}