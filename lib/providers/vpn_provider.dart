import 'package:flutter/foundation.dart';
import 'package:wireguard_flutter/wireguard_flutter.dart';
import '../models/vpn_config.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class VpnProvider extends ChangeNotifier {
  final _wireguard = WireGuardFlutter.instance;
  
  String _vpnStage = 'disconnected';
  List<VpnConfig> _savedConfigs = [];
  VpnConfig? _currentConfig;
  String _statusMessage = 'Disconnected';
  bool _isInitialized = false;

  String get vpnStage => _vpnStage;
  List<VpnConfig> get savedConfigs => _savedConfigs;
  VpnConfig? get currentConfig => _currentConfig;
  String get statusMessage => _statusMessage;
  bool get isInitialized => _isInitialized;
  bool get isConnected => _vpnStage == 'connected';
  bool get isConnecting => _vpnStage == 'connecting';

  VpnProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    await _loadSavedConfigs();
    
    // Listen to VPN stage changes
    _wireguard.vpnStageSnapshot.listen((stage) {
      _vpnStage = stage.name;
      _updateStatusMessage();
      notifyListeners();
    });
  }

  void _updateStatusMessage() {
    switch (_vpnStage) {
      case 'connected':
        _statusMessage = 'Connected to ${_currentConfig?.name ?? 'VPN'}';
        break;
      case 'connecting':
        _statusMessage = 'Connecting...';
        break;
      case 'disconnecting':
        _statusMessage = 'Disconnecting...';
        break;
      case 'disconnected':
        _statusMessage = 'Disconnected';
        break;
      case 'preparing':
        _statusMessage = 'Preparing connection...';
        break;
      case 'authenticating':
        _statusMessage = 'Authenticating...';
        break;
      case 'reconnect':
        _statusMessage = 'Reconnecting...';
        break;
      case 'denied':
        _statusMessage = 'Connection denied';
        break;
      case 'waitingConnection':
        _statusMessage = 'Waiting for connection...';
        break;
      case 'noConnection':
        _statusMessage = 'No connection available';
        break;
      default:
        _statusMessage = 'Unknown status';
    }
  }

  Future<bool> initializeWireGuard() async {
    try {
      // Use a unique interface name to avoid conflicts
      await _wireguard.initialize(interfaceName: 'foxwire0');
      _isInitialized = true;
      debugPrint('WireGuard initialized successfully with interface: foxwire0');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('WireGuard initialization error: $e');
      return false;
    }
  }

  Future<void> addConfig(VpnConfig config) async {
    _savedConfigs.add(config);
    await _savePersistentConfigs();
    notifyListeners();
  }

  Future<void> removeConfig(VpnConfig config) async {
    _savedConfigs.removeWhere((c) => c.name == config.name);
    if (_currentConfig?.name == config.name) {
      _currentConfig = null;
    }
    await _savePersistentConfigs();
    notifyListeners();
  }

  Future<bool> connectToVpn(VpnConfig config) async {
    try {
      debugPrint('=== CONNECTING TO: ${config.name} ===');
      debugPrint('Target endpoint: ${config.endpoint}');
      
      // Step 1: Force complete disconnection and cleanup
      await _completeDisconnectAndCleanup();
      
      // Step 2: Reinitialize WireGuard with a unique interface name
      await _reinitializeWireGuard(config.name);
      
      // Step 3: Wait a moment for system cleanup
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Step 4: Extract server address from endpoint
      String serverAddress = config.endpoint;
      
      debugPrint('Connecting to ${config.name} at $serverAddress');
      debugPrint('Using interface: foxwire_${config.name.toLowerCase().replaceAll(' ', '_')}');
      
      // Step 5: Start the new VPN connection
      await _wireguard.startVpn(
        serverAddress: serverAddress,
        wgQuickConfig: config.configData,
        providerBundleIdentifier: 'com.foxwire.vpn.${config.name.toLowerCase()}',
      );
      
      _currentConfig = config;
      debugPrint('Successfully initiated connection to ${config.name}');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('VPN connection error: $e');
      _currentConfig = null;
      notifyListeners();
      return false;
    }
  }

  Future<void> _forceDisconnect() async {
    try {
      await _wireguard.stopVpn();
      // Wait for proper disconnection
      int attempts = 0;
      while (_vpnStage != 'disconnected' && attempts < 20) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
      debugPrint('Force disconnect completed after ${attempts * 100}ms');
    } catch (e) {
      debugPrint('Force disconnect error: $e');
    }
  }

  Future<bool> disconnectVpn() async {
    try {
      await _wireguard.stopVpn();
      _currentConfig = null;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('VPN disconnection error: $e');
      return false;
    }
  }

  Future<void> _loadSavedConfigs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configsJson = prefs.getStringList('saved_configs') ?? [];
      
      _savedConfigs = configsJson
          .map((json) => VpnConfig.fromJson(jsonDecode(json)))
          .toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading saved configs: $e');
    }
  }

  Future<void> _savePersistentConfigs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configsJson = _savedConfigs
          .map((config) => jsonEncode(config.toJson()))
          .toList();
      
      await prefs.setStringList('saved_configs', configsJson);
    } catch (e) {
      debugPrint('Error saving configs: $e');
    }
  }

  String getConnectionTime() {
    // This would need additional implementation to track connection start time
    // For now, return a placeholder
    return isConnected ? 'Connected' : 'Not connected';
  }

  // Method to clear any stuck state and reinitialize
  Future<bool> resetConnection() async {
    try {
      debugPrint('Resetting VPN connection...');
      await _wireguard.stopVpn();
      _currentConfig = null;
      _vpnStage = 'disconnected';
      _statusMessage = 'Disconnected';
      
      // Wait a moment before reinitializing
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Reinitialize
      final success = await initializeWireGuard();
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('Reset connection error: $e');
      return false;
    }
  }

  // Complete disconnection and cleanup
  Future<void> _completeDisconnectAndCleanup() async {
    try {
      debugPrint('Starting complete disconnect and cleanup...');
      
      // Step 1: Stop current VPN if any
      if (_vpnStage != 'disconnected') {
        await _wireguard.stopVpn();
        
        // Wait for complete disconnection
        int attempts = 0;
        while (_vpnStage != 'disconnected' && attempts < 30) {
          await Future.delayed(const Duration(milliseconds: 200));
          attempts++;
        }
        debugPrint('Disconnection took ${attempts * 200}ms');
      }
      
      // Step 2: Clear current config
      _currentConfig = null;
      _isInitialized = false;
      
      // Step 3: Additional cleanup delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      debugPrint('Complete disconnect and cleanup finished');
    } catch (e) {
      debugPrint('Complete disconnect error: $e');
    }
  }
  
  // Reinitialize WireGuard with unique interface
  Future<void> _reinitializeWireGuard(String configName) async {
    try {
      // Create unique interface name based on config
      String interfaceName = 'foxwire_${configName.toLowerCase().replaceAll(' ', '_').replaceAll(RegExp(r'[^a-z0-9_]'), '')}';
      if (interfaceName.length > 15) {
        interfaceName = interfaceName.substring(0, 15);
      }
      
      debugPrint('Reinitializing WireGuard with interface: $interfaceName');
      
      await _wireguard.initialize(interfaceName: interfaceName);
      _isInitialized = true;
      
      debugPrint('WireGuard reinitialized successfully');
    } catch (e) {
      debugPrint('WireGuard reinitialization error: $e');
      // Fallback to default interface
      try {
        await _wireguard.initialize(interfaceName: 'foxwire0');
        _isInitialized = true;
        debugPrint('Fallback initialization successful');
      } catch (e2) {
        debugPrint('Fallback initialization failed: $e2');
        throw e2;
      }
    }
  }

  // Get detailed connection info for debugging
  Map<String, dynamic> getConnectionInfo() {
    return {
      'vpnStage': _vpnStage,
      'isInitialized': _isInitialized,
      'currentConfig': _currentConfig?.name ?? 'None',
      'statusMessage': _statusMessage,
      'endpoint': _currentConfig?.endpoint ?? 'None',
      'savedConfigsCount': _savedConfigs.length,
    };
  }
}
