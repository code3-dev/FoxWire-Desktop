import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/vpn_provider.dart';
import '../models/vpn_config.dart';
import '../widgets/config_list.dart';
import '../widgets/modern_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize WireGuard when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VpnProvider>().initializeWireGuard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const DashboardScreenContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _importConfig(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Import Config', style: GoogleFonts.lato(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }


  Future<void> _importConfig(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['conf', 'txt'],
        dialogTitle: 'Select WireGuard Configuration File',
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final configContent = await file.readAsString();
        
        // Show dialog to name the configuration
        if (context.mounted) {
          _showNameConfigDialog(context, configContent, result.files.single.name);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing config: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showNameConfigDialog(BuildContext context, String configContent, String fileName) {
    final nameController = TextEditingController(
      text: fileName.replaceAll('.conf', '').replaceAll('.txt', ''),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Name Configuration', style: GoogleFonts.lato()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter a name for this VPN configuration:',
              style: GoogleFonts.lato(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Configuration Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: GoogleFonts.lato(),
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
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                final config = VpnConfig.fromConfigString(configContent, name);
                context.read<VpnProvider>().addConfig(config);
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Configuration "$name" imported successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text('Import', style: GoogleFonts.lato()),
          ),
        ],
      ),
    );
  }
}

// Separate content widget that can be used in the sidebar layout
class DashboardScreenContent extends StatefulWidget {
  const DashboardScreenContent({super.key});

  @override
  State<DashboardScreenContent> createState() => _DashboardScreenContentState();
}

class _DashboardScreenContentState extends State<DashboardScreenContent> {
  @override
  void initState() {
    super.initState();
    // Initialize WireGuard when the content loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VpnProvider>().initializeWireGuard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildStatusCard(context),
            Expanded(
              child: const ConfigList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _importConfig(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Import Config', style: GoogleFonts.lato(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
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
              Icons.shield,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FoxWire',
                  style: GoogleFonts.lato(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Modern WireGuard VPN Client',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Consumer<VpnProvider>(
            builder: (context, vpnProvider, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: vpnProvider.isConnected 
                    ? Colors.green.withOpacity(0.2)
                    : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      vpnProvider.isConnected ? Icons.shield : Icons.shield_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      vpnProvider.isConnected ? 'Protected' : 'Unprotected',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1);
  }

  Widget _buildStatusCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Consumer<VpnProvider>(
        builder: (context, vpnProvider, child) {
          return ModernCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VPN Status',
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          StatusIndicator(
                            isConnected: vpnProvider.isConnected,
                            isConnecting: vpnProvider.isConnecting,
                            status: vpnProvider.statusMessage,
                          ),
                        ],
                      ),
                    ),
                    if (vpnProvider.currentConfig != null)
                      ModernButton(
                        text: vpnProvider.isConnected ? 'Disconnect' : 'Connect',
                        onPressed: vpnProvider.isConnected 
                          ? () => vpnProvider.disconnectVpn()
                          : () => vpnProvider.connectToVpn(vpnProvider.currentConfig!),
                        isPrimary: !vpnProvider.isConnected,
                        isLoading: vpnProvider.isConnecting,
                      ),
                  ],
                ),
                if (vpnProvider.currentConfig != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildQuickStats(vpnProvider),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickStats(VpnProvider vpnProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            'Server',
            vpnProvider.currentConfig?.endpoint ?? 'N/A',
            Icons.dns,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            'Address',
            vpnProvider.currentConfig?.address ?? 'N/A',
            Icons.location_on,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            'Status',
            vpnProvider.getConnectionTime(),
            Icons.timer,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Future<void> _importConfig(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['conf', 'txt'],
        dialogTitle: 'Select WireGuard Configuration File',
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final configContent = await file.readAsString();
        
        // Show dialog to name the configuration
        if (context.mounted) {
          _showNameConfigDialog(context, configContent, result.files.single.name);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing config: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showNameConfigDialog(BuildContext context, String configContent, String fileName) {
    final nameController = TextEditingController(
      text: fileName.replaceAll('.conf', '').replaceAll('.txt', ''),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Name Configuration', style: GoogleFonts.lato()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter a name for this VPN configuration:',
              style: GoogleFonts.lato(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Configuration Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: GoogleFonts.lato(),
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
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                final config = VpnConfig.fromConfigString(configContent, name);
                context.read<VpnProvider>().addConfig(config);
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Configuration "$name" imported successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text('Import', style: GoogleFonts.lato()),
          ),
        ],
      ),
    );
  }
}
