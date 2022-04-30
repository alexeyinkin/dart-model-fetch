import 'package:flutter/widgets.dart';
import 'package:model_fetch/model_fetch.dart';

class LazyLoadBuilder<T> extends StatelessWidget {
  final LazyLoadBloc<T> bloc;
  final Widget Function(BuildContext context, LazyLoadState<T> state) builder;

  LazyLoadBuilder({Key? key, required this.bloc, required this.builder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LazyLoadState<T>>(
      stream: bloc.states,
      builder: (context, snapshot) =>
          builder(context, snapshot.data ?? bloc.initialState),
    );
  }
}
