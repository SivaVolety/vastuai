import 'package:flutter/material.dart';
import '../../models/results_analysis.dart';
import '../../theme/vastu_theme.dart';

Color statusColor(FindingStatus status) => switch (status) {
      FindingStatus.favorable => VastuColors.success,
      FindingStatus.attention => VastuColors.error,
      FindingStatus.notEvaluated => VastuColors.muted,
    };

class ResultStatusPill extends StatelessWidget {
  const ResultStatusPill(this.status, {super.key});
  final FindingStatus status;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: VastuSpace.md, vertical: VastuSpace.sm),
        decoration: BoxDecoration(
            color: statusColor(status).withValues(alpha: .09),
            borderRadius: BorderRadius.circular(VastuRadius.pill)),
        child: Text(status.label,
            style: VastuType.caption.copyWith(
                color: statusColor(status), fontWeight: FontWeight.w700)),
      );
}
