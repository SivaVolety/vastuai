import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vastuai/models/results_analysis.dart';
import 'package:vastuai/pages/result_page.dart';
import 'package:vastuai/providers/rule_set_provider.dart';
import 'package:vastuai/services/analysis_summary_service.dart';
import 'package:vastuai/widgets/results/remedy_details.dart';
import 'package:vastuai/theme/vastu_theme.dart';

// Response fixture: the frontend never supplies cultural knowledge itself.
const significance =
    'In Vastu tradition, South-East is associated with Agni, the deity of fire. '
    'The stove serves the fire function of the home, so South-East is '
    'traditionally considered suitable for cooking. '
    'This selected rule also permits North-West as an alternative.';
Map<String, dynamic> finding(
        {bool covered = true, bool favorable = false, bool context = true}) =>
    {
      'label': 'stove',
      'direction': 'W',
      'rule_applied': covered,
      'vastu_ok': favorable,
      'allowed_directions': ['SE', 'NW'],
      if (context) 'traditional_significance': significance,
    };

class UnavailableSummary extends AnalysisSummaryService {
  @override
  Future<ResultNarrative?> generate(ResultsAnalysis analysis) async => null;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  setUpAll(() async {
    final body = FontLoader('Lato')
      ..addFont(rootBundle.load('assets/fonts/Lato-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Lato-Bold.ttf'));
    final display = FontLoader('DMSerifDisplay')
      ..addFont(rootBundle.load('assets/fonts/DMSerifDisplay-Regular.ttf'));
    await Future.wait([body.load(), display.load()]);
  });
  test('only failed evaluated findings carry corrective context to summary',
      () {
    for (final row in [finding(covered: false), finding(favorable: true)]) {
      final analysis = ResultsAnalysis(report: [row]);
      expect(analysis.findings.single.remedy, isNull);
      expect(
          (AnalysisSummaryService.payload(analysis)['vastu_report'] as List)
              .single
              .containsKey('traditional_significance'),
          false);
    }
    final analysis = ResultsAnalysis(report: [finding()]);
    final row =
        (AnalysisSummaryService.payload(analysis)['vastu_report'] as List)
            .single;
    expect(row['traditional_significance'], significance);
    expect(analysis.attention, 1);
  });
  for (final ruleSet in [
    'Vastu Presets',
    'Custom',
    'Feng Shui Compass Preset'
  ]) {
    testWidgets('$ruleSet without context uses a safe fallback',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
          theme: VastuTheme.light,
          home: Scaffold(
              body: SingleChildScrollView(
                  child: RemedyDetails(
                      finding: ResultFinding(finding(context: false)),
                      ruleSet: ruleSet)))));
      await tester.tap(find.text('Why?'));
      await tester.pumpAndSettle();
      expect(find.text('Why this matters'),
          ruleSet == 'Vastu Presets' ? findsOneWidget : findsNothing);
      expect(find.text('Rule basis'), findsOneWidget);
      expect(find.textContaining('Agni'), findsNothing);
      if (ruleSet == 'Vastu Presets') {
        expect(
            find.text(
                'This recommendation follows the selected Vastu rule for this element.'),
            findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  }
  for (final width in [1440.0, 1024.0, 390.0, 320.0]) {
    testWidgets('curated Why survives AI fallback at ${width.toInt()}px',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 1000);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(ChangeNotifierProvider(
          create: (_) => RuleSetProvider(),
          child: MaterialApp(
              theme: VastuTheme.light,
              home: ResultPage(
                  imageUrl: '',
                  vastuReport: [finding()],
                  summaryService: UnavailableSummary()))));
      await tester.pumpAndSettle();
      final why = find.text('Why?').first;
      await tester.ensureVisible(why);
      await tester.tap(why);
      await tester.pumpAndSettle();
      expect(find.text(significance), findsOneWidget);
      expect(
          find.textContaining(
              'The selected rule allows South-East or North-West'),
          findsOneWidget);
      expect(find.text('Analysis Summary'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
