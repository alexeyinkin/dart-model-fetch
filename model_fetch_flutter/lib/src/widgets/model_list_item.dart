import 'package:flutter/material.dart';
import 'package:model_interfaces/model_interfaces.dart';

import '../util/iterable.dart';
import 'my_spacing.dart';

class ModelListItem<I, T extends WithIdTitle<I>> extends StatelessWidget {
  final bool isSelected;
  final T model;
  final VoidCallback? onEditPressed;
  final ValueChanged<bool>? onSelectionChanged;
  final bool pad;

  const ModelListItem(
    this.model, {
    super.key,
    this.isSelected = false,
    this.onEditPressed,
    this.onSelectionChanged,
    this.pad = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget result = Row(
      children: [
        if (onSelectionChanged != null)
          Checkbox(
            value: isSelected,
            onChanged: (value) => onSelectionChanged!(value!),
          ),
        Expanded(child: Text(model.title)),
        if (onEditPressed != null)
          IconButton(onPressed: onEditPressed, icon: const Icon(Icons.edit)),
      ].intersperse(const MySpacing()).toList(growable: false),
    );

    if (pad) {
      result = Padding(
        padding: const EdgeInsets.all(MySpacing.value),
        child: result,
      );
    }

    return result;
  }
}
