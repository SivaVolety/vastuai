import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/advanced_settings_provider.dart';

class AdvancedPage extends StatelessWidget {
  const AdvancedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdvancedSettingsProvider>(
      builder: (context, settings, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Detection Confidence: ${settings.confidenceThreshold.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Slider(
            value: settings.confidenceThreshold,
            min: 0.1,
            max: 0.9,
            divisions: 80,
            label: settings.confidenceThreshold.toStringAsFixed(2),
            onChanged: settings.setConfidence,
          ),
          SwitchListTile(
            title: const Text('Show Detection Confidence'),
            value: settings.showConfidence,
            onChanged: settings.setShowConfidence,
          ),
          SwitchListTile(
            title: const Text('Show Bounding Boxes'),
            value: settings.showBoundingBoxes,
            onChanged: settings.setShowBoundingBoxes,
          ),
          const Divider(),
          const ListTile(
            title: Text('Floor Plan Orientation'),
            subtitle: Text('VastuAI currently treats the top of the prepared image as North.'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: settings.reset,
            child: const Text('Reset to Defaults'),
          ),
        ],
      ),
    );
  }
}
