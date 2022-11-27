import 'package:flutter/widgets.dart';
import 'package:model_fetch/model_fetch.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'lazy_load_bloc_trailing.dart';

/// Loads more items when the child becomes partially visible.
class BlocAutoLoadMoreWidget extends StatelessWidget {
  final LazyLoadBloc bloc;
  final Widget Function(BuildContext, CollectionState state)? loadingBuilder;
  final Widget Function(BuildContext, CollectionState state)? noMoreBuilder;
  final Widget Function(BuildContext, CollectionState state)? errorBuilder;

  ///
  const BlocAutoLoadMoreWidget({
    super.key,
    required this.bloc,
    this.errorBuilder,
    this.loadingBuilder,
    this.noMoreBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const ValueKey('LoadMoreWidget'),
      onVisibilityChanged: _onVisibilityChanged,
      child: LazyLoadBlocTrailingWidget(
        bloc: bloc,
        loadingBuilder: loadingBuilder,
        noMoreBuilder: noMoreBuilder,
        errorBuilder: errorBuilder,
      ),
    );
  }

  Future<void> _onVisibilityChanged(VisibilityInfo info) async {
    if (info.visibleFraction > .01) {
      await bloc.loadMoreIfCan();
    }
  }
}
