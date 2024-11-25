import 'package:flutter/material.dart';
import '../models/crowd_level_data.dart';

class _HistoricalChartPainter extends CustomPainter {
  final List<CrowdLevelData> data;
  final Color color;
  final double strokeWidth;
  final bool smoothCurve;

  _HistoricalChartPainter({
    required this.data,
    required this.color,
    this.strokeWidth = 2.0,
    this.smoothCurve = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final width = size.width;
    final height = size.height;
    final xStep = width / (data.length - 1);

    // Calculate points
    final points = List<Offset>.generate(data.length, (i) {
      final x = i * xStep;
      final y = height - (height * (data[i].level.level / 5.0));
      return Offset(x, y);
    });

    // Draw smooth curve or straight lines
    if (smoothCurve) {
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 0; i < points.length - 1; i++) {
        final current = points[i];
        final next = points[i + 1];
        final controlPoint1 = Offset(
          current.dx + (next.dx - current.dx) / 2,
          current.dy,
        );
        final controlPoint2 = Offset(
          current.dx + (next.dx - current.dx) / 2,
          next.dy,
        );
        path.cubicTo(
          controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy,
          next.dx, next.dy,
        );
      }
    } else {
      path.moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
    }

    // Draw path
    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, strokeWidth, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
