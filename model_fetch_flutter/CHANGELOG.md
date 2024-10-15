## 0.6.4

* Added `LazyLoadListView.itemBuilder`, `.loadingBuilder`.

## 0.6.3

* Added `LoaderBuilder`.

## 0.6.2

* Added `.asListenable()` extension methods to `ListLoader`, `ModelLoaderByFilter`, and `ModelLoaderById`.
* Added `LoaderValueNotifier`, `LoaderValueListNotifier`.
* Added `LazyLoadListView`, `LoaderDropdownButton`, `LoaderSelectableListView`,
  `LoaderSelectablePopUpListView`, `ModelCapsuleWidget`, `ModelListItem`.
* Added `ListLazyLoaderAutoLoadMoreWidget`, deprecated `BlocAutoLoadMoreWidget` in favor of it.
* Added `ListLazyLoaderTrailingWidget`, deprecated `LazyLoadBlocTrailingWidget` in favor of it.
* Deprecated `CollectionBlocBuilder` in favor of `ListenableBuilder` with `.asListenable()`.

## 0.6.0

* Made the default builder of `LazyLoadBlocTrailingWidget` trigger loading the data.
* Support [model_fetch](https://pub.dev/packages/model_fetch) v0.6.0.

## 0.5.6

* Support `visibility_detector` v0.4.x in addition to v0.3.3.

## 0.5.5

* Upgrade to `total_lints` v3.1.0.

## 0.5.1

* Added `BlocAutoLoadMoreWidget`, `LazyLoadBlocTrailingWidget`.
* Deprecated `LoadMoreWidget`.

## 0.5.0

* Support and require `model_fetch` v0.5.*

## 0.4.0

* **BREAKING:** Support and require `model_interfaces` v0.3.*
* Fixed linter issues.
* Use `total_lints`.
* Licensed under MIT-0.

## 0.3.0

* **BREAKING**: Renamed `LazyLoadBuilder` to `CollectionBlocBuilder`.

## 0.2.1

* Support and require Flutter 3.0.
* Loose [visibility_detector](https://pub.dev/packages/visibility_detector) version requirements after [#354](https://github.com/google/flutter.widgets/issues/354).

## 0.2.0

* Updated dependencies.

## 0.1.0

* Initial release.
