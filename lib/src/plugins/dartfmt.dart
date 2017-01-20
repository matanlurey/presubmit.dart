// Copyright (c) 2017, presubmit authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:presubmit/src/plugin.dart';

class DartFormatterPlugin implements Plugin {
  static Future<Plugin> plugin([Map options]) async {
    options ??= const {};
    final path = options['path'] as String;
    if (path == null) {
      throw new ArgumentError('Expected an option of "path"');
    }
    return new DartFormatterPlugin(path: path);
  }

  final String path;

  @literal
  const DartFormatterPlugin({@required this.path});

  @override
  final String name = 'darfmt';

  @override
  Stream<Result> run() async* {
    if (path == null) {
      throw new ArgumentError.notNull('path');
    }
    final process = await Process.start('dartfmt', [
      '--dry-run',
      '--set-exit-if-changed',
      path,
    ]);
    await for (final pathNeedingFormat in process.stdout.map(UTF8.decode)) {
      yield new Result(
        pathNeedingFormat.trim(),
        false,
        message: 'Needs dartfmt',
      );
    }
    yield ((await process.exitCode == 0) ? Result.success : Result.failure);
  }
}
