## 0.6.0-5.dev

* **BREAKING:** Added abstract `ModelByIdBloc.get()`.
* Support [rxdart](https://pub.dev/packages/rxdart) 0.28.

## 0.5.6

* Added `LoaderFactory`.
* Added `EmptyLazyLoadBloc`, `IterableLazyLoadBloc`, `FixedModelByIdBloc`.
* Added `ModelByIdBloc.reload()`.
* Added `AsyncDisposable` as interface to all blocs.

## 0.5.5

* Added `CollectionBloc.currentState`.

## 0.5.4

* Added `ModelByFilterBloc`.

## 0.5.3

* Added `LazyLoadBloc.loadAllIfCan()`.

## 0.5.2

* Downgrade the Dart SDK upper limit to `<3.0.0` from `<4.0.0` because of incomplete support by pub.dev.

## 0.5.1

* Added `CollectionBloc.onError`, `LazyLoadBloc.onError`.

## 0.5.0

* Added `AbstractFilter.pageSize`.

## 0.4.0

* **BREAKING:** `CollectionBloc.dispose` and `ModelByIdBloc.dispose` are asynchronous.
* **BREAKING:** Support and require `model_interfaces` v0.3.0.
* Use `total_lints`.
* Licensed under MIT-0.

## 0.3.0

* **BREAKING**: Renamed `LazyLoadState` to `CollectionState`.
* Added `CollectionBloc` as a superclass of `LazyLoadBloc`.

## 0.2.0

* **BREAKING**: Renamed `LazyLoadStatus` to `LoadStatus`.
* Added `ModelByIdBloc`.

## 0.1.0

* Initial release.
