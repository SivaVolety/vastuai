import 'package:flutter/material.dart';
import '../../models/results_analysis.dart';
import '../../models/finding_remedy.dart';
import '../../theme/vastu_theme.dart';
import '../brand_components.dart';

/// Concise issue index. Full guidance belongs only in Recommended Actions.
class ResultRemediesCard extends StatelessWidget {
  const ResultRemediesCard({super.key, required this.analysis});
  final ResultsAnalysis analysis;
  @override
  Widget build(BuildContext context) {
    final items = analysis.withStatus(FindingStatus.attention);
    return BrandedCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Areas to Review', style: VastuType.title),
      const SizedBox(height: VastuSpace.lg),
      if (items.isEmpty)
        Text(
            analysis.evaluated == 0
                ? 'No issues can be established without evaluated findings.'
                : 'No placements need attention under the selected rules.',
            style: VastuType.small),
      for (final item in items.take(4))
        Padding(
            padding: const EdgeInsets.only(bottom: VastuSpace.lg),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${item.label} · ${directionName(item.direction)}',
                  style: VastuType.section),
              const SizedBox(height: VastuSpace.sm),
              Text(
                  item.allowedDirections?.isNotEmpty == true
                      ? 'Outside the allowed ${directionList(item.allowedDirections!)} zones.'
                      : 'This placement does not match the selected rule.',
                  style: VastuType.small),
            ])),
      if (items.length > 4)
        Text(
            '${items.length - 4} more placements are listed in Recommended Actions.',
            style: VastuType.caption),
    ]));
  }
}
