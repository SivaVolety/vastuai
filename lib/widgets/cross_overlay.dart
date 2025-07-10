// lib/widgets/cross_overlay.dart
import 'package:flutter/material.dart';

class CrossOverlay extends StatelessWidget {
  const CrossOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: CrossOverlayPainter(),
        );
      },
    );
  }
}

class CrossOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    // Draw cross lines
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // Direction labels
    final textPainter = (String text) {
      final textStyle = TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      );
      final span = TextSpan(text: text, style: textStyle);
      final tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      return tp;
    };

    const padding = 8.0;

    // North (top center)
    final northTp = textPainter('N');
    northTp.paint(canvas, Offset((size.width - northTp.width) / 2, padding));

    // East (right center)
    final eastTp = textPainter('E');
    eastTp.paint(
        canvas,
        Offset(size.width - eastTp.width - padding,
            (size.height - eastTp.height) / 2));

    // South (bottom center)
    final southTp = textPainter('S');
    southTp.paint(
        canvas,
        Offset((size.width - southTp.width) / 2,
            size.height - southTp.height - padding));

    // West (left center)
    final westTp = textPainter('W');
    westTp.paint(canvas, Offset(padding, (size.height - westTp.height) / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
