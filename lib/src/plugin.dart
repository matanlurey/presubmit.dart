// Copyright (c) 2017, presubmit authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

/// Returns a future that completes with a simple `true/false` if successful.
///
/// A value of `false` may be considered a presubmit _failure_.
Future<bool> isSuccess(Stream<Result> results) {
  return results.any((r) => r.isSuccess);
}

/// Represents a tool that runs as part of the presubmit process.
abstract class Plugin {
  /// Name of the plugin.
  String get name;

  /// Runs the plugin.
  ///
  /// Returns a stream of results that reports status.
  Stream<Result> run();
}

typedef Future<Plugin> _PluginFactory([Map options]);

class PluginRegistry {
  final Set<_PluginFactory> _plugins = new Set<_PluginFactory>();

  /// Returns a stream of plugins as they are created, in order.
  Stream<Plugin> create([Map options = const {}]) async* {
    for (final factory in _plugins) {
      yield await factory(options);
    }
  }

  /// Adds a plugin [factory] explaining how to create it when needed.
  void register(Future<Plugin> factory([Map options])) {
    _plugins.add(factory);
  }
}

/// A result, potentially partial, from running a plugin.
abstract class Result {
  /// Represents a simple "this plugin reported a failure".
  static const Result failure = const _SimpleResult(false);

  /// Represents a simple "this plugin reported a success".
  static const Result success = const _SimpleResult(true);

  factory Result(String path, bool success, {String message}) = _PathResult;

  /// Message describing the state, if any.
  String get message;

  /// The file or directory name that either failed or passed if any.
  ///
  /// May be `null` representing not file or directory specific.
  String get path;

  /// Whether this result is a reported failure.
  bool get isFailure;

  /// Whether this result is a reported success.
  bool get isSuccess;
}

class _PathResult implements Result {
  @override
  final String path;

  @override
  final String message;

  @override
  final bool isSuccess;

  const _PathResult(this.path, this.isSuccess, {this.message});

  @override
  bool get isFailure => !isSuccess;

  @override
  String toString() => '$Result {$path: $message}';
}

class _SimpleResult implements Result {
  @override
  final bool isSuccess;

  const _SimpleResult(this.isSuccess);

  @override
  bool get isFailure => !isSuccess;

  @override
  final String message = null;

  @override
  final String path = null;

  @override
  String toString() => '$Result {$message}';
}
