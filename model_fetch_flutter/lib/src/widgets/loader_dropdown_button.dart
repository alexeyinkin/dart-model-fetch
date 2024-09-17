import 'package:flutter/material.dart';
import 'package:model_interfaces/model_interfaces.dart';

import '../notifiers/loader_value.dart';

class LoaderDropdownButton<I, T extends WithIdTitle<I>>
    extends StatelessWidget {
  final LoaderValueNotifier<I, T> controller;
  final String emptyText;

  const LoaderDropdownButton({
    super.key,
    required this.controller,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final items = [
          if (controller.value == null)
            DropdownMenuItem<I>(
              child: Text(emptyText),
            ),
          for (final item in controller.loader.items)
            DropdownMenuItem<I>(
              value: item.id,
              child: Text(item.title),
            ),
        ];

        return DropdownButton<I>(
          items: items,
          onChanged: controller.setIdOrThrow,
          value: controller.value?.id,
        );
      },
    );
  }
}
