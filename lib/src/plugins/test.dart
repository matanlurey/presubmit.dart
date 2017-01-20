// Copyright (c) 2017, presubmit authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:presubmit/src/plugin.dart';

class TestPlugin implements Plugin {
  static Future<Plugin> plugin([Map options]) async {
    options ??= const {};
    final path = options['path'] as String;
    if (path == null) {
      throw new ArgumentError('Expected an option of "path"');
    }
    return new TestPlugin(path: path);
  }

  final String path;

  @literal
  const TestPlugin({@required this.path});

  @override
  final String name = 'pub run test';

  @override
  Stream<Result> run() async* {
    if (path == null) {
      throw new ArgumentError.notNull('path');
    }
    final process = await Process.start('pub', const ['run', 'test']);
    await for (final message in process.stdout.map(UTF8.decode)) {
      stderr.writeln(message);
    }
    yield ((await process.exitCode == 0) ? Result.success : Result.failure);
  }
}
