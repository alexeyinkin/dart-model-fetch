import 'package:flutter/widgets.dart';
import 'package:model_fetch/model_fetch.dart';
import 'package:model_interfaces/model_interfaces.dart';

import '../listenable.dart';
import 'auto_load_more.dart';
import 'model_list_item.dart';

class LazyLoadListView<T extends WithIdTitle<String>> extends StatelessWidget {
  final Widget leading;
  final ListLazyLoader<T> loader;
  final ValueSetter<T>? onEditPressed;
  final bool shrinkWrap;

  const LazyLoadListView({
    super.key,
    required this.loader,
    this.leading = const SizedBox.shrink(),
    this.onEditPressed,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: loader.asListenable(),
      builder: (context, _) {
        return ListView.builder(
          itemCount: loader.items.length + 2,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) return leading;

            final itemIndex = index - 1;
            if (itemIndex < loader.items.length) {
              final item = loader.items[itemIndex];
              return ModelListItem(
                item,
                onEditPressed:
                onEditPressed == null ? null : () => onEditPressed!(item),
              );
            }

            return ListLazyLoaderAutoLoadMoreWidget(loader: loader);
          },
          physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
          shrinkWrap: shrinkWrap,
        );
      },
    );
  }
}
