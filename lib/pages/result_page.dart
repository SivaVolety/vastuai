// lib/pages/result_page.dart
import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final String htmlContent;

  const ResultPage({super.key, required this.htmlContent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),

        child: SelectableText(htmlContent),
      ),
    );
  }
}
