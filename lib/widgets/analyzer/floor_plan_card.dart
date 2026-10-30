import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/vastu_theme.dart';
import '../brand_components.dart';

class FloorPlanCard extends StatelessWidget {
  const FloorPlanCard(
      {super.key,
      required this.preview,
      required this.hasImage,
      required this.desktop,
      required this.onUpload,
      required this.onRotateLeft,
      required this.onRotateRight,
      required this.onZoomIn,
      required this.onZoomOut,
      required this.onReset,
      required this.rotation,
      this.filename});
  final Widget preview;
  final bool hasImage;
  final bool desktop;
  final VoidCallback? onUpload,
      onRotateLeft,
      onRotateRight,
      onZoomIn,
      onZoomOut,
      onReset;
  final int rotation;
  final String? filename;

  @override
  Widget build(BuildContext context) => BrandedCard(
        padding: EdgeInsets.all(desktop ? VastuSpace.xl : VastuSpace.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text('Floor Plan',
                    style:
                        VastuType.title.copyWith(fontSize: desktop ? 30 : 28))),
            StatusPill(label: hasImage ? 'READY' : 'STEP 01', active: hasImage),
          ]),
          const SizedBox(height: VastuSpace.sm),
          Row(children: [
            Expanded(
                child: Text(filename ?? 'A clearer view of your space.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: VastuType.small)),
            if (hasImage)
              TextButton(
                  onPressed: onUpload,
                  style: VastuButtons.secondary(tonal: true),
                  child: const Text('Change image')),
          ]),
          const SizedBox(height: VastuSpace.lg),
          LayoutBuilder(builder: (context, constraints) {
            final height = desktop
                ? math.min(560.0, constraints.maxWidth / 1.25)
                : constraints.maxWidth;
            return Container(
              height: height,
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                  color: VastuColors.canvas,
                  border: Border.all(color: VastuColors.border),
                  borderRadius: BorderRadius.circular(VastuRadius.control)),
              child: Stack(fit: StackFit.expand, children: [
                CustomPaint(painter: _PlanGrid()),
                if (hasImage)
                  Center(child: AspectRatio(aspectRatio: 1, child: preview))
                else
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.all(VastuSpace.lg),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      if (height >= 300)
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                                colors: [VastuColors.sage, VastuColors.canvas],
                                radius: 0.8),
                          ),
                          child: const Center(
                              child: Icon(Icons.upload_file_outlined,
                                  size: 30, color: VastuColors.forest)),
                        ),
                      const SizedBox(height: VastuSpace.md),
                      Text('Your space starts here',
                          style: VastuType.title
                              .copyWith(fontSize: desktop ? 28 : 23),
                          textAlign: TextAlign.center),
                      const SizedBox(height: VastuSpace.sm),
                      const Text('Choose a floor plan to begin.',
                          style: VastuType.small, textAlign: TextAlign.center),
                      const SizedBox(height: VastuSpace.md),
                      SecondaryButton(
                          label: 'Upload Floor Plan',
                          tonal: true,
                          icon: Icons.upload_file_outlined,
                          onPressed: onUpload),
                    ]),
                  )),
              ]),
            );
          }),
          const SizedBox(height: VastuSpace.lg),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _Tool('Rotate Left', Icons.rotate_left, onRotateLeft),
            const SizedBox(width: VastuSpace.xs),
            _Tool('Rotate Right', Icons.rotate_right, onRotateRight),
            const SizedBox(width: VastuSpace.xs),
            _Tool('Zoom out', Icons.remove, onZoomOut),
            const SizedBox(width: VastuSpace.xs),
            _Tool('Zoom in', Icons.add, onZoomIn),
            const SizedBox(width: VastuSpace.xs),
            _Tool('Fit / Reset zoom', Icons.fit_screen_outlined, onReset),
          ]),
          const SizedBox(height: VastuSpace.sm),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.north_rounded,
                size: 18, color: VastuColors.terracotta),
            const SizedBox(width: VastuSpace.sm),
            Flexible(
                child: Text('Rotate so North is facing up',
                    style: VastuType.small, textAlign: TextAlign.center)),
            if (hasImage) ...[
              const SizedBox(width: VastuSpace.sm),
              Text('$rotation°', style: VastuType.caption)
            ],
          ]),
        ]),
      );
}

class _Tool extends StatelessWidget {
  const _Tool(this.label, this.icon, this.onPressed);
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: label,
        onPressed: onPressed,
        style: VastuButtons.icon(),
        icon: Icon(icon, size: 20),
      );
}

class _PlanGrid extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = VastuColors.border.withValues(alpha: 0.32)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += VastuSpace.xl) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += VastuSpace.xl) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
