import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../flutter_recoil.dart';

_useRecoilState<T>(AtomOptions<T> atomOptions) {
  final stateStore = RecoilStateStore.of(useContext());

  final dependencies = useState(<String>[]);
  late ValueNotifier<T> stateValue;

  final evaluateResult = useMemoized(
    () => () {
      final result = stateStore.evaluateResult(atomOptions);
      stateValue.value =
          atomOptions is Selector ? result.evaluatorResult : result.evaluatorResult.value;

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
    return atomOptions is Selector ? result.evaluatorResult : result.evaluatorResult.value;
  }, [dependencies]);

  stateValue = useState<T>(result);

  return atomOptions is Selector ? stateValue.value : stateValue;
}

ValueNotifier<T> useRecoilAtomState<T>(AtomOptions<T> atomOptions) => _useRecoilState(atomOptions);

T useRecoilSelectorState<T>(AtomOptions<T> atomOptions) => _useRecoilState(atomOptions);
