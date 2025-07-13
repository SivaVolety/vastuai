import 'package:flutter/material.dart';

class ReleaseNotesPage extends StatelessWidget {
  const ReleaseNotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final releases = [
      {
        'version': '1.0.0',
        'features': [
          'Initial release',
          'Image upload & rotation',
          'Vastu report',
          'Drawer navigation'
        ]
      },
      {
        'version': '0.9.0',
        'features': ['YOLO backend integration', 'Floor plan preview']
      }
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: releases.map((release) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version ${release['version']}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ...List<Widget>.from(
                (release['features'] as List).map((f) => Text('• $f'))),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }
}
