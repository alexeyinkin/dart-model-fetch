## 0.7.0

* **BREAKING:** Dropped `FirestoreModel` macro.
* **BREAKING:** `AbstractFirestoreLoaderFactory` by default creates loaders that only load from server and not from cache.
* **BREAKING:** Require Dart 3.6+ and workspace resolution.
* Added optional `options` to the `AbstractFirestoreLoaderFactory` constructor to override that.
* Added optional `options` to the `FirestoreFrozenListLazyLoader` constructor.
* Support [cloud_firestore](https://pub.dev/packages/cloud_firestore) v6.0.0+.

## 0.6.4

* Extracted `AbstractFirestoreLoaderFactory.onError()` to `LoaderFactory` from model_fetch v0.6.4.

## 0.6.3

* Extracted the management of loading to `Loader` from model_fetch v0.6.3.

## 0.6.2

* Handling concurrent loading attempts.
* Renamed `FirestoreLazyLoadBloc` to `FirestoreListLazyLoader`.
* Renamed `FirestoreFrozenLazyLoadBloc` to `FirestoreFrozenListLazyLoader`.
* Renamed `FirestoreLiveSingleDocumentCollectionBloc` to `FirestoreLiveSingleDocumentListLoader`.
* Renamed `FirestoreLiveByFilterBloc` to `FirestoreLiveModelLoaderByFilter`.
* Renamed `FirestoreLiveByIdBloc` to `FirestoreLiveModelLoaderById`.

## 0.6.1

* Generating filter parameters from the model String fields, filtering by them in `QueryBuilder`.

## 0.6.0

* **BREAKING:** Made `QueryBuilder.collectionReference` and `.collectionGroupQuery` return the objects with `withCoverter`.
  Added `.mapCollectionReference` and `.mapCollectionGroupQuery` for the old versions without it.
* Support `model_fetch` 0.6.0-7.dev.
* Added `FirestoreModel.prefix` and `.suffix` to the macro to allow generating multiple loader factories for a model.
* Added `FirestoreModel.subcollectionsJson`.
* `withConverter()` changed from `T` to `Future<T>`.
* Added `onError` and `dispose()` to `FirestoreLiveByIdBloc` and `FirestoreLiveByFilterBloc`.
* Moved the source of truth of the default collection from `QueryBuilder` to `AbstractFirestoreLoaderFactory`.
* Added `id` to filters.
* Added `QueryBuilder.sourceType`.
* Make filter constructors const.
* Added `QueryBuilder.filter`, `.loaderFactory`, `.collectionName`, `.collectionReference`, `.emptyQuery`.
* Added `F` type parameter to `QueryBuilder`.
* Creating an unnamed constructor for a `Filter` class.
* Added `@FirestoreModel` macro.
* `AbstractFirestoreLoaderFactory.onError` made non-abstract, it prints the error.

## 0.5.7

* Support [cloud_firestore](https://pub.dev/packages/cloud_firestore) v5.0.0+.

## 0.5.6

* Bloc management extracted to the `LoaderFactory` of `model_fetch`.

## 0.5.5

* Fixed unrecognized platforms on pub.dev.

## 0.5.4

* Added `FirestoreLiveByFilterBloc`.

## 0.5.3

* Added `FirestoreFrozenLazyLoadBloc.loadAllIfCan()`.

## 0.5.2

* Added `onError` to `FirestoreLazyLoadBloc`, `FirestoreFrozenLazyLoadBloc`, `FirestoreLiveSingleDocumentCollectionBloc`.

## 0.5.0

* **BREAKING:** Renamed `FirestoreFrozenLazyLoadBloc.fetchSize` to `pageSize`.
* Add `AbstractFirestoreLoaderFactory`.

## 0.4.0

* **BREAKING:** `FirestoreFrozenLazyLoadBloc.backgroundReloadFirstPage` is asynchronous.
* **BREAKING:** Support and require `model_interfaces` v0.3.0.
* Fixed linter issues.
* Use `total_lints`.
* Licensed under MIT-0.

## 0.3.0

* Added `FirestoreLiveSingleDocumentCollectionBloc`.

## 0.2.0

* Added `FirestoreLiveByIdBloc`.

## 0.1.1

* Removed debug output and comments.
* Support client filters.

## 0.1.0

* Initial release.
