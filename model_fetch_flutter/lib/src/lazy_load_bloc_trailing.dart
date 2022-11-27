import 'package:flutter/widgets.dart';
import 'package:model_fetch/model_fetch.dart';

import 'collection_bloc_builder.dart';

/// Calls a specific builder based on the [bloc]'s loading status.
class LazyLoadBlocTrailingWidget extends StatelessWidget {
  final LazyLoadBloc bloc;
  final Widget Function(BuildContext, CollectionState state)? loadingBuilder;
  final Widget Function(BuildContext, CollectionState state)? noMoreBuilder;
  final Widget Function(BuildContext, CollectionState state)? errorBuilder;

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
    return Container();
  }
}
