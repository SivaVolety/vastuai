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
  Widget build(BuildContext context) => BrandedCard(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              content.isAiGenerated ? 'AI-Powered Summary' : 'Analysis Summary',
              style: VastuType.title),
          const SizedBox(height: VastuSpace.sm),
          const Text('Based on your detected placements and selected rules',
              style: VastuType.caption),
          const SizedBox(height: VastuSpace.lg),
          if (content.isAiGenerated) ...[
            Text(content.headline, style: VastuType.section),
            const SizedBox(height: VastuSpace.sm),
          ],
          Text(content.summary, style: VastuType.body),
          if (loading) ...[
            const SizedBox(height: VastuSpace.md),
            const Text('Generating enhanced summary…',
                style: VastuType.caption),
          ],
          if (content.disclaimer != null) ...[
            const SizedBox(height: VastuSpace.md),
            Text(content.disclaimer!, style: VastuType.caption),
          ],
          if (!loading && !content.isAiGenerated && onRetry != null) ...[
            const SizedBox(height: VastuSpace.sm),
            TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry summary')),
          ],
        ],
      ));
}
