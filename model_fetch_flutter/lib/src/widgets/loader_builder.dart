import 'package:flutter/widgets.dart';
import 'package:model_fetch/model_fetch.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../listenable.dart';

/// Triggers loading when becomes visible.
class LoaderBuilder extends StatelessWidget {
  final WidgetBuilder builder;
  final Loader loader;

  const LoaderBuilder({
    required this.loader,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey('LoaderBuilder_with_${loader.hashCode}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: ListenableBuilder(
        listenable: loader.asListenable(),
        builder: (context, _) => builder(context),
      ),
    );
  }

  Future<void> _onVisibilityChanged(VisibilityInfo info) async {
    if (info.visibleFraction > .01 && loader.hasMore) {
      await loader.loadAllIfCan();
    }
  }
}
