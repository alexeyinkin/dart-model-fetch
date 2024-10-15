import 'package:model_fetch/model_fetch.dart';
import 'package:model_interfaces/model_interfaces.dart';

import 'list/loader.dart';

abstract class AbstractFirebaseFunctionLoaderFactory<
    I,
    T extends WithId<I>,
    F extends AbstractFilter
//
    > extends LoaderFactory<
    I,
    T,
    F
//
    > {
  final String name;

  AbstractFirebaseFunctionLoaderFactory({
    required this.name,
  });

  Future<T> denormalize(
    Map<String, dynamic> map,
  );

  Future<T> denormalizeBase(
    Map<String, dynamic> map,
  ) async {
    try {
      return await denormalize(map);

      // ignore: avoid_catches_without_on_clauses
    } catch (error, trace) {
      // TODO(alexeyinkin): Allow to silence this, https://github.com/alexeyinkin/dart-model-fetch/issues/9
      print('Error denormalizing object ${map['id']}.'); //ignore: avoid_print
      onError(error, trace);
      rethrow;
    }
  }

  @override
  ModelLoaderById<I, T> createLiveModelLoaderById(I id) =>
      throw UnimplementedError();

  @override
  ModelLoaderById<I, T> createFrozenModelLoaderById(I id) =>
      throw UnimplementedError();

  @override
  ModelLoaderByFilter<I, T> createLiveModelLoaderByFilter(F filter) =>
      throw UnimplementedError();

  @override
  ModelLoaderByFilter<I, T> createFrozenModelLoaderByFilter(F filter) =>
      throw UnimplementedError();

  @override
  ListLazyLoader<T> createLiveListLazyLoader(F filter) =>
      throw UnimplementedError();

  @override
  CloudFunctionFrozenListLazyLoader<T, F> createFrozenListLazyLoader(F filter) {
    return CloudFunctionFrozenListLazyLoader(
      denormalize: denormalizeBase,
      filter: filter,
      name: name,
      onError: onError,
      pageSize: filter.pageSize,
      // TODO: Filter.
    );
  }
}
