// Copyright (c) 2017, presubmit authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:presubmit/src/cli/arguments.dart';
import 'package:presubmit/src/options.dart';
import 'package:presubmit/src/plugin.dart';
import 'package:presubmit/src/plugins/analyzer.dart';
import 'package:presubmit/src/plugins/dartfmt.dart';
import 'package:presubmit/src/plugins/test.dart';

Future<Null> main(List<String> args) async {
  final results = argsParser.parse(args);
  if (results.wasParsed('help')) {
    stderr.writeln(argsParser.usage);
    exitCode = 1;
    return;
  }
  final options = new PresubmitOptions.fromArgs(results);
  stderr.writeln('DIAGNOSTICS');
  stderr.writeln('-' * 80);
  stderr.writeln(options);
  stderr.writeln('-' * 80);
  final plugins = new PluginRegistry();
  if (options.runDartAnalyzer) {
    plugins.register(DartAnalyzerPlugin.plugin);
  }
  if (options.runDartFormatter) {
    plugins.register(DartFormatterPlugin.plugin);
  }
  if (options.runTests) {
    plugins.register(TestPlugin.plugin);
  }
  var anyPluginFailed = false;
  await for (final plugin in plugins.create({'path': options.path})) {
    var hadSuccess = true;
    await for (final result in plugin.run()) {
      if (hadSuccess && result.isFailure) {
        hadSuccess = false;
      }
      if (result.path != null) {
        stderr.writeln('${plugin.name}: ${result.path}');
        if (result.message != null) {
          stderr.writeln(result.message);
          stderr.writeln();
        }
      }
    }
    stderr.writeln(
      'Summary for ${plugin.name}: ${hadSuccess ? 'PASS' : 'FAIL'}',
    );
    stderr.writeln();
    if (!anyPluginFailed && !hadSuccess) {
      anyPluginFailed = true;
    }
  }
  if (anyPluginFailed) {
    stderr.writeln('Summmary: FAIL');
    stderr.writeln('Presubmit failed since at least one plugin did not pass');
    exitCode = 1;
  } else {
    stderr.writeln('Summary: PASS');
    exitCode = 0;
  }
}
