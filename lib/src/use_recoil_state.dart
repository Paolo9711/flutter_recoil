import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_recoil/src/recoil_state_store.dart';
import '../flutter_recoil.dart';

class RecoilNotifier<T> {
  final RecoilStateStore _stateStore;
  final Atom<T> _atom;
  ValueNotifier<T> _valueNotifier;

  RecoilNotifier(this._valueNotifier, this._atom, this._stateStore);

  /// Get the current value of the [Atom]
  T get data => _valueNotifier.value;

  /// Change the stored value of the current [Atom]
  void setData(T value) {
    final currentResult = _stateStore.evaluateResult(_atom).evaluatorResult;
    currentResult.value = value;

    if (_atom.effects != null) {
      _atom.effects!.map((e) => e).forEach((effect) => effect(currentResult.value, currentResult));
    }
  }
}

/// Returns the value of an [Atom] and
/// subscribes the components to future updates of that state.
///
/// See also:
///  * [Atom]
///  * [RecoilNotifier]
RecoilNotifier<T> useRecoilState<T>(Atom<T> atom) {
  final stateStore = RecoilStateStore.of(useContext());

  final dependencies = useState(<String>[]);
  final stateValue = RecoilNotifier<T>(atom.defaultValueNotifier, atom, stateStore);

  final evaluateResult = useMemoized(
    () => () {
      final result = stateStore.evaluateResult(atom);
      stateValue._valueNotifier.value = result.evaluatorResult.value;

      dependencies.value = result.dependencies;
    },
    [dependencies],
  );

  final result = useMemoized<T>(() {
    final result = stateStore.evaluateResult(atom);

    result.dependencies.map((name) => stateStore.states[name]).forEach((element) {
      element.addListener(evaluateResult);
    });
    dependencies.value = result.dependencies;
    return result.evaluatorResult.value;
  }, [dependencies]);

  stateValue._valueNotifier = useState<T>(result);

  return stateValue;
}

/// Returns the value of [Selector] and
/// subscribes the components to future updates of that state.
///
/// See also:
///  * [Selector]
///  * [RecoilOptions]
T useRecoilSelectorState<T>(RecoilOptions<T> atomOptions) {
  final stateStore = RecoilStateStore.of(useContext());

  final dependencies = useState(<String>[]);
  late ValueNotifier<T> stateValue;

  final evaluateResult = useMemoized(
    () => () {
      final result = stateStore.evaluateResult(atomOptions);
      stateValue.value = result.evaluatorResult;

      dependencies.value = result.dependencies;
    },
    [dependencies],
  );

  final result = useMemoized<T>(() {
    final result = stateStore.evaluateResult(atomOptions);

    result.dependencies.map((name) => stateStore.states[name]).forEach((element) {
      element.addListener(evaluateResult);
    });
    dependencies.value = result.dependencies;
    return result.evaluatorResult;
  }, [dependencies]);

  stateValue = useState<T>(result);

  return stateValue.value;
}
