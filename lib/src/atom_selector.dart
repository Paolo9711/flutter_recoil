import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../flutter_recoil.dart';

class AtomOptions<T> {
  String key;
  T? defaultValue;

  ValueNotifier<T?> get defaultValueNotifier => ValueNotifier<T?>(defaultValue);

  AtomOptions({required this.key, this.defaultValue});
}

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

class Selector<T> extends AtomOptions<T> {
  GetRecoilValue getValue;

  Selector({
    required String key,
    required this.getValue,
  }) : super(key: key);
}
