// ------------------------------------------------------------

// ------------------------------------------------------------

// flutter run -d macos --target-platform=macos-arm64

// ------------------------------------------------------------

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

const BUILD_RUNNER_COMMAND =
    "flutter packages pub run build_runner build -d --enable-experiment=records";

// ------------------------------------------------------------

void main() {
  runApp(MyApp());
}

// ------------------------------------------------------------

class MyApp extends StatelessWidget {
  @override
  Widget build(_) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Screen()),
    );
  }
}

// ------------------------------------------------------------

class Screen extends StatefulWidget {
  @override
  _State createState() => _State();
}

// ------------------------------------------------------------

class _State extends State<Screen> {
  //
  //
  //

  final _cClassName = TextEditingController(text: "");
  final _cOutputName = TextEditingController(text: "");
  final _cTitle = TextEditingController(text: "");
  final _cApplicationPath = TextEditingController(text: "");
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

  final _makeupOptions = <String>[
    "Default",
    "Overlay",
    "Clear",
  ];

  late var _accessibility = _accessibilityOptions[0];
  var _makeup = "Default";

  //
  //
  //

  @override
  void initState() {
    this._cClassName
      ..addListener(() {
        this._cOutputName.text = camelToSnakeCase(this._cClassName.text);
      });
    getApplicationDocumentsDirectory().then(
      (value) => this.setState(() {
        _cApplicationPath.text = value.path;
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
  Widget build(_) {
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
                    child: TextField(
                      controller: this._cApplicationPath,
                      readOnly: true,
                    ),
                  ),
                  MyTitle(
                    title: "Output Path",
                    subtitle:
                        "Where with respect to the Application Path to save the generated files",
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
                onPressed: this._generateTemplate,
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

  //
  //
  //

  Future<void> _generateTemplate() async {
    var className = this._cClassName.text;
    className = className.isNotEmpty ? className : "ScreenPleaseRenameMe${Random().nextInt(10000)}";
    final outputName = camelToSnakeCase(className);
    final applicationPath = this._cApplicationPath.text;
    var outputPath = _cOutputPath.text;
    outputPath = outputPath.isEmpty ? "" : "/$outputPath";
    final outputFolderPath = "$applicationPath$outputPath/$outputName";
    final outputFolder = Directory(outputFolderPath);
    await outputFolder.create(recursive: true);
    final logicFile = File("$outputFolderPath/_logic.dart");
    final stateFile = File("$outputFolderPath/_state.dart");
    final screenFile = File("$outputFolderPath/$outputName.dart");
    final generatedFile = File("$outputFolderPath/$outputName.g.dart");
    await logicFile.writeAsString(
      createLogicFileBody(
        outputName: outputName,
        className: className,
      ),
    );
    await stateFile.writeAsString(
      createStateFileBody(
        outputName: outputName,
        className: className,
      ),
    );
    await screenFile.writeAsString(
      createScreenFileBody(
        outputName: outputName,
        className: className,
        accessibility: this._accessibility,
        makeup: this._makeup,
        title: this._cTitle.text,
        accessibilityOptions: this._accessibilityOptions,
        flagOptions: this._flags.values.toList(),
      ),
    );
    await generatedFile.writeAsString("// Please run: $BUILD_RUNNER_COMMAND");

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
              const SizedBox(height: 16.0),
              ElevatedButton(
                style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.grey)),
                child: Text("COPY"),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: outputFolderPath));
                },
              ),
              const SizedBox(height: 32.0),
              Text(
                "Please run the following command to generate the files:",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12.0),
              TextField(
                controller: TextEditingController(text: BUILD_RUNNER_COMMAND),
                readOnly: true,
              ),
              const SizedBox(height: 16.0),
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
  }
}

// ------------------------------------------------------------

String camelToSnakeCase(String input) {
  return input
      .replaceAllMapped(
        RegExp(r'([a-z])([A-Z0-9])'),
        (Match match) => '${match.group(1)}_${match.group(2)}',
      )
      .replaceAll(RegExp(r'_+'), '_')
      .toLowerCase();
}

// ------------------------------------------------------------

class MyTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  const MyTitle({
    Key? key,
    required this.title,
    this.subtitle,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(_) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          this.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8.0),
          Text(
            this.subtitle!,
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: 12.0),
        this.child,
      ],
    );
  }
}

// ------------------------------------------------------------

String createLogicFileBody({
  required String outputName,
  required String className,
}) {
  return """
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// This file is not open source. See license file.
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

part of '$outputName.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class _Logic extends _LogicBroker<$className, _State> {
  //
  //
  //

  _Logic(super.screen, super.state);

  //
  //
  //

  final _pCounter = Pod<int>(-1);

  //
  //
  //

  void incrementCounter() {
    this._pCounter.update((final value) => value + 1);
  }

  //
  //
  //

  @override
  Future<void> initLogic() async {
    this._pCounter.set(0);
    await super.initLogic();
  }

  //
  //
  //

  @override
  void dispose() async {
    this._pCounter.dispose();
    await super.dispose();
  }
}

""";
}

// ------------------------------------------------------------

String createStateFileBody({
  required String outputName,
  required String className,
}) {
  return """
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// This file is not open source. See license file.
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

part of '$outputName.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class _State extends MyScreenState<$className, ${className}Configuration, _Logic> {
  //
  //
  //

  @override
  Widget layout(Widget body) {
    return super.layout(
      SizedBox.expand(
        child: MyScrollable(
          makeup: G.theme.scrollableDefault(),
          child: body,
        ),
      ),
    );
  }

  //
  //
  //

  @override
  Widget body(final context) {
    return MyColumn(
      divider: SizedBox(height: \$20),
      children: [
        // Consumer(
        //   builder: (_, final ref, __) {
        //     final value = ref.watch(this.logic.pCounter);
        //     return Text("Count: \$value", style: G.theme.textStyles.p1);
        //   },
        // ),
        this.logic.pCounter.build((final value) {
          return Text("Count: \$value", style: G.theme.textStyles.p1);
        }),
        MyButton(
          text: "INCREMENT COUNTER",
          onPressed: this.logic.incrementCounter,
        ),
      ],
    );
  }
}

""";
}

// ------------------------------------------------------------

String createScreenFileBody({
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

  return """
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// This file is not open source. See license file.
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

import 'package:flutter/material.dart';

import '/all.dart';

part '$outputName.g.dart';
part '_state.dart';
part '_logic.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

@GenerateScreenAccess(${() {
    if (isOnlyAccessibleIfSignedIn) return "\n  isOnlyAccessibleIfSignedIn: true,\n";
    if (isOnlyAccessibleIfSignedInAndVerified)
      return "\n  isOnlyAccessibleIfSignedInAndVerified: true,\n";
    if (isOnlyAccessibleIfSignedOut) return "\n  sOnlyAccessibleIfSignedOut: true,\n";
    if (isAccessibilityAlways) return "";
  }()}${isRedirectable ? "" : "\n  isRedirectable: false,\n"})
class $className extends MyScreen {
  //
  //
  //

  $className(MyRouteConfiguration configuration)
      : super(
          configuration,${makeup != "Default" ? "\n          G.theme.myScreen$makeup()," : ""}${title.isNotEmpty ? '\n          title: "$title",\n' : ""}${bottomNavigationBar ? "" : "\n          bottomNavigationBar: null,"}
        );

  //
  //
  //

  @override
  _State createState() => _State();

  //
  //
  //

  @override
  _Logic createLogic(final screen, final state) => _Logic(screen, state);
}
""";
}
