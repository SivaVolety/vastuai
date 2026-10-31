import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/analysis_summary_service.dart';
import '../models/results_analysis.dart';
import '../theme/vastu_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/results/results_header.dart';
import '../widgets/results/assessment_overview_card.dart';
import '../widgets/results/analysis_summary_card.dart';
import '../widgets/results/annotated_plan_card.dart';
import '../widgets/results/result_insights_card.dart';
import '../widgets/results/recommendations_card.dart';
import '../widgets/results/detailed_findings.dart';
import '../widgets/results/result_remedies_card.dart';

class ResultPage extends StatefulWidget {
  final String imageUrl;
  final List<Map<String, dynamic>> vastuReport;
  final String? ruleSetName;
  final bool showConfidence;
  final String? localImagePath;
  final String? modelVersion;
  final AnalysisSummaryService? summaryService;

  const ResultPage({
    super.key,
    required this.imageUrl,
    required this.vastuReport,
    this.ruleSetName,
    this.showConfidence = false,
    this.localImagePath,
    this.modelVersion,
    this.summaryService,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late ResultsAnalysis _analysis;
  late String _fingerprint;
  late AnalysisSummaryService _service;
  ResultNarrative? _enhanced;
  bool _loading = true;
  int _request = 0;

  ResultsAnalysis _fromWidget() => ResultsAnalysis(
      report: widget.vastuReport,
      ruleSetName: widget.ruleSetName,
      modelVersion: widget.modelVersion);

  @override
  void initState() {
    super.initState();
    _service = widget.summaryService ?? AnalysisSummaryService.shared;
    _analysis = _fromWidget();
    _fingerprint = jsonEncode(AnalysisSummaryService.payload(_analysis));
    _loadSummary();
  }

  @override
  void didUpdateWidget(covariant ResultPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _fromWidget();
    final fingerprint = jsonEncode(AnalysisSummaryService.payload(next));
    if (fingerprint != _fingerprint) {
      _analysis = next;
      _fingerprint = fingerprint;
      _enhanced = null;
      _loading = true;
      _loadSummary();
    }
  }

  Future<void> _loadSummary({bool retry = false}) async {
    final request = ++_request;
    ResultNarrative? content;
    try {
      content = await (retry
          ? _service.retry(_analysis)
          : _service.generate(_analysis));
    } catch (_) {
      content = null;
    }
    if (!mounted || request != _request) return;
    setState(() {
      _enhanced = content;
      _loading = false;
    });
  }

  void _retry() {
    setState(() => _loading = true);
    _loadSummary(retry: true);
  }

  @override
  void dispose() {
    _request++;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analysis = _analysis;
    final narrative = _enhanced ?? analysis.localNarrative;
    return AppScaffold(
        title: 'Analysis Results',
        body: LayoutBuilder(builder: (context, constraints) {
          final desktop = constraints.maxWidth >= VastuLayout.desktop;
          final inset = desktop
              ? (constraints.maxWidth >= 1280
                  ? VastuSpace.page
                  : VastuSpace.xxl)
              : VastuSpace.lg;
          final overview = AssessmentOverviewCard(analysis: analysis);
          final summary = AnalysisSummaryCard(
              content: narrative, loading: _loading, onRetry: _retry);
          final plan = AnnotatedPlanCard(
              imageUrl: widget.imageUrl, localImagePath: widget.localImagePath);
          final strengths = ResultInsightsCard(
              title: 'Key Strengths',
              items: narrative.strengths,
              emptyText: analysis.evaluated == 0
                  ? 'No favorable placements can be identified without evaluated findings.'
                  : 'No evaluated placements are favorable under the selected rules.',
              icon: Icons.check_circle_outline_rounded,
              positive: true);
          final improvements = ResultRemediesCard(analysis: analysis);
          final recommendations = RecommendationsCard(
              content: narrative,
              evaluated: analysis.evaluated,
              analysis: analysis);
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(inset, 0, inset, VastuSpace.section),
            child: Center(
                child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: VastuLayout.contentMax),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResultsHeader(
                        analysis: analysis,
                        desktop: desktop,
                        onBack: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacementNamed(context, '/');
                          }
                        }),
                    if (desktop)
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 5,
                                child: _SectionStack(
                                    children: [overview, summary, strengths])),
                            const SizedBox(width: VastuSpace.xl),
                            Expanded(
                                flex: 6,
                                child: _SectionStack(
                                    children: [plan, recommendations])),
                          ])
                    else
                      _SectionStack(children: [
                        overview,
                        summary,
                        plan,
                        strengths,
                        improvements,
                        recommendations
                      ]),
                    if (desktop) ...[
                      const SizedBox(height: VastuSpace.xl),
                      improvements
                    ],
                    const SizedBox(height: VastuSpace.xl),
                    DetailedFindings(
                        analysis: analysis,
                        showConfidence: widget.showConfidence),
                  ]),
            )),
          );
        }));
  }
}

class _SectionStack extends StatelessWidget {
  const _SectionStack({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Column(children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: VastuSpace.xl),
          children[i],
        ],
      ]);
}
