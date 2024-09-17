import 'package:flutter/material.dart';
import 'package:model_interfaces/model_interfaces.dart';

import '../notifiers/loader_value_list.dart';
import 'loader_selectable_list_view.dart';
import 'model_capsule.dart';
import 'my_spacing.dart';

class LoaderSelectablePopUpListView<I, T extends WithIdTitle<I>>
    extends StatelessWidget {
  final LoaderValueListNotifier<I, T> controller;
  final bool shrinkWrap;

  const LoaderSelectablePopUpListView({
    super.key,
    required this.controller,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final items = controller.value;

        return Wrap(
          runSpacing: MySpacing.value,
          spacing: MySpacing.value,
          children: [
            for (final item in items)
              ModelCapsuleWidget(
                item,
                onDeletePressed: () async =>
                    controller.setIdSelectedOrThrow(item.id, false),
              ),
            MaterialButton(
              onPressed: () async => _showPopUp(context),
              child: const Text('…'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPopUp(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(48),
          child: LoaderSelectableListView(
            controller: controller,
            shrinkWrap: shrinkWrap,
          ),
        );
      },
    );
  }
}
