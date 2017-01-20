// Copyright (c) 2017, presubmit authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:args/args.dart';
import 'package:path/path.dart' as p;

/// Parses CLI arguments into a format that the presubmit runner can understand.
final ArgParser argsParser = new ArgParser()
  ..addFlag(
    'dartanalyzer',
    help: 'Whether to ensure the package passes static code analysis',
    defaultsTo: true,
  )
  ..addFlag(
    'dartfmt',
    help: 'Whether to ensure the package has been formatted using dartfmt',
    defaultsTo: true,
  )
  ..addFlag(
    'help',
    help: 'Show CLI usage and options',
    negatable: false,
  )
  ..addOption(
    'path',
    help: 'A path to a pub package to run the presubmit for',
    defaultsTo: p.current,
  )
  ..addFlag(
    'tests',
    help: 'Whether to run "pub run test"',
    defaultsTo: true,
  );
