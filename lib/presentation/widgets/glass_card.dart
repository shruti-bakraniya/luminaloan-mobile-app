import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final LuminaTokens t;
  final EdgeInsets padding;
  final bool strong;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    required this.t,
    this.padding = const EdgeInsets.all(16),
    this.strong = false,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(22);
    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: strong ? t.glassStrong : t.glass,
              borderRadius: br,
              border: Border.all(color: t.glassBorder),
              boxShadow: [
                BoxShadow(
                  color: t.isDark
                      ? Colors.black.withOpacity(0.42)
                      : const Color(0x291B2B48),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
