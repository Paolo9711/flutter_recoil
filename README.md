<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

A Flutter package that helps implement the Recoil pattern from React.  
For more information about Recoil visit the official web site of [RecoilJS](https://recoiljs.org).

## Features

- Implement `Atom` and `Selector` classes
- Manage Recoil State using `useRecoilSelectorStat` or `useRecoilAtomState`

## Getting started

See `example/lib/main.dart` for full example usage

## Usage

Use `Atom` and `Selector` to manage Recoil states.

```dart
final checkBoxAtom = Atom<List<CheckBoxModel>>(
  key: 'check_box',
  defaultValue: initialCheckBox,
);

final checkBoxSelector = Selector<List<String>>(
  key: 'check_box_selector',
  getValue: (getValue) {
    final currentCheckBox = getValue(checkBoxAtom);

    return (currentCheckBox.value as List<CheckBoxModel>)
        .where((e) => e.value)
        .map((e) => e.id.toString())
        .toList();
  },
);
```
