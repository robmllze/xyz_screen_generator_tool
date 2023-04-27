// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// XYZ Screen Generator Tool
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

import 'utils.dart';
import 'main.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

String generateLogicFileBody({
  required String outputName,
  required String className,
}) {
  return replaceExpressions(templateLogic, {
    "___SCREEN_FILE_NAME___": "$outputName.dart",
    "___CLASS_NAME___": className,
  });
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

String generateStateFileBody({
  required String outputName,
  required String className,
}) {
  return replaceExpressions(templateState, {
    "___SCREEN_FILE_NAME___": "$outputName.dart",
    "___CLASS_NAME___": className,
  });
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

String generateScreenFileBody({
  required String outputName,
  required String className,
  required String accessibility,
  required String makeup,
  required String title,
  required List<String> accessibilityOptions,
  required List<bool> flagOptions,
}) {
  final isAccessibilityAlways = accessibility == accessibilityOptions[0];
  final isOnlyAccessibleIfSignedIn = accessibility == accessibilityOptions[1];
  final isOnlyAccessibleIfSignedInAndVerified = accessibility == accessibilityOptions[2];
  final isOnlyAccessibleIfSignedOut = accessibility == accessibilityOptions[3];
  final isRedirectable = flagOptions[0];
  final bottomNavigationBar = flagOptions[1];

  return replaceExpressions(templateScreen, {
    "___SCREEN_G_FILE_NAME___": "$outputName.g.dart",
    "___CLASS_NAME___": className,
    "___GENERATE_SCREEN_ACCESS___": "${() {
      if (isOnlyAccessibleIfSignedIn) return "\n  isOnlyAccessibleIfSignedIn: true,\n";
      if (isOnlyAccessibleIfSignedInAndVerified)
        return "\n  isOnlyAccessibleIfSignedInAndVerified: true,\n";
      if (isOnlyAccessibleIfSignedOut) return "\n  isOnlyAccessibleIfSignedOut: true,\n";
      if (isAccessibilityAlways) return "";
    }()}${isRedirectable ? "" : "\n  isRedirectable: false,\n"}",
    "___SUPER_CLASS_ARGUMENTS___":
        "${makeup != "Default" ? "\n          G.theme.myScreen$makeup()," : ""}${title.isNotEmpty ? '\n          title: "$title::title".screenTr(),\n' : ""}${bottomNavigationBar ? "" : "\n          bottomNavigationBar: null,"}",
  });
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

String generateScreenGFileBody({
  required String outputName,
}) {
  return replaceExpressions(templateScreenG, {
    "___SCREEN_FILE_NAME___": "$outputName.g.dart",
  });
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

Future<void> generateTemplate({
  required String className,
  required String outputPath,
  required String title,
  required String accessibility,
  required String makeup,
  required Map<String, bool> flags,
  required BuildContext context,
  required List<String> accessibilityOptions,
}) async {
  try {
    className = className.isNotEmpty ? className : "ScreenPleaseRenameMe${Random().nextInt(10000)}";
    final outputName = camelToSnakeCase(className);
    final outputFolderPath = path.join(outputPath, outputName);
    final outputFolder = Directory(outputFolderPath);
    await outputFolder.create(recursive: true);
    final logicFile = File(path.join(outputFolderPath, "_logic.dart"));
    final stateFile = File(path.join(outputFolderPath, "_state.dart"));
    final screenFile = File(path.join(outputFolderPath, "$outputName.dart"));
    final generatedFile = File(path.join(outputFolderPath, "$outputName.g.dart"));
    await logicFile.writeAsString(
      generateLogicFileBody(
        outputName: outputName,
        className: className,
      ),
    );
    await stateFile.writeAsString(
      generateStateFileBody(
        outputName: outputName,
        className: className,
      ),
    );
    await screenFile.writeAsString(
      generateScreenFileBody(
        outputName: outputName,
        className: className,
        accessibility: accessibility,
        makeup: makeup,
        title: title,
        accessibilityOptions: accessibilityOptions,
        flagOptions: flags.values.toList(),
      ),
    );
    await generatedFile.writeAsString(
      generateScreenGFileBody(
        outputName: outputName,
      ),
    );

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Success!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "The generated files were saved at:",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12.0),
              TextField(
                controller: TextEditingController(text: outputFolderPath),
                readOnly: true,
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.grey)),
                child: Text("COPY"),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: outputFolderPath));
                },
              ),
              const SizedBox(height: 32.0),
              Text(
                "Run the following command to generate the access files:",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12.0),
              TextField(
                controller: TextEditingController(text: BUILD_RUNNER_COMMAND),
                readOnly: true,
              ),
              const SizedBox(height: 9.0),
              ElevatedButton(
                style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.grey)),
                child: Text("COPY"),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: BUILD_RUNNER_COMMAND));
                },
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("CLOSE"),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  } catch (e) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Error!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${e.toString()}",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("CLOSE"),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
