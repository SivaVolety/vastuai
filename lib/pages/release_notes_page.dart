import 'package:flutter/material.dart';
import '../constants/app_info.dart';
import '../models/detector_model.dart';

class ReleaseNotesPage extends StatelessWidget {
  const ReleaseNotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    const features = [DetectorModel.description, 'Optional Research Beta selector; Stable V1 remains the default', 'Web deployment configuration through VASTUAI_API_BASE_URL', 'Mobile History retains model metadata; saved History is unavailable on Web', 'Camera and Gallery floor-plan input', 'Pan, zoom, rotation, and alignment tools', 'North-up orientation guidance', 'YOLO-based object detection', 'Vastu direction and compliance evaluation', 'Built-in and custom independent rule sets', 'Configurable backend API and connection testing', 'Detection confidence controls', 'Optional confidence display and bounding boxes', 'Local analysis History', 'Offline reopening of saved analyses', 'Loading and network error handling'];
    return ListView(padding: const EdgeInsets.all(16), children: [Text('VastuAI $appVersion', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 12), ...features.map((feature) => ListTile(leading: const Icon(Icons.check_circle_outline), title: Text(feature)))]);
  }
}
