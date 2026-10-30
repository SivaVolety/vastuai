import 'package:flutter/material.dart';
import '../../models/results_analysis.dart';
import '../../theme/vastu_theme.dart';
import '../brand_components.dart';

/// Accepts structured content independently of its source. Phase 2 passes only
/// ResultsAnalysis.localNarrative; this UI never makes external AI requests.
class AnalysisSummaryCard extends StatelessWidget {
  const AnalysisSummaryCard({super.key, required this.content});
  final ResultNarrative content;
  @override
  Widget build(BuildContext context) => BrandedCard(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Analysis Summary', style: VastuType.title),
          const SizedBox(height: VastuSpace.sm),
          const Text('Based on your detected placements and selected rules',
              style: VastuType.caption),
          const SizedBox(height: VastuSpace.lg),
          Text(content.summary, style: VastuType.body),
        ],
      ));
}
