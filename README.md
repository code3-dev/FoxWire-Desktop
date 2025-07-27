# FoxWire Desktop - Modern WireGuard VPN Client

FoxWire is a modern, intuitive WireGuard VPN client built with Flutter, designed for desktop platforms with a focus on user experience and ease of use.

## ✨ Features

- **Modern UI Design**: Clean, intuitive interface with Material Design 3
- **Easy Configuration Import**: Simply import `.conf` files from your file system
- **Multiple VPN Configurations**: Store and manage multiple WireGuard configurations
- **Real-time Status Updates**: Live connection status and detailed information
- **Auto VPN Mode**: Automatic connection management
- **Cross-platform**: Supports Windows, macOS, and Linux
- **Secure Storage**: Configurations are securely stored locally

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>= 3.7.2)
- Dart SDK

### Installation

1. Clone the repository or navigate to the project directory

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run -d windows  # For Windows
flutter run -d macos    # For macOS  
flutter run -d linux    # For Linux
```

## 📱 Usage

### Importing a Configuration

1. Click the **"Import Config"** floating action button
2. Select your WireGuard `.conf` file
3. Give your configuration a name
4. Click **"Import"

### Connecting to VPN

1. Select a configuration from the list
2. Click **"Connect"
3. Monitor the connection status in real-time

### Managing Configurations

- **View Details**: Connected configurations show detailed connection information
- **Delete**: Remove unwanted configurations with the delete button
- **Status Monitoring**: Real-time connection status updates

## 🔧 Configuration Format

FoxWire supports standard WireGuard configuration files:

```ini
[Interface]
PrivateKey = your-private-key
Address = 10.8.0.4/32
DNS = 1.1.1.1

[Peer]
PublicKey = peer-public-key
PresharedKey = preshared-key
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 0
Endpoint = server.example.com:51820
```

## 🛡️ Security

- Configurations are stored securely using Flutter's SharedPreferences
- No configuration data is transmitted to external servers
- All VPN connections use WireGuard's proven cryptography

## 🎨 UI/UX Features

- **Smooth Animations**: Powered by flutter_animate
- **Modern Typography**: Beautiful fonts via Google Fonts
- **Responsive Design**: Optimized for desktop usage
- **Status Indicators**: Clear visual feedback for connection states
- **Theme Support**: Consistent Material Design 3 theming

## ⚠️ Disclaimer

This software is provided "as is" without warranty of any kind. Use at your own risk. Always ensure you have proper authorization to use VPN services in your jurisdiction.

---

**Made with ❤️ by Hossein Pira**
