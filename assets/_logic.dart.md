
```dart
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// This file is not open source. See license file.
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

part of '___SCREEN_FILE_NAME___';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class _Logic extends _LogicBroker<___CLASS_NAME___, _State> {
  //
  // hello
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
```