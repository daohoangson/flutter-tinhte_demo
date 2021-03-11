import 'dart:convert';
import 'dart:async';

import '../api.dart';
import '../batch_job.dart';
import 'crypto.dart';

class Batch {
  final String path;
  final Completer _completer = Completer();

  final _jobs = <BatchJob>[];
  final Map<String, BatchJob> _uniqueJobs = Map();

  String get bodyJson {
    print('Batch has ${_jobs.length} jobs, ${_uniqueJobs.length} unique');
    for (final _job in _jobs) {
      print("Batch job ${_job.id}: ${_job.method} ${_job.uri}");
    }

    return json.encode(_uniqueJobs.values.toList());
  }

  int get length => _jobs.length;
  Future get future => _completer.future;

  Batch({required this.path});

  Future newJob(String method, String uri, {Map<String, String>? params}) {
    final String id = 'job' + (_jobs.length + 1).toString();
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

  bool handleResponse(json) {
    Map<String, dynamic> jsonAsMap =
        json is Map<String, dynamic> ? json : Map();
    Map<String, dynamic> jsonJobs =
        jsonAsMap.containsKey('jobs') ? jsonAsMap['jobs'] : Map();

    _jobs.forEach((job) {
      Map<String, dynamic> jsonJob =
          jsonJobs.containsKey(job.id) ? jsonJobs[job.id] : Map();
      String jobResult = jsonJob.containsKey('_job_result')
          ? jsonJob['_job_result']
          : "No job result (${job.method} ${job.uri.replaceAll(RegExp(r'\?.+$'), '')})";

      if (jobResult == 'ok') {
        job.completer.complete(jsonJob);
        return;
      }

      if (jsonJob.containsKey('_job_error')) {
        job.completer
            .completeError(ApiErrorSingle(jsonJob['_job_error'], isHtml: true));
        return;
      }

      job.completer.completeError(ApiErrorSingle(jobResult, isHtml: true));
      return;
    });

    _completer.complete(jsonAsMap);
    return true;
  }
}
