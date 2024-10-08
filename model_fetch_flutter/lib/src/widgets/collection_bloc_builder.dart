import 'package:flutter/widgets.dart';
import 'package:model_fetch/model_fetch.dart';

@Deprecated('Use ListenableBuilder with asListenable()')
class CollectionBlocBuilder<T> extends StatelessWidget {
  final CollectionBloc<T> bloc;
  final Widget Function(BuildContext context, CollectionState<T> state) builder;

  const CollectionBlocBuilder({
    super.key,
    required this.bloc,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CollectionState<T>>(
      stream: bloc.states,
      builder: (context, snapshot) =>
          builder(context, snapshot.data ?? bloc.initialState),
    );
  }
}
