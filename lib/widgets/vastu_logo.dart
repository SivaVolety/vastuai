import 'package:flutter/material.dart';
import '../theme/vastu_theme.dart';

class VastuLogo extends StatelessWidget {
  const VastuLogo({super.key, this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) => Semantics(
        label: 'VastuAI',
        image: true,
        child: ExcludeSemantics(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
          VastuMark(size: compact ? 34 : 40),
          const SizedBox(width: 10),
          Text('VastuAI',
              style: VastuType.title
                  .copyWith(fontSize: compact ? 26 : 29, letterSpacing: -0.6)),
        ])),
      );
}

/// Standalone vector mark for compact brand placements.
class VastuMark extends StatelessWidget {
  const VastuMark({super.key, this.size = 40});
  final double size;
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _LogoPainter());
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 48);
    final line = Paint()
      ..color = VastuColors.forest
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final house = Path()
      ..moveTo(7, 22)
      ..lineTo(23, 7)
      ..lineTo(39, 22)
      ..lineTo(39, 42)
      ..lineTo(7, 42)
      ..close();
    canvas.drawPath(house, line);
    canvas.drawLine(const Offset(23, 20), const Offset(23, 42), line);
    canvas.drawLine(const Offset(7, 30), const Offset(23, 30), line);
    canvas.drawLine(const Offset(23, 34), const Offset(32, 34), line);
    final accent = Paint()..color = VastuColors.terracotta;
    canvas.drawPath(
        Path()
          ..moveTo(40, 4)
          ..lineTo(45, 17)
          ..lineTo(40, 14)
          ..lineTo(35, 17)
          ..close(),
        accent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
