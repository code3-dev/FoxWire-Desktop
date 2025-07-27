import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/vpn_config.dart';
import '../providers/vpn_provider.dart';
import 'modern_card.dart';
import 'package:provider/provider.dart';

class ConfigList extends StatelessWidget {
  const ConfigList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VpnProvider>(
      builder: (context, vpnProvider, child) {
        if (vpnProvider.savedConfigs.isEmpty) {
          return const EmptyConfigState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: vpnProvider.savedConfigs.length,
          itemBuilder: (context, index) {
            final config = vpnProvider.savedConfigs[index];
            final isCurrentConfig = vpnProvider.currentConfig?.name == config.name;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ConfigCard(
                config: config,
                isCurrentConfig: isCurrentConfig,
                isConnected: vpnProvider.isConnected && isCurrentConfig,
                isConnecting: vpnProvider.isConnecting,
                onConnect: () async {
                  // Show loading state immediately
                  await vpnProvider.connectToVpn(config);
                },
                onDisconnect: () => vpnProvider.disconnectVpn(),
                onDelete: () => _showDeleteDialog(context, config, vpnProvider),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, VpnConfig config, VpnProvider vpnProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Configuration', style: GoogleFonts.lato()),
        content: Text(
          'Are you sure you want to delete "${config.name}"?',
          style: GoogleFonts.lato(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: GoogleFonts.lato()),
          ),
          TextButton(
            onPressed: () {
              vpnProvider.removeConfig(config);
              Navigator.of(context).pop();
            },
            child: Text('Delete', style: GoogleFonts.lato(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class ConfigCard extends StatelessWidget {
  final VpnConfig config;
  final bool isCurrentConfig;
  final bool isConnected;
  final bool isConnecting;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final VoidCallback onDelete;

  const ConfigCard({
    super.key,
    required this.config,
    required this.isCurrentConfig,
    required this.isConnected,
    required this.isConnecting,
    required this.onConnect,
    required this.onDisconnect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ModernCard(
      backgroundColor: isCurrentConfig ? theme.primaryColor.withOpacity(0.1) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.name,
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      config.endpoint,
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              StatusIndicator(
                isConnected: isConnected,
                isConnecting: isConnecting,
                status: isConnected 
                  ? 'Connected' 
                  : isConnecting 
                    ? 'Connecting...' 
                    : 'Disconnected',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ModernButton(
                  text: isConnected ? 'Disconnect' : 'Connect',
                  onPressed: isConnected ? onDisconnect : onConnect,
                  isPrimary: !isConnected,
                  isLoading: isConnecting,
                  icon: isConnected ? Icons.stop : Icons.play_arrow,
                ),
              ),
              const SizedBox(width: 8),
              Consumer<VpnProvider>(
                builder: (context, vpnProvider, child) {
                  return ModernButton(
                    text: 'Reset',
                    onPressed: () => vpnProvider.resetConnection(),
                    isPrimary: false,
                    icon: Icons.refresh,
                  );
                },
              ),
              const SizedBox(width: 8),
              ModernButton(
                text: 'Delete',
                onPressed: onDelete,
                isPrimary: false,
                icon: Icons.delete_outline,
              ),
            ],
          ),
          if (isCurrentConfig && isConnected) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _buildConnectionDetails(),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectionDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connection Details',
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _buildDetailRow('Server', config.endpoint),
        _buildDetailRow('Address', config.address),
        _buildDetailRow('DNS', config.dns),
        _buildDetailRow('Allowed IPs', config.allowedIPs),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.lato(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.lato(
                fontSize: 12,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyConfigState extends StatelessWidget {
  const EmptyConfigState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.vpn_key_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No VPN Configurations',
            style: GoogleFonts.lato(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Import a WireGuard configuration file to get started',
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
