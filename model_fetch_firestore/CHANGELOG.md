## 0.6.0-7.dev

* **BREAKING:** Made `QueryBuilder.collectionReference` and `.collectionGroupQuery` return the objects with `withCoverter`.
  Added `.mapCollectionReference` and `.mapCollectionGroupQuery` for the old versions without it.
* Support `model_fetch` 0.6.0-7.dev.
* Add `FirestoreModel.prefix` and `.suffix` to the macro to allow generating multiple loader factories for a model.

## 0.6.0-6.dev

* Add `FirestoreModel.subcollectionsJson`.

## 0.6.0-5.dev

* `withConverter()` changed from `T` to `Future<T>`.
* Added `onError` and `dispose()` to `FirestoreLiveByIdBloc` and `FirestoreLiveByFilterBloc`.
* Moved the source of truth of the default collection from `QueryBuilder` to `AbstractFirestoreLoaderFactory`.

## 0.6.0-4.dev

* Added `id` to filters.
* Added `QueryBuilder.sourceType`.

## 0.6.0-3.dev

* Make filter constructors const.

## 0.6.0-2.dev

* Added `QueryBuilder.filter`, `.loaderFactory`, `.collectionName`, `.collectionReference`, `.emptyQuery`.
* Added `F` type parameter to `QueryBuilder`.
* Creating an unnamed constructor for a `Filter` class.

## 0.6.0-1.dev

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
