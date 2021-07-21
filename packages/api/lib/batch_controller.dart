import 'dart:async';

import 'src/batch.dart';

typedef FunctionFetch = Future<bool> Function();

class BatchController {
  final Batch _batch;
  final FunctionFetch fetch;

  int get length => _batch.length;

  BatchController(this._batch, this.fetch);
}
