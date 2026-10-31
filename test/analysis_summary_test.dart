import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vastuai/models/results_analysis.dart';
import 'package:vastuai/pages/result_page.dart';
import 'package:vastuai/providers/rule_set_provider.dart';
import 'package:vastuai/services/analysis_summary_service.dart';
import 'package:vastuai/widgets/results/assessment_overview_card.dart';

const report = [
  {
    'label': 'bed',
    'direction': 'N',
    'rule_applied': true,
    'vastu_ok': true,
    'confidence': .9
  },
  {
    'label': 'stove',
    'direction': 'SW',
    'rule_applied': true,
    'vastu_ok': false
  },
  {'label': 'tub', 'direction': 'E', 'rule_applied': false, 'vastu_ok': false},
];
Map<String, dynamic> success() => {
      'status': 'ok',
      'summary': {
        'headline': 'Needs Attention',
        'summary': 'Enhanced homeowner explanation from actual findings.',
        'strengths': ['Bed in N follows the selected rule.'],
        'priorities': ['Stove in SW needs attention under the selected rules.'],
        'recommendations': [
          'Review the stove placement according to the selected rule.'
        ],
        'disclaimer':
            'AI-generated explanation based on deterministic analysis.',
      }
    };

class ControlledService extends AnalysisSummaryService {
  final requests = <Completer<ResultNarrative?>>[];
  @override
  Future<ResultNarrative?> generate(ResultsAnalysis analysis) {
    final next = Completer<ResultNarrative?>();
    requests.add(next);
    return next.future;
  }
}

Widget screen(AnalysisSummaryService service, {String version = 'v1'}) =>
    ChangeNotifierProvider(
        create: (_) => RuleSetProvider(),
        child: MaterialApp(
            home: ResultPage(
                imageUrl: '',
                vastuReport: report,
                modelVersion: version,
                summaryService: service)));

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

  test('service sends only normalized analysis to configured backend override',
      () async {
    SharedPreferences.setMockInitialValues(
        {'api_base_url': 'http://custom.local:8123'});
    final client = MockClient((request) async {
      expect(
          request.url.toString(), 'http://custom.local:8123/analysis-summary');
      expect(request.method, 'POST');
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body.keys,
          unorderedEquals(['rule_set_name', 'model_version', 'vastu_report']));
      final rows = body['vastu_report'] as List;
      expect(rows.last['rule_applied'], false);
      expect(rows.first.containsKey('confidence'), false);
      expect(request.headers.containsKey('authorization'), false);
      return http.Response(jsonEncode(success()), 200);
    });
    final result = await AnalysisSummaryService(client: client)
        .generate(ResultsAnalysis(report: report, modelVersion: 'v2'));
    expect(result!.isAiGenerated, true);
  });

  for (final reply in [
    http.Response('broken', 200),
    http.Response('{}', 500),
    http.Response(
        '{"status":"unavailable","summary":null,"reason":"timeout"}', 200),
    http.Response(
        jsonEncode({
          'status': 'ok',
          'summary': {...success()['summary'] as Map, 'headline': 'Favorable'}
        }),
        200),
    http.Response(
        jsonEncode({
          'status': 'ok',
          'summary': {...success()['summary'] as Map, 'favorable': 99}
        }),
        200)
  ]) {
    test(
        'invalid, failed or conflicting summary safely falls back ${reply.body}',
        () async {
      final service =
          AnalysisSummaryService(client: MockClient((_) async => reply));
      expect(await service.generate(ResultsAnalysis(report: report)), isNull);
    });
  }
  test('network failure and timeout safely retain fallback', () async {
    final service = AnalysisSummaryService(
        client: MockClient((_) => throw Exception('private detail')));
    expect(await service.generate(ResultsAnalysis(report: report)), isNull);
    final slow = AnalysisSummaryService(
        requestTimeout: const Duration(milliseconds: 1),
        client: MockClient((_) => Completer<http.Response>().future));
    expect(await slow.generate(ResultsAnalysis(report: report)), isNull);
  });

  test(
      'session cache deduplicates in-flight and completed requests; retry bypasses it',
      () async {
    var calls = 0;
    final pending = Completer<http.Response>();
    final service = AnalysisSummaryService(client: MockClient((_) {
      calls++;
      return calls == 1
          ? pending.future
          : Future.value(http.Response(jsonEncode(success()), 200));
    }));
    final analysis = ResultsAnalysis(report: report);
    final first = service.generate(analysis);
    final second = service.generate(ResultsAnalysis(report: report));

    await Future<void>.delayed(Duration.zero);
    expect(calls, 1);
    pending.complete(http.Response(jsonEncode(success()), 200));
    expect((await first)!.isAiGenerated, true);
    expect((await second)!.isAiGenerated, true);
    expect((await service.generate(analysis))!.isAiGenerated, true);
    expect(calls, 1);
    expect((await service.retry(analysis))!.isAiGenerated, true);
    expect(calls, 2);
    SharedPreferences.setMockInitialValues(
        {'api_base_url': 'http://different-backend.local'});
    expect((await service.generate(analysis))!.isAiGenerated, true);
    expect(calls, 3);
  });

  testWidgets(
      'local summary appears immediately, loading does not block and rebuilds do not duplicate',
      (tester) async {
    final service = ControlledService();
    Widget page() => screen(service);
    await tester.pumpWidget(page());
    await tester.pump();
    expect(find.text('Analysis Summary'), findsOneWidget);
    expect(find.textContaining('Your plan has 2 evaluated placements.'),
        findsOneWidget);
    expect(find.text('Generating enhanced summary…'), findsOneWidget);
    expect(find.text('Annotated Floor Plan'), findsOneWidget);
    expect(find.text('Detailed Analysis'), findsOneWidget);
    await tester.pumpWidget(page());
    await tester.pump();
    expect(service.requests, hasLength(1));
    service.requests.single.complete(null);
    await tester.pumpAndSettle();
    expect(find.text('Analysis Summary'), findsOneWidget);
    expect(find.text('Generating enhanced summary…'), findsNothing);
  });

  for (final version in ['v1', 'v2']) {
    testWidgets('AI success replaces narratives only for $version',
        (tester) async {
      final pending = Completer<http.Response>();
      var requests = 0;
      final service = AnalysisSummaryService(client: MockClient((_) {
        requests++;
        return pending.future;
      }));
      await tester.pumpWidget(screen(service, version: version));
      await tester.pump();
      expect(find.text('Analysis Summary'), findsOneWidget);
      pending.complete(http.Response(jsonEncode(success()), 200));
      await tester.pumpAndSettle();
      expect(find.text('AI-Powered Summary'), findsOneWidget);
      expect(find.text('Enhanced homeowner explanation from actual findings.'),
          findsOneWidget);
      final truth = tester
          .widget<AssessmentOverviewCard>(find.byType(AssessmentOverviewCard))
          .analysis;
      expect(truth.verdict, 'Needs Attention');
      expect(truth.favorable, 1);
      expect(truth.attention, 1);
      expect(truth.notEvaluated, 1);
      expect(truth.findings.last.status, FindingStatus.notEvaluated);
      expect(
          find.text(
              'Model: ${version == 'v1' ? 'Stable V1' : 'Experimental V2'}'),
          findsOneWidget);
      expect(requests, 1);
    });
  }

  testWidgets('failure keeps fallback, explicit retry succeeds',
      (tester) async {
    var calls = 0;
    final service = AnalysisSummaryService(client: MockClient((_) async {
      calls++;
      return calls == 1
          ? http.Response('{}', 503)
          : http.Response(jsonEncode(success()), 200);
    }));
    await tester.pumpWidget(screen(service));
    await tester.pumpAndSettle();
    expect(find.text('Analysis Summary'), findsOneWidget);
    final retry = find.text('Retry summary');
    await tester.ensureVisible(retry);
    await tester.tap(retry);
    await tester.pumpAndSettle();
    expect(find.text('AI-Powered Summary'), findsOneWidget);
    expect(calls, 2);
  });

  testWidgets(
      'navigation works while summary is pending and late result is ignored',
      (tester) async {
    final service = ControlledService();
    await tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => RuleSetProvider(),
        child: MaterialApp(
            home: Builder(
                builder: (context) => Scaffold(
                    body: TextButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                                builder: (_) => ResultPage(
                                    imageUrl: '',
                                    vastuReport: report,
                                    summaryService: service))),
                        child: const Text('Open results')))))));
    await tester.tap(find.text('Open results'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back to Upload'));
    await tester.pumpAndSettle();
    service.requests.single.complete(null);
    await tester.pump();
    expect(find.text('Open results'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
