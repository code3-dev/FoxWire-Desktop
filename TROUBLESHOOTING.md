# FoxWire Troubleshooting Guide

## VPN Configuration Switching Issues

### Problem: Wrong Server Connected
**Issue**: When clicking "Connect" on Turkey server, the IP shows Germany (or wrong country).

### Root Cause
This happens when WireGuard doesn't properly disconnect from the previous server before connecting to a new one, resulting in overlapping tunnels or cached connections.

### Solution Implemented
The app now includes a comprehensive 5-step connection switching process:

1. **Complete Disconnection**: Force stops current VPN and waits for full disconnection
2. **Interface Cleanup**: Clears WireGuard interface and resets internal state
3. **Unique Reinitialization**: Creates new interface with config-specific name
4. **System Delay**: Waits for Windows to clear network cache
5. **Fresh Connection**: Establishes new tunnel with proper configuration

### Additional Features
- **Reset Button**: Manual connection reset for stuck states
- **Enhanced Debugging**: Detailed logs for connection tracking
- **Unique Bundle IDs**: Per-config identifiers to prevent conflicts

### Key Improvements

#### 1. Connection Switching Logic
```dart
// Always disconnect first to ensure clean state
if (_vpnStage != 'disconnected') {
  debugPrint('Disconnecting current connection before switching to ${config.name}');
  await _forceDisconnect();
}
```

#### 2. Force Disconnect Method
```dart
Future<void> _forceDisconnect() async {
  await _wireguard.stopVpn();
  // Wait for proper disconnection
  int attempts = 0;
  while (_vpnStage != 'disconnected' && attempts < 20) {
    await Future.delayed(const Duration(milliseconds: 100));
    attempts++;
  }
}
```

#### 3. Enhanced Debugging
- Logs server switching operations
- Shows configuration details
- Tracks connection state changes

### Testing the Fix

1. **Import Multiple Configs**: Add Germany, Turkey, and UAE configurations
2. **Connect to Germany**: Verify IP shows German location
3. **Switch to Turkey**: Click connect on Turkey config
4. **Verify Switch**: Check that IP now shows Turkish location
5. **Switch to UAE**: Test another switch to confirm proper disconnection

### Debug Information

To see debug output while testing:
- Run app in debug mode: `flutter run -d windows --debug`
- Watch console for connection logs like:
  ```
  Disconnecting current connection before switching to Turkey
  Force disconnect completed after 500ms
  Starting connection to Turkey at turkey-server.com:51820
  Successfully initiated connection to Turkey
  ```

### Additional Troubleshooting

#### If Switching Still Doesn't Work:

1. **Reset Connection**:
   ```dart
   // Use the reset method (can be added to UI if needed)
   await vpnProvider.resetConnection();
   ```

2. **Check Original WireGuard App**:
   - Ensure configs work properly in official WireGuard app
   - Verify no conflicting WireGuard instances are running

3. **Restart FoxWire**:
   - Close the app completely
   - Restart to clear any cached states

4. **System-level Check**:
   - Check Windows network adapters for stuck WireGuard interfaces
   - Disable/enable network adapter if needed

### Configuration Validation

Ensure your `.conf` files have:
- Correct `[Interface]` section with private key and address
- Correct `[Peer]` section with public key and endpoint
- Different endpoints for different countries
- Valid IP addresses and ports

### Example Working Configuration

```ini
[Interface]
PrivateKey = your-private-key-here
Address = 10.8.0.4/32
DNS = 1.1.1.1

[Peer]
PublicKey = peer-public-key-here
PresharedKey = preshared-key-here (optional)
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
Endpoint = turkey-server.example.com:51820
```

### Known Limitations

1. **Platform-specific**: Some WireGuard behaviors may vary between Windows/macOS/Linux
2. **Network Timing**: Very fast switching might need longer delays
3. **System VPN**: Other VPN software might interfere

### Reporting Issues

If problems persist, include:
1. Debug console output
2. Configuration files (without private keys)
3. Operating system version
4. Network adapter information
5. Steps to reproduce the issue

The improved connection switching should now properly disconnect from one server before connecting to another, ensuring the correct IP address is shown for each location.
