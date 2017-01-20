# presubmit

**NOT YET AVAILABLE**: Watch this package for updates.

A _batteries included_ package to validate whether the working revision of a
Dart package conforms to testing and contribution requirements. Stated simply,
"something to run on continuous integration before merging pull requests".

## Planned work

A high-level list of work required to get this close to an initial release:

### Running modes

- [ ] Allow running as a binary (i.e. `pub run presubmit`)
- [ ] Allow specifying binary arguments via the command-line
- [ ] Allow specifying binary arguments via `presubmit.yaml`
- [ ] Allow programmatic use, i.e. write your own `tool/presubmit.dart`

### Built-in plugins

- [ ] Run the Dart analyzer and linter
- [ ] Run the Dart formatter
- [ ] Run the Dart test runner (`pub run test`)
- [ ] Run an offline source generator (i.e. a `build.dart` file)

### Extensibility

- [ ] Allow defining your own plugin (unclear how this works yet)
- [ ] Run nested sets of plugins (i.e. run program, run tests, close program)
