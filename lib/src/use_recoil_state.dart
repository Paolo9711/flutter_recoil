part of '../flutter_recoil.dart';

class RecoilNotifier<T> {
  final RecoilStateStore _stateStore;
  final Atom<T> _atom;
  ValueNotifier<T> _valueNotifier;

  /// Custom Recoil Notifier which provides parameters for reading and manipulating the state of an [Atom]
  ///
  /// * `data` can be used in order to get the value of the [Atom]
  /// * `setData` can be used to change the value of the [Atom]
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

/// Returns a custom [ValueNotifier] of an [Atom] and
/// subscribes the components to future updates of that state.
///
/// The return type of `useRecoilState()` it's [RecoilNotifier] which provides parameters for reading and manipulating the state of an [Atom].
/// * `data` can be used in order to get the value of the [Atom]
/// * `setData` can be used to change the value of the [Atom]
///
/// See also:
///  * [Atom]
///  * [RecoilNotifier]
RecoilNotifier<T> useRecoilState<T>(Atom<T> atom) => _useRecoilState(atom);

/// Returns the value of [Selector] and
/// subscribes the components to future updates of related [Atom] state.
///
/// See also:
///  * [Selector]
///  * [RecoilOptions]
T useRecoilSelectorState<T>(Selector<T> selector) => _useRecoilState(selector);

dynamic _useRecoilState<T>(RecoilOptions<T> recoilOptions) {
  final stateStore = RecoilStateStore.of(useContext());

  final enter = useState(<String>[]);
  final leave = useState(<String>[]);
  final dependencies = useState(<String>[]);

  dynamic stateValue = recoilOptions is Atom<T>
      ? RecoilNotifier<T>(recoilOptions.defaultValueNotifier, recoilOptions, stateStore)
      : ValueNotifier<T>(stateStore.evaluateResult(recoilOptions).evaluatorResult);

  final evaluateResult = useMemoized(
    () => () {
      final result = stateStore.evaluateResult(recoilOptions);

      recoilOptions is Atom<T>
          ? (stateValue as RecoilNotifier<T>)._valueNotifier.value = result.evaluatorResult.value
          : (stateValue as ValueNotifier<T>).value = result.evaluatorResult;

      enter.value =
          result.dependencies.where((element) => !dependencies.value.contains(element)).toList();
      leave.value =
          dependencies.value.where((element) => !result.dependencies.contains(element)).toList();

      dependencies.value = result.dependencies;
    },
  );

  useEffect(() {
    enter.value.map((name) => stateStore.states[name]).forEach((element) {
      if (element is Listenable) element.addListener(evaluateResult);
    });
    leave.value.map((name) => stateStore.states[name]).forEach((element) {
      if (element is Listenable) element.removeListener(evaluateResult);
    });
    return () {
      dependencies.value.map((name) => stateStore.states[name]).forEach((element) {
        if (element is Listenable) element.removeListener(evaluateResult);
      });
    };
  }, [enter, leave]);

  final result = useMemoized<T>(
    () {
      final result = stateStore.evaluateResult(recoilOptions);

      result.dependencies.map((name) => stateStore.states[name]).forEach((element) {
        element.addListener(evaluateResult);
      });
      dependencies.value = result.dependencies;
      return recoilOptions is Selector<T> ? result.evaluatorResult : result.evaluatorResult.value;
    },
  );

  recoilOptions is Atom<T>
      ? (stateValue as RecoilNotifier<T>)._valueNotifier = useState<T>(result)
      : stateValue = useState<T>(result);

  return recoilOptions is Selector<T> ? stateValue.value : stateValue;
}
