import 'package:flutter/material.dart';
import '../../models/results_analysis.dart';
import '../../models/detector_model.dart';
import '../../theme/vastu_theme.dart';

class ResultsHeader extends StatelessWidget {
  const ResultsHeader(
      {super.key,
      required this.analysis,
      required this.onBack,
      required this.desktop});
  final ResultsAnalysis analysis;
  final VoidCallback onBack;
  final bool desktop;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: VastuSpace.xl),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Back to Upload')),
          const SizedBox(height: VastuSpace.md),
          Text('Analysis Results',
              style: VastuType.display.copyWith(fontSize: desktop ? 52 : 36)),
          const SizedBox(height: VastuSpace.md),
          ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: Text(
                  'Here’s your Vastu analysis. Get a clear summary, key insights, and detailed findings for each element.',
                  style: VastuType.body)),
          const SizedBox(height: VastuSpace.lg),
          Wrap(spacing: VastuSpace.sm, runSpacing: VastuSpace.sm, children: [
            _Metadata(
                icon: Icons.layers_outlined,
                text: 'Model: ${analysis.modelLabel}'),
            _Metadata(
                icon: Icons.explore_outlined,
                text: 'Rule set: ${analysis.ruleSetName}'),
          ]),
          if (analysis.experimental) ...[
            const SizedBox(height: VastuSpace.sm),
            Text('Research Beta · ${DetectorModel.betaWarning}',
                style: VastuType.small.copyWith(color: VastuColors.warning)),
          ],
        ]),
      );
}

class _Metadata extends StatelessWidget {
  const _Metadata({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: VastuSpace.md, vertical: VastuSpace.sm),
        decoration: BoxDecoration(
            color: VastuColors.sage,
            borderRadius: BorderRadius.circular(VastuRadius.control)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: VastuColors.forest),
          const SizedBox(width: VastuSpace.sm),
          Flexible(child: Text(text, style: VastuType.small))
        ]),
      );
}
