import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vastuai/models/results_analysis.dart';
import 'package:vastuai/pages/result_page.dart';
import 'package:vastuai/providers/rule_set_provider.dart';
import 'package:vastuai/services/analysis_summary_service.dart';
import 'package:vastuai/theme/vastu_theme.dart';
import 'package:vastuai/widgets/results/analysis_summary_card.dart';
import 'package:vastuai/widgets/results/annotated_plan_card.dart';
import 'package:vastuai/widgets/results/detailed_findings.dart';

const rows = [
  {
    'label': 'bed',
    'direction': 'S',
    'vastu_ok': true,
    'allowed_directions': ['S']
  },
  {
    'label': 'stove',
    'direction': 'W',
    'vastu_ok': false,
    'allowed_directions': ['SE', 'NW']
  },
  {
    'label': 'stairs',
    'direction': 'E',
    'vastu_ok': false,
    'allowed_directions': ['S', 'W', 'SW']
  },
  {'label': 'tub', 'direction': 'N', 'vastu_ok': false, 'rule_applied': false},
];

class PendingSummary extends AnalysisSummaryService {
  final pending = Completer<ResultNarrative?>();
  @override
  Future<ResultNarrative?> generate(ResultsAnalysis analysis) => pending.future;
}

const sections = [
  'assessment',
  'summary',
  'plan',
  'strengths',
  'review',
  'actions',
  'findings'
];
Finder section(String name) => find.byKey(ValueKey('results-$name'));
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  setUpAll(() async {
    final fonts = FontLoader('Lato')
      ..addFont(rootBundle.load('assets/fonts/Lato-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Lato-Bold.ttf'));
    final display = FontLoader('DMSerifDisplay')
      ..addFont(rootBundle.load('assets/fonts/DMSerifDisplay-Regular.ttf'));
    await Future.wait([fonts.load(), display.load()]);
  });
  for (final width in [1440.0, 1280.0, 1024.0, 390.0, 320.0]) {
    for (final version in ['v1', 'v2']) {
      for (final success in [true, false]) {
        testWidgets(
            '$width $version stable loading to ${success ? 'success' : 'fallback'}',
            (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(width, 1000);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final service = PendingSummary();
          await tester.pumpWidget(ChangeNotifierProvider(
              create: (_) => RuleSetProvider(),
              child: MaterialApp(
                  theme: VastuTheme.light,
                  home: ResultPage(
                      imageUrl: '',
                      vastuReport: rows,
                      modelVersion: version,
                      showConfidence: true,
                      summaryService: service))));
          await tester.pump();
          Map<String, Rect> bounds() => {
                for (final name in sections) name: tester.getRect(section(name))
              };
          final before = bounds();
          final element = tester.element(find.byType(AnalysisSummaryCard));
          final viewport =
              find.byKey(const ValueKey('annotated-plan-viewport'));
          final imageBefore = tester.getSize(viewport);
          expect(imageBefore.height, inInclusiveRange(200, 360));
          if (width >= 1000) {
            expect(before['summary']!.top, before['plan']!.top);
            expect(before['strengths']!.top, before['review']!.top);
            expect(before['strengths']!.top,
                greaterThanOrEqualTo(before['plan']!.bottom));
            expect(before['actions']!.top,
                greaterThanOrEqualTo(before['review']!.bottom));
          } else {
            for (var i = 1; i < sections.length; i++) {
              expect(before[sections[i]]!.top,
                  greaterThanOrEqualTo(before[sections[i - 1]]!.bottom));
            }
          }
          final local = ResultsAnalysis(report: rows).localNarrative;
          service.pending.complete(success
              ? ResultNarrative(
                  headline: local.headline,
                  summary: List.filled(10, 'A deliberately longer explanation.')
                      .join(' '),
                  strengths: local.strengths,
                  priorities: local.priorities,
                  recommendations: const [
                    'Unsupported action: rebuild the entire kitchen.'
                  ],
                  isAiGenerated: true,
                  disclaimer:
                      'AI-generated explanation based on deterministic findings.')
              : null);
          await tester.pumpAndSettle();
          expect(
              identical(
                  element, tester.element(find.byType(AnalysisSummaryCard))),
              true);
          expect(bounds(), before);
          expect(tester.getSize(viewport), imageBefore);
          expect(find.text('Unsupported action: rebuild the entire kitchen.'),
              findsNothing);
          expect(find.byType(DataTable), findsNothing);
          final review = section('review');
          expect(
              find.descendant(
                  of: review,
                  matching: find.textContaining('Outside the allowed')),
              findsNWidgets(2));
          expect(
              find.descendant(
                  of: review, matching: find.text('What you can do')),
              findsNothing);
          final action = find.byKey(const ValueKey('action-0'));
          final actionsBefore = tester.getRect(section('actions'));
          final detailsBefore = tester.getRect(section('findings'));
          final why = find.descendant(of: action, matching: find.text('Why?'));
          await tester.ensureVisible(why);
          await tester.tap(why);
          await tester.pumpAndSettle();
          // Scrolling changes global Y, so compare relative geometry and X/width.
          expect(tester.getRect(section('actions')).width, actionsBefore.width);
          expect(
              tester.getRect(section('findings')).top -
                  tester.getRect(section('actions')).top,
              greaterThan(detailsBefore.top - actionsBefore.top));
          expect(
              find.text(
                  'This placement does not match the selected rule for this element.'),
              findsOneWidget);
          expect(
              find.text(
                  'If relocation is impractical, treat this as a design constraint rather than a required renovation.'),
              findsOneWidget);
          for (final index in [0, 1]) {
            final row = find.byKey(ValueKey('finding-$index'));
            await tester.ensureVisible(row);
            await tester.tap(
                find.descendant(of: row, matching: find.byType(InkWell)).first);
            await tester.pumpAndSettle();
          }
          expect(
              find.descendant(
                  of: find.byType(DetailedFindings),
                  matching: find.text('Rule applied: Yes')),
              findsNWidgets(2));
          expect(
              find.descendant(
                  of: find.byType(DetailedFindings),
                  matching: find.text('What you can do')),
              findsNothing);
          for (final name in sections) {
            final rect = tester.getRect(section(name));
            expect(rect.left, greaterThanOrEqualTo(0));
            expect(rect.right, lessThanOrEqualTo(width));
          }
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
  for (final width in [1440.0, 1280.0, 1024.0, 390.0, 320.0]) {
    testWidgets('all favorable keeps the same section structure at $width',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 1000);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final service = PendingSummary();
      service.pending.complete(null);
      await tester.pumpWidget(ChangeNotifierProvider(
          create: (_) => RuleSetProvider(),
          child: MaterialApp(
              home: ResultPage(
                  imageUrl: '',
                  vastuReport: [rows.first],
                  summaryService: service))));
      await tester.pumpAndSettle();
      for (final name in sections) {
        expect(section(name), findsOneWidget);
      }
      expect(
          find.text(
              'No corrective actions are needed under the selected rules.'),
          findsOneWidget);
      expect(find.text('What you can do'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
      'image viewport remains fixed when URL changes from missing to failure',
      (tester) async {
    Widget page(String url) => MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: SizedBox(
                    width: 400, child: AnnotatedPlanCard(imageUrl: url)))));
    await tester.pumpWidget(page(''));
    final view = find.byKey(const ValueKey('annotated-plan-viewport'));
    final size = tester.getSize(view);
    await tester.pumpWidget(page('https://example.invalid/image.jpg'));
    await tester.pumpAndSettle();
    expect(tester.getSize(view), size);
    expect(tester.takeException(), isNull);
  });
}
