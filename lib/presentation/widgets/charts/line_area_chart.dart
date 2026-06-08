import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/amortization_row.dart';

class LineAreaChart extends StatefulWidget {
  final List<AmortizationRow> schedule;
  final LuminaTokens t;
  final String currency;

  const LineAreaChart({
    super.key,
    required this.schedule,
    required this.t,
    required this.currency,
  });

  @override
  State<LineAreaChart> createState() => _LineAreaChartState();
}

class _LineAreaChartState extends State<LineAreaChart> {
  int? _scrubIndex;

  List<AmortizationRow> _sample(List<AmortizationRow> sched, int max) {
    if (sched.length <= max) return sched;
    final out = <AmortizationRow>[];
    final step = (sched.length - 1) / (max - 1);
    for (int k = 0; k < max; k++) {
      out.add(sched[(step * k).round()]);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final pts = _sample(widget.schedule, 96);
    final n = widget.schedule.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        const h = 188.0;
        const padL = 8.0, padR = 8.0, padT = 14.0, padB = 24.0;

        final maxPay = widget.schedule.fold(0.0, (m, r) => r.payment > m ? r.payment : m);
        if (maxPay == 0) return SizedBox(height: h);

        return GestureDetector(
          onHorizontalDragUpdate: (d) {
            final rx = d.localPosition.dx;
            final frac = ((rx - padL) / (w - padL - padR)).clamp(0.0, 1.0);
            setState(() => _scrubIndex = (frac * (n - 1)).round());
          },
          onHorizontalDragEnd: (_) => setState(() => _scrubIndex = null),
          onTapDown: (d) {
            final rx = d.localPosition.dx;
            final frac = ((rx - padL) / (w - padL - padR)).clamp(0.0, 1.0);
            setState(() => _scrubIndex = (frac * (n - 1)).round());
          },
          onTapUp: (_) => setState(() => _scrubIndex = null),
          child: Stack(
            children: [
              CustomPaint(
                size: Size(w, h),
                painter: _LineAreaPainter(
                  schedule: widget.schedule,
                  sampledPts: pts,
                  n: n,
                  maxPay: maxPay,
                  w: w,
                  h: h,
                  scrubIdx: _scrubIndex,
                  t: widget.t,
                ),
              ),
              if (_scrubIndex != null && _scrubIndex! < widget.schedule.length)
                _buildTooltip(_scrubIndex!, w, h, padL, padR, padT, padB, maxPay, n),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTooltip(int idx, double w, double h, double padL, double padR, double padT, double padB, double maxPay, int n) {
    final row = widget.schedule[idx];
    final x = padL + (idx / (n - 1).clamp(1, double.infinity)) * (w - padL - padR);
    final isRight = idx > n * 0.6;
    return Positioned(
      left: isRight ? null : x + 8,
      right: isRight ? (w - x + 8) : null,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Month ${row.month}', style: TextStyle(fontSize: 11, color: widget.t.subtext)),
            const SizedBox(height: 4),
            _TooltipRow(dot: widget.t.principal, label: 'Principal', value: formatCurrency(row.principal, widget.currency), t: widget.t),
            _TooltipRow(dot: widget.t.interest, label: 'Interest', value: formatCurrency(row.interest, widget.currency), t: widget.t),
            Divider(color: widget.t.grid, height: 10),
            _TooltipRow(dot: Colors.transparent, label: 'Balance', value: formatCurrency(row.balance, widget.currency), t: widget.t),
          ],
        ),
      ),
    );
  }
}

class _TooltipRow extends StatelessWidget {
  final Color dot;
  final String label;
  final String value;
  final LuminaTokens t;

  const _TooltipRow({required this.dot, required this.label, required this.value, required this.t});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: dot, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 11.5, color: t.text.withOpacity(0.7))),
          const SizedBox(width: 8),
          Text(value, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: t.text,
              fontFeatures: const [FontFeature.tabularFigures()])),
        ],
      );
}

class _LineAreaPainter extends CustomPainter {
  final List<AmortizationRow> schedule;
  final List<AmortizationRow> sampledPts;
  final int n;
  final double maxPay;
  final double w;
  final double h;
  final int? scrubIdx;
  final LuminaTokens t;

  static const padL = 8.0, padR = 8.0, padT = 14.0, padB = 24.0;

  const _LineAreaPainter({
    required this.schedule,
    required this.sampledPts,
    required this.n,
    required this.maxPay,
    required this.w,
    required this.h,
    required this.scrubIdx,
    required this.t,
  });

  double _x(int idx) => padL + (idx / (n - 1).clamp(1, double.infinity)) * (w - padL - padR);
  double _y(double v) => padT + (1 - v / maxPay) * (h - padT - padB);

  Path _smoothPath(List<Offset> pts) {
    final path = Path();
    if (pts.isEmpty) return path;
    path.moveTo(pts[0].dx, pts[0].dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final cx = (pts[i].dx + pts[i + 1].dx) / 2;
      path.cubicTo(cx, pts[i].dy, cx, pts[i + 1].dy, pts[i + 1].dx, pts[i + 1].dy);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final base = h - padB;

    // gridlines
    final gridPaint = Paint()
      ..color = t.grid
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (final g in [0.25, 0.5, 0.75]) {
      final gy = padT + g * (h - padT - padB);
      final path = Path();
      path.moveTo(padL, gy);
      for (double x = padL + 6; x < w - padR; x += 6) {
        path.lineTo(x, gy);
        path.moveTo(x + 5, gy);
      }
      canvas.drawPath(path, gridPaint);
    }

    final principalPts = sampledPts.map((r) => Offset(_x(r.month - 1), _y(r.principal))).toList();
    final paymentPts = sampledPts.map((r) => Offset(_x(r.month - 1), _y(r.payment))).toList();

    final princPath = _smoothPath(principalPts);
    final payPath = _smoothPath(paymentPts);

    // principal area
    final princAreaPath = Path.from(princPath)
      ..lineTo(principalPts.last.dx, base)
      ..lineTo(principalPts.first.dx, base)
      ..close();

    canvas.drawPath(
      princAreaPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [t.principal.withOpacity(0.55), t.principal.withOpacity(0.08)],
        ).createShader(Rect.fromLTWH(0, padT, w, h - padT - padB)),
    );

    // interest area (between payment and principal)
    final interestAreaPath = Path.from(payPath);
    for (int i = principalPts.length - 1; i >= 0; i--) {
      if (i == principalPts.length - 1) {
        interestAreaPath.lineTo(principalPts[i].dx, principalPts[i].dy);
      } else {
        interestAreaPath.lineTo(principalPts[i].dx, principalPts[i].dy);
      }
    }
    interestAreaPath.close();

    canvas.drawPath(
      interestAreaPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [t.interest.withOpacity(0.5), t.interest.withOpacity(0.06)],
        ).createShader(Rect.fromLTWH(0, padT, w, h - padT - padB)),
    );

    // principal line
    canvas.drawPath(
      princPath,
      Paint()
        ..color = t.principal
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // payment line
    canvas.drawPath(
      payPath,
      Paint()
        ..color = t.interest
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // scrubber
    if (scrubIdx != null && scrubIdx! < schedule.length) {
      final sx = _x(scrubIdx!);
      canvas.drawLine(
        Offset(sx, padT),
        Offset(sx, base),
        Paint()
          ..color = t.axis.withOpacity(0.5)
          ..strokeWidth = 1,
      );
      canvas.drawCircle(
        Offset(sx, _y(schedule[scrubIdx!].payment)),
        4,
        Paint()..color = t.interest,
      );
      canvas.drawCircle(
        Offset(sx, _y(schedule[scrubIdx!].payment)),
        4,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      canvas.drawCircle(
        Offset(sx, _y(schedule[scrubIdx!].principal)),
        4,
        Paint()..color = t.principal,
      );
      canvas.drawCircle(
        Offset(sx, _y(schedule[scrubIdx!].principal)),
        4,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // x labels
    final tp = TextPainter(textDirection: TextDirection.ltr);
    final labelStyle = TextStyle(fontSize: 9, color: t.subtext);
    tp.text = TextSpan(text: 'Mo 1', style: labelStyle);
    tp.layout();
    tp.paint(canvas, Offset(padL, h - 14));
    tp.text = TextSpan(text: 'Mo $n', style: labelStyle);
    tp.layout();
    tp.paint(canvas, Offset(w - padR - tp.width, h - 14));
  }

  @override
  bool shouldRepaint(_LineAreaPainter old) =>
      old.schedule != schedule || old.scrubIdx != scrubIdx || old.t.isDark != t.isDark;
}
