import 'package:flutter/widgets.dart';
import 'package:model_fetch/model_fetch.dart';

import '../listenable.dart';
import 'collection_bloc_builder.dart';

/// Calls a specific builder based on the [loader]'s loading status.
///
/// If any of the builders is omitted, a SizedBox of 1x1 is used.
class ListLazyLoaderTrailingWidget extends StatelessWidget {
  final ListLoader loader;

  /// Called if the [loader] is currently loading or not loading but has more.
  final WidgetBuilder? loadingBuilder;

  /// Called if the [loader] has successfully loaded everything has no more.
  final WidgetBuilder? noMoreBuilder;

  /// Called if the [loader]'s status is error.
  final WidgetBuilder? errorBuilder;

  /// Calls a specific builder based on the [loader]'s loading status.
  const ListLazyLoaderTrailingWidget({
    super.key,
    required this.loader,
    this.errorBuilder,
    this.loadingBuilder,
    this.noMoreBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: loader.asListenable(),
      builder: (context, _) {
        switch (loader.status) {
          case LoadStatus.error:
            return (errorBuilder ?? _defaultBuilder)(context);

          case LoadStatus.notTried:
          case LoadStatus.loading:
            return (loadingBuilder ?? _defaultBuilder)(context);

          case LoadStatus.ok:
            return loader.hasMore
                ? (loadingBuilder ?? _defaultBuilder)(context)
                : (noMoreBuilder ?? _defaultBuilder)(context);
        }
      },
    );
  }

  Widget _defaultBuilder(BuildContext context) {
    return const SizedBox(width: 1, height: 1);
  }
}

@Deprecated('Use ListLazyLoaderTrailingWidget')

/// Calls a specific builder based on the [bloc]'s loading status.
class LazyLoadBlocTrailingWidget extends StatelessWidget {
  final LazyLoadBloc bloc;
  final Widget Function(BuildContext, CollectionState state)? loadingBuilder;
  final Widget Function(BuildContext, CollectionState state)? noMoreBuilder;
  final Widget Function(BuildContext, CollectionState state)? errorBuilder;

  @Deprecated('Use ListLazyLoaderTrailingWidget')
  const LazyLoadBlocTrailingWidget({
    super.key,
    required this.bloc,
    this.errorBuilder,
    this.loadingBuilder,
    this.noMoreBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return CollectionBlocBuilder(
      bloc: bloc,
      builder: _buildWithState,
    );
  }

  Widget _buildWithState(BuildContext context, CollectionState state) {
    switch (state.status) {
      case LoadStatus.error:
        return (errorBuilder ?? _defaultBuilder)(context, state);

      case LoadStatus.notTried:
      case LoadStatus.loading:
        return (loadingBuilder ?? _defaultBuilder)(context, state);

      case LoadStatus.ok:
        return state.hasMore
            ? (loadingBuilder ?? _defaultBuilder)(context, state)
            : (noMoreBuilder ?? _defaultBuilder)(context, state);
    }
  }

  Widget _defaultBuilder(BuildContext context, CollectionState state) {
    return const SizedBox(width: 1, height: 1);
  }
}
