import 'package:flutter/material.dart';
import '../widgets/cross_overlay.dart';
import 'dart:io';

class ResultPage extends StatefulWidget {
  final String imageUrl;
  final List<Map<String, dynamic>> vastuReport;
  final String? ruleSetName;
  final bool showConfidence;
  final String? localImagePath;

  const ResultPage({
    super.key,
    required this.imageUrl,
    required this.vastuReport,
    this.ruleSetName,
    this.showConfidence = false,
    this.localImagePath,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final TransformationController _transformationController =
      TransformationController();
  double _currentScale = 1.0;

  void _toggleZoom(double factor) {
    setState(() {
      if (_currentScale <= 1.0) {
        _currentScale = factor;
      } else {
        _currentScale = 1.0;
      }
      _transformationController.value = Matrix4.identity()
        ..scaleByDouble(_currentScale, _currentScale, _currentScale, 1.0);
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analysis Results')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onDoubleTap: () => _toggleZoom(2.5),
                        child: InteractiveViewer(
                          transformationController: _transformationController,
                          clipBehavior: Clip.none,
                          panEnabled: true,
                          minScale: 0.5,
                          maxScale: 5.0,
                          child: widget.localImagePath != null
                              ? Image.file(File(widget.localImagePath!), fit: BoxFit.contain)
                              : Image.network(
                            widget.imageUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Text("Failed to load image.");
                            },
                          ),
                        ),
                      ),
                    ),
                    const IgnorePointer(child: CrossOverlay()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton.icon(
                onPressed: _resetZoom,
                icon: const Icon(Icons.center_focus_strong),
                label: const Text('Reset Zoom'),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Vastu Compliance Report:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (widget.ruleSetName != null) Text('Rule set: ${widget.ruleSetName}'),
            const Divider(),
            ...widget.vastuReport.map((item) {
              // Older backend responses did not include rule_applied. Treat
              // the missing field as the legacy evaluated behavior, while a
              // present false value is explicitly neutral/not evaluated.
              final ruleApplied = item['rule_applied'] != false;
              final isOk = item['vastu_ok'] == true;
              final label = item['label'];
              final direction = item['direction'];
              final color = !ruleApplied
                  ? Colors.grey.shade700
                  : (isOk ? Colors.green : Colors.red);
              final icon = !ruleApplied
                  ? Icons.help_outline
                  : (isOk ? Icons.check_circle : Icons.cancel);
              final confidence = item['confidence'];
              final confidenceText = widget.showConfidence && confidence is num
                  ? ' • ${(confidence * 100).round()}% confidence'
                  : '';
              final statusText = !ruleApplied
                  ? 'Not evaluated${widget.ruleSetName == null ? '' : ' by ${widget.ruleSetName}'}'
                  : (isOk ? 'Vastu compliant' : 'Not compliant');

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Icon(icon, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${label.toString()} • $direction$confidenceText\n$statusText',
                        style: TextStyle(
                          fontSize: 16,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _resetZoom() {
    setState(() {
      _transformationController.value = Matrix4.identity();
      _currentScale = 1.0;
    });
  }
}
