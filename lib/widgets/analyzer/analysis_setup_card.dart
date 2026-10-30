import 'package:flutter/material.dart';
import '../../theme/vastu_theme.dart';
import '../brand_components.dart';
import '../processing_mode_selector.dart';
import '../model_selector.dart';

class AnalysisSetupCard extends StatelessWidget {
  const AnalysisSetupCard(
      {super.key,
      required this.desktop,
      required this.loading,
      required this.onAnalyze,
      required this.onRotateLeft,
      required this.onRotateRight});
  final bool desktop, loading;
  final VoidCallback? onAnalyze, onRotateLeft, onRotateRight;
  @override
  Widget build(BuildContext context) => BrandedCard(
        padding: EdgeInsets.all(desktop ? VastuSpace.xl : VastuSpace.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Analysis Setup', style: VastuType.title),
          const SizedBox(height: VastuSpace.sm),
          const Text('A few details, a more thoughtful analysis.',
              style: VastuType.small),
          const SizedBox(height: VastuSpace.xl),
          const SectionLabel('Vastu Tradition'),
          ProcessingModeSelector(enabled: !loading),
          const SizedBox(height: VastuSpace.xl),
          const SectionLabel('Detection Model'),
          ModelSelector(enabled: !loading),
          if (desktop) ...[
            const SizedBox(height: VastuSpace.xl),
            const SectionLabel('Set North Orientation'),
            const Text('Align the top of your plan with North.',
                style: VastuType.small),
            const SizedBox(height: VastuSpace.md),
            Row(children: [
              Expanded(
                  child: SecondaryButton(
                      label: 'Rotate Left',
                      icon: Icons.rotate_left,
                      onPressed: onRotateLeft)),
              const SizedBox(width: VastuSpace.sm),
              Expanded(
                  child: SecondaryButton(
                      label: 'Rotate Right',
                      icon: Icons.rotate_right,
                      onPressed: onRotateRight)),
            ]),
          ],
          const SizedBox(height: VastuSpace.xl),
          Container(
            padding: const EdgeInsets.all(VastuSpace.lg),
            decoration: BoxDecoration(
                color: VastuColors.peach,
                border: Border.all(color: VastuColors.warmBorder),
                borderRadius: BorderRadius.circular(VastuRadius.control)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.info_outline_rounded,
                  color: VastuColors.warning, size: 18),
              const SizedBox(width: VastuSpace.md),
              Expanded(
                  child: Text(
                      'The entrance door should be at the bottom of the original (unrotated) image.',
                      style: VastuType.small
                          .copyWith(fontSize: 13.5, height: 1.55))),
            ]),
          ),
          const SizedBox(height: VastuSpace.xl),
          PrimaryButton(
              label: 'Analyze Floor Plan',
              onPressed: onAnalyze,
              loading: loading),
          const SizedBox(height: VastuSpace.md),
          Center(
              child: TextButton.icon(
            onPressed: loading
                ? null
                : () => Navigator.pushNamed(context, '/advanced'),
            icon: const Icon(Icons.tune_rounded, size: 16),
            label: const Text('Advanced settings'),
          )),
        ]),
      );
}
