import 'package:flutter/foundation.dart';
import 'package:flutter_recoil/src/types.dart';

class Atom<T> extends RecoilOptions<T> {
  /// Add custom actions to [Atom]
  ///
  /// `T` value represents `onItemSet` and it's called every time [Atom] value change
  ///
  /// `ValueNotifier<T>` represents `setItemData` useful to change value of current [Atom]
  List<AtomEffect<T>>? effects;

  T defaultValue;

  /// Creates an [Atom], which represents a piece of writeable state
  ///
  /// Define a unique `key` in order to identify the relative atom
  ///
  /// Use `defaultValue` in order to set the initial value of the Atom
  Atom({
    required String key,
    required this.defaultValue,
    this.effects,
  }) : super(key: key);

  @protected
  ValueNotifier<T> get defaultValueNotifier => ValueNotifier<T>(defaultValue);
}

class Selector<T> extends RecoilOptions<T> {
  /// Get the current value of an [Atom].
  ///
  /// `getValue` returns a dynamic, so be sure to cast with the return type of the atom you're reading from.
  GetRecoilValue<T, dynamic> getValue;

  /// Creates a [Selector], which represents a piece of readable state
  ///
  /// Use `getValue` in order to get the value of a created [Atom]
  Selector({
    required String key,
    required this.getValue,
  }) : super(key: key);
}

class RecoilOptions<T> {
  String key;

  RecoilOptions({required this.key});
}
