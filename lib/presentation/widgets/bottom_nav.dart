import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final LuminaTokens t;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: t.glassStrong,
              borderRadius: BorderRadius.circular(20),
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
            child: Row(
              children: [
                _NavItem(label: 'Calculate', icon: Icons.calculate_rounded,
                    selected: currentIndex == 0, t: t, onTap: () => onTap(0)),
                _NavItem(label: 'History', icon: Icons.history_rounded,
                    selected: currentIndex == 1, t: t, onTap: () => onTap(1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final LuminaTokens t;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.t,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
            decoration: BoxDecoration(
              gradient: selected ? t.accentGradient : null,
              borderRadius: BorderRadius.circular(15),
              boxShadow: selected
                  ? [const BoxShadow(color: Color(0x6B3E5C8A), blurRadius: 16, offset: Offset(0, 6))]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 19, color: selected ? t.onAccent : t.subtext),
                const SizedBox(width: 7),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? t.onAccent : t.subtext,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
