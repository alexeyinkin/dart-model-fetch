import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:model_fetch/model_fetch.dart';
import 'package:model_interfaces/model_interfaces.dart';

import '../listenable.dart';

/// A [ValueNotifier] for selecting an item from the [loader].
class LoaderValueNotifier<I, T extends WithIdTitle<I>>
    extends ValueNotifier<T?> {
  final ListLazyLoader<T> loader;

  I? get id => _id;
  I? _id;

  LoaderValueNotifier({
    required this.loader,
  }) : super(null) {
    loader.asListenable().addListener(_onLoaderChanged);
    unawaited(_onLoaderChanged());
  }

  Future<void> _onLoaderChanged() async {
    await loader.loadAllIfCan();
    notifyListeners();
  }

  Future<void> setIdOrThrow(I? id) async {
    await setId(id, ifNotFound: () => throw Exception('Object not found: $id'));
  }

  Future<void> setIdOrNull(I? id) async {
    await setId(id, ifNotFound: () => null);
  }

  Future<void> setId(I? id, {required ValueGetter<T?> ifNotFound}) async {
    _id = id;

    if (id == null) {
      value = null;
      return;
    }

    if (loader.hasMore) {
      await loader.loadAllIfCan();
    }

    final item =
        loader.items.firstWhereOrNull((item) => item.id == id) ?? ifNotFound();

    value = item;
  }

  @override
  Future<void> dispose() async {
    await loader.dispose();
    super.dispose();
  }
}
