import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vastuai/pages/result_page.dart';

void main() {
  for (final entry in <String?, String>{
    'v1': 'Stable V1', 'v2': 'Experimental V2', null: 'Not reported by backend',
  }.entries) {
    testWidgets('shows model indicator ${entry.value}', (tester) async {
      await tester.pumpWidget(MaterialApp(home: ResultPage(
        imageUrl: 'https://example.invalid/output.jpg', vastuReport: const [],
        modelVersion: entry.key,
      )));
      expect(find.text('Model: ${entry.value}'), findsOneWidget);
    });
  }

  testWidgets('shows a neutral not-evaluated state for uncovered labels',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ResultPage(
        imageUrl: 'https://example.invalid/output.jpg',
        ruleSetName: 'Feng Shui Compass Preset',
        vastuReport: [
          {
            'label': 'bed',
            'direction': 'SE',
            'vastu_ok': false,
            'rule_applied': false,
            'confidence': 0.88,
          },
        ],
        showConfidence: true,
      ),
    ));

    expect(find.textContaining('bed • SE • 88% confidence'), findsOneWidget);
    expect(find.textContaining('Not evaluated by Feng Shui Compass Preset'), findsOneWidget);
    expect(find.byIcon(Icons.help_outline), findsOneWidget);
    expect(find.byIcon(Icons.cancel), findsNothing);
  });

  testWidgets('keeps pass/fail presentation when a rule is applied',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ResultPage(
        imageUrl: 'https://example.invalid/output.jpg',
        vastuReport: [
          {
            'label': 'sink',
            'direction': 'N',
            'vastu_ok': true,
            'rule_applied': true,
          },
        ],
      ),
    ));

    expect(find.textContaining('Vastu compliant'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}
