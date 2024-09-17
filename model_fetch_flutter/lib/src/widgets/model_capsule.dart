import 'package:flutter/material.dart';
import 'package:model_editors/model_editors.dart';
import 'package:model_interfaces/model_interfaces.dart';

import '../util/iterable.dart';
import 'clickable.dart';
import 'my_spacing.dart';

class ModelCapsuleWidget<I, T extends WithIdTitle<I>> extends StatelessWidget {
  final T model;
  final VoidCallback? onDeletePressed;

  const ModelCapsuleWidget(
    this.model, {
    super.key,
    this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return CapsuleWidget(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(model.title),
          if (onDeletePressed != null)
            ClickableWidget(
              onTap: onDeletePressed,
              child: const Icon(Icons.cancel),
            ),
        ].intersperse(const MySpacing()).toList(growable: false),
      ),
    );
  }
}
