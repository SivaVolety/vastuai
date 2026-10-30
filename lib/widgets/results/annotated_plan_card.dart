import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../theme/vastu_theme.dart';
import '../brand_components.dart';
import '../cross_overlay.dart';

class AnnotatedPlanCard extends StatefulWidget {
  const AnnotatedPlanCard(
      {super.key, required this.imageUrl, this.localImagePath});
  final String imageUrl;
  final String? localImagePath;
  @override
  State<AnnotatedPlanCard> createState() => _AnnotatedPlanCardState();
}

class _AnnotatedPlanCardState extends State<AnnotatedPlanCard> {
  final _controller = TransformationController();
  void _reset() => _controller.value = Matrix4.identity();
  void _zoom(double factor) {
    final current = _controller.value.getMaxScaleOnAxis();
    final next = (current * factor).clamp(.5, 5.0);
    _controller.value = _controller.value.clone()
      ..scaleByDouble(next / current, next / current, next / current, 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _message(String title, String message, IconData icon) => Center(
          child: Padding(
        padding: const EdgeInsets.all(VastuSpace.lg),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 32, color: VastuColors.muted),
          const SizedBox(height: VastuSpace.md),
          Text(title, style: VastuType.section, textAlign: TextAlign.center),
          const SizedBox(height: VastuSpace.sm),
          Text(message, style: VastuType.small, textAlign: TextAlign.center),
        ]),
      ));

  @override
  Widget build(BuildContext context) {
    final local = !kIsWeb && widget.localImagePath != null;
    final missing = !local && widget.imageUrl.trim().isEmpty;
    Widget error(BuildContext context, Object error, StackTrace? stack) =>
        _message(
            'Annotated image unavailable',
            'Your findings are still available below.',
            Icons.broken_image_outlined);
    Widget frame(BuildContext context, Widget child, int? frame, bool sync) =>
        frame == null && !sync
            ? const Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                CircularProgressIndicator(),
                SizedBox(height: VastuSpace.lg),
                Text('Loading annotated plan…', style: VastuType.small)
              ]))
            : Stack(
                fit: StackFit.expand,
                children: [child, const IgnorePointer(child: CrossOverlay())]);
    final image = missing
        ? _message('No annotated image', 'Review the available findings below.',
            Icons.image_not_supported_outlined)
        : local
            ? Image.file(File(widget.localImagePath!),
                fit: BoxFit.contain, errorBuilder: error, frameBuilder: frame)
            : Image.network(widget.imageUrl,
                fit: BoxFit.contain, errorBuilder: error, frameBuilder: frame);
    return BrandedCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Annotated Floor Plan', style: VastuType.title),
      const SizedBox(height: VastuSpace.sm),
      const Text('Drag to pan · Pinch or use controls to zoom',
          style: VastuType.caption),
      const SizedBox(height: VastuSpace.lg),
      ClipRRect(
          borderRadius: BorderRadius.circular(VastuRadius.control),
          child: AspectRatio(
            aspectRatio: 1,
            child: ColoredBox(
                color: VastuColors.canvas,
                child: GestureDetector(
                    onDoubleTap: () =>
                        _controller.value.getMaxScaleOnAxis() <= 1
                            ? _zoom(2.5)
                            : _reset(),
                    child: InteractiveViewer(
                        transformationController: _controller,
                        minScale: .5,
                        maxScale: 5,
                        panEnabled: true,
                        clipBehavior: Clip.hardEdge,
                        child: image))),
          )),
      const SizedBox(height: VastuSpace.md),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(
            style: VastuButtons.icon(),
            tooltip: 'Zoom out',
            onPressed: missing ? null : () => _zoom(.8),
            icon: const Icon(Icons.remove)),
        const SizedBox(width: VastuSpace.xs),
        IconButton(
            style: VastuButtons.icon(),
            tooltip: 'Zoom in',
            onPressed: missing ? null : () => _zoom(1.25),
            icon: const Icon(Icons.add)),
        const SizedBox(width: VastuSpace.xs),
        IconButton(
            style: VastuButtons.icon(),
            tooltip: 'Reset Zoom',
            onPressed: missing ? null : _reset,
            icon: const Icon(Icons.center_focus_strong)),
      ]),
      const SizedBox(height: VastuSpace.md),
      const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.north_rounded, size: 16, color: VastuColors.terracotta),
        SizedBox(width: VastuSpace.xs),
        Text('North is up', style: VastuType.caption),
      ]),
      const SizedBox(height: VastuSpace.lg),
      const Text('Image legend', style: VastuType.section),
      const SizedBox(height: VastuSpace.xs),
      const Text('Favorable: blue · Needs Attention: red · Not Evaluated: gray',
          style: VastuType.caption),
      const SizedBox(height: VastuSpace.xs),
      const Text(
          'Original annotations are shown unchanged. Outlines may be hidden by your analysis settings.',
          style: VastuType.caption),
    ]));
  }
}
