// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

import 'model.dart';
import 'sdk_env.dart';

const documentationSectionTitle = 'Package has documentation';

List<Suggestion> getDartdocSuggestions(DartdocResult result) {
  if (result == null) {
    return null;
  }

  final suggestions = <Suggestion>[];

  if (!result.wasSuccessful) {
    suggestions.add(getDartdocRunFailedSuggestion(result));
  }

  return suggestions.isEmpty ? null : suggestions;
}

Suggestion getDartdocRunFailedSuggestion([DartdocResult result]) {
  final errorMessage = result?.processResult?.stderr?.toString() ?? '';
  return Suggestion.error(
    SuggestionCode.dartdocAborted,
    "Make sure `dartdoc` successfully runs on your package's source files.",
    'Running `dartdoc` failed with the following output:\n\n```\n$errorMessage\n```\n',
    score: 10.0,
  );
}

/// Creates a report section about documentation coverage.
/// 20% coverage grants the maximum number of points.
ReportSection documentationCoverageSection({
  @required int documented,
  @required int total,
}) {
  final percent = total <= 0 ? 1.0 : documented / total;
  final accepted = percent >= 0.2;
  final granted = accepted ? 10 : 0;
  final undocumented = total - documented;
  return ReportSection(
    title: documentationSectionTitle,
    grantedPoints: granted,
    maxPoints: 10,
    summary: accepted
        ? 'At least 20% of the public API has documentation comments.'
        : '$undocumented out of $total API elements have no dartdoc comment. '
            'Providing good documentation for libraries, classes, functions, and other API '
            'elements improves code readability and helps developers find and use your API. '
            'Document at least 20% of the public API elements.',
  );
}

/// Creates a report section when running dartdoc failed to produce content.
ReportSection dartdocFailedSection(DartdocResult result) {
  final suggestion = getDartdocRunFailedSuggestion(result);
  return ReportSection(
    title: documentationSectionTitle,
    grantedPoints: 0,
    maxPoints: 10,
    summary: suggestion.description,
  );
}
