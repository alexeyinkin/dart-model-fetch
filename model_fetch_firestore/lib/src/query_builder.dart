import 'package:cloud_firestore/cloud_firestore.dart';

abstract class QueryBuilder<T> {
  Query<T> get query;
}
