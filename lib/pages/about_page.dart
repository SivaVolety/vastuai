import 'package:flutter/material.dart';
import '../constants/app_info.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(24), children: [
      const Icon(Icons.architecture, size: 64, color: Colors.blue),
      const SizedBox(height: 12),
      const Center(child: Text('VastuAI', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
      Center(child: Text('Version $appVersion+$appBuild')),
      const SizedBox(height: 24),
      const Text('VastuAI is an AI-assisted floor-plan analysis application that uses computer vision to identify objects in floor plans, determine their directional placement, and evaluate them using configurable Vastu rules.', style: TextStyle(height: 1.5)),
      const SizedBox(height: 16),
      const Text('Technology', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      const Text('Flutter • FastAPI • Ultralytics YOLO • Python • local on-device history and persistence'),
      const SizedBox(height: 16),
      const Text('Architecture', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      const Text('Flutter → FastAPI → YOLO detection → direction calculation → selected Vastu rule evaluation → annotated result and report'),
      const SizedBox(height: 16),
      const Text('Responsible use', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      const Text('Results are AI-assisted and may be wrong. Verify important decisions with an appropriately qualified professional.'),
    ]);
  }
}
