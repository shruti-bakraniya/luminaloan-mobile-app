import 'package:flutter/material.dart';

class AnimatedNumber extends StatefulWidget {
  final double value;
  final String Function(double) render;
  final TextStyle? style;
  final Duration duration;

  const AnimatedNumber({
    super.key,
    required this.value,
    required this.render,
    this.style,
    this.duration = const Duration(milliseconds: 480),
  });

  @override
  State<AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<AnimatedNumber>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late double _from;
  late double _to;

  @override
  void initState() {
    super.initState();
    _from = widget.value;
    _to = widget.value;
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didUpdateWidget(AnimatedNumber old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _from = old.value;
      _to = widget.value;
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;
        final ease = 1 - (1 - t) * (1 - t) * (1 - t);
        final current = _from + (_to - _from) * ease;
        return Text(widget.render(current), style: widget.style);
      },
    );
  }
}
