import 'package:flutter/material.dart';
import '../models/crowd_level_data.dart';

class HistoricalChart extends StatelessWidget {
  final List<CrowdLevelData> data;
  final Color color;
  final double height;
  final bool smoothCurve;

  const HistoricalChart({
    Key? key,
    required this.data,
    required this.color,
    this.height = 100,
    this.smoothCurve = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _HistoricalChartPainter(
          data: data,
          color: color,
          smoothCurve: smoothCurve,
        ),
        child: _buildTimeLabels(),
      ),
    );
  }

  Widget _buildTimeLabels() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < data.length; i += data.length ~/ 4)
            Text(
              _formatTime(data[i].timestamp),
              style: const TextStyle(fontSize: 10),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class _HistoricalChartPainter extends CustomPainter {
  final List<CrowdLevelData> data;
  final Color color;
  final bool smoothCurve;

  _HistoricalChartPainter({
    required this.data,
    required this.color,
    required this.smoothCurve,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final points = _calculatePoints(size);
    final path = _createPath(points);

    // Draw main line
    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 3.0, pointPaint);
    }

    // Draw gradient
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.2),
          color.withOpacity(0.0),
        ],
      ).createShader(Offset.zero & size);

    final gradientPath = Path()
      ..addPath(path, Offset.zero)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(gradientPath, gradientPaint);
  }

  List<Offset> _calculatePoints(Size size) {
    final width = size.width;
    final height = size.height * 0.8; // Leave room for labels
    final xStep = width / (data.length - 1);

    return List<Offset>.generate(data.length, (i) {
      final x = i * xStep;
      final y = height - (height * (data[i].level.level / 5.0));
      return Offset(x, y);
    });
  }

  Path _createPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);

    if (smoothCurve) {
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
      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
