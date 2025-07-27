import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import '../providers/vpn_provider.dart';
import '../providers/settings_provider.dart';
import 'dart:io' show Platform, exit;

class ModernSidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const ModernSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<ModernSidebar> createState() => _ModernSidebarState();
}

class _ModernSidebarState extends State<ModernSidebar> {
  int? hoveredIndex;

  final List<SidebarItem> items = [
    SidebarItem(
      icon: Icons.home_rounded,
      label: 'Home',
      index: 0,
    ),
    SidebarItem(
      icon: Icons.settings_rounded,
      label: 'Settings',
      index: 1,
    ),
    SidebarItem(
      icon: Icons.info_rounded,
      label: 'About',
      index: 2,
    ),
    SidebarItem(
      icon: Icons.exit_to_app_rounded,
      label: 'Exit App',
      index: 3,
      isExit: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: theme.dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(theme),
          Expanded(
            child: _buildNavigation(theme),
          ),
          _buildFooter(theme),
        ],
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
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return InkWell(
            onTap: () => _showEditUsernameDialog(settingsProvider),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
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
                          'Welcome back,',
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                settingsProvider.username,
                                style: GoogleFonts.lato(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.edit_rounded,
                              color: Colors.white.withOpacity(0.7),
                              size: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2);
  }

  Widget _buildNavigation(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = widget.selectedIndex == item.index;
        final isHovered = hoveredIndex == item.index;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: MouseRegion(
            onEnter: (_) => setState(() => hoveredIndex = item.index),
            onExit: (_) => setState(() => hoveredIndex = null),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected
                  ? theme.primaryColor.withOpacity(0.1)
                  : isHovered
                    ? theme.hoverColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                  ? Border.all(
                      color: theme.primaryColor.withOpacity(0.3),
                      width: 1,
                    )
                  : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (item.isExit) {
                      _showExitDialog();
                    } else {
                      widget.onItemSelected(item.index);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          color: isSelected
                            ? const Color(0xFF6B46C1) // Always use purple for selected
                            : item.isExit
                              ? Colors.red.shade400
                              : (theme.brightness == Brightness.dark 
                                  ? const Color(0xFF6B46C1) // Purple for dark mode icons
                                  : theme.iconTheme.color), // Default for light mode
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            item.label,
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected
                                ? const Color(0xFF6B46C1) // Always use purple for selected
                                : item.isExit
                                  ? Colors.red.shade400
                                  : (theme.brightness == Brightness.dark 
                                      ? Colors.white // White text for dark mode
                                      : theme.textTheme.bodyLarge?.color), // Default for light
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6B46C1), // Always purple for selected indicator
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ).animate(delay: (index * 100).ms).fadeIn().slideX(begin: -0.1);
      },
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Divider(color: theme.dividerColor.withOpacity(0.3)),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.security_rounded,
                  color: theme.primaryColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Secure Connection',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    Text(
                      'Protected by WireGuard',
                      style: GoogleFonts.lato(
                        fontSize: 10,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms);
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

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => Consumer<VpnProvider>(
        builder: (context, vpnProvider, child) {
          final bool isConnected = vpnProvider.isConnected;
          
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.exit_to_app_rounded,
                  color: Colors.red.shade400,
                ),
                const SizedBox(width: 12),
                Text(
                  'Exit FoxWire',
                  style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isConnected) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_rounded,
                          color: Colors.orange.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'VPN is currently connected to "${vpnProvider.currentConfig?.name ?? 'Unknown'}"',
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  isConnected 
                    ? 'The VPN connection will be automatically disconnected when you exit the application. Are you sure you want to continue?'
                    : 'Are you sure you want to exit FoxWire?',
                  style: GoogleFonts.lato(
                    height: 1.4,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.lato(),
                ),
              ),
              if (isConnected) ...[
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    // First disconnect VPN
                    await vpnProvider.disconnectVpn();
                    // Wait a moment for disconnection
                    await Future.delayed(const Duration(milliseconds: 500));
                    // Then close the window
                    FlutterWindowClose.closeWindow();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Disconnect & Exit',
                    style: GoogleFonts.lato(fontWeight: FontWeight.w600),
                  ),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    FlutterWindowClose.closeWindow();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Exit',
                    style: GoogleFonts.lato(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

}

class SidebarItem {
  final IconData icon;
  final String label;
  final int index;
  final bool isExit;

  SidebarItem({
    required this.icon,
    required this.label,
    required this.index,
    this.isExit = false,
  });
}
