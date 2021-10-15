part of '../flutter_recoil.dart';

class Atom<T> extends RecoilOptions<T> {
  List<AtomEffect<T>>? effects;
  T defaultValue;

  /// Creates an [Atom], which represents a piece of writeable state
  ///
  /// * Define a unique `key` in order to identify the relative atom
  /// * Use `defaultValue` in order to set the initial value of the Atom
  /// * Use `effects` in order to add custom actions to [Atom]
  ///   1. `T` value represents `onItemSet` and it's called every time [Atom] value change
  ///   2. `ValueNotifier<T>` represents `setItemData` useful to change value of current [Atom]
  ///
  /// It's possibile to create an array of effects to give different actions to [Atom]:
  /// ```dart
  /// final fooAtom = Atom(
  ///   key: 'foo_atom_key',
  ///   defaultValue: initialValue,
  ///   effects: [
  ///     (onItemSet, setItemData) {
  ///       // First Effect
  ///     },
  ///     (onItemSet, setItemData) {
  ///       // Second Effect
  ///     },
  ///   ],
  /// );
  /// ```
  ///
  /// See also:
  ///  * [Selector]
  Atom({
    required String key,
    required this.defaultValue,
    this.effects,
  }) : super(key: key);

  @protected
  ValueNotifier<T> get defaultValueNotifier => ValueNotifier<T>(defaultValue);
}

class Selector<T> extends RecoilOptions<T> {
  GetRecoilValue<T, dynamic> getValue;

  /// Creates a [Selector], which represents a piece of readable state
  ///
  /// * Define a unique `key` in order to identify the relative atom
  /// * Use `getValue` in order to get a readable value of a created [Atom].
  ///   The return type of `getValue` is a dynamic, so be sure to cast with the return type of the [Atom] you're reading from.
  ///   That's because in a [Selector] it's possible to get the value of different [Atom]
  ///
  /// ```dart
  /// final fooSelector = Selector(
  ///   key: 'foo_selector_key',
  ///   getValue: (getValue) {
  ///     final value = getValue(fooAtom) as YourAtomType;
  ///     // Manipulate your value
  ///     return manipulatedValue;
  ///   },
  /// );
  /// ```
  Selector({
    required String key,
    required this.getValue,
  }) : super(key: key);
}

class RecoilOptions<T> {
  String key;

  RecoilOptions({required this.key});
}
