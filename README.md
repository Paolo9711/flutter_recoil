
<h1 align="center">
  ▶ Flutter Recoil ◀
</h1>

<p align="center">
  <img src="https://miro.medium.com/max/1400/1*kmm4E29iST5X569ItIEaKQ.png" width="300" alt="centered image" />
</p>

A Flutter package that helps implement the Recoil pattern from React.  
For more information about Recoil visit the official web site of [RecoilJS](https://recoiljs.org).

## Features

- Implement `Atom` and `Selector` classes
- Manage Recoil State using `useRecoilSelectorState` or `useRecoilState`
- Manage a list of `effects` for Atom

## Getting started
See `example/lib/recoil/atoms.dart` for an example on the creation of **Atom** and **Selector** and `example/lib/main.dart` for full example usage.

## Usage

First of all create `Atom` and `Selector` to manage Recoil states.

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

To listen for status changes of Atom and Selector, the respective methods `useRecoilState` and `useRecoilSelectorState` are provided.

```dart
 final checkBox = useRecoilState(checkBoxAtom);
 
 final checkBoxValue = useRecoilSelectorState(checkBoxSelector);
```

In order to use effects of `Atom`, `setItemData` and `onItemSet` are provided.

## Class and Widgets

### `RecoilWidget`
A _Widget_ that can use **Atom** and **Selector**. It's usage is very similar to _StatelessWidget_ and implements only a `build` method.
Widgets that uses _Atom_ and _Selector_ must necessarily extend a **RecoilWidget**

---

### `RecoilStateStore<T>`
Manage and evaluate values of **Atom** and **Selector**

---

### `RecoilProvider<T>`
Provide a Recoil Context using **RecoilStateStore**

It's important to wrap widget that need Recoil Context, using builder method of **RecoilProvider**:
```dart
@override
Widget build(BuildContext context) {
 return RecoilProvider(
   builder: (context, child) {
     return YourWidget(
     // Widget parameters
     );
   },
 );
}
```
---

### `Atom<T>`
Creates an Atom, which represents a piece of writeable state

* Define a unique `key` in order to identify the relative **Atom**
* Use `defaultValue` in order to set the initial value of the **Atom**
* Use `effects` in order to add custom actions to **Atom**
1. `T` value represents `onItemSet` and it's called every time **Atom** value change
2. `ValueNotifier<T>` represents `setItemData` useful to change value of current **Atom**

It's possibile to create an array of effects to give different actions to **Atom**:
```dart
final fooAtom = Atom(
  key: 'foo_atom_key',
  defaultValue: initialValue,
  effects: [
    (onItemSet, setItemData) {
      // First Effect
    },
    (onItemSet, setItemData) {
      // Second Effect
    },
  ],
);
```
---

### `Selector<T>`
Creates a **Selector**, which represents a piece of _readable state_.

* Define a unique `key` in order to identify the relative **Atom**
* Use `getValue` in order to get a readable value of a created **Atom**.
  The return type of `getValue` is a dynamic, so be sure to cast with the return type of the **Atom** you're reading from.
  That's because in a Selector it's possible to get the value of different **Atom**

```dart
final fooSelector = Selector(
  key: 'foo_selector_key',
  getValue: (getValue) {
    final value = getValue(fooAtom) as YourAtomType;
    // Manipulate your value
    return manipulatedValue;
  },
);
```
---

### `useRecoilState()`
Returns a custom **ValueNotifier** (see `RecoilNotifier<T>`) and subscribes the components to future updates of that state.

```dart
final value = useRecoilState(myAtom);
```
---

### `RecoilNotifier<T>`
It's the return type of `useRecoilState()` which provides parameters for reading and manipulating the state of an **Atom**.
* `data` can be used in order to get the value of the **Atom**
* `setData` can be used to change the value of the **Atom**
---

### `useRecoilSelectorState()`
Returns the value of **Selector** and subscribes the components to future updates of related **Atom** state.

```dart
final value = useRecoilSelectorState(mySelector);
```
---

## License
[MIT](LICENSE)
