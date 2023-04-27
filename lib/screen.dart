// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// XYZ Screen Generator Tool
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'generate_template.dart';
import 'my_title.dart';
import 'utils.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class Screen extends StatefulWidget {
  @override
  _State createState() => _State();
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class _State extends State<Screen> {
  //
  //
  //

  final _cClassName = TextEditingController(text: "");
  final _cOutputName = TextEditingController(text: "");
  final _cTitle = TextEditingController(text: "");
  final _cApplicationPath = TextEditingController(text: "");
  final _cExecutablePath = TextEditingController(text: "");
  final _cOutputPath = TextEditingController(text: ".");

  final _flags = <String, bool>{
    "Enable: isRedirectable": false,
    "Enable: bottomNavigationBar": true,
  };

  final _accessibilityOptions = <String>[
    "Always",
    "Only if signed in",
    "Only if signed in and verified",
    "Only if signed out",
  ];
  late var _accessibility = _accessibilityOptions[0];

  final _makeupOptions = <String>[
    "Default",
    "Overlay",
    "Clear",
  ];
  late var _makeup = _makeupOptions[0];

  //
  //
  //

  @override
  void initState() {
    this._cClassName
      ..addListener(() {
        this._cOutputName.text = camelToSnakeCase(this._cClassName.text);
      });

    this._cExecutablePath.text = Directory(Platform.resolvedExecutable).path;
    this._cOutputPath.text = getDesktopPath();
    getApplicationDocumentsDirectory().then(
      (value) => this.setState(() {
        this._cApplicationPath.text = value.path;
      }),
    );
    super.initState();
  }

  //
  //
  //

  @override
  void dispose() {
    this._cTitle.dispose();
    this._cClassName.dispose();
    this._cOutputName.dispose();
    this._cApplicationPath.dispose();
    this._cOutputPath.dispose();
    super.dispose();
  }

  //
  //
  //

  @override
  Widget build(final context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyTitle(
                    title: "Class Name",
                    subtitle: "Always start class names with Screen***",
                    child: TextField(
                      controller: this._cClassName,
                      decoration: InputDecoration(
                        hintText: "e.g. ScreenSignIn",
                      ),
                    ),
                  ),
                  MyTitle(
                    title: "Output Name",
                    child: TextField(
                      controller: this._cOutputName,
                      readOnly: true,
                    ),
                  ),
                  MyTitle(
                    title: "Title",
                    subtitle: "Optional",
                    child: TextField(
                      controller: this._cTitle,
                      decoration: InputDecoration(hintText: "e.g. Sign In"),
                    ),
                  ),
                  MyTitle(
                    title: "Screen Accessibility",
                    subtitle: "This determines when the screen is accessible",
                    child: DropdownButton<String>(
                      value: this._accessibility,
                      items:
                          this._accessibilityOptions.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        this.setState(() => this._accessibility = newValue!);
                      },
                    ),
                  ),
                  MyTitle(
                    title: "Makeup",
                    subtitle: "This determines the background color of the screen",
                    child: DropdownButton<String>(
                      value: this._makeup,
                      items: this._makeupOptions.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        this.setState(() => this._makeup = newValue!);
                      },
                    ),
                  ),
                  MyTitle(
                    title: "Additional Options",
                    subtitle:
                        "isRedirectable means it's accessible by typing, e.g. myapp.com/redirectable_screen",
                    child: Column(
                      children: this._flags.entries.map(
                        (final e) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: e.value,
                                  onChanged: (value) {
                                    this.setState(() {
                                      this._flags[e.key] = value!;
                                    });
                                  },
                                ),
                                Text("${e.key}")
                              ],
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  MyTitle(
                    title: "Application Path",
                    subtitle:
                        "Where with respect to the Executable Path to save the generated files",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: this._cApplicationPath,
                          readOnly: true,
                        ),
                        const SizedBox(height: 8.0),
                        ElevatedButton(
                          style:
                              ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.grey)),
                          child: Text("COPY"),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: this._cApplicationPath.text));
                          },
                        ),
                      ],
                    ),
                  ),
                  MyTitle(
                    title: "Executable Path",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: this._cExecutablePath,
                          readOnly: true,
                        ),
                        const SizedBox(height: 8.0),
                        ElevatedButton(
                          style:
                              ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.grey)),
                          child: Text("COPY"),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: this._cExecutablePath.text));
                          },
                        ),
                      ],
                    ),
                  ),
                  MyTitle(
                    title: "Output Path",
                    subtitle:
                        "Where with respect to the Executable Path to save the generated files",
                    child: TextField(
                      controller: this._cOutputPath,
                    ),
                  ),
                ].map((e) {
                  return Padding(padding: EdgeInsets.all(16.0), child: e);
                }).toList(),
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          color: Colors.blue[100],
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  generateTemplate(
                    className: this._cClassName.text,
                    outputPath: this._cOutputPath.text,
                    title: this._cTitle.text,
                    accessibility: this._accessibility,
                    makeup: this._makeup,
                    accessibilityOptions: this._accessibilityOptions,
                    flags: this._flags,
                    context: context,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: const Text("GENERATE"),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
