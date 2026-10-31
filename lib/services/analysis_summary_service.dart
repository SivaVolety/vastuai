import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ai_analysis_summary.dart';
import '../models/results_analysis.dart';
import 'api_config.dart';

/// Calls only the configured VasthuAI backend. Provider credentials/configuration
/// belong exclusively to that server; no image bytes or paths are submitted.
class AnalysisSummaryService {
  AnalysisSummaryService({http.Client? client, this.requestTimeout = timeout})
      : _client = client;
  final Duration requestTimeout;
  final http.Client? _client;
  static const timeout = Duration(seconds: 15);
  static final shared = AnalysisSummaryService();
  // Session-only and bounded; never persists analysis content to disk.
  final _requests = <String, Future<ResultNarrative?>>{};

  Future<ResultNarrative?> generate(ResultsAnalysis analysis) =>
      _cached(analysis, false);

  Future<ResultNarrative?> retry(ResultsAnalysis analysis) =>
      _cached(analysis, true);

  Future<ResultNarrative?> _cached(
      ResultsAnalysis analysis, bool refresh) async {
    try {
      final base = await ApiConfig.getBaseUrl();
      final key = jsonEncode([base, payload(analysis)]);
      if (refresh) {
        _requests.remove(key);
      }
      final existing = _requests[key];
      if (existing != null) {
        return await existing;
      }
      if (_requests.length >= 32) {
        _requests.remove(_requests.keys.first);
      }
      final request = _generate(analysis, base);
      _requests[key] = request;
      return await request;
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> payload(ResultsAnalysis analysis) => {
        'rule_set_name': analysis.ruleSetName,
        'model_version': const ['v1', 'v2'].contains(analysis.modelVersion)
            ? analysis.modelVersion
            : null,
        'vastu_report': analysis.findings
            .map((finding) => {
                  'label': finding.data['label']?.toString() ?? 'Unknown item',
                  'direction': const [
                    'N',
                    'NE',
                    'E',
                    'SE',
                    'S',
                    'SW',
                    'W',
                    'NW'
                  ].contains(finding.data['direction'])
                      ? finding.data['direction']
                      : null,
                  'rule_applied': finding.data['rule_applied'] != false,
                  'vastu_ok': finding.data['vastu_ok'] == true,
                  if (finding.allowedDirections != null)
                    'allowed_directions': finding.allowedDirections,
                })
            .toList(),
      };

  Future<ResultNarrative?> _generate(
      ResultsAnalysis analysis, String base) async {
    try {
      final uri = Uri.parse('$base/analysis-summary');
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode(payload(analysis));
      final response =
          await (_client?.post(uri, headers: headers, body: body) ??
                  http.post(uri, headers: headers, body: body))
              .timeout(requestTimeout);
      if (response.statusCode != 200) {
        return null;
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> ||
          decoded['status'] != 'ok' ||
          decoded['summary'] is! Map<String, dynamic>) {
        return null;
      }
      return AiAnalysisSummary.fromJson(
              decoded['summary'] as Map<String, dynamic>, analysis)
          .content;
    } catch (_) {
      // Enhancement-only: HTTP, timeout, older backend, invalid data all retain
      // the local summary. Never leak transport error details into the page.
      return null;
    }
  }
}
