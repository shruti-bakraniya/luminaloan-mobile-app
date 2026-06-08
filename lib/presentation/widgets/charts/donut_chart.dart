import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';

class DonutChart extends StatefulWidget {
  final double principal;
  final double interest;
  final LuminaTokens t;
  final String currency;

  const DonutChart({
    super.key,
    required this.principal,
    required this.interest,
    required this.t,
    required this.currency,
  });

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(DonutChart old) {
    super.didUpdateWidget(old);
    if (old.principal != widget.principal || old.interest != widget.interest) {
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
    final total = widget.principal + widget.interest;
    final intFrac = total > 0 ? widget.interest / total : 0.0;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomPaint(
            size: const Size(150, 150),
            painter: _DonutPainter(
              principal: widget.principal,
              interest: widget.interest,
              progress: _anim.value,
              t: widget.t,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LegendItem(
                  dot: widget.t.principal,
                  label: 'Principal',
                  value: formatCurrency(widget.principal, widget.currency),
                  sub: '${((1 - intFrac) * 100).toStringAsFixed(1)}% of total',
                  t: widget.t,
                ),
                const SizedBox(height: 14),
                _LegendItem(
                  dot: widget.t.interest,
                  label: 'Interest',
                  value: formatCurrency(widget.interest, widget.currency),
                  sub: '${(intFrac * 100).toStringAsFixed(1)}% of total',
                  t: widget.t,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color dot;
  final String label;
  final String value;
  final String sub;
  final LuminaTokens t;

  const _LegendItem({
    required this.dot,
    required this.label,
    required this.value,
    required this.sub,
    required this.t,
  });

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: dot, borderRadius: BorderRadius.circular(3)),
            ),
          ),
          const SizedBox(width: 9),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: t.subtext)),
              Text(value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: t.text,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  )),
              Text(sub, style: TextStyle(fontSize: 10.5, color: t.subtext.withOpacity(0.8))),
            ],
          ),
        ],
      );
}

class _DonutPainter extends CustomPainter {
  final double principal;
  final double interest;
  final double progress;
  final LuminaTokens t;

  const _DonutPainter({
    required this.principal,
    required this.interest,
    required this.progress,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = principal + interest;
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    const r = 64.0;
    const strokeW = 22.0;
    final intFrac = interest / total;

    // principal full circle
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = t.principal
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );

    // interest arc
    if (intFrac > 0) {
      final sweepAngle = 2 * math.pi * intFrac * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        -math.pi / 2,
        sweepAngle,
        false,
        Paint()
          ..color = t.interest
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.round,
      );
    }

    // center text
    final tp = TextPainter(textDirection: TextDirection.ltr);
    tp.text = TextSpan(
      text: 'Interest',
      style: TextStyle(fontSize: 11, color: t.subtext),
    );
    tp.layout();
    tp.paint(canvas, center - Offset(tp.width / 2, 18));

    final pct = (intFrac * 100 * progress).toStringAsFixed(1);
    tp.text = TextSpan(
      text: '$pct%',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: t.text,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
    tp.layout();
    tp.paint(canvas, center - Offset(tp.width / 2, -4));
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.progress != progress || old.t.isDark != t.isDark || old.interest != interest;
}
