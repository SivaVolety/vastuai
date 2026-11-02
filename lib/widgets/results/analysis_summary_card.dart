import 'package:flutter/material.dart';
import '../../models/results_analysis.dart';
import '../../theme/vastu_theme.dart';
import '../brand_components.dart';

/// Renders narrative only; all assessment/finding widgets use deterministic data.
class AnalysisSummaryCard extends StatelessWidget {
  const AnalysisSummaryCard(
      {super.key, required this.content, this.loading = false, this.onRetry});
  final ResultNarrative content;
  final bool loading;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, bounds) {
        // Stable across loading, success and fallback. Long narratives scroll inside
        // the same body rather than moving the plan or any following section.
        final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
        final height =
            (bounds.maxWidth < 360 ? 410.0 : 370.0) * scale.clamp(1, 1.8);
        return BrandedCard(
            child: SizedBox(
                height: height,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                          height: 68 * scale,
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                  content.isAiGenerated
                                      ? 'AI-Powered Summary'
                                      : 'Analysis Summary',
                                  style: VastuType.title))),
                      Expanded(
                          child: SingleChildScrollView(
                              key: const ValueKey('summary-narrative-viewport'),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (content.isAiGenerated)
                                      Text(content.headline,
                                          style: VastuType.section),
                                    const SizedBox(height: VastuSpace.md),
                                    Text(content.summary,
                                        style: VastuType.body),
                                    const SizedBox(height: VastuSpace.lg),
                                    Text(
                                        content.disclaimer ??
                                            'Based on your detected placements and selected rules.',
                                        style: VastuType.caption),
                                  ]))),
                      const SizedBox(height: VastuSpace.md),
                      SizedBox(
                          height: 56 * scale,
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: loading
                                  ? const Text('Generating enhanced summary…',
                                      style: VastuType.caption)
                                  : !content.isAiGenerated && onRetry != null
                                      ? TextButton.icon(
                                          onPressed: onRetry,
                                          icon: const Icon(
                                              Icons.refresh_rounded,
                                              size: 16),
                                          label: const Text('Retry summary'))
                                      : const Text(
                                          'Generated from your Vastu analysis',
                                          style: VastuType.caption))),
                    ])));
      });
}
