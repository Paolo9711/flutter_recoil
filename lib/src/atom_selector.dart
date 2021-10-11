import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_recoil/src/recoil_state_store.dart';
import 'package:flutter_recoil/src/types.dart';

class Atom<T> extends AtomOptions<T> {
  /// Add custom actions to [Atom]
  ///
  /// `T` value represents `onItemSet` and it's called every time [Atom] value change
  ///
  /// `ValueNotifier<T>` represents `setItemData` useful to change value of current [Atom]
  AtomEffect<T> effects;

  /// Creates an [Atom], which represents a piece of writeable state
  ///
  /// Define a unique `key` in order to identify the relative atom
  ///
  /// Use `defaultValue` in order to set the initial value of the Atom
  Atom({
    required String key,
    required T defaultValue,
    this.effects,
  }) : super(key: key, defaultValue: defaultValue);

  /// Change the stored value of the current atom
  VoidCallback setData(GetAtomValue<T> buildValue) {
    final stateStore = RecoilStateStore.of(useContext());

    final currentResult = stateStore.evaluateResult(this).evaluatorResult;

    final setData = buildValue(currentResult);

    if (effects != null) {
      effects!(currentResult.value, currentResult);
    }

    return () => setData;
  }
}

class Selector<T> extends AtomOptions<T> {
  /// Get the current value of an [Atom]
  GetRecoilValue getValue;

  /// Creates a [Selector], which represents a piece of readable state
  ///
  /// Use `getValue` in order to get the value of a created [Atom]
  Selector({
    required String key,
    required this.getValue,
  }) : super(key: key);
}

class AtomOptions<T> {
  String key;
  T? defaultValue;

  ValueNotifier<T?> get defaultValueNotifier => ValueNotifier<T?>(defaultValue);

  AtomOptions({required this.key, this.defaultValue});
}
