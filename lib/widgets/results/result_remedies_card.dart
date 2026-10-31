import 'package:flutter/material.dart';
import '../../models/results_analysis.dart';
import '../../theme/vastu_theme.dart';
import '../brand_components.dart';
import 'remedy_details.dart';
import 'result_status_pill.dart';

class ResultRemediesCard extends StatelessWidget {
  const ResultRemediesCard({super.key, required this.analysis});
  final ResultsAnalysis analysis;
  @override
  Widget build(BuildContext context) {
    final items = analysis.withStatus(FindingStatus.attention);
    return BrandedCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Areas for Improvement', style: VastuType.title),
      const SizedBox(height: VastuSpace.lg),
      if (items.isEmpty)
        Text(
            analysis.evaluated == 0
                ? 'No issues can be established without evaluated findings.'
                : 'No placements need attention under the selected rules.',
            style: VastuType.small),
      LayoutBuilder(builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 2 : 1;
        final width =
            (constraints.maxWidth - (columns - 1) * VastuSpace.lg) / columns;
        return Wrap(
            spacing: VastuSpace.lg,
            runSpacing: VastuSpace.lg,
            children: [
              for (final item in items.take(4))
                SizedBox(
                    width: width,
                    child: Container(
                      padding: const EdgeInsets.all(VastuSpace.lg),
                      decoration: BoxDecoration(
                          color: VastuColors.peach,
                          borderRadius:
                              BorderRadius.circular(VastuRadius.control)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                                spacing: VastuSpace.md,
                                runSpacing: VastuSpace.sm,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(item.label, style: VastuType.section),
                                  const ResultStatusPill(
                                      FindingStatus.attention)
                                ]),
                            const SizedBox(height: VastuSpace.lg),
                            RemedyDetails(
                                finding: item, ruleSet: analysis.ruleSetName),
                          ]),
                    )),
            ]);
      }),
      const SizedBox(height: VastuSpace.lg),
      if (items.length > 4)
        Text(
            'Review all ${items.length} placements in Detailed Analysis below.',
            style: VastuType.caption),
    ]));
  }
}
