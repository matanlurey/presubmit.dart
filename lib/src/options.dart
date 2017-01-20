// Copyright (c) 2017, presubmit authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:args/args.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

/// Understood options and configuration for running a presubmit.
class PresubmitOptions {
  final String path;

  final bool runDartAnalyzer;
  final bool runDartFormatter;
  final bool runTests;

  /// Creates a new set of options for running a presubmit.
  factory PresubmitOptions({
    String path,
    bool runDartAnalyzer: true,
    bool runDartFormatter: true,
    bool runTests: true,
  }) =>
      new PresubmitOptions._(
        path: path ?? p.current,
        runDartAnalyzer: runDartAnalyzer,
        runDartFormatter: runDartFormatter,
        runTests: runTests,
      );

  /// Creates a new set of options for running a presubmit from [parsedArgs].
  factory PresubmitOptions.fromArgs(
    ArgResults parsedArgs,
  ) =>
      new PresubmitOptions(
        path: parsedArgs['path'],
        runDartAnalyzer: parsedArgs['dartanalyzer'],
        runDartFormatter: parsedArgs['dartfmt'],
        runTests: parsedArgs['tests'],
      );

  const PresubmitOptions._({
    @required this.path,
    @required this.runDartAnalyzer,
    @required this.runDartFormatter,
    @required this.runTests,
  });

  String _toJson() => const JsonEncoder.withIndent('  ').convert({
        'path': path,
        'runDartAnalyzer': runDartAnalyzer,
        'runDartFormatter': runDartFormatter,
        'runTests': runTests,
      });

  @override
  String toString() => '$PresubmitOptions ${_toJson()}';
}
