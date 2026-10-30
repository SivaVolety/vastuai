import 'package:flutter/material.dart';
import '../../theme/vastu_theme.dart';

class AnalyzerHero extends StatelessWidget {
  const AnalyzerHero({super.key, required this.desktop});
  final bool desktop;
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(
            top: desktop ? VastuSpace.section : VastuSpace.xxl,
            bottom: VastuSpace.xxl),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: VastuLayout.heroTextMax),
              child: Text(
                'Understand Your Space with VastuAI',
                style: VastuType.display.copyWith(fontSize: desktop ? 64 : 40),
              )),
          const SizedBox(height: VastuSpace.copyGap),
          ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Text(
                'Upload your floor plan, set the orientation, and get an AI-powered Vastu analysis with clear insights and recommendations.',
                style: VastuType.body
                    .copyWith(color: VastuColors.muted, height: 1.65),
              )),
          if (desktop) ...[
            const SizedBox(height: VastuSpace.xl),
            const Wrap(
                spacing: VastuSpace.xl,
                runSpacing: VastuSpace.sm,
                children: [
                  _Feature(Icons.auto_awesome_outlined, 'AI-Powered Analysis',
                      warm: true),
                  _Feature(Icons.explore_outlined, 'Traditional Vastu Rules'),
                  _Feature(Icons.task_alt_outlined, 'Clear Recommendations'),
                ]),
          ],
        ]),
      );
}

class _Feature extends StatelessWidget {
  const _Feature(this.icon, this.text, {this.warm = false});
  final bool warm;
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
              color: warm ? VastuColors.peach : VastuColors.sage,
              shape: BoxShape.circle),
          child: Icon(icon,
              size: 16, color: warm ? VastuColors.warning : VastuColors.forest),
        ),
        const SizedBox(width: VastuSpace.sm),
        Text(text,
            style: VastuType.small
                .copyWith(fontSize: 13.5, color: VastuColors.muted)),
      ]);
}
