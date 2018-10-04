import 'dart:async';
import 'batch.dart';

typedef Future<bool> FunctionFetch();

class BatchController {
  final Batch _batch;
  final FunctionFetch fetch;

  int get length => _batch.length;

  BatchController(this._batch, this.fetch);
}
