import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final String imageUrl;
  final List<Map<String, dynamic>> vastuReport;

  const ResultPage({
    super.key,
    required this.imageUrl,
    required this.vastuReport,
  });

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
              child: Image.network(
                imageUrl,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Text("Failed to load image.");
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Vastu Compliance Report:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...vastuReport.map((item) {
              final isOk = item['vastu_ok'] as bool;
              final label = item['label'];
              final direction = item['direction'];
              final color = isOk ? Colors.green : Colors.red;
              final icon = isOk ? Icons.check_circle : Icons.cancel;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Icon(icon, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$label – Direction: $direction',
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
            }).toList(),
          ],
        ),
      ),
    );
  }
}
