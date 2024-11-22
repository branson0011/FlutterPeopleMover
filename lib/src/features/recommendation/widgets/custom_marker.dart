import 'package:flutter/material.dart';
import 'dart:ui' as user_interface;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomMarker {
  static Future<BitmapDescriptor> createCustomMarker(
    BuildContext context,
    String label,
    Color color,
  ) async {
    final recorder = user_interface.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(120, 60);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(size.width / 2 - 10, size.height - 10)
      ..lineTo(size.width / 2 + 10, size.height - 10)
      ..close();

    canvas.drawPath(path, paint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height - 10),
        const Radius.circular(8),
      ),
      paint,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2 - 5,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final bytes = await image.toByteData(format: user_interface.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }
}
