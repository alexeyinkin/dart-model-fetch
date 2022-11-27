import 'package:flutter/widgets.dart';
import 'package:model_fetch/model_fetch.dart';
import 'package:visibility_detector/visibility_detector.dart';

@Deprecated('Use BlocAutoLoadMoreWidget')
class LoadMoreWidget extends StatelessWidget {
  final LazyLoadBloc bloc;
  final Widget child;

  @Deprecated('Use BlocAutoLoadMoreWidget')
  const LoadMoreWidget({
    super.key,
    required this.bloc,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const ValueKey('LoadMoreWidget'),
      onVisibilityChanged: _onVisibilityChanged,
      child: child,
    );
  }

  Future<void> _onVisibilityChanged(VisibilityInfo info) async {
    if (info.visibleFraction > .01) {
      await bloc.loadMoreIfCan();
    }
  }
}
