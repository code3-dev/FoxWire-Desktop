import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ModernCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final bool elevated;

  const ModernCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.backgroundColor,
    this.elevated = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: elevated ? [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1);
  }
}

class StatusIndicator extends StatelessWidget {
  final bool isConnected;
  final bool isConnecting;
  final String status;

  const StatusIndicator({
    super.key,
    required this.isConnected,
    required this.isConnecting,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color indicatorColor;
    IconData iconData;
    
    if (isConnected) {
      indicatorColor = Colors.green;
      iconData = Icons.check_circle;
    } else if (isConnecting) {
      indicatorColor = Colors.orange;
      iconData = Icons.sync;
    } else {
      indicatorColor = Colors.grey;
      iconData = Icons.radio_button_unchecked;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          iconData,
          color: indicatorColor,
          size: 20,
        ).animate(
          onPlay: (controller) => isConnecting ? controller.repeat() : null,
        ).rotate(duration: 1.seconds),
        const SizedBox(width: 8),
        Text(
          status,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: indicatorColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;
  final IconData? icon;

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary 
            ? theme.primaryColor 
            : theme.cardColor,
          foregroundColor: isPrimary 
            ? Colors.white 
            : theme.primaryColor,
          elevation: isPrimary ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isPrimary ? BorderSide.none : BorderSide(
              color: theme.primaryColor.withOpacity(0.3),
            ),
          ),
        ),
        child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
      ),
    ).animate().scale(delay: 100.ms, duration: 200.ms);
  }
}
