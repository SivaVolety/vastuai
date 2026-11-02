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
          final overview = AssessmentOverviewCard(
              key: const ValueKey('results-assessment'), analysis: analysis);
          final summary = AnalysisSummaryCard(
              key: const ValueKey('results-summary'),
              content: narrative,
              loading: _loading,
              onRetry: _retry);
          final plan = AnnotatedPlanCard(
              key: const ValueKey('results-plan'),
              imageUrl: widget.imageUrl,
              localImagePath: widget.localImagePath);
          final strengths = ResultInsightsCard(
              key: const ValueKey('results-strengths'),
              title: 'Key Strengths',
              items: analysis.localNarrative.strengths,
              emptyText: analysis.evaluated == 0
                  ? 'No favorable placements can be identified without evaluated findings.'
                  : 'No evaluated placements are favorable under the selected rules.',
              icon: Icons.check_circle_outline_rounded,
              positive: true);
          final improvements = ResultRemediesCard(
              key: const ValueKey('results-review'), analysis: analysis);
          final recommendations = RecommendationsCard(
              key: const ValueKey('results-actions'), analysis: analysis);
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
                    overview,
                    const SizedBox(height: VastuSpace.xl),
                    _ResultsRow(
                        key: const ValueKey('results-row-b'),
                        columns: desktop,
                        leftFlex: 6,
                        rightFlex: 4,
                        left: summary,
                        right: plan),
                    const SizedBox(height: VastuSpace.xl),
                    _ResultsRow(
                        key: const ValueKey('results-row-c'),
                        columns: desktop,
                        left: strengths,
                        right: improvements),
                    const SizedBox(height: VastuSpace.xl),
                    recommendations,
                    const SizedBox(height: VastuSpace.xl),
                    DetailedFindings(
                        key: const ValueKey('results-findings'),
                        analysis: analysis,
                        showConfidence: widget.showConfidence),
                  ]),
            )),
          );
        }));
  }
}

/// Explicit row boundaries: no independent vertical stacks or masonry reflow.
class _ResultsRow extends StatelessWidget {
  const _ResultsRow(
      {super.key,
      required this.columns,
      required this.left,
      required this.right,
      this.leftFlex = 1,
      this.rightFlex = 1});
  final bool columns;
  final Widget left, right;
  final int leftFlex, rightFlex;
  @override
  Widget build(BuildContext context) => columns
      ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: leftFlex, child: left),
          const SizedBox(width: VastuSpace.xl),
          Expanded(flex: rightFlex, child: right),
        ])
      : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          left,
          const SizedBox(height: VastuSpace.xl),
          right,
        ]);
}
