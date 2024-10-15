import 'package:cloud_functions/cloud_functions.dart';
import 'package:model_fetch/model_fetch.dart';

class CloudFunctionFrozenListLazyLoader<T, F extends AbstractFilter>
    extends ListLazyLoader<T> {
  final Future<T> Function(Map<String, dynamic> map) denormalize;
  final F filter;
  final String name;
  final int pageSize;

  @override
  final items = <T>[];

  CloudFunctionFrozenListLazyLoader({
    required this.denormalize,
    required this.filter,
    required this.name,
    required this.pageSize,
    super.clientFilters,
    super.onError,
    super.totalLimit,
  });

  @override
  Future<void> loadAll() async {
    // print('CloudFunctionFrozenListLazyLoader.loadAll');
    await loadMore();
  }

  @override
  Future<bool> loadMore() async {
    // print('CloudFunctionFrozenListLazyLoader.loadMore');
    final result = await FirebaseFunctions.instance
        .httpsCallable(name)
        .call(filter.toJson());
    // print(result.data);
    // print(result.data.runtimeType);
    await _addResultToList(result);
    return false;
  }

  @override
  Future<void> clearItems() async {
    items.clear();
    // setLastDocument(null);
  }

  Future<void> _addResultToList(
    HttpsCallableResult result,
  ) async {
    final data = result.data['data'];

    if (data is! Iterable) {
      throw Exception('Expected an iterable in data, got $data');
    }

    items.addAll(await Future.wait(data.map((map) => denormalize(map))));
  }
}
