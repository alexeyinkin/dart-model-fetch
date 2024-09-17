import 'package:flutter/widgets.dart';
import 'package:model_interfaces/model_interfaces.dart';

import '../notifiers/loader_value_list.dart';
import 'model_list_item.dart';

class LoaderSelectableListView<I, T extends WithIdTitle<I>>
    extends StatelessWidget {
  final LoaderValueListNotifier<I, T> controller;
  final bool shrinkWrap;

  const LoaderSelectableListView({
    super.key,
    required this.controller,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final selectedIds = controller.ids.toSet();

        return ListView.builder(
          itemCount: controller.loader.items.length,
          itemBuilder: (BuildContext context, int index) {
            final item = controller.loader.items[index];

            return ModelListItem<I, T>(
              item,
              isSelected: selectedIds.contains(item.id),
              onSelectionChanged: (v) async =>
                  controller.setIdSelectedOrThrow(item.id, v),
            );
          },
          physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
          shrinkWrap: shrinkWrap,
        );
      },
    );
  }
}
