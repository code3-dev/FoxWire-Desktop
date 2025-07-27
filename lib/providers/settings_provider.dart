import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isPasswordEnabled = false;
  String? _hashedPassword;
  bool _isAuthenticated = false;
  String _username = 'Guest';

  ThemeMode get themeMode => _themeMode;
  bool get isPasswordEnabled => _isPasswordEnabled;
  bool get isAuthenticated => _isAuthenticated;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  String get username => _username;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load theme mode
      final themeModeIndex = prefs.getInt('theme_mode') ?? 0;
      _themeMode = ThemeMode.values[themeModeIndex];
      
      // Load password settings
      _isPasswordEnabled = prefs.getBool('is_password_enabled') ?? false;
      _hashedPassword = prefs.getString('hashed_password');
      
      // Load username
      _username = prefs.getString('username') ?? 'Guest';
      
      // If password is enabled, user needs to authenticate
      if (_isPasswordEnabled && _hashedPassword != null) {
        _isAuthenticated = false;
      } else {
        _isAuthenticated = true;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      _themeMode = mode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('theme_mode', mode.index);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  Future<bool> setPassword(String password) async {
    try {
      if (password.isEmpty) {
        // Disable password
        _isPasswordEnabled = false;
        _hashedPassword = null;
        _isAuthenticated = true;
      } else {
        // Enable password with basic hashing
        _isPasswordEnabled = true;
        _hashedPassword = _hashPassword(password);
        _isAuthenticated = true;
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_password_enabled', _isPasswordEnabled);
      if (_hashedPassword != null) {
        await prefs.setString('hashed_password', _hashedPassword!);
      } else {
        await prefs.remove('hashed_password');
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error setting password: $e');
      return false;
    }
  }

  bool authenticatePassword(String password) {
    if (!_isPasswordEnabled || _hashedPassword == null) {
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    
    final hashedInput = _hashPassword(password);
    _isAuthenticated = hashedInput == _hashedPassword;
    
    // Always notify listeners when authentication state changes
    notifyListeners();
    return _isAuthenticated;
  }

  void logout() {
    if (_isPasswordEnabled) {
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  Future<bool> setUsername(String username) async {
    try {
      _username = username.trim().isEmpty ? 'Guest' : username.trim();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', _username);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error setting username: $e');
      return false;
    }
  }

  String _hashPassword(String password) {
    // Simple hash - in production, use a proper hashing library
    return password.split('').map((c) => c.codeUnitAt(0)).join('-');
  }

  // Get current theme data
  ThemeData getLightTheme() {
    const primaryColor = Color(0xFF6B46C1); // Purple
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      textTheme: _getTextTheme(Brightness.light),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  ThemeData getDarkTheme() {
    const primaryColor = Color(0xFF6B46C1); // Purple
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
      ),
      textTheme: _getTextTheme(Brightness.dark),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: const Color(0xFF2D2D2D),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      iconTheme: const IconThemeData(
        color: primaryColor, // Use purple for all icons in dark mode
      ),
      dividerColor: Colors.white24,
      hoverColor: Colors.white.withOpacity(0.08),
    );
  }

  TextTheme _getTextTheme(Brightness brightness) {
    final baseTheme = brightness == Brightness.light 
        ? ThemeData.light().textTheme 
        : ThemeData.dark().textTheme;
    
    return baseTheme.copyWith(
      bodyLarge: baseTheme.bodyLarge?.copyWith(
        color: brightness == Brightness.dark ? Colors.white : Colors.black87,
      ),
      bodyMedium: baseTheme.bodyMedium?.copyWith(
        color: brightness == Brightness.dark ? Colors.white70 : Colors.black87,
      ),
      bodySmall: baseTheme.bodySmall?.copyWith(
        color: brightness == Brightness.dark ? Colors.white60 : Colors.black54,
      ),
      titleLarge: baseTheme.titleLarge?.copyWith(
        color: brightness == Brightness.dark ? Colors.white : Colors.black87,
      ),
      titleMedium: baseTheme.titleMedium?.copyWith(
        color: brightness == Brightness.dark ? Colors.white : Colors.black87,
      ),
      titleSmall: baseTheme.titleSmall?.copyWith(
        color: brightness == Brightness.dark ? Colors.white70 : Colors.black87,
      ),
    );
  }
}
