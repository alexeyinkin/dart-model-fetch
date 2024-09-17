import 'package:flutter/widgets.dart';
import 'package:model_fetch/model_fetch.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'list_lazy_loader_trailing.dart';

/// Loads more items when the child becomes partially visible.
class ListLazyLoaderAutoLoadMoreWidget extends StatelessWidget {
  final ListLazyLoader loader;

  /// Called if the [loader] is currently loading or not loading but has more.
  final WidgetBuilder? loadingBuilder;

  /// Called if the [loader] has successfully loaded everything has no more.
  final WidgetBuilder? noMoreBuilder;

  /// Called if the [loader]'s status is error.
  final WidgetBuilder? errorBuilder;

  /// Loads more items when the child becomes partially visible.
  const ListLazyLoaderAutoLoadMoreWidget({
    super.key,
    required this.loader,
    this.errorBuilder,
    this.loadingBuilder,
    this.noMoreBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey('ListLazyLoaderAutoLoadMore_with_${loader.items.length}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: ListLazyLoaderTrailingWidget(
        loader: loader,
        loadingBuilder: loadingBuilder,
        noMoreBuilder: noMoreBuilder,
        errorBuilder: errorBuilder,
      ),
    );
  }

  Future<void> _onVisibilityChanged(VisibilityInfo info) async {
    if (info.visibleFraction > .01) {
      await loader.loadMoreIfCan();
    }
  }
}

/// Loads more items when the child becomes partially visible.
@Deprecated('Use ListLazyLoaderAutoLoadMoreWidget')
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
      key: ValueKey('LoadMoreWidget_with_${bloc.currentState.items.length}'),
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
