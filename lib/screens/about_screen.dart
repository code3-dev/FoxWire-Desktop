import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/modern_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 32),
            _buildAppInfo(theme),
            const SizedBox(height: 24),
            _buildFeatures(theme),
            const SizedBox(height: 24),
            _buildTechnologies(theme),
            const SizedBox(height: 24),
            _buildCredits(theme),
            const SizedBox(height: 24),
            _buildDisclaimer(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.primaryColor,
                theme.primaryColor.withOpacity(0.8),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.shield_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About FoxWire',
                style: GoogleFonts.lato(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              Text(
                'Modern WireGuard VPN Client',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2);
  }

  Widget _buildAppInfo(ThemeData theme) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: theme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Application Information',
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Version', '1.0.0', Icons.tag_rounded),
          _buildInfoRow('Build', '1', Icons.build_rounded),
          _buildInfoRow('Platform', 'Desktop (Windows, macOS, Linux)', Icons.computer_rounded),
          _buildInfoRow('Framework', 'Flutter 3.7.2+', Icons.flutter_dash_rounded),
          _buildInfoRow('License', 'MIT License', Icons.gavel_rounded),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.lato(
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures(ThemeData theme) {
    final features = [
      FeatureItem(
        icon: Icons.security_rounded,
        title: 'Secure & Private',
        description: 'Built on WireGuard\'s proven cryptographic foundation',
      ),
      FeatureItem(
        icon: Icons.speed_rounded,
        title: 'High Performance',
        description: 'Optimized for speed and minimal resource usage',
      ),
      FeatureItem(
        icon: Icons.palette_rounded,
        title: 'Modern UI',
        description: 'Beautiful, intuitive interface with Material Design 3',
      ),
      FeatureItem(
        icon: Icons.import_export_rounded,
        title: 'Easy Import',
        description: 'Simple configuration file import and management',
      ),
      FeatureItem(
        icon: Icons.devices_rounded,
        title: 'Cross-Platform',
        description: 'Works seamlessly across Windows, macOS, and Linux',
      ),
      FeatureItem(
        icon: Icons.storage_rounded,
        title: 'Local Storage',
        description: 'Configurations stored securely on your device',
      ),
    ];

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                color: theme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Key Features',
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        feature.icon,
                        color: theme.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            feature.title,
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            feature.description,
                            style: GoogleFonts.lato(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate(delay: (index * 100).ms).fadeIn().scale(begin: const Offset(0.8, 0.8));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTechnologies(ThemeData theme) {
    final technologies = [
      'Flutter & Dart',
      'WireGuard Protocol',
      'Material Design 3',
      'Provider State Management',
      'Google Fonts',
      'Flutter Animate',
    ];

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.code_rounded,
                color: theme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Technologies Used',
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: technologies.map((tech) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  tech,
                  style: GoogleFonts.lato(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCredits(ThemeData theme) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite_rounded,
                color: Colors.red.shade400,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Credits & Acknowledgments',
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'FoxWire is built with love and appreciation for the open-source community. Special thanks to:',
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          _buildCreditItem('WireGuard Team', 'For creating the amazing VPN protocol'),
          _buildCreditItem('Flutter Team', 'For the incredible cross-platform framework'),
          _buildCreditItem('Open Source Contributors', 'For all the amazing packages and libraries'),
          _buildCreditItem('Design Community', 'For inspiration and design guidance'),
        ],
      ),
    );
  }

  Widget _buildCreditItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.lato(color: Colors.grey[800]),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer(ThemeData theme) {
    return ModernCard(
      backgroundColor: Colors.orange.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: Colors.orange.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Important Disclaimer',
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'This software is provided "as is" without warranty of any kind, express or implied. '
            'Use at your own risk. Always ensure you have proper authorization to use VPN services '
            'in your jurisdiction. The developers are not responsible for any misuse of this software.',
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.orange.shade800,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureItem {
  final IconData icon;
  final String title;
  final String description;

  FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
