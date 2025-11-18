/// Simple boundary enforcement script (stub).
/// Ensures UI layer does not import data layer directly.
/// Extend with real path rules as project grows.
library;

import 'dart:io';

final forbiddenPairs = <String, String>{
  // key: disallowed importer substring, value: disallowed import target substring
  'packages/feature_': 'packages/core/data',
};

void main() {
  final violations = <String>[];
  final dartFiles = Directory('.')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  for (final file in dartFiles) {
    final content = file.readAsStringSync();
    for (final entry in forbiddenPairs.entries) {
      if (file.path.contains(entry.key) && content.contains(entry.value)) {
        violations.add('${file.path} imports forbidden ${entry.value}');
      }
    }
  }

  if (violations.isNotEmpty) {
    stderr.writeln('Boundary violations found:');
    for (final v in violations) {
      stderr.writeln('- $v');
    }
    exit(1);
  } else {
    print('Boundary check passed.');
  }
}
