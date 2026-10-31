import 'results_analysis.dart';

/// Strict narrative-only DTO. Deterministic status/count fields are never read
/// from this response and cannot be replaced through this model.
class AiAnalysisSummary {
  const AiAnalysisSummary(this.content);
  final ResultNarrative content;

  factory AiAnalysisSummary.fromJson(
      Map<String, dynamic> json, ResultsAnalysis truth) {
    const keys = {
      'headline',
      'summary',
      'strengths',
      'priorities',
      'recommendations',
      'disclaimer'
    };
    if (json.length != keys.length || !json.keys.every(keys.contains)) {
      throw const FormatException('Invalid summary fields');
    }
    String text(String key, int max) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty || value.length > max) {
        throw const FormatException('Invalid summary text');
      }
      return value;
    }

    List<String> items(String key, int max) {
      final value = json[key];
      if (value is! List ||
          value.length > max ||
          value
              .any((v) => v is! String || v.trim().isEmpty || v.length > 300)) {
        throw const FormatException('Invalid summary items');
      }
      return List<String>.unmodifiable(value.cast<String>());
    }

    final headline = text('headline', 100);
    // The backend constrains the headline to the deterministic verdict. Keep a
    // second check here so an incompatible response simply retains fallback.
    if (headline != truth.verdict) {
      throw const FormatException('Conflicting summary');
    }
    final strengths = items('strengths', 4),
        priorities = items('priorities', 4),
        recommendations = items('recommendations', 3);
    if ((truth.favorable > 0) != strengths.isNotEmpty ||
        (truth.attention > 0) != priorities.isNotEmpty ||
        (truth.attention > 0) != recommendations.isNotEmpty) {
      throw const FormatException('Conflicting summary coverage');
    }
    return AiAnalysisSummary(ResultNarrative(
      headline: headline,
      summary: text('summary', 1000),
      strengths: strengths,
      priorities: priorities,
      recommendations: recommendations,
      disclaimer: text('disclaimer', 180),
      isAiGenerated: true,
    ));
  }
}
