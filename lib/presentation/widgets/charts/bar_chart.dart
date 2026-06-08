import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/amortization_row.dart';

class _Bucket {
  final int idx;
  final double principal;
  final double interest;
  final int m0;
  final int m1;

  double get total => principal + interest;
  const _Bucket({required this.idx, required this.principal, required this.interest, required this.m0, required this.m1});
}

class BarChart extends StatefulWidget {
  final List<AmortizationRow> schedule;
  final LuminaTokens t;
  final String currency;

  const BarChart({super.key, required this.schedule, required this.t, required this.currency});

  @override
  State<BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<BarChart> {
  int? _hoveredBucket;

  List<_Bucket> _buildBuckets() {
    final buckets = widget.schedule.length.clamp(1, 12);
    final size = widget.schedule.length / buckets;
    final out = <_Bucket>[];
    for (int b = 0; b < buckets; b++) {
      final start = (b * size).floor();
      final end = ((b + 1) * size).floor();
      final slice = widget.schedule.sublist(start, end.clamp(0, widget.schedule.length));
      if (slice.isEmpty) continue;
      out.add(_Bucket(
        idx: b,
        principal: slice.fold(0, (s, r) => s + r.principal),
        interest: slice.fold(0, (s, r) => s + r.interest),
        m0: slice.first.month,
        m1: slice.last.month,
      ));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final bars = _buildBuckets();
    if (bars.isEmpty) return const SizedBox(height: 188);

    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      const h = 188.0;
      const padL = 8.0, padR = 8.0;

      final maxTotal = bars.fold(0.0, (m, b) => b.total > m ? b.total : m);
      if (maxTotal == 0) return SizedBox(height: h);

      final bw = (w - padL - padR) / bars.length;

      return GestureDetector(
        onTapDown: (d) {
          final idx = ((d.localPosition.dx - padL) / bw).floor();
          setState(() => _hoveredBucket = idx.clamp(0, bars.length - 1));
        },
        onTapUp: (_) => setState(() => _hoveredBucket = null),
        child: Stack(
          children: [
            CustomPaint(
              size: Size(w, h),
              painter: _BarPainter(
                bars: bars,
                maxTotal: maxTotal,
                w: w,
                h: h,
                hoveredBucket: _hoveredBucket,
                t: widget.t,
              ),
            ),
            if (_hoveredBucket != null && _hoveredBucket! < bars.length)
              _buildTooltip(bars[_hoveredBucket!], bw, padL, w),
          ],
        ),
      );
    });
  }

  Widget _buildTooltip(_Bucket bar, double bw, double padL, double w) {
    final x = padL + bar.idx * bw + bw / 2;
    final isRight = bar.idx > ((_buildBuckets().length) * 0.6);

    return Positioned(
      left: isRight ? null : x + 5,
      right: isRight ? (w - x + 5) : null,
      top: 0,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: widget.t.tooltipBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.t.grid),
          boxShadow: const [BoxShadow(blurRadius: 24, offset: Offset(0, 8), color: Color(0x30000000))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Months ${bar.m0}–${bar.m1}',
                style: TextStyle(fontSize: 11, color: widget.t.subtext)),
            const SizedBox(height: 4),
            _Row(dot: widget.t.principal, label: 'Principal',
                value: formatCurrency(bar.principal, widget.currency), t: widget.t),
            _Row(dot: widget.t.interest, label: 'Interest',
                value: formatCurrency(bar.interest, widget.currency), t: widget.t),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final Color dot;
  final String label;
  final String value;
  final LuminaTokens t;

  const _Row({required this.dot, required this.label, required this.value, required this.t});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 7, height: 7, decoration: BoxDecoration(color: dot, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 11.5, color: t.text.withOpacity(0.7))),
            const SizedBox(width: 8),
            Text(value,
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: t.text,
                    fontFeatures: const [FontFeature.tabularFigures()])),
          ],
        ),
      );
}

class _BarPainter extends CustomPainter {
  final List<_Bucket> bars;
  final double maxTotal;
  final double w;
  final double h;
  final int? hoveredBucket;
  final LuminaTokens t;

  static const padL = 8.0, padR = 8.0, padT = 14.0, padB = 24.0;

  const _BarPainter({
    required this.bars,
    required this.maxTotal,
    required this.w,
    required this.h,
    required this.hoveredBucket,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bw = (w - padL - padR) / bars.length;
    final base = h - padB;
    final innerH = h - padT - padB;

    // gridlines
    for (final g in [0.25, 0.5, 0.75]) {
      final gy = padT + g * innerH;
      final path = Path();
      path.moveTo(padL, gy);
      for (double x = padL + 6; x < w - padR; x += 6) {
        path.lineTo(x, gy);
        path.moveTo(x + 5, gy);
      }
      canvas.drawPath(path, Paint()..color = t.grid..strokeWidth = 1..style = PaintingStyle.stroke);
    }

    for (final bar in bars) {
      final bx = padL + bar.idx * bw + bw * 0.18;
      final barW = bw * 0.64;
      final prinH = (bar.principal / maxTotal) * innerH;
      final intH = (bar.interest / maxTotal) * innerH;
      final opacity = hoveredBucket != null && hoveredBucket != bar.idx ? 0.45 : 1.0;

      // principal rect
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bx, base - prinH, barW, prinH),
          const Radius.circular(2),
        ),
        Paint()..color = t.principal.withOpacity(opacity),
      );

      // interest rect
      if (intH > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(bx, base - prinH - intH, barW, intH),
            const Radius.circular(2),
          ),
          Paint()..color = t.interest.withOpacity(opacity),
        );
      }
    }

    // x labels
    final tp = TextPainter(textDirection: TextDirection.ltr);
    final labelStyle = TextStyle(fontSize: 9, color: t.subtext);
    tp.text = TextSpan(text: 'Mo 1', style: labelStyle);
    tp.layout();
    tp.paint(canvas, Offset(padL, h - 14));
    tp.text = TextSpan(text: 'Mo ${bars.last.m1}', style: labelStyle);
    tp.layout();
    tp.paint(canvas, Offset(w - padR - tp.width, h - 14));
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.bars != bars || old.hoveredBucket != hoveredBucket || old.t.isDark != t.isDark;
}
