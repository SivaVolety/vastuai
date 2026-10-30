import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/detector_model.dart';
import '../providers/model_selection_provider.dart';

class ModelSelector extends StatelessWidget {
  const ModelSelector({super.key, this.enabled = true});
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final selection = context.watch<ModelSelectionProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: DropdownButtonFormField<DetectorModel>(
            initialValue: selection.selected,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Detection model',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: DetectorModel.values
                .map((model) => DropdownMenuItem(
                      value: model,
                      child: Text(model.selectorLabel,
                          overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: enabled
                ? (model) {
                    if (model != null) selection.select(model);
                  }
                : null,
          ),
        ),
        if (selection.selected == DetectorModel.v2)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(DetectorModel.betaWarning, textAlign: TextAlign.center),
          ),
      ]),
    );
  }
}
