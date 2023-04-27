// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// XYZ Screen Generator Tool
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

const BUILD_RUNNER_COMMAND =
    "flutter packages pub run build_runner build -d --enable-experiment=records";

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

String replaceExpressions(String inputString, Map<String, String> expressions) {
  String outputString = inputString;
  for (final entry in expressions.entries) {
    final expression = RegExp(entry.key);
    final replacement = entry.value;
    outputString = outputString.replaceAllMapped(expression, (match) {
      final groups = List<String?>.filled(match.groupCount + 1, null);
      for (int i = 0; i <= match.groupCount; i++) {
        groups[i] = match.group(i);
      }
      return replacement.replaceAllMapped(RegExp(r'\{\{(\d+)\}\}'), (innerMatch) {
        int index = int.parse(innerMatch.group(1)!);
        return groups[index]!;
      });
    });
  }
  return outputString;
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

String getDesktopPath() {
  if (Platform.isMacOS) {
    return "/Users/${Platform.environment["USER"]}/Desktop";
  } else if (Platform.isWindows) {
    return "${Platform.environment["USERPROFILE"]}/${path.join('Desktop')}";
  } else if (Platform.isLinux) {
    return "/home/${Platform.environment["USER"]}/Desktop";
  } else {
    throw UnsupportedError("Unsupported platform");
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

String camelToSnakeCase(String input) {
  return input
      .replaceAllMapped(
        RegExp(r"([a-z])([A-Z0-9])"),
        (Match match) => "${match.group(1)}_${match.group(2)}",
      )
      .replaceAll(RegExp(r"_+"), "_")
      .toLowerCase();
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

Future<String> getBodyFromTemplate(String path) async {
  final body = await rootBundle.loadString(path);
  final expression = RegExp(r"```dart\s+(.*?)\s+```", dotAll: true);
  final matches = expression.allMatches(body);
  String result = "";
  for (final match in matches) {
    final group1 = match.group(1)?.trim();
    if (group1 != null) {
      result += "$group1\n";
    }
  }
  return result.trim();
}
