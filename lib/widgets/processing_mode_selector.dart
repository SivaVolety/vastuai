import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rule_set_provider.dart';

class ProcessingModeSelector extends StatelessWidget {
  const ProcessingModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RuleSetProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Tooltip(
          message: 'Select rule set for Vastu processing',
          child: Icon(Icons.help_outline),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: Colors.grey, // You can customize the border color
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: provider.selected,
              borderRadius: BorderRadius.circular(12.0),
              items: provider.ruleSetNames.map((name) {
                return DropdownMenuItem(value: name, child: Text(name));
              }).toList(),
              onChanged: (val) => provider.select(val!),
              isDense: true,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blueAccent),
          tooltip: 'Manage rule sets',
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
          },
        ),
      ],
    );
  }
}
