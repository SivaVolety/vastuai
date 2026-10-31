import 'package:flutter/material.dart';
import '../../models/results_analysis.dart';
import '../../theme/vastu_theme.dart';
import '../brand_components.dart';
import 'result_status_pill.dart';
import 'remedy_details.dart';
import '../../models/finding_remedy.dart';

class DetailedFindings extends StatefulWidget {
  const DetailedFindings(
      {super.key, required this.analysis, required this.showConfidence});
  final ResultsAnalysis analysis;
  final bool showConfidence;
  @override
  State<DetailedFindings> createState() => _DetailedFindingsState();
}

class _DetailedFindingsState extends State<DetailedFindings> {
  FindingStatus? _filter;
  @override
  Widget build(BuildContext context) {
    final findings = widget.analysis.findings;
    final visible = findings
        .asMap()
        .entries
        .where((entry) => _filter == null || entry.value.status == _filter);
    return BrandedCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Detailed Analysis', style: VastuType.title),
      const SizedBox(height: VastuSpace.sm),
      const Text(
          'The evidence behind your assessment. Expand a finding for details.',
          style: VastuType.small),
      const SizedBox(height: VastuSpace.lg),
      Wrap(spacing: VastuSpace.sm, runSpacing: VastuSpace.sm, children: [
        for (final status in <FindingStatus?>[null, ...FindingStatus.values])
          ChoiceChip(
            label: Text(status?.label ?? 'All'),
            selected: _filter == status,
            onSelected: (_) => setState(() => _filter = status),
            showCheckmark: false,
            backgroundColor: VastuColors.surface,
            selectedColor: VastuColors.sage,
            side: BorderSide(
                color: _filter == status
                    ? VastuColors.forest
                    : VastuColors.border),
            labelStyle: VastuType.small.copyWith(color: VastuColors.forest),
          ),
      ]),
      const SizedBox(height: VastuSpace.lg),
      if (visible.isEmpty)
        Padding(
            padding: const EdgeInsets.symmetric(vertical: VastuSpace.xl),
            child: Text(
                findings.isEmpty
                    ? 'No detections to display. Try a clearer floor plan or review your analysis settings.'
                    : 'No findings match this filter.',
                style: VastuType.small)),
      LayoutBuilder(builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;
        return Column(children: [
          if (!compact && visible.isNotEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(
                  VastuSpace.lg, 0, VastuSpace.section, VastuSpace.md),
              child: Row(children: [
                Expanded(
                    flex: 3,
                    child: Text('DETECTED ITEM', style: VastuType.caption)),
                Expanded(child: Text('DIRECTION', style: VastuType.caption)),
                SizedBox(
                    width: 150, child: Text('STATUS', style: VastuType.caption))
              ]),
            ),
          for (final entry in visible)
            Padding(
                padding: const EdgeInsets.only(bottom: VastuSpace.sm),
                child: _FindingRow(
                    key: ValueKey('finding-${entry.key}'),
                    finding: entry.value,
                    analysis: widget.analysis,
                    compact: compact,
                    showConfidence: widget.showConfidence)),
        ]);
      }),
    ]));
  }
}

class _FindingRow extends StatefulWidget {
  const _FindingRow(
      {super.key,
      required this.finding,
      required this.analysis,
      required this.compact,
      required this.showConfidence});
  final ResultFinding finding;
  final ResultsAnalysis analysis;
  final bool compact, showConfidence;
  @override
  State<_FindingRow> createState() => _FindingRowState();
}

class _FindingRowState extends State<_FindingRow> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    final f = widget.finding;
    final label = Text(f.label, style: VastuType.section);
    final status = ResultStatusPill(f.status);
    final heading = widget.compact
        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            label,
            const SizedBox(height: VastuSpace.sm),
            status,
            const SizedBox(height: VastuSpace.sm),
            Text('Direction: ${f.direction}', style: VastuType.small),
          ])
        : Row(children: [
            Expanded(flex: 3, child: label),
            Expanded(child: Text(f.direction, style: VastuType.small)),
            SizedBox(
                width: 150,
                child: Align(alignment: Alignment.centerLeft, child: status))
          ]);
    return DecoratedBox(
      decoration: BoxDecoration(
          border: Border.all(color: VastuColors.border),
          borderRadius: BorderRadius.circular(VastuRadius.control)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Semantics(
            button: true,
            expanded: _expanded,
            child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(VastuRadius.control),
                child: InkWell(
                  focusColor: VastuColors.sage,
                  hoverColor: VastuColors.controlHover,
                  borderRadius: BorderRadius.circular(VastuRadius.control),
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Padding(
                      padding: const EdgeInsets.all(VastuSpace.lg),
                      child: Row(children: [
                        Expanded(child: heading),
                        const SizedBox(width: VastuSpace.sm),
                        Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                            color: VastuColors.forest),
                      ])),
                ))),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(
                VastuSpace.lg, 0, VastuSpace.lg, VastuSpace.lg),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Divider(color: VastuColors.border),
              const SizedBox(height: VastuSpace.sm),
              Text(f.explanation(widget.analysis.ruleSetName),
                  style: VastuType.body),
              const SizedBox(height: VastuSpace.md),
              Text('Rule set: ${widget.analysis.ruleSetName}',
                  style: VastuType.small),
              if (widget.showConfidence && f.confidence != null)
                Text('Detection confidence: ${(f.confidence! * 100).round()}%',
                    style: VastuType.small),
              Text('Model: ${widget.analysis.modelLabel}',
                  style: VastuType.small),
              if (f.remedy != null) ...[
                const SizedBox(height: VastuSpace.lg),
                RemedyDetails(finding: f, ruleSet: widget.analysis.ruleSetName),
              ] else if (f.allowedDirections != null &&
                  f.allowedDirections!.isNotEmpty)
                Text(
                    'Allowed directions: ${directionList(f.allowedDirections!)}',
                    style: VastuType.small),
            ]),
          ),
      ]),
    );
  }
}
