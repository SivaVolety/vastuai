import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/vastu_theme.dart';

/// Original vector foliage. Decorative only: no assets, requests, or semantics.
class BotanicalSprig extends StatelessWidget {
  const BotanicalSprig(
      {super.key,
      this.size = 320,
      this.opacity = VastuBotanical.desktopOpacity});
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: ExcludeSemantics(
          child: RepaintBoundary(
            child: CustomPaint(
                size: Size.square(size), painter: _SprigPainter(opacity)),
          ),
        ),
      );
}

/// Paints only in the empty hero-side space and outer gutter. The foreground
/// receives its original constraints; this layer cannot change page geometry.
class BotanicalBackground extends StatelessWidget {
  const BotanicalBackground(
      {super.key, required this.child, required this.contentInset});
  final Widget child;
  final double contentInset;

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < VastuLayout.desktop) return child;
        return Stack(
            fit: StackFit.passthrough,
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  key: const ValueKey('botanical-decoration'),
                  child: ExcludeSemantics(
                    child: RepaintBoundary(
                      child: CustomPaint(
                          painter: _BackgroundPainter(contentInset)),
                    ),
                  ),
                ),
              ),
              child,
            ]);
      });
}

class _BackgroundPainter extends CustomPainter {
  const _BackgroundPainter(this.inset);
  final double inset;

  @override
  void paint(Canvas canvas, Size size) {
    final desktop = size.width >= 1280;
    final contentLeft =
        math.max(inset, (size.width - VastuLayout.contentMax) / 2);
    final clearTextEdge = math.min(size.width - contentLeft,
        contentLeft + VastuLayout.heroTextMax + VastuSpace.lg);
    final accentSize = desktop ? 380.0 : 240.0;
    canvas.save();
    // This hard exclusion zone protects the full heading/supporting-text area,
    // even if a leaf shape changes later. Tablet foliage stays in the gutter.
    canvas.clipRect(Rect.fromLTRB(clearTextEdge, 0, size.width, size.height));
    canvas.translate(size.width - accentSize * 0.78, -accentSize * 0.12);
    canvas.scale(accentSize / 320);
    _BotanicalVector.paint(canvas,
        desktop ? VastuBotanical.desktopOpacity : VastuBotanical.tabletOpacity);
    canvas.restore();

    if (desktop) {
      canvas.save();
      // The secondary accent is confined outside the cards' content bounds.
      canvas.clipRect(Rect.fromLTWH(0, size.height * 0.56,
          math.max(0, contentLeft - VastuSpace.sm), size.height * 0.44));
      canvas.translate(-125, size.height * 0.61);
      canvas.rotate(-0.22);
      canvas.scale(0.82);
      _BotanicalVector.paint(canvas, VastuBotanical.secondaryOpacity);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) =>
      oldDelegate.inset != inset;
}

class _SprigPainter extends CustomPainter {
  const _SprigPainter(this.opacity);
  final double opacity;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 320, size.height / 320);
    _BotanicalVector.paint(canvas, opacity);
  }

  @override
  bool shouldRepaint(covariant _SprigPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}

abstract final class _BotanicalVector {
  static void paint(Canvas canvas, double opacity) {
    final stem = Paint()
      ..color = VastuColors.botanical.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
        Path()
          ..moveTo(327, -20)
          ..cubicTo(252, 38, 294, 138, 182, 308),
        stem);
    for (final leaf in const [
      (280.0, 28.0, 3.50, 114.0, 31.0, false),
      (271.0, 66.0, -0.12, 103.0, 32.0, false),
      (267.0, 108.0, 3.65, 122.0, 35.0, false),
      (250.0, 150.0, 0.12, 115.0, 34.0, false),
      (232.0, 193.0, 3.85, 116.0, 34.0, true),
      (208.0, 241.0, 0.20, 112.0, 31.0, false),
      (182.0, 292.0, 3.90, 97.0, 27.0, false),
    ]) {
      canvas.save();
      canvas.translate(leaf.$1, leaf.$2);
      canvas.rotate(leaf.$3);
      final length = leaf.$4, width = leaf.$5;
      final shape = Path()
        ..moveTo(0, 0)
        ..cubicTo(
            length * 0.20, -width, length * 0.73, -width * 0.78, length, 0)
        ..cubicTo(
            length * 0.75, width * 0.68, length * 0.22, width * 0.68, 0, 0)
        ..close();
      final leafColor =
          leaf.$6 ? VastuColors.botanicalSaffron : VastuColors.botanical;
      final leafOpacity =
          leaf.$6 ? opacity * VastuBotanical.saffronOpacityFactor : opacity;
      canvas.drawPath(
          shape, Paint()..color = leafColor.withValues(alpha: leafOpacity));
      canvas.drawPath(
          Path()
            ..moveTo(0, 0)
            ..quadraticBezierTo(length * 0.5, -width * 0.05, length * 0.9, 0),
          Paint()
            ..color = VastuColors.forest.withValues(alpha: opacity * 0.40)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.7);
      canvas.restore();
    }
  }
}
