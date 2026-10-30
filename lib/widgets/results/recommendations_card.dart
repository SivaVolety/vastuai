import 'package:flutter/material.dart';
import '../../models/results_analysis.dart';
import '../../theme/vastu_theme.dart';
import '../brand_components.dart';

class RecommendationsCard extends StatelessWidget {
  const RecommendationsCard(
      {super.key, required this.content, required this.evaluated});
  final ResultNarrative content;
  final int evaluated;
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
          for (int i = 0; i < content.recommendations.length; i++)
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
                    child: Text(content.recommendations[i],
                        style: VastuType.small)),
              ]),
            ),
          if (content.recommendations.isNotEmpty) ...[
            const SizedBox(height: VastuSpace.lg),
            const Text(
                'Allowed directions are not included in this report. Consult the selected rule set for direction-specific guidance.',
                style: VastuType.caption),
          ],
        ],
      ));
}
