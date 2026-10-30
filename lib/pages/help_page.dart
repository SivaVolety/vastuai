import 'package:flutter/material.dart';
import '../models/detector_model.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});
  Widget _section(String title, String body) => Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(body, style: const TextStyle(height: 1.4))])));

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
        _section('How to Analyze a Floor Plan', '1. Take a photo or choose a floor plan from Gallery.\n2. Position the image with pan and zoom.\n3. Rotate until North faces up.\n4. Select a Vastu rule set.\n5. Optionally configure Advanced settings.\n6. Tap Analyze.\n7. Review the annotated image and compliance report.'),
        _section('Floor Plan Orientation', 'VastuAI treats the top of the prepared image as North. Rotate the floor plan until North is facing up. Incorrect orientation can produce incorrect direction-based Vastu results.'),
        _section('Camera vs Gallery', 'Camera is useful for a paper plan or a plan on a screen. Gallery is useful for an existing scan, photograph, or digital image.'),
        _section('Image Positioning', 'Pan by dragging, zoom with gestures or double tap, rotate in 30-degree increments, and use Reset Zoom to return to the default view. The center cross helps align the plan.'),
        _section('Rule Sets', 'Vastu Presets is the built-in read-only set. You can create and edit custom rule sets, then select the active set before analysis. Custom rule sets are complete independent maps and do not inherit unspecified Vastu Preset rules.'),
        _section('Detection Models', '${DetectorModel.description} ${DetectorModel.betaWarning} Choose the model on Home; your choice lasts for the app session. Results show the model reported by the backend.'),
        _section('Advanced Settings', 'Detection Confidence controls the minimum YOLO confidence from 0.10 to 0.90. Increasing it may reduce false detections but can miss real objects. Show Detection Confidence displays percentages. Show Bounding Boxes controls annotation boxes. Reset to Defaults restores original behavior.'),
        _section('Understanding Results', 'Each detected object has a label, calculated direction, and Vastu pass/fail result. When enabled, confidence is shown as a percentage and bounding boxes appear on the annotated image.'),
        _section('History', 'In the mobile app, successful analyses are saved locally on this device. Web analyses are not saved and must be reviewed before leaving the results page. You can reopen them without the backend. The newest 25 analyses are retained, and entries can be deleted individually or cleared.'),
        _section('Connection Troubleshooting', 'Check the backend URL in Settings and use Test Connection. The FastAPI backend must be running. A phone and local development server usually need to be on the same network. Web deployments use a public HTTPS API, normally https://api.vastuai.com.'),
        _section('Detection Troubleshooting', 'Use a clear floor plan, avoid extreme cropping, and make sure objects are visible. If valid objects are missed, try a lower confidence threshold within the allowed range.'),
        _section('Disclaimer', 'VastuAI is an AI-assisted tool. Object detections, directions, and Vastu evaluations may be incorrect and should be reviewed by a qualified person.'),
      ]);
}
