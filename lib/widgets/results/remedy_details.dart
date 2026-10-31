import 'package:flutter/material.dart';
import '../../models/results_analysis.dart';
import '../../models/finding_remedy.dart';
import '../../theme/vastu_theme.dart';

class RemedyDetails extends StatelessWidget {
  const RemedyDetails(
      {super.key, required this.finding, required this.ruleSet});
  final ResultFinding finding;
  final String ruleSet;
  @override
  Widget build(BuildContext context) {
    final remedy = finding.remedy;
    if (remedy == null) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: VastuSpace.xl, runSpacing: VastuSpace.md, children: [
        _Placement('Current placement', directionName(finding.direction)),
        _Placement(
            'Recommended placement',
            remedy.allowedDirections.isEmpty
                ? 'Consult selected rule'
                : directionList(remedy.allowedDirections)),
      ]),
      const SizedBox(height: VastuSpace.lg),
      Text(remedy.action, style: VastuType.body),
      const SizedBox(height: VastuSpace.sm),
      Material(
          color: Colors.transparent,
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: VastuSpace.md),
            shape: const Border(),
            collapsedShape: const Border(),
            title: const Text('Why?', style: VastuType.section),
            children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text('${remedy.basis}\nRule set: $ruleSet',
                      style: VastuType.small))
            ],
          )),
    ]);
  }
}

class _Placement extends StatelessWidget {
  const _Placement(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: VastuType.caption),
        const SizedBox(height: VastuSpace.xs),
        Text(value, style: VastuType.section),
      ]));
}
