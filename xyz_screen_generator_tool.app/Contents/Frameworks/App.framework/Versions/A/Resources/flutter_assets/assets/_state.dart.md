```dart
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// This file is not open source. See license file.
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

part of '___SCREEN_FILE_NAME___';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class _State extends MyScreenState<___CLASS_NAME___, ___CLASS_NAME___Configuration, _Logic> {
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
      divider: SizedBox(height: $20),
      children: [
        // Consumer(
        //   builder: (_, final ref, __) {
        //     final value = ref.watch(this.logic.pCounter);
        //     return Text("Count: $value", style: G.theme.textStyles.p1);
        //   },
        // ),
        this.logic.pCounter.build((final value) {
          return Text("Count: $value", style: G.theme.textStyles.p1);
        }),
        MyButton(
          text: "INCREMENT COUNTER",
          onPressed: this.logic.incrementCounter,
        ),
      ],
    );
  }
}
```