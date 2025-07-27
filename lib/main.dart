import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/vpn_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/main_layout.dart';
import 'screens/auth_screen.dart';

void main() {
  runApp(const FoxWireApp());
}

class FoxWireApp extends StatelessWidget {
  const FoxWireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => VpnProvider()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          debugPrint('Main app rebuilding - isAuthenticated: ${settingsProvider.isAuthenticated}, isPasswordEnabled: ${settingsProvider.isPasswordEnabled}');
          
          return MaterialApp(
            title: 'FoxWire - Modern WireGuard VPN',
            debugShowCheckedModeBanner: false,
            theme: settingsProvider.getLightTheme(),
            darkTheme: settingsProvider.getDarkTheme(),
            themeMode: settingsProvider.themeMode,
            home: settingsProvider.isAuthenticated 
                ? const MainLayout() 
                : const AuthScreen(),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    const primaryColor = Color(0xFF6B46C1); // Purple
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.latoTextTheme(),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.lato(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

