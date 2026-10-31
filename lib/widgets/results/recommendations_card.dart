import 'package:flutter/material.dart';
import '../../models/results_analysis.dart';
import '../../theme/vastu_theme.dart';
import '../brand_components.dart';

class RecommendationsCard extends StatelessWidget {
  const RecommendationsCard(
      {super.key,
      required this.content,
      required this.evaluated,
      this.analysis});
  final ResultNarrative content;
  final int evaluated;
  final ResultsAnalysis? analysis;
  @override
  Widget build(BuildContext context) => BrandedCard(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Recommendations', style: VastuType.title),
          const SizedBox(height: VastuSpace.sm),
          const Text('Review points from the applied rules',
              style: VastuType.caption),
          const SizedBox(height: VastuSpace.lg),
          if (content.recommendations.isEmpty)
            Text(
                evaluated == 0
                    ? 'No recommendations can be made without evaluated placements.'
                    : 'No placements need attention under the selected rules.',
                style: VastuType.small),
          for (int i = 0;
              i <
                  (analysis?.attention ?? content.recommendations.length)
                      .clamp(0, 3);
              i++)
            Padding(
              padding: EdgeInsets.only(
                  bottom: i == content.recommendations.length - 1
                      ? 0
                      : VastuSpace.lg),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: VastuColors.peach, shape: BoxShape.circle),
                    child: Text('${i + 1}',
                        style: VastuType.section
                            .copyWith(color: VastuColors.warning))),
                const SizedBox(width: VastuSpace.md),
                Expanded(
                    child: Text(
                        analysis == null
                            ? content.recommendations[i]
                            : analysis!
                                .withStatus(FindingStatus.attention)[i]
                                .remedy!
                                .action,
                        style: VastuType.small)),
              ]),
            ),
          if (content.isAiGenerated && content.recommendations.isNotEmpty)
            Material(
                color: Colors.transparent,
                child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title:
                        const Text('AI explanation', style: VastuType.section),
                    children: [
                      for (final text in content.recommendations)
                        Padding(
                            padding:
                                const EdgeInsets.only(bottom: VastuSpace.md),
                            child: Text(text, style: VastuType.small))
                    ])),
          if (content.recommendations.isNotEmpty) ...[
            const SizedBox(height: VastuSpace.lg),
            const Text(
                'Use these review points only where practical. The selected rules determine the suggested placements.',
                style: VastuType.caption),
          ],
        ],
      ));
}
