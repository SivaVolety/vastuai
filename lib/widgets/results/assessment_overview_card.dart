import 'package:flutter/material.dart';
import '../../models/results_analysis.dart';
import '../../theme/vastu_theme.dart';
import '../brand_components.dart';

class AssessmentOverviewCard extends StatelessWidget {
  const AssessmentOverviewCard({super.key, required this.analysis});
  final ResultsAnalysis analysis;
  @override
  Widget build(BuildContext context) {
    final color = analysis.evaluated == 0
        ? VastuColors.muted
        : analysis.attention > 0
            ? VastuColors.warning
            : VastuColors.success;
    return BrandedCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionLabel('Overall Vastu Assessment'),
      const SizedBox(height: VastuSpace.sm),
      Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: VastuSpace.md,
          runSpacing: VastuSpace.sm,
          children: [
            Icon(
                analysis.evaluated == 0
                    ? Icons.info_outline_rounded
                    : analysis.attention > 0
                        ? Icons.flag_outlined
                        : Icons.check_circle_outline_rounded,
                color: color,
                size: 30),
            Text(analysis.verdict,
                style: VastuType.title.copyWith(color: color)),
          ]),
      const SizedBox(height: VastuSpace.md),
      Text(
          '${analysis.favorable} of ${analysis.evaluated} evaluated placements follow the selected rules.',
          style: VastuType.body),
      const SizedBox(height: VastuSpace.xl),
      LayoutBuilder(builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 4 : 2;
        final width =
            (constraints.maxWidth - (columns - 1) * VastuSpace.md) / columns;
        return Wrap(
            spacing: VastuSpace.md,
            runSpacing: VastuSpace.md,
            children: [
              _metric(width, analysis.findings.length, 'Total Detected',
                  VastuColors.forest),
              _metric(
                  width, analysis.favorable, 'Favorable', VastuColors.success),
              _metric(width, analysis.attention, 'Needs Attention',
                  VastuColors.warning),
              _metric(width, analysis.notEvaluated, 'Not Evaluated',
                  VastuColors.muted),
            ]);
      }),
      const SizedBox(height: VastuSpace.md),
      const Text(
          'Assessment applies only to placements covered by the selected rules. No overall score is calculated.',
          style: VastuType.caption),
    ]));
  }

  Widget _metric(double width, int count, String label, Color color) =>
      Semantics(
          label: '$count $label',
          excludeSemantics: true,
          child: Container(
            width: width,
            padding: const EdgeInsets.all(VastuSpace.md),
            decoration: BoxDecoration(
                color: VastuColors.canvas,
                borderRadius: BorderRadius.circular(VastuRadius.control)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$count', style: VastuType.title.copyWith(color: color)),
              const SizedBox(height: VastuSpace.xs),
              Text(label, style: VastuType.caption),
            ]),
          ));
}
