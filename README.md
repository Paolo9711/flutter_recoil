<img src="https://miro.medium.com/max/1400/1*kmm4E29iST5X569ItIEaKQ.png" width="250" >

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
  getValue: (getValue) => (getValue(checkBoxAtom).value as List<CheckBoxModel>)
      .where((e) => e.value)
      .map((e) => e.id.toString())
      .toList(),
);
```
