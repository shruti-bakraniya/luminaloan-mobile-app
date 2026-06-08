import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SegmentedOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const SegmentedOption({required this.value, required this.label, this.icon});
}

class LuminaSegmented<T> extends StatelessWidget {
  final List<SegmentedOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final LuminaTokens t;

  const LuminaSegmented({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final selectedIdx = options.indexWhere((o) => o.value == selected);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: t.track,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 320),
            curve: Curves.elasticOut,
            left: selectedIdx == 0 ? 0 : null,
            right: selectedIdx == options.length - 1 ? 0 : null,
            top: 0,
            bottom: 0,
            width: MediaQuery.of(context).size.width * 0.5 - 24,
            child: Container(
              decoration: BoxDecoration(
                gradient: t.accentGradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3E5C8A).withOpacity(0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: options.map((opt) {
              final isSelected = opt.value == selected;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(opt.value),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
                    decoration: const BoxDecoration(color: Colors.transparent),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (opt.icon != null) ...[
                          Icon(
                            opt.icon,
                            size: 15,
                            color: isSelected ? t.onAccent : t.subtext,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          opt.label,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? t.onAccent : t.subtext,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
