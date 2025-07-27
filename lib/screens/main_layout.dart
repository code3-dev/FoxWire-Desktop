import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import '../widgets/modern_sidebar.dart';
import '../providers/vpn_provider.dart';
import 'dashboard_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int selectedIndex = 0;

  final List<Widget> screens = [
    const DashboardContent(),
    const SettingsScreen(),
    const AboutScreen(),
  ];

@override
  void initState() {
    super.initState();
    _setupWindowCloseHandler();
  }

  void _setupWindowCloseHandler() {
    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      return await _showExitConfirmationDialog();
    });
  }

  Future<bool> _showExitConfirmationDialog() async {
    final vpnProvider = Provider.of<VpnProvider>(context, listen: false);
    
    if (vpnProvider.isConnected) {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade600,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'VPN Connected',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      Icons.vpn_lock_rounded,
                      color: Colors.orange.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Connected to "${vpnProvider.currentConfig?.name ?? 'Unknown'}"',
                        style: TextStyle(
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
              const Text(
                'The VPN connection will be automatically disconnected when you exit. Are you sure you want to continue?',
                style: TextStyle(height: 1.4),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
                // Disconnect VPN before closing
                await vpnProvider.disconnectVpn();
                // Give it a moment to disconnect
                await Future.delayed(const Duration(milliseconds: 500));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Disconnect & Exit'),
            ),
          ],
        ),
      );
      return result ?? false;
    } else {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.exit_to_app_rounded,
                color: Colors.red,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Exit FoxWire',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to exit FoxWire?',
            style: TextStyle(height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
              ),
              child: const Text('Exit'),
            ),
          ],
        ),
      );
      return result ?? false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          ModernSidebar(
            selectedIndex: selectedIndex,
            onItemSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: selectedIndex < screens.length 
              ? screens[selectedIndex]
              : const DashboardContent(),
          ),
        ],
      ),
    );
  }
}

// Dashboard content without the full Scaffold
class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  @override
  void initState() {
    super.initState();
    // Initialize WireGuard when the content loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // We'll need to access the provider from here
    });
  }

  @override
  Widget build(BuildContext context) {
    // Return the content from dashboard_screen without the Scaffold wrapper
    return const DashboardScreenContent();
  }
}
