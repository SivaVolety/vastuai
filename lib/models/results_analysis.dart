import 'detector_model.dart';

/// Presentation of the existing response semantics; never computes a score.
enum FindingStatus {
  favorable('Favorable'),
  attention('Needs Attention'),
  notEvaluated('Not Evaluated');

  const FindingStatus(this.label);
  final String label;
}

class ResultFinding {
  ResultFinding(Map<String, dynamic> data)
      : data = Map<String, dynamic>.unmodifiable(data);
  final Map<String, dynamic> data;
  String get label => displayLabel(data['label']);
  String get direction => data['direction']?.toString() ?? 'Not reported';
  num? get confidence =>
      data['confidence'] is num ? data['confidence'] as num : null;

  // Preserve legacy reports without rule_applied; explicit false is neutral.
  FindingStatus get status => data['rule_applied'] == false
      ? FindingStatus.notEvaluated
      : data['vastu_ok'] == true
          ? FindingStatus.favorable
          : FindingStatus.attention;

  String explanation(String ruleSet) => switch (status) {
        FindingStatus.favorable =>
          'This placement follows the selected rule in $ruleSet.',
        FindingStatus.attention =>
          'This placement does not follow the selected rule in $ruleSet.',
        FindingStatus.notEvaluated =>
          'This item is not covered by $ruleSet. It is not counted as a failed placement.',
      };

  static String displayLabel(Object? value) => (value?.toString() ??
          'Unknown item')
      .split('_')
      .map((word) =>
          word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}

/// Replaceable structured content for the summary UI. Phase 2 uses only the
/// local factory below; there are no external AI calls or generated claims.
class ResultNarrative {
  const ResultNarrative(
      {required this.headline,
      required this.summary,
      required this.strengths,
      required this.priorities,
      required this.recommendations});
  final String headline, summary;
  final List<String> strengths, priorities, recommendations;
}

class ResultsAnalysis {
  ResultsAnalysis(
      {required List<Map<String, dynamic>> report,
      String? ruleSetName,
      this.modelVersion})
      : findings = List.unmodifiable(report.map(ResultFinding.new)),
        ruleSetName = ruleSetName ?? 'Vastu Presets';
  final List<ResultFinding> findings;
  final String ruleSetName;
  final String? modelVersion;
  String get modelLabel =>
      DetectorModel.fromVersion(modelVersion)?.label ??
      'Not reported by backend';
  bool get experimental => modelVersion == 'v2';
  List<ResultFinding> withStatus(FindingStatus status) =>
      findings.where((finding) => finding.status == status).toList();
  int get favorable => withStatus(FindingStatus.favorable).length;
  int get attention => withStatus(FindingStatus.attention).length;
  int get notEvaluated => withStatus(FindingStatus.notEvaluated).length;
  int get evaluated => favorable + attention;
  String get verdict => evaluated == 0
      ? 'Insufficient Information'
      : attention > 0
          ? 'Needs Attention'
          : 'Favorable';

  ResultNarrative get localNarrative {
    List<ResultFinding> unique(FindingStatus status, int limit) {
      final seen = <String>{};
      return withStatus(status)
          .where((f) => seen.add('${f.label}|${f.direction}'))
          .take(limit)
          .toList();
    }

    final strengths = unique(FindingStatus.favorable, 4);
    final priorities = unique(FindingStatus.attention, 4);
    final reviewNames =
        priorities.map((f) => f.label.toLowerCase()).toSet().join(', ');
    return ResultNarrative(
      headline: verdict,
      summary: evaluated == 0
          ? findings.isEmpty
              ? 'No items were detected. There is not enough information to assess this plan.'
              : 'None of the ${findings.length} detected placements were evaluated by the selected rules. There is not enough information for a verdict.'
          : 'Your plan has $evaluated evaluated placements. $favorable follow the selected rules, while $attention need attention.'
              '${priorities.isEmpty ? '' : ' The placements to review include $reviewNames.'}'
              '${notEvaluated == 0 ? '' : ' $notEvaluated detected placements are not evaluated.'}',
      strengths: strengths
          .map((f) => '${f.label} — ${f.direction}: placement is favorable.')
          .toList(),
      priorities: priorities
          .map((f) => '${f.label} — ${f.direction}: placement needs attention.')
          .toList(),
      // The current response does not provide allowed directions. Never infer
      // them from defaults: this analysis might use a custom or Feng Shui set.
      recommendations: priorities
          .take(3)
          .map((f) =>
              '${f.label} — ${f.direction}: review this placement according to the selected rule.')
          .toList(),
    );
  }
}
