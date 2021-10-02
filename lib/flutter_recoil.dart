import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart' as provider;

export 'package:flutter_hooks/flutter_hooks.dart';

typedef RecoilState<T> = T Function(AtomOptions<T> recoilOptions);
typedef SelectorOptions<T> = T Function(RecoilState<T> recoilState);
typedef GetAtomValue<T> = void Function(RecoilState<T> recoilState);

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
  Atom({
    required String key,
    required T defaultValue,
  }) : super(key: key, defaultValue: defaultValue);

  VoidCallback setData(Function(ValueNotifier<T?>) value) {
    final stateStore = StateStore.of(useContext());

    return () => value(stateStore.evaluateResult(this).evaluatorResult);
  }
}

class Selector<T> extends AtomOptions<T> {
  SelectorOptions getValue;

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

  getModelValue(AtomOptions stateDescriptor) {
    if (states.containsKey(stateDescriptor.key)) {
      return states[stateDescriptor.key];
    }

    final modelValue = stateDescriptor.defaultValueNotifier;
    states[stateDescriptor.key] = modelValue;

    return modelValue;
  }

  _EvaluatorResult<T> evaluateResult(AtomOptions<T> recoilOptions) {
    final dependencies = <String>[];

    if (recoilOptions is Selector<T>) {
      return _EvaluatorResult<T>(
        recoilOptions.getValue((state) => getModelValue(state)),
        dependencies,
      );
    }

    dependencies.add(recoilOptions.key);
    return _EvaluatorResult<T>(getModelValue(recoilOptions), dependencies);
  }
}

ValueNotifier<T> userRecoilState<T>(AtomOptions<T> recoilOptions) {
  final stateStore = StateStore.of(useContext());

  final enter = useState(<String>[]);
  final leave = useState(<String>[]);
  final dependencies = useState(<String>[]);
  late ValueNotifier<T> stateValue;

  final reeval = useMemoized(
    () => () {
      final result = stateStore.evaluateResult(recoilOptions);
      stateValue.value = result.evaluatorResult.value;

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
    final result = stateStore.evaluateResult(recoilOptions);

    result.dependencies.map((name) => stateStore.states[name]).forEach((element) {
      element.addListener(reeval);
    });
    dependencies.value = result.dependencies;
    return result.evaluatorResult.value;
  });

  stateValue = useState<T>(result);

  return stateValue;
}
