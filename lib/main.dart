// lib/main.dart
import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() => runApp(const FloorPlanApp());

class FloorPlanApp extends StatelessWidget {
  const FloorPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Floor Plan Analyzer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}
