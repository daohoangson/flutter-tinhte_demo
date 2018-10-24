import 'dart:convert';
import 'dart:async';

import '../api.dart';
import '../batch_job.dart';

class Batch {
  final String path;
  final Completer _completer = Completer();
  final List<BatchJob> _jobs = List();

  String get bodyJson {
    print('Batch has ${_jobs.length} jobs');
    for (final _job in _jobs) {
      print("Batch job ${_job.id}: ${_job.method} ${_job.uri}");
    }

    return json.encode(_jobs);
  }

  int get length => _jobs.length;
  Future get future => _completer.future;

  Batch({this.path});

  Future newJob(String method, String uri, Map<String, String> params) {
    final String id = 'job' + (_jobs.length + 1).toString();
    BatchJob job = BatchJob(id, method, uri, params);
    _jobs.add(job);

    return job.future;
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
        job.completer.completeError(ApiError(message: jsonJob['_job_error']));
        return;
      }

      job. completer.completeError(ApiError(message: jobResult));
      return;
    });

    _completer.complete(jsonAsMap);
    return true;
  }
}
