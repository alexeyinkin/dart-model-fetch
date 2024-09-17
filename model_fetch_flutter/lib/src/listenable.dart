import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:model_fetch/model_fetch.dart';

// Delete when Listenable is extracted from Flutter to pure Dart: https://github.com/flutter/flutter/issues/149466

final _cache = <Object, Listenable>{};

extension ListLoaderListenableExtension on ListLoader {
  Listenable asListenable() {
    return _cache[this] ?? _createAndSave();
  }

  Listenable _createAndSave() {
    final result = StreamListenable(states); // ignore: deprecated_member_use
    _cache[this] = result;
    return result;
  }
}

extension ModelLoaderByFilterListenableExtension on ModelLoaderByFilter {
  Listenable asListenable() {
    return _cache[this] ?? _createAndSave();
  }

  Listenable _createAndSave() {
    final result = StreamListenable(states); // ignore: deprecated_member_use
    _cache[this] = result;
    return result;
  }
}

extension ModelLoaderByIdListenableExtension on ModelLoaderById {
  Listenable asListenable() {
    return _cache[this] ?? _createAndSave();
  }

  Listenable _createAndSave() {
    final result = StreamListenable(states); // ignore: deprecated_member_use
    _cache[this] = result;
    return result;
  }
}

class StreamListenable implements Listenable {
  final Stream _stream;
  final _subscriptions = <VoidCallback, StreamSubscription>{};

  StreamListenable(this._stream);

  @override
  void addListener(VoidCallback listener) {
    _subscriptions[listener] = _stream.listen((_) => listener());
  }

  @override
  void removeListener(VoidCallback listener) {
    unawaited(_subscriptions[listener]!.cancel());
    _subscriptions.remove(listener);
  }
}
