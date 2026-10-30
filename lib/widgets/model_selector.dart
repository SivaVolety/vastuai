import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/detector_model.dart';
import '../providers/model_selection_provider.dart';
import '../theme/vastu_theme.dart';
import 'brand_components.dart';

class ModelSelector extends StatelessWidget {
  const ModelSelector({super.key, this.enabled = true});
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final selection = context.watch<ModelSelectionProvider>();
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrandSelect<DetectorModel>(
            value: selection.selected,
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
          if (selection.selected == DetectorModel.v2)
            Padding(
              padding: const EdgeInsets.only(top: VastuSpace.sm),
              child: Text(DetectorModel.betaWarning,
                  style: VastuType.small.copyWith(color: VastuColors.warning)),
            ),
        ]);
  }
}
