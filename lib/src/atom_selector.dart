import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../flutter_recoil.dart';

class AtomOptions<T> {
  String key;
  T? defaultValue;

  ValueNotifier<T?> get defaultValueNotifier => ValueNotifier<T?>(defaultValue);

  AtomOptions({required this.key, this.defaultValue});
}

/// Creates an [Atom], which represents a piece of writeable state
///
/// Define a unique `key` in order to identify the relative atom
///
/// Use `defaultValue` in order to set the initial value of the Atom
class Atom<T> extends AtomOptions<T> {
  Atom({
    required String key,
    required T defaultValue,
  }) : super(key: key, defaultValue: defaultValue);

  VoidCallback setData(GetAtomValue<T> buildValue) {
    final stateStore = RecoilStateStore.of(useContext());

    return () => buildValue(stateStore.evaluateResult(this).evaluatorResult);
  }
}

/// Creates a [Selector], which represents a piece of readable state
///
/// Use `getValue` in order to get the value of a created atom
class Selector<T> extends AtomOptions<T> {
  GetRecoilValue getValue;

  Selector({
    required String key,
    required this.getValue,
  }) : super(key: key);
}
