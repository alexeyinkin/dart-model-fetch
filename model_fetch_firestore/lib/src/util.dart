import 'dart:async';

import 'package:flutter/foundation.dart';

typedef ErrorCallback = void Function(Object error, StackTrace trace);

extension SynchronousFutureExtension<T> on SynchronousFuture<T> {
  T get value {
    late final T result;

    unawaited(
      then((v) {
        result = v;
      }),
    );

    return result;
  }
}
