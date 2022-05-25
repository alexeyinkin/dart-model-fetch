import 'package:flutter/widgets.dart';
import 'package:model_fetch/model_fetch.dart';

class CollectionBlocBuilder<T> extends StatelessWidget {
  final CollectionBloc<T> bloc;
  final Widget Function(BuildContext context, CollectionState<T> state) builder;

  const CollectionBlocBuilder({
    Key? key,
    required this.bloc,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CollectionState<T>>(
      stream: bloc.states,
      builder: (context, snapshot) =>
          builder(context, snapshot.data ?? bloc.initialState),
    );
  }
}
