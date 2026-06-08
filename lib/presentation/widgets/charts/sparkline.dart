import 'package:flutter/material.dart';

class Sparkline extends StatelessWidget {
  final List<double> balances;
  final Color color;
  final double width;
  final double height;

  const Sparkline({
    super.key,
    required this.balances,
    required this.color,
    this.width = 64,
    this.height = 26,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _SparklinePainter(balances: balances, color: color),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> balances;
  final Color color;

  const _SparklinePainter({required this.balances, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (balances.isEmpty) return;
    final max = balances.reduce((a, b) => a > b ? a : b);
    if (max == 0) return;

    final n = balances.length;
    List<Offset> pts = [];
    for (int i = 0; i < n; i++) {
      final x = (i / (n - 1).clamp(1, double.infinity)) * size.width;
      final y = size.height - (balances[i] / max) * (size.height - 3) - 1.5;
      pts.add(Offset(x, y));
    }

    final path = _smoothPath(pts);
    final areaPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(areaPath, Paint()..color = color.withOpacity(0.14));
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

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
  bool shouldRepaint(_SparklinePainter old) =>
      old.balances != balances || old.color != color;
}
