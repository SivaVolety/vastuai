import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vastuai/providers/rule_set_provider.dart';
import 'package:vastuai/widgets/results/assessment_overview_card.dart';
import 'package:vastuai/pages/result_page.dart';

Widget _app({required Widget home}) => ChangeNotifierProvider(
    create: (_) => RuleSetProvider(), child: MaterialApp(home: home));

Future<void> _expandFirst(WidgetTester tester) async {
  final row = find.byKey(const ValueKey('finding-0'));
  await tester.ensureVisible(row);
  await tester
      .tap(find.descendant(of: row, matching: find.byType(InkWell)).first);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    final body = FontLoader('Lato')
      ..addFont(rootBundle.load('assets/fonts/Lato-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Lato-Bold.ttf'));
    final display = FontLoader('DMSerifDisplay')
      ..addFont(rootBundle.load('assets/fonts/DMSerifDisplay-Regular.ttf'));
    await Future.wait([body.load(), display.load()]);
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));
  for (final entry in <String?, String>{
    'v1': 'Stable V1',
    'v2': 'Experimental V2',
    null: 'Not reported by backend',
  }.entries) {
    testWidgets('shows model indicator ${entry.value}', (tester) async {
      await tester.pumpWidget(_app(
          home: ResultPage(
        imageUrl: 'https://example.invalid/output.jpg',
        vastuReport: const [],
        modelVersion: entry.key,
      )));
      expect(find.text('Model: ${entry.value}'), findsOneWidget);
    });
  }

  testWidgets('shows a neutral not-evaluated state for uncovered labels',
      (tester) async {
    await tester.pumpWidget(_app(
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

    await tester.pumpAndSettle();
    await _expandFirst(tester);
    expect(find.text('Detection confidence: 88%'), findsOneWidget);
    expect(
        find.textContaining(
            'This item is not covered by Feng Shui Compass Preset'),
        findsOneWidget);
    expect(find.text('Not Evaluated'), findsWidgets);
    expect(find.byIcon(Icons.cancel), findsNothing);
  });

  testWidgets('keeps pass/fail presentation when a rule is applied',
      (tester) async {
    await tester.pumpWidget(_app(
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

    expect(find.text('Favorable'), findsWidgets);
    expect(find.byIcon(Icons.check_circle_outline_rounded), findsWidgets);
  });

  testWidgets('shows the not-fully-compliant verdict and failed items',
      (tester) async {
    await tester.pumpWidget(_app(
      home: ResultPage(
        imageUrl: 'https://example.invalid/output.jpg',
        ruleSetName: 'Vastu Presets',
        vastuReport: [
          {
            'label': 'bed',
            'direction': 'SE',
            'vastu_ok': false,
            'rule_applied': true
          },
          {
            'label': 'door',
            'direction': 'N',
            'vastu_ok': false,
            'rule_applied': false
          },
        ],
      ),
    ));

    expect(find.text('Needs Attention'), findsWidgets);
    expect(find.text('Bed'), findsWidgets);
    expect(find.text('South-East'), findsWidgets);
    final assessment = tester
        .widget<AssessmentOverviewCard>(find.byType(AssessmentOverviewCard))
        .analysis;
    expect(assessment.notEvaluated, 1);
    expect(assessment.attention, 1);
    expect(find.textContaining('0 of 1 evaluated placements'), findsOneWidget);
  });

  testWidgets('shows insufficient information when nothing is evaluated',
      (tester) async {
    await tester.pumpWidget(_app(
      home: ResultPage(
        imageUrl: 'https://example.invalid/output.jpg',
        ruleSetName: 'Feng Shui Compass Preset',
        vastuReport: [
          {
            'label': 'bed',
            'direction': 'SE',
            'vastu_ok': false,
            'rule_applied': false
          },
        ],
      ),
    ));

    expect(find.text('Insufficient Information'), findsOneWidget);
    expect(find.textContaining('0 of 0 evaluated placements'), findsOneWidget);
    expect(find.text('Not Evaluated'), findsWidgets);
    expect(find.textContaining('0 of 1'), findsNothing);
  });

  testWidgets('finding expands and collapses; filters use neutral semantics',
      (tester) async {
    await tester.pumpWidget(_app(
        home: const ResultPage(
            imageUrl: '',
            showConfidence: true,
            ruleSetName: 'Custom tradition',
            vastuReport: [
          {
            'label': 'bed',
            'direction': 'NE',
            'vastu_ok': true,
            'confidence': .9
          },
          {
            'label': 'tub',
            'direction': 'W',
            'vastu_ok': false,
            'rule_applied': false
          },
        ])));
    await tester.pumpAndSettle();
    await _expandFirst(tester);
    expect(find.text('Detection confidence: 90%'), findsOneWidget);
    await _expandFirst(tester);
    expect(find.text('Detection confidence: 90%'), findsNothing);
    final filter = find.widgetWithText(ChoiceChip, 'Not Evaluated');
    await tester.ensureVisible(filter);
    await tester.tap(filter);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('finding-0')), findsNothing);
    expect(find.byKey(const ValueKey('finding-1')), findsOneWidget);
  });

  for (final width in [1440.0, 1280.0, 1024.0, 390.0, 320.0]) {
    testWidgets('results and expanded findings fit ${width.toInt()}px',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 1000);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_app(
          home: const ResultPage(
              imageUrl: '',
              modelVersion: 'v2',
              ruleSetName:
                  'A custom tradition with a deliberately long name for responsive validation',
              vastuReport: [
            {'label': 'main_entrance', 'direction': 'NE', 'vastu_ok': false}
          ])));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(DataTable), findsNothing);
      expect(
          find.text(
              'Research Beta · V2 is experimental and may be less accurate for some rare classes.'),
          findsOneWidget);
      await _expandFirst(tester);
      expect(tester.takeException(), isNull);
      final rect = tester.getRect(find.byKey(const ValueKey('finding-0')));
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(width));
      expect(
          find.textContaining(
              'This placement does not follow the selected rule'),
          findsOneWidget);
    });
  }

  testWidgets('missing image and zero detections show useful empty states',
      (tester) async {
    await tester.pumpWidget(
        _app(home: const ResultPage(imageUrl: '', vastuReport: [])));
    await tester.pumpAndSettle();
    expect(find.text('No annotated image'), findsOneWidget);
    expect(find.text('Insufficient Information'), findsOneWidget);
    expect(find.textContaining('No detections to display'), findsOneWidget);
    expect(
        find.text(
            'No recommendations can be made without evaluated placements.'),
        findsOneWidget);
  });
}
