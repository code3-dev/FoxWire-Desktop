import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/vpn_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(theme),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildProfileSection(theme),
                      const SizedBox(height: 24),
                      _buildThemeSection(theme),
                      const SizedBox(height: 24),
                      _buildPasswordSection(theme),
                      const SizedBox(height: 24),
                      _buildConfigManagementSection(theme),
                      const SizedBox(height: 24),
                      _buildAboutSection(theme),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor,
            theme.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.settings_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: GoogleFonts.lato(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Customize your FoxWire experience',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2);
  }

  Widget _buildProfileSection(ThemeData theme) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return _buildSettingsCard(
          theme: theme,
          title: 'Profile',
          icon: Icons.person_rounded,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF6B46C1).withOpacity(0.1),
              child: const Icon(
                Icons.person_rounded,
                color: Color(0xFF6B46C1),
              ),
            ),
            title: Text(
              'Username',
              style: GoogleFonts.lato(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              settingsProvider.username,
              style: GoogleFonts.lato(
                fontSize: 14,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            trailing: ElevatedButton.icon(
              onPressed: () => _showEditUsernameDialog(settingsProvider),
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: const Text('Edit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                foregroundColor: theme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeSection(ThemeData theme) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return _buildSettingsCard(
          theme: theme,
          title: 'Appearance',
          icon: Icons.palette_rounded,
          child: Column(
            children: [
              _buildThemeOption(
                theme: theme,
                title: 'Light Mode',
                subtitle: 'Use light theme',
                value: ThemeMode.light,
                groupValue: settingsProvider.themeMode,
                onChanged: (value) => settingsProvider.setThemeMode(value!),
              ),
              _buildThemeOption(
                theme: theme,
                title: 'Dark Mode',
                subtitle: 'Use dark theme',
                value: ThemeMode.dark,
                groupValue: settingsProvider.themeMode,
                onChanged: (value) => settingsProvider.setThemeMode(value!),
              ),
              _buildThemeOption(
                theme: theme,
                title: 'System Default',
                subtitle: 'Follow system theme',
                value: ThemeMode.system,
                groupValue: settingsProvider.themeMode,
                onChanged: (value) => settingsProvider.setThemeMode(value!),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required ThemeMode value,
    required ThemeMode groupValue,
    required ValueChanged<ThemeMode?> onChanged,
  }) {
    return RadioListTile<ThemeMode>(
      title: Text(
        title,
        style: GoogleFonts.lato(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.lato(
          fontSize: 12,
          color: theme.textTheme.bodySmall?.color,
        ),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: theme.primaryColor,
    );
  }

  Widget _buildPasswordSection(ThemeData theme) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return _buildSettingsCard(
          theme: theme,
          title: 'Security',
          icon: Icons.security_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: Text(
                  'App Password Protection',
                  style: GoogleFonts.lato(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  settingsProvider.isPasswordEnabled
                      ? 'Password protection is enabled'
                      : 'Protect app with password',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                value: settingsProvider.isPasswordEnabled,
                onChanged: (value) {
                  if (value) {
                    _showSetPasswordDialog();
                  } else {
                    _showDisablePasswordDialog();
                  }
                },
                activeColor: theme.primaryColor,
              ),
              if (settingsProvider.isPasswordEnabled) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showChangePasswordDialog,
                        icon: const Icon(Icons.key_rounded),
                        label: const Text('Change Password'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor.withOpacity(0.1),
                          foregroundColor: theme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        settingsProvider.logout();
                      },
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.1),
                        foregroundColor: Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildConfigManagementSection(ThemeData theme) {
    return Consumer<VpnProvider>(
      builder: (context, vpnProvider, child) {
        return _buildSettingsCard(
          theme: theme,
          title: 'Configuration Management',
          icon: Icons.folder_delete_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  child: Icon(
                    Icons.delete_sweep_rounded,
                    color: Colors.red.shade600,
                  ),
                ),
                title: Text(
                  'Delete All Configurations',
                  style: GoogleFonts.lato(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${vpnProvider.savedConfigs.length} configurations saved',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                trailing: ElevatedButton(
                  onPressed: vpnProvider.savedConfigs.isEmpty
                      ? null
                      : () => _showDeleteAllConfigsDialog(vpnProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    foregroundColor: Colors.red.shade600,
                  ),
                  child: const Text('Delete All'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAboutSection(ThemeData theme) {
    return _buildSettingsCard(
      theme: theme,
      title: 'About',
      icon: Icons.info_rounded,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF6B46C1).withOpacity(0.1),
              child: const Icon(
                Icons.shield_rounded,
                color: Color(0xFF6B46C1),
              ),
            ),
            title: Text(
              'FoxWire',
              style: GoogleFonts.lato(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Version 1.0.0\nWireGuard VPN Client',
              style: GoogleFonts.lato(
                fontSize: 12,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF6B46C1), // Always use purple for consistency
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: child,
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  void _showEditUsernameDialog(SettingsProvider settingsProvider) {
    final usernameController = TextEditingController(text: settingsProvider.username);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.person_rounded,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 12),
            Text(
              'Edit Username',
              style: GoogleFonts.lato(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose how you want to be addressed in the app:',
              style: GoogleFonts.lato(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: 'Enter your name (or leave as Guest)',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: GoogleFonts.lato(),
              maxLength: 20,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: GoogleFonts.lato()),
          ),
          ElevatedButton(
            onPressed: () {
              final username = usernameController.text.trim();
              settingsProvider.setUsername(username.isEmpty ? 'Guest' : username);
              Navigator.of(context).pop();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Username updated to "${username.isEmpty ? 'Guest' : username}"',
                    style: GoogleFonts.lato(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            child: Text('Save', style: GoogleFonts.lato()),
          ),
        ],
      ),
    );
  }

  void _showSetPasswordDialog() {
    _passwordController.clear();
    _confirmPasswordController.clear();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Set App Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _setPassword(),
            child: const Text('Set Password'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    _passwordController.clear();
    _confirmPasswordController.clear();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _setPassword(),
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  void _showDisablePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Disable Password Protection'),
        content: const Text('Are you sure you want to disable password protection?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<SettingsProvider>().setPassword('');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.1),
              foregroundColor: Colors.red,
            ),
            child: const Text('Disable'),
          ),
        ],
      ),
    );
  }

  void _setPassword() {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 4 characters'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    context.read<SettingsProvider>().setPassword(_passwordController.text);
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password set successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showDeleteAllConfigsDialog(VpnProvider vpnProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: Colors.red.shade600,
            ),
            const SizedBox(width: 12),
            const Text('Delete All Configurations'),
          ],
        ),
        content: Text(
          'This will permanently delete all ${vpnProvider.savedConfigs.length} saved VPN configurations. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAllConfigs(vpnProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _deleteAllConfigs(VpnProvider vpnProvider) async {
    final configs = List.from(vpnProvider.savedConfigs);
    for (final config in configs) {
      await vpnProvider.removeConfig(config);
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted ${configs.length} configurations'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
