import 'package:flutter/widgets.dart';
import 'package:model_fetch/model_fetch.dart';
import 'package:visibility_detector/visibility_detector.dart';

class LoadMoreWidget extends StatelessWidget {
  final LazyLoadBloc bloc;
  final Widget child;

  const LoadMoreWidget({
    Key? key,
    required this.bloc,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey('LoadMoreWidget'),
      child: child,
      onVisibilityChanged: _onVisibilityChanged,
    );
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction > .01) {
      bloc.loadMoreIfCan();
    }
  }
}
