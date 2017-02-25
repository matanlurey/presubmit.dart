// Copyright (c) 2017, presubmit authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:presubmit/src/plugin.dart';

class DartAnalyzerPlugin implements Plugin {
  static const List<String> _knownDartPaths = const [
    'bin',
    'lib',
    'tool',
    'test',
  ];

  static Future<Plugin> plugin([Map options]) async {
    options ??= const {};
    final path = options['path'] as String;
    if (path == null) {
      throw new ArgumentError('Expected an option of "path"');
    }
    final strong = options['strong'] ?? true;
    return new DartAnalyzerPlugin(path: path, strong: strong);
  }

  /// What path the `dartanalyzer` should run against.
  final String path;

  /// Whether to run using _strong_ mode.
  ///
  /// **NOTE**: This is superseded if a `.analysis_options` file is found in
  /// [path] - those defaults are used instead (including whether or not to run
  /// using strong-mode and configuration like lints).
  final bool strong;

  const DartAnalyzerPlugin({@required this.path, @required this.strong});

  @override
  final String name = 'dartanalyzer';

  @override
  Stream<Result> run() async* {
    if (path == null) {
      throw new ArgumentError.notNull('path');
    }
    final maybeAnalysisOptions = new File(_analysisOptions);
    List<String> args;
    if (maybeAnalysisOptions.existsSync()) {
      args = [
        '--fatal-hints',
        '--fatal-lints',
        '--fatal-warnings',
        '--format=machine',
        '--options=${maybeAnalysisOptions.path}',
      ];
    } else {
      args = [
        '--fatal-hints',
        '--fatal-lints',
        '--fatal-warnings',
        '--format=machine',
        strong ? '--strong' : '--no-strong',
      ];
    }
    args.addAll(
      _knownDartPaths.where(
        (dir) => new Directory(p.join(path, dir)).existsSync(),
      ),
    );
    final process = await Process.start('dartanalyzer', args);
    final ls = const LineSplitter();
    await for (final message in process.stderr.map(UTF8.decode).transform(ls)) {
      final parts = message.split('|');
      if (parts.length >= 6) {
        final file = p.relative(parts[3], from: path);
        final line = parts[4];
        final col = parts[5];
        final msg =
            '@$line:$col ${parts[0]}(${parts[1]}, ${parts[2]}): ${parts.last}';
        yield new Result(
          file,
          false,
          message: msg,
        );
      } else {
        yield new Result(
          '<Unknown>',
          false,
          message: 'Unknown error: $message',
        );
      }
    }
    yield ((await process.exitCode == 0) ? Result.success : Result.failure);
  }

  String get _analysisOptions => p.join(path, '.analysis_options');
}
