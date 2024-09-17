import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:model_fetch/model_fetch.dart';
import 'package:model_interfaces/model_interfaces.dart';

import '../listenable.dart';

/// A [ValueNotifier] for selecting an list of items from the [loader].
class LoaderValueListNotifier<I, T extends WithIdTitle<I>>
    extends ValueNotifier<List<T>> {
  final ListLazyLoader<T> loader;

  List<I> get ids => _ids;
  List<I> _ids;

  LoaderValueListNotifier({
    required this.loader,
  }) : _ids = const [], super(const []) {
    loader.asListenable().addListener(_onLoaderChanged);
    unawaited(_onLoaderChanged());
  }

  Future<void> _onLoaderChanged() async {
    await loader.loadAllIfCan();
    notifyListeners();
  }

  @override
  @mustCallSuper
  set value(List<T> newValue) {
    _ids = newValue.map((item) => item.id).toList(growable: false);
    super.value = newValue;
  }

  // ignore: avoid_positional_boolean_parameters
  Future<void> setIdSelectedOrThrow(I id, bool isSelected) async {
    final newIds = {..._ids};

    if (isSelected) {
      newIds.add(id);
    } else {
      newIds.remove(id);
    }

    if (_ids.length != newIds.length) {
      await setIdsOrThrow(newIds.toList(growable: false));
    }
  }

  Future<void> setIdsOrThrow(List<I> ids) async {
    _ids = ids;

    if (ids.isEmpty) {
      value = const [];
      return;
    }

    if (loader.hasMore) {
      await loader.loadAllIfCan();
    }

    final itemMap = loader.items.mapByIds();

    final missingIds = <I>[];
    final items = <T>[];

    for (final id in ids) {
      final item = itemMap[id];

      if (item == null) {
        missingIds.add(id);
      } else {
        items.add(item);
      }
    }

    if (missingIds.isNotEmpty) {
      throw Exception('Missing ids: $missingIds');
    }

    value = items;
  }

  @override
  Future<void> dispose() async {
    await loader.dispose();
    super.dispose();
  }
}
