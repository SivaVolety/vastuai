import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vastuai/config/creator_profile.dart';
import 'package:vastuai/models/results_analysis.dart';
import 'package:vastuai/models/finding_remedy.dart';
import 'package:vastuai/pages/about_page.dart';
import 'package:vastuai/pages/result_page.dart';
import 'package:vastuai/providers/rule_set_provider.dart';
import 'package:vastuai/services/analysis_summary_service.dart';
import 'package:vastuai/theme/vastu_theme.dart';

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
  test('public web metadata uses VasthuAI and icon references exist', () {
    final html = File('web/index.html').readAsStringSync();
    final manifest =
        jsonDecode(File('web/manifest.json').readAsStringSync()) as Map;
    expect(html, contains('<title>VasthuAI</title>'));
    expect(manifest['name'], 'VasthuAI');
    expect(manifest['short_name'], 'VasthuAI');
    expect(manifest['description'], contains('Vastu rules'));
    for (final icon in manifest['icons'] as List) {
      expect(File('web/${icon['src']}').existsSync(), true);
    }
    expect(File('web/favicon.png').existsSync(), true);
    expect(File('web/icons/favicon-16.png').existsSync(), true);
  });
  test('unconfigured and unsafe creator contacts are hidden', () {
    expect(const CreatorProfile(website: null).contacts, isEmpty);
    expect(
        const CreatorProfile(
                email: 'missing',
                github: 'javascript:bad',
                linkedIn: 'https://',
                website: null)
            .contacts,
        isEmpty);
    expect(CreatorProfile.current.contacts.keys, ['LinkedIn', 'Website']);
  });
  test(
      'remedy uses one/multiple supplied directions and no default rule lookup',
      () {
    final finding = ResultFinding({
      'label': 'stove',
      'direction': 'NW',
      'vastu_ok': false,
      'rule_applied': true,
      'allowed_directions': ['E']
    });
    expect(finding.remedy!.action, contains('East'));
    expect(finding.remedy!.action, isNot(contains('South-East')));
    final multiple = ResultFinding({
      'label': 'bed',
      'vastu_ok': false,
      'allowed_directions': ['S', 'W', 'NW']
    });
    expect(multiple.remedy!.action, contains('South, West, or North-West'));
    expect(directionName('NW'), 'North-West');
  });
  test(
      'neutral and favorable findings have no corrective remedy; absent metadata is generic',
      () {
    expect(
        ResultFinding({
          'label': 'tub',
          'rule_applied': false,
          'vastu_ok': false,
          'allowed_directions': ['S']
        }).remedy,
        isNull);
    expect(
        ResultFinding({
          'label': 'bed',
          'vastu_ok': true,
          'allowed_directions': ['S']
        }).remedy,
        isNull);
    expect(ResultFinding({'label': 'stove', 'vastu_ok': false}).remedy!.action,
        'Review this placement according to the selected rule.');
  });
  test('summary input carries the rule snapshot without client-authored advice',
      () {
    final body = AnalysisSummaryService.payload(ResultsAnalysis(report: [
      {
        'label': 'sink',
        'direction': 'W',
        'vastu_ok': false,
        'allowed_directions': ['N']
      }
    ], ruleSetName: 'Feng Shui Compass Preset'));
    final row = (body['vastu_report'] as List).single as Map;
    expect(row['allowed_directions'], ['N']);
    expect(row.containsKey('remedy'), false);
    expect(body['rule_set_name'], 'Feng Shui Compass Preset');
  });
  testWidgets('configured contact buttons stack at 320px', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 1000);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: VastuTheme.light,
        home: const Scaffold(
            body: AboutPage(
                profile: CreatorProfile(
                    email: 'test@example.invalid',
                    github: 'https://example.invalid/github',
                    linkedIn: 'https://example.invalid/linkedin')))));
    await tester.pumpAndSettle();
    final buttons = ['Email', 'GitHub', 'LinkedIn', 'Website']
        .map((name) => find.widgetWithText(OutlinedButton, name))
        .toList();
    for (var i = 1; i < buttons.length; i++) {
      expect(tester.getTopLeft(buttons[i]).dy,
          greaterThan(tester.getBottomLeft(buttons[i - 1]).dy));
    }
    expect(tester.takeException(), isNull);
  });

  for (final width in [1440.0, 1024.0, 390.0, 320.0]) {
    testWidgets('creator page is responsive at ${width.toInt()}px',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 1000);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
          theme: VastuTheme.light, home: const Scaffold(body: AboutPage())));
      await tester.pumpAndSettle();
      expect(find.text('Siva Volety'), findsOneWidget);
      expect(find.text('How VasthuAI was built'), findsOneWidget);
      expect(find.textContaining('Deterministic Vastu rules'), findsOneWidget);
      expect(find.text('GitHub'), findsNothing);
      expect(find.text('LinkedIn'), findsOneWidget);
      expect(find.text('Email'), findsNothing);
      expect(tester.takeException(), isNull);
    });
    testWidgets('remedies survive AI failure and expand at ${width.toInt()}px',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 1000);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(ChangeNotifierProvider(
          create: (_) => RuleSetProvider(),
          child: MaterialApp(
              home: ResultPage(
                  imageUrl: '',
                  ruleSetName: 'Custom rules',
                  summaryService: UnavailableSummary(),
                  vastuReport: const [
                {
                  'label': 'stove',
                  'direction': 'NW',
                  'vastu_ok': false,
                  'rule_applied': true,
                  'allowed_directions': ['E']
                },
                {
                  'label': 'tub',
                  'direction': 'N',
                  'vastu_ok': false,
                  'rule_applied': false
                },
              ]))));
      await tester.pumpAndSettle();
      expect(find.text('Analysis Summary'), findsOneWidget);
      expect(
          find.text(
              'Consider repositioning the stove toward East if the layout allows.'),
          findsWidgets);
      expect(find.text('North-West'), findsOneWidget);
      expect(find.text('Recommended placement'), findsOneWidget);
      final why = find.text('Why?').first;
      await tester.ensureVisible(why);
      await tester.tap(why);
      await tester.pumpAndSettle();
      expect(
          find.textContaining('The selected rule allows East'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
