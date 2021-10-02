import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart' as provider;

export 'package:flutter_hooks/flutter_hooks.dart';

typedef RecoilState<T> = T Function(AtomOptions<T> atomOptions);
typedef GetRecoilValue<T> = T Function(RecoilState<T> recoilState);
typedef AtomState<T> = Function(ValueNotifier<T?> atomValue);

abstract class RecoilWidget extends HookWidget {
  const RecoilWidget({Key? key}) : super(key: key);
}

class RecoilProvider<T> extends StatelessWidget {
  final Widget? child;
  final provider.Dispose<T>? dispose;
  final bool? lazy;
  final TransitionBuilder? builder;

  const RecoilProvider({
    Key? key,
    this.child,
    this.dispose,
    this.lazy,
    this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return provider.Provider(
      key: key,
      create: (context) => StateStore<T>(),
      child: child,
      lazy: lazy,
      builder: builder,
      dispose: (context, value) => dispose,
    );
  }
}

class AtomOptions<T> {
  String key;
  T? defaultValue;

  ValueNotifier<T?> get defaultValueNotifier => ValueNotifier<T?>(defaultValue);

  AtomOptions({required this.key, this.defaultValue});
}

class Atom<T> extends AtomOptions<T> {
  Function(
    ValueNotifier<T?> setSelf,
    // Function(ValueNotifier<T> oldValue, ValueNotifier<T> newValue) onSet,
  )? effects;

  Atom({
    required String key,
    required T defaultValue,
    this.effects,
  }) : super(key: key, defaultValue: defaultValue);

  VoidCallback setData(AtomState<T> buildValue) {
    final stateStore = StateStore.of(useContext());

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

class _EvaluatorResult<T> {
  T evaluatorResult;
  List<String> dependencies;

  _EvaluatorResult(this.evaluatorResult, this.dependencies);
}

class StateStore<T> {
  Map<String, dynamic> states = {};

  StateStore();

  factory StateStore.of(BuildContext context) => provider.Provider.of<StateStore<T>>(context);

  T getModelValue(AtomOptions atomOptions) {
    if (states.containsKey(atomOptions.key)) {
      return states[atomOptions.key];
    }

    final modelValue = atomOptions.defaultValueNotifier;
    states[atomOptions.key] = modelValue;

    return modelValue.value;
  }

  _EvaluatorResult<T> evaluateResult(AtomOptions<T> atomOptions) {
    final dependencies = <String>[];

    if (atomOptions is Selector<T>) {
      return _EvaluatorResult<T>(
        atomOptions.getValue((state) => getModelValue(state)),
        dependencies,
      );
    }

    dependencies.add(atomOptions.key);
    return _EvaluatorResult<T>(getModelValue(atomOptions), dependencies);
  }
}

void manageAtomEffects<T>(AtomOptions<T> atomOptions) {
  final atom = atomOptions as Atom<T>;
  if (atom.effects == null) return;

  final stateStore = StateStore.of(useContext());

  atom.effects!(
    stateStore.evaluateResult(atom).evaluatorResult,
  );
}

T userRecoilState<T>(AtomOptions<T> atomOptions) {
  final stateStore = StateStore.of(useContext());

  final enter = useState(<String>[]);
  final leave = useState(<String>[]);
  final dependencies = useState(<String>[]);
  late ValueNotifier<T> stateValue;

  final reeval = useMemoized(
    () => () {
      final result = stateStore.evaluateResult(atomOptions);
      stateValue.value = result.evaluatorResult;

      enter.value =
          result.dependencies.where((element) => !dependencies.value.contains(element)).toList();
      leave.value =
          dependencies.value.where((element) => !result.dependencies.contains(element)).toList();

      dependencies.value = result.dependencies;
    },
  );

  useEffect(() {
    enter.value.map((name) => stateStore.states[name]).forEach((element) {
      if (element is Listenable) element.addListener(reeval);
    });

    leave.value.map((name) => stateStore.states[name]).forEach((element) {
      if (element is Listenable) element.removeListener(reeval);
    });

    return () {
      dependencies.value.map((name) => stateStore.states[name]).forEach((element) {
        if (element is Listenable) element.removeListener(reeval);
      });
    };
  }, [enter, leave]);

  final result = useMemoized<T>(() {
    final result = stateStore.evaluateResult(atomOptions);

    result.dependencies.map((name) => stateStore.states[name]).forEach((element) {
      element.addListener(reeval);
    });
    dependencies.value = result.dependencies;
    return result.evaluatorResult;
  });

  stateValue = useState<T>(result);

  if (atomOptions is Atom<T>) manageAtomEffects<T>(atomOptions);

  return stateValue.value;
}
