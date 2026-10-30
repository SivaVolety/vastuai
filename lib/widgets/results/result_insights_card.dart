import 'package:flutter/material.dart';
import '../../theme/vastu_theme.dart';
import '../brand_components.dart';

class ResultInsightsCard extends StatelessWidget {
  const ResultInsightsCard(
      {super.key,
      required this.title,
      required this.items,
      required this.emptyText,
      required this.icon,
      this.positive = false});
  final String title, emptyText;
  final List<String> items;
  final IconData icon;
  final bool positive;
  @override
  Widget build(BuildContext context) => BrandedCard(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: VastuType.title),
          const SizedBox(height: VastuSpace.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(VastuSpace.lg),
            decoration: BoxDecoration(
                color: positive ? VastuColors.sage : VastuColors.peach,
                borderRadius: BorderRadius.circular(VastuRadius.control)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (items.isEmpty) Text(emptyText, style: VastuType.small),
              for (int i = 0; i < items.length; i++)
                Padding(
                  padding: EdgeInsets.only(top: i == 0 ? 0 : VastuSpace.lg),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(icon,
                            size: 18,
                            color: positive
                                ? VastuColors.success
                                : VastuColors.warning),
                        const SizedBox(width: VastuSpace.md),
                        Expanded(
                            child: Text(items[i],
                                style: VastuType.small
                                    .copyWith(color: VastuColors.ink))),
                      ]),
                ),
            ]),
          ),
        ],
      ));
}
