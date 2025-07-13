import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'VastuAI\n\nCreated by Siva Volety.\n© 2025 All rights reserved.',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
