import 'package:flutter/material.dart';
import '../../models/results_analysis.dart';
import '../../theme/vastu_theme.dart';
import '../brand_components.dart';
import 'remedy_details.dart';
import 'result_status_pill.dart';

/// Canonical deterministic actions. AI narratives never replace these cards.
class RecommendationsCard extends StatelessWidget {
  const RecommendationsCard({super.key, required this.analysis});
  final ResultsAnalysis analysis;
  @override
  Widget build(BuildContext context) {
    final issues = analysis.withStatus(FindingStatus.attention);
    return BrandedCard(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Text('Recommended Actions', style: VastuType.title),
      const SizedBox(height: VastuSpace.sm),
      const Text('Practical options based on the selected rules',
          style: VastuType.caption),
      const SizedBox(height: VastuSpace.lg),
      if (issues.isEmpty)
        Text(
            analysis.evaluated == 0
                ? 'No recommendations can be made without evaluated placements.'
                : 'No corrective actions are needed under the selected rules.',
            style: VastuType.small),
      for (final entry in issues.asMap().entries)
        Padding(
            padding: EdgeInsets.only(top: entry.key == 0 ? 0 : VastuSpace.lg),
            child: Container(
                key: ValueKey('action-${entry.key}'),
                padding: const EdgeInsets.all(VastuSpace.lg),
                decoration: BoxDecoration(
                    color: VastuColors.surface,
                    border: Border.all(color: VastuColors.border),
                    borderRadius: BorderRadius.circular(VastuRadius.control)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                          spacing: VastuSpace.md,
                          runSpacing: VastuSpace.sm,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(entry.value.label, style: VastuType.section),
                            const ResultStatusPill(FindingStatus.attention),
                          ]),
                      const SizedBox(height: VastuSpace.lg),
                      RemedyDetails(
                          finding: entry.value, ruleSet: analysis.ruleSetName),
                    ]))),
    ]));
  }
}
