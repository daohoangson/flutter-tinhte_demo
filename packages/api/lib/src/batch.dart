import 'dart:convert';
import 'dart:async';
import 'dart:developer';

import '../api.dart';
import '../batch_job.dart';
import 'crypto.dart';

class Batch {
  final String path;
  final Completer _completer = Completer();

  final _jobs = <BatchJob>[];
  final _uniqueJobs = <String, BatchJob>{};

  String get bodyJson {
    log('Batch has ${_jobs.length} jobs, ${_uniqueJobs.length} unique');
    for (final job in _jobs) {
      log("Batch job ${job.id}: ${job.method} ${job.uri}");
    }

    return json.encode(_uniqueJobs.values.toList());
  }

  int get length => _jobs.length;
  Future get future => _completer.future;

  Batch({required this.path});

  Future newJob(String method, String uri, {Map<String, String>? params}) {
    final String id = 'job${_jobs.length + 1}';
    final String paramsAsString = json.encode(params);
    final String signature = "$method$uri$paramsAsString";
    final String hash = md5(signature);

    final prevJob = _uniqueJobs[hash];
    if (prevJob != null) {
      final duplicateJob = BatchJob(prevJob.id, method, uri, params);
      _jobs.add(duplicateJob);

      return duplicateJob.future;
    }

    final newJob = BatchJob(id, method, uri, params);
    _jobs.add(newJob);
    _uniqueJobs[hash] = newJob;

    return newJob.future;
  }

  bool handleError(Object error, StackTrace stackTrace) {
    for (final job in _jobs) {
      job.completer.completeError(error, stackTrace);
    }
    return false;
  }

  bool handleResponse(json) {
    Map<String, dynamic> jsonAsMap = json is Map<String, dynamic> ? json : {};
    Map<String, dynamic> jsonJobs = jsonAsMap['jobs'] ?? {};

    for (final job in _jobs) {
      Map<String, dynamic> jsonJob = jsonJobs[job.id] ?? {};
      String jobResult = jsonJob.containsKey('_job_result')
          ? jsonJob['_job_result']
          : "No job result (${job.method} ${job.uri.replaceAll(RegExp(r'\?.+$'), '')})";

      if (jobResult == 'ok') {
        job.completer.complete(jsonJob);
        continue;
      }

      if (jsonJob.containsKey('_job_error')) {
        job.completer
            .completeError(ApiErrorSingle(jsonJob['_job_error'], isHtml: true));
        continue;
      }

      job.completer.completeError(ApiErrorSingle(jobResult, isHtml: true));
    }

    _completer.complete(jsonAsMap);
    return true;
  }
}
