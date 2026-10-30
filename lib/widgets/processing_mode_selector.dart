import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rule_set_provider.dart';
import '../theme/vastu_theme.dart';
import 'brand_components.dart';

class ProcessingModeSelector extends StatelessWidget {
  const ProcessingModeSelector(
      {super.key,
      this.enabled = true,
      this.compact = false,
      this.showManage = true});
  final bool enabled, compact, showManage;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RuleSetProvider>();
    return Row(children: [
      Expanded(
          child: BrandSelect<String>(
        value: provider.selected,
        compact: compact,
        hint: 'Select a tradition',
        items: provider.ruleSetNames
            .map((name) => DropdownMenuItem(
                  value: name,
                  child: Text(name, overflow: TextOverflow.ellipsis),
                ))
            .toList(),
        onChanged: enabled
            ? (value) {
                if (value != null) provider.select(value);
              }
            : null,
      )),
      if (showManage) ...[
        const SizedBox(width: VastuSpace.xs),
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20),
          tooltip: 'Manage rule sets',
          onPressed:
              enabled ? () => Navigator.pushNamed(context, '/settings') : null,
        ),
      ],
    ]);
  }
}
