import 'package:flutter/material.dart';
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

class ResultPage extends StatelessWidget {
  final String imageUrl;
  final List<Map<String, dynamic>> vastuReport;
  final String? ruleSetName;
  final bool showConfidence;
  final String? localImagePath;
  final String? modelVersion;

  const ResultPage({
    super.key,
    required this.imageUrl,
    required this.vastuReport,
    this.ruleSetName,
    this.showConfidence = false,
    this.localImagePath,
    this.modelVersion,
  });

  @override
  Widget build(BuildContext context) {
    final analysis = ResultsAnalysis(
        report: vastuReport,
        ruleSetName: ruleSetName,
        modelVersion: modelVersion);
    final narrative = analysis.localNarrative;
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
          final summary = AnalysisSummaryCard(content: narrative);
          final plan = AnnotatedPlanCard(
              imageUrl: imageUrl, localImagePath: localImagePath);
          final strengths = ResultInsightsCard(
              title: 'Key Strengths',
              items: narrative.strengths,
              emptyText: analysis.evaluated == 0
                  ? 'No favorable placements can be identified without evaluated findings.'
                  : 'No evaluated placements are favorable under the selected rules.',
              icon: Icons.check_circle_outline_rounded,
              positive: true);
          final improvements = ResultInsightsCard(
              title: 'Areas for Improvement',
              items: narrative.priorities,
              emptyText: analysis.evaluated == 0
                  ? 'No issues can be established without evaluated findings.'
                  : 'No placements need attention under the selected rules.',
              icon: Icons.flag_outlined);
          final recommendations = RecommendationsCard(
              content: narrative, evaluated: analysis.evaluated);
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
                                child: _SectionStack(children: [
                                  overview,
                                  summary,
                                  strengths,
                                  improvements
                                ])),
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
                    const SizedBox(height: VastuSpace.xl),
                    DetailedFindings(
                        analysis: analysis, showConfidence: showConfidence),
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
