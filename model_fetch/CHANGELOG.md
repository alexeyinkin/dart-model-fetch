## 0.6.3

* Added `Loader` as a superinterface to `ListLoader`.
* Added `CompoundLoader`, `LoaderStreamMixin`.

## 0.6.2

* Renamed `CollectionBloc` to `ListLoader`, added a deprecated `typedef`.
* Renamed `EmptyLazyLoadBloc` to `EmptyListLazyLoader`, added a deprecated `typedef`.
* Renamed `IterableLazyLoadBloc` to `IterableLazyLoader`, added a deprecated `typedef`.
* Renamed `LazyLoadBloc` to `ListLazyLoader`, added a deprecated `typedef`.
* Renamed `ModelByFilterBloc` to `ModelLoaderByFilter`, added a deprecated `typedef`.
* Renamed `ModelByIdBloc` to `ModelLoaderById`, added a deprecated `typedef`.
* Renamed `FixedModelByIdBloc` to `FixedModelLoaderById`, added a deprecated `typedef`.
* Renamed many methods in `LoaderFactory`, added deprecated forwarders.
* Deprecated `AbstractClientFilter`.

## 0.6.1

* Added `AbstractFilter.fields`.
* Deprecated `AbstractFilter.toJson()` and `.hash`.

## 0.6.0

* **BREAKING:** Added abstract `CollectionBloc.clear()`.
* **BREAKING:** Added abstract `ModelByFilterBloc.reload()`.
* **BREAKING:** Added abstract `ModelByIdBloc.get()`.
* Added `LoaderFactory.clearFrozenLoaders()`.
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
