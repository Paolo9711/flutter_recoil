import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart' as provider;

export 'package:provider/provider.dart';

typedef GetStateValue<T> = T Function(StateDescriptor stateDescriptor);
typedef SelectorEvaluator<T> = T Function(GetStateValue get);
typedef Action = void Function(GetStateValue get);

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

class StateDescriptor<T> {
  String name;
  T? initialValue;

  StateDescriptor(this.name, {this.initialValue});
}

class Atom<T> extends StateDescriptor<T> {
  Atom(
    name,
    initialValue,
  ) : super(
          name,
          initialValue: initialValue,
        );
}

class Selector<T> extends StateDescriptor<T> {
  SelectorEvaluator<T> selectorEvaluator;

  Selector(
    String name,
    this.selectorEvaluator,
  ) : super(name);
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

  dynamic getModelValue(StateDescriptor stateDescriptor) {
    if (states.containsKey(stateDescriptor.name)) {
      return states[stateDescriptor.name];
    }

    final modelValue = stateDescriptor.initialValue;
    states[stateDescriptor.name] = modelValue;

    return modelValue;
  }

  dynamic _evaluateStateValue(
    StateDescriptor stateDescriptor,
    GetStateValue getStateValue,
  ) =>
      stateDescriptor is Selector
          ? stateDescriptor.selectorEvaluator(getStateValue)
          : getModelValue(stateDescriptor);

  _EvaluatorResult evaluateResult(StateDescriptor stateDescriptor) {
    final dependencies = <String>[];

    getStateValue(stateDescriptor) {
      final value = _evaluateStateValue(stateDescriptor, getStateValue);
      if (stateDescriptor is Atom) {
        dependencies.add(stateDescriptor.name);
      }

      return value;
    }

    return _EvaluatorResult(getStateValue(stateDescriptor), dependencies);
  }
}

T useModel<T>(StateDescriptor stateDescriptor) {
  final stateStore = StateStore.of(useContext());

  final enter = useState(<String>[]);
  final leave = useState(<String>[]);
  final dependencies = useState(<String>[]);
  ValueNotifier? stateValue;

  final reeval = useMemoized(
    () => () {
      final result = stateStore.evaluateResult(stateDescriptor);
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
    final result = stateStore.evaluateResult(stateDescriptor);
    result.dependencies.map((name) => stateStore.states[name]).forEach((element) {
      element.addListener(reeval);
    });
    dependencies.value = result.dependencies;
    return result;
  });

  stateValue = useState(result.evaluatorResult);

  return stateValue.value;
}

VoidCallback useAction(Action action) {
  final stateStore = StateStore.of(useContext());

  getEvaluatedResult(StateDescriptor stateDescriptor) {
    return stateStore.evaluateResult(stateDescriptor).evaluatorResult;
  }

  return () => action(getEvaluatedResult);
}
