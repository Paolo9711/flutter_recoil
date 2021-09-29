import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart' as provider;

export 'package:provider/provider.dart';

typedef RecoilState<T> = T Function(RecoilOptions recoilOptions);
typedef SelectorOptions<T> = T Function(RecoilState recoilState);
typedef SetAtomData = void Function(RecoilState recoilState);

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
      create: (context) => StateStore(),
      child: child,
      lazy: lazy,
      builder: builder,
      dispose: (context, value) => dispose,
    );
  }
}

class RecoilOptions<T> {
  String key;
  T? defaultValue;

  RecoilOptions({required this.key, this.defaultValue});
}

class Atom<T> extends RecoilOptions<T> {
  Atom({
    key,
    defaultValue,
  }) : super(key: key, defaultValue: defaultValue);
}

class Selector<T> extends RecoilOptions<T> {
  SelectorOptions<T> selectorOptions;

  Selector(
    key,
    this.selectorOptions,
  ) : super(key: key);
}

class _EvaluatorResult<T> {
  T evaluatorResult;
  List<String> dependencies;

  _EvaluatorResult(this.evaluatorResult, this.dependencies);
}

class StateStore {
  Map<String, dynamic> states = {};

  StateStore();

  factory StateStore.of(BuildContext context) => provider.Provider.of<StateStore>(context);

  dynamic getModelValue(RecoilOptions stateDescriptor) {
    if (states.containsKey(stateDescriptor.key)) {
      return states[stateDescriptor.key];
    }

    final modelValue = stateDescriptor.defaultValue;
    states[stateDescriptor.key] = modelValue;

    return modelValue;
  }

  dynamic _evaluateStateValue(
    RecoilOptions recoilOptions,
    RecoilState recoilState,
  ) =>
      recoilOptions is Selector
          ? recoilOptions.selectorOptions(recoilState)
          : getModelValue(recoilOptions);

  _EvaluatorResult evaluateResult(RecoilOptions stateDescriptor) {
    final dependencies = <String>[];

    getStateValue(stateDescriptor) {
      final value = _evaluateStateValue(stateDescriptor, getStateValue);
      if (stateDescriptor is Atom) {
        dependencies.add(stateDescriptor.key);
      }

      return value;
    }

    return _EvaluatorResult(getStateValue(stateDescriptor), dependencies);
  }
}

T userRecoilState<T>(RecoilOptions recoilOptions) {
  final stateStore = StateStore.of(useContext());

  final enter = useState(<String>[]);
  final leave = useState(<String>[]);
  final dependencies = useState(<String>[]);
  ValueNotifier? stateValue;

  final reeval = useMemoized(
    () => () {
      final result = stateStore.evaluateResult(recoilOptions);
      stateValue!.value = result.evaluatorResult;

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

  final result = useMemoized(() {
    final result = stateStore.evaluateResult(recoilOptions);
    result.dependencies.map((name) => stateStore.states[name]).forEach((element) {
      element.addListener(reeval);
    });
    dependencies.value = result.dependencies;
    return result;
  });

  stateValue = useState(result.evaluatorResult);

  return stateValue.value;
}

VoidCallback setAtomData(SetAtomData setData) {
  final stateStore = StateStore.of(useContext());

  getEvaluatedResult(RecoilOptions stateDescriptor) {
    return stateStore.evaluateResult(stateDescriptor).evaluatorResult;
  }

  return () => setData(getEvaluatedResult);
}
