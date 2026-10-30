import 'package:flutter_test/flutter_test.dart';
import 'package:vastuai/models/results_analysis.dart';

void main() {
  test('all favorable has factual counts and no fake score', () {
    final a = ResultsAnalysis(report: [
      {
        'label': 'bed',
        'direction': 'NE',
        'vastu_ok': true,
        'rule_applied': true
      },
      {'label': 'sink', 'direction': 'N', 'vastu_ok': true},
    ]);
    expect(a.verdict, 'Favorable');
    expect(a.favorable, 2);
    expect(a.evaluated, 2);
    expect(a.localNarrative.summary, contains('2 evaluated placements'));
    expect(a.localNarrative.recommendations, isEmpty);
  });
  test('mixed findings retain explicit neutral and legacy semantics', () {
    final a = ResultsAnalysis(report: [
      {'label': 'bed', 'vastu_ok': true},
      {'label': 'stove', 'direction': 'SW', 'vastu_ok': false},
      {'label': 'tub', 'vastu_ok': false, 'rule_applied': false},
      {'label': 'door', 'vastu_ok': true, 'rule_applied': false},
    ], ruleSetName: 'My custom rules');
    expect(a.verdict, 'Needs Attention');
    expect(a.evaluated, 2);
    expect(a.favorable, 1);
    expect(a.attention, 1);
    expect(a.notEvaluated, 2);
    expect(a.localNarrative.summary, contains('stove'));
    expect(a.localNarrative.summary, isNot(contains('tub')));
    expect(a.localNarrative.recommendations.single, contains('Stove — SW'));
    expect(
        a.localNarrative.recommendations.single, isNot(contains('South-East')));
    expect(a.localNarrative.strengths.single, startsWith('Bed'));
  });
  test('zero evaluated placements and zero detections are insufficient', () {
    for (final report in <List<Map<String, dynamic>>>[
      [],
      [
        {'label': 'kitchen_bar', 'rule_applied': false, 'vastu_ok': false}
      ]
    ]) {
      final a = ResultsAnalysis(
          report: report, ruleSetName: 'Feng Shui Compass Preset');
      expect(a.verdict, 'Insufficient Information');
      expect(a.attention, 0);
      expect(a.localNarrative.recommendations, isEmpty);
      expect(a.localNarrative.strengths, isEmpty);
    }
  });
  test(
      'summary content refers only to actual detections and caps initial lists',
      () {
    final a = ResultsAnalysis(
        report: List.generate(
            8,
            (i) => {
                  'label': 'custom_item_$i',
                  'direction': 'W',
                  'vastu_ok': i < 2
                }));
    expect(a.localNarrative.strengths, hasLength(2));
    expect(a.localNarrative.priorities, hasLength(4));
    expect(a.localNarrative.recommendations, hasLength(3));
    for (final text in [
      ...a.localNarrative.strengths,
      ...a.localNarrative.priorities,
      ...a.localNarrative.recommendations
    ]) {
      expect(
          a.findings.any((f) => text.startsWith('${f.label} — ${f.direction}')),
          isTrue);
      expect(text, isNot(contains('energy')));
    }
  });
}
